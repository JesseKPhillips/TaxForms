/**
 * Provides the sequence of events for the USA 2014 Qualified Dividend and Capital Gain Tax Worksheet.
 *
 * This is license under Boost 1.0:
 * http://www.boost.org/LICENSE_1_0.txt
 *
 * Do not rely on this software being correct, do yourself a favor and
 * review the the logic.
 */
module taxforms.usa.dividendworksheet;

import scriptlike.std;
import scriptlike.interact;

import taxforms.framework;

static this() {
    initDocument!fillSheet(
      "Qualified Dividend and Capital Gain Tax Worksheet",
      Year(2015),
      Reviewers(0));
}

auto form1040 = form!"Form 1040 U.S. Individual Income Tax Return";
auto schD     = form!"SCHEDULE D Capital Gains and Losses";
auto form4952 = form!"Form 4952 Investment Interest Expense Deduction";
auto foreignIncome = form!"Foreign Earned Income Tax Worksheet";

auto worksheet = DocumentEntries(27);

DocumentEntries fillSheet() {
    if(userInput!bool("Are you filing Form 2555 or 2555-EZ?"))
        worksheet[Line(1)] = foreignIncome[Line(3)];
    else
        worksheet[Line(1)] = form1040[Line(43)];

    worksheet[Line(2)] = form1040[Line(9,'b')];

    if(userInput!bool("Are you filing Schedule D?"))
        worksheet[Line(3)] = [schD[Line(15)], schD[Line(16)]]
            .reduce!min.noLessThanZero;
    else
        worksheet[Line(3)] = form1040[Line(13)];

    worksheet[Line(4)] = worksheet[Line(2)] + worksheet[Line(3)];

    if(userInput!bool("Are you filing Form 4952 (used to figure investment interest expense deduction)?"))
        worksheet[Line(5)] = form4952[Line(4,'g')];
    else worksheet[Line(5)] = 0;

    worksheet[Line(6)]
        = (worksheet[Line(4)] - worksheet[Line(5)]).noLessThanZero;
    worksheet[Line(7)]
        = (worksheet[Line(1)] - worksheet[Line(6)]).noLessThanZero;

    auto statusSelection = askMarriageFiling();

    final switch(statusSelection) with(MarriageFiling) {
        case single:
            worksheet[Line(8)] = 37_450;
            break;
        case separate:
            worksheet[Line(8)] = 37_450;
            break;
        case jointly:
            worksheet[Line(8)] = 74_900;
            break;
        case headofhouse:
            worksheet[Line(8)] = 50_200;
            break;
        case unanswered:
            throw new Exception("Can't avoid answering this question.");
    }

    worksheet[Line(9)] = [worksheet[Line(1)], worksheet[Line(8)]].reduce!min;
    worksheet[Line(10)] = [worksheet[Line(7)], worksheet[Line(9)]].reduce!min;
    worksheet[Line(11)] = worksheet[Line(9)] - worksheet[Line(10)];
    worksheet[Line(12)] = [worksheet[Line(1)], worksheet[Line(6)]].reduce!min;
    worksheet[Line(13)] = worksheet[Line(11)];
    worksheet[Line(14)] = worksheet[Line(12)] - worksheet[Line(13)];

    final switch(statusSelection) with(MarriageFiling) {
        case single:
            worksheet[Line(15)] = 413_200;
            break;
        case separate:
            worksheet[Line(15)] = 232_425;
            break;
        case jointly:
            worksheet[Line(15)] = 464_850;
            break;
        case headofhouse:
            worksheet[Line(15)] = 439_000;
            break;
        case unanswered:
            assert(false, "Already verified question was answered");
    }

    worksheet[Line(16)] = [worksheet[Line(1)], worksheet[Line(15)]].reduce!min;
    worksheet[Line(17)] = worksheet[Line(7)] + worksheet[Line(11)];
    worksheet[Line(18)] = worksheet[Line(16)] - worksheet[Line(17)].noLessThanZero;
    worksheet[Line(19)] = [worksheet[Line(14)], worksheet[Line(18)]].reduce!min;
    worksheet[Line(20)] = worksheet[Line(19)] * 0.15;
    worksheet[Line(21)] = worksheet[Line(11)] + worksheet[Line(19)];
    worksheet[Line(22)] = worksheet[Line(12)] - worksheet[Line(21)];
    worksheet[Line(23)] = worksheet[Line(22)] * 0.20;

    if(worksheet[Line(7)] < 100_000)
        worksheet[Line(24)] = userInput!int("24. Figure the tax on the amount of %s (Tax Table)".format(worksheet[Line(7)].formatNum));
    else
        worksheet[Line(24)] = userInput!int("24. Figure the tax on the amount of %s (Tax Computation Worksheet)".format(worksheet[Line(7)].formatNum));

    worksheet[Line(25)] = worksheet[Line(20)] + worksheet[Line(23)] + worksheet[Line(24)];

    if(worksheet[Line(1)] < 100_000)
        worksheet[Line(26)] = userInput!int("26. Figure the tax on the amount of %s (Tax Table)".format(worksheet[Line(1)].formatNum));
    else
        worksheet[Line(26)] = userInput!int("26. Figure the tax on the amount of %s (Tax Computation Worksheet)".format(worksheet[Line(1)].formatNum));

    worksheet[Line(27)] = [worksheet[Line(25)], worksheet[Line(26)]].reduce!min;

    return worksheet;
}

