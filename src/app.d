import std.experimental.logger;
import scriptlike;

import taxforms.framework;

int main(string[] args) {
    string startingForm;
    bool listForms = false;
    string saveFolder = "workingsession";
    auto helpInformation = getopt(args,
        "form|f", "The tax form being filled out.", &startingForm,
        "list|l", "List the available tax forms.", &listForms,
        );


    if (helpInformation.helpWanted)
    {
        defaultGetoptPrinter("Usage: " ~ args[0] ~ " options\nOptions:",
                             helpInformation.options);
        return 0;
    }

    critical(!listForms && startingForm.empty,
             "Must provide a form name or request list of forms.");

    if(listForms) {
        writeln();
        writeln("Registered Tax Forms:");
        registeredForms.each!writeln;
    } else {
        display(requestForm(startingForm));
    }

    return 0;
}
