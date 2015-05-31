module taxforms.framework.formregistration;

import scriptlike.std;
import scriptlike.interact;

import taxforms.framework.formdocument;

private Tuple!(SheetInfo,  DocumentEntries function())[string] sheet;
private DocumentData[string] documentData;

void initDocument(alias fill)(string formalName, Year taxYear, Reviewers humanEyes) {
    assert(formalName !in sheet, "Can't have two tax documents:\n"~formalName);
    sheet[formalName] = tuple(SheetInfo(formalName, humanEyes, taxYear), &fill);
}

auto registeredForms() {
    return sheet.byKey();
}


auto form(string formName)() {
    Sheet!formName s;
    return s;
}

DocumentData requestForm(string formName) {
    if(auto psheet = formName in sheet) {
        auto sheet = *psheet;

        auto data = DocumentData(sheet[0], sheet[1]());
        documentData[formName] =  data;
        return data;
    }

    return DocumentData(SheetInfo(formName, Reviewers(0), Year(1971)),
                        DocumentEntries(0));
}

auto display(DocumentData data) {
    writeln();
    writeln(data.info.sheetTaxYear, " ", data.info.formalName);
    writeln("Human Reviewers: ", data.info.humanReviewCount.value);
    writeln();

    foreach(lineNum, lineValue; data.entry[]) {
        if(lineValue.peek!(int[]))
            foreach(subi, subline; lineValue.get.get!(int[]))
                writeln("Line %3s".format(to!string(lineNum+1) ~ to!char(subi+'a')), ": ", lineValue.get.get!int.formatNum);
        else
            writeln("Line %3s".format(lineNum+1), ": ", lineValue.get.get!int.formatNum);
    }
}

struct Sheet(string formName) {
    int opIndex(Line num) {
        auto sheet = formName in documentData;

        if(!sheet) {
            import std.conv;
            auto lineNum = num.value.to!string;
            if(num.sub != char.init)
                lineNum ~= num.sub;
            return userInput!int("Enter the amount from\n%s\nline %s:"
                                 .format(formName, lineNum));
        }

        return sheet.entry[num];
    }
}
