module taxforms.framework.standardquestions;

import scriptlike.std;
import scriptlike.interact;

private auto marriageFiling = ["Single", "Married Filing Separate", "Married Filing Jointly", "Head of House"];

enum MarriageFiling {
    unanswered,
    single,
    separate,
    jointly,
    headofhouse
}

private MarriageFiling mfAnswer;

MarriageFiling askMarriageFiling() {
    if(mfAnswer == MarriageFiling.unanswered)
        mfAnswer = cast(MarriageFiling) menu!int("Are you: ", marriageFiling);

    return mfAnswer;
}
