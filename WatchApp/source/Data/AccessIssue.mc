import Toybox.Lang;

typedef AccessIssue as Lang.String;

module AccessIssues {

const NoPermission as AccessIssue = "p";
const ReadFailed as AccessIssue = "r";
const Disabled as AccessIssue = "d";

}

function accessIssuePrompt(issue as AccessIssue) as Lang.String {
    switch (issue) {
        case AccessIssues.NoPermission: return "Give Permissions:";
        case AccessIssues.ReadFailed: return "Read Failed:";
        case AccessIssues.Disabled: return "Enable in Companion:";
    }
    return "Unknown Issue:";
}