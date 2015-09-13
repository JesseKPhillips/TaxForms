module taxforms.framework.formdocument;

struct Year {
    mixin intValue;
}

struct Reviewers {
    mixin intValue;
}

struct Line {
    int value;
    @disable this();

    char sub;

    this(int v) in { assert(v>=0); } body {
        value = v;
    }

    this(int v, char s)
    in {
        assert(v>=0);
        assert(s >= 'a');
        assert(s <= 'z');
    } body {
        value = v;
        sub = s;
    }
}

protected struct SheetInfo {
    string formalName;
    Reviewers humanReviewCount;
    Year sheetTaxYear;
}

struct DocumentData {
    SheetInfo info;
    DocumentEntries entry;

    this(SheetInfo si, DocumentEntries de) {
        info = si;
        entry = de;
    }
}

import std.variant : Algebraic;
alias LineType = Algebraic!(int, int[]);

struct DocumentEntries {
    import std.typecons : Nullable;
    private Nullable!LineType[] lineData;

    @disable this();

    this(int lineCount) {
        lineData = new Nullable!LineType[](lineCount);
    }

    int opIndex(Line i) {
        if(i.sub == char.init)
            return lineData[i.value-1].get.get!int;
        else
            return lineData[i.value-1][i.sub-'a'].get!int;
    }

    void opIndexAssign(int v, Line i) {
        this[i.value, i.sub] = v;
    }

    private void opIndexAssign(int v, int i, char sub) {
        auto value = lineData[i-1];
        if(sub == char.init) {
            lineData[i-1] = LineType(v);
            return;
        }

        auto subIndex = sub - 'a';

        if(value.isNull) {
            auto arr = new int[](subIndex + 1);
            arr[subIndex] = v;
            lineData[i-1] = LineType(arr);
            return;
        }

        auto nonNull = value.get.get!(int[]);
        if(nonNull.length < subIndex+1)
            nonNull.length = subIndex+1;
        nonNull[subIndex] = v;
        lineData[i-1] = LineType(nonNull);
    }

    void opIndexAssign(double v, Line i) {
        import std.math : round;
        import std.conv;
        this[i] = round(v).to!int;
    }

    Nullable!LineType[] opSlice() {
        return lineData[];
    }
}

auto noLessThanZero(int num) {
    if(num < 0)
        return 0;
    else
        return num;
}

string formatNum(int num) {
    import std.conv;
    auto snum = num.to!string;

    return snum;
}

mixin template intValue() {
    int value;
    @disable this();
    this(int v) in { assert(v>=0); } body {
        value = v;
    }
}
