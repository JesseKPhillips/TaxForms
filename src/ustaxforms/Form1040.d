/**
 * Provides the sequence of events for the USA 2014 Individual Income Tax
 * Return.
 *
 * This is license under Boost 1.0:
 * http://www.boost.org/LICENSE_1_0.txt
 *
 * Do not rely on this software being correct, do yourself a favor and
 * review the the logic.
 */
module taxforms.usa.form1040;

import scriptlike.std;
import scriptlike.interact;

import taxforms.framework;

static this() {
    initDocument!fillSheet(
      "Form 1040 U.S. Individual Income Tax Return",
      Year(2014),
      Reviewers(0));
}

auto dividendworksheet = form!"Qualified Dividend and Capital Gain Tax Worksheet";
auto w2       = form!"W2 Wage and Tax Statement";
auto schB     = form!"SCHEDULE B Interest and Ordinary Dividends";
auto schC     = form!"SCHEDULE C Profit or Loss From Business";
auto schD     = form!"SCHEDULE D Capital Gains and Losses";
auto schE     = form!"SCHEDULE E Supplemental Income and Loss";
auto schF     = form!"SCHEDULE F Profit or Loss From Farming";
auto form4797 = form!"Form 4797 Sales of Business Property";

auto worksheet = DocumentEntries(79);

DocumentEntries fillSheet() {
    auto statusSelection = askMarriageFiling();
    final switch(statusSelection) with(MarriageFiling) {
        case unanswered:
            worksheet[Line(1)] = 0;
            worksheet[Line(2)] = 0;
            worksheet[Line(3)] = 0;
            worksheet[Line(4)] = 0;
            break;
        case single:
            worksheet[Line(1)] = 1;
            worksheet[Line(2)] = 0;
            worksheet[Line(3)] = 0;
            worksheet[Line(4)] = 0;
            break;
        case separate:
            worksheet[Line(1)] = 0;
            worksheet[Line(2)] = 0;
            worksheet[Line(3)] = 1;
            worksheet[Line(4)] = 0;
            break;
        case jointly:
            worksheet[Line(1)] = 0;
            worksheet[Line(2)] = 1;
            worksheet[Line(3)] = 0;
            worksheet[Line(4)] = 0;
            break;
        case headofhouse:
            worksheet[Line(1)] = 0;
            worksheet[Line(2)] = 0;
            worksheet[Line(3)] = 0;
            worksheet[Line(4)] = 1;
            break;
    }
    if(userInput!bool("Are you a qualifying widow(er) with dependent child?")) {
        worksheet[Line(1)] = 0;
        worksheet[Line(2)] = 0;
        worksheet[Line(3)] = 0;
        worksheet[Line(4)] = 0;
        worksheet[Line(5)] = 1;
    } else
        worksheet[Line(5)] = 0;

    worksheet[Line(6)] = userInput!int("6: Calculate number of dependents");
    writeln("7: Wages, salaries, tips, etc");
    worksheet[Line(7)] = w2[Line(1)];
    writeln("8a: Taxable interest");
    worksheet[Line(8, 'a')] = schB[Line(4)];
    worksheet[Line(8, 'b')] = userInput!int("8b: Tax-exempt interest. Do not include on line 8a");
    writeln("9a: Ordinary dividends");
    worksheet[Line(9, 'a')] = schB[Line(6)];
    worksheet[Line(9, 'b')] = userInput!int("9b: Qualified dividends");
    worksheet[Line(10)] = userInput!int("10: Taxable refunds, credits, or offsets of state and local income taxes");
    worksheet[Line(11)] = userInput!int("11: Alimony received");
    writeln("12: Business income or (loss)");
    worksheet[Line(12)] = schC[Line(31)];
    writeln("13: Capital gain or (loss)");
    // TODO: SCHEDULE D provides several lines which answer this question
    worksheet[Line(13)] = schD[Line(16)];
    writeln("14: Other gains or (losses)");
    worksheet[Line(14)] = form4797[Line(18, 'b')];
    worksheet[Line(15, 'a')] = userInput!int("15a: IRA distribution");
    worksheet[Line(15, 'b')] = userInput!int("15b: IRA distribution Taxable ammount");
    worksheet[Line(16, 'a')] = userInput!int("16a: Pensions and annuities");
    worksheet[Line(16, 'b')] = userInput!int("16b: Pensions and annuities Taxable ammount");
    writeln("17: Rental real estate, royalties, partnerships, S corporations, trusts, etc");
    worksheet[Line(17)] = schE[Line(26)];
    worksheet[Line(18)] = userInput!int("18: Farm income or (loss)");
    worksheet[Line(19)] = userInput!int("19: Unemployment compensation");
    worksheet[Line(20, 'a')] = userInput!int("20a: Social security benefits");
    worksheet[Line(20, 'b')] = userInput!int("20b: Social security benefits Taxable ammount");
    worksheet[Line(21)] = userInput!int("21: Other income.");

    worksheet[Line(22)] = {
        auto w = worksheet;
        return [w[Line(7)], w[Line(8, 'a')], w[Line(9, 'a')], w[Line(10)],
            w[Line(11)], w[Line(12)], w[Line(13)], w[Line(14)],
            w[Line(15, 'b')], w[Line(16, 'b')], w[Line(17)], w[Line(18)],
            w[Line(19)], w[Line(20, 'b')], w[Line(21)]]
            .reduce!"a+b";
    }();

    return worksheet;
}
