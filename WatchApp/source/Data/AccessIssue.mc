import Toybox.Lang;

typedef AccessIssue as Lang.String;

module AccessIssues {

const NoPermission as AccessIssue = "p";
const ReadFailed as AccessIssue = "r";
const Disabled as AccessIssue = "d";

}

function accessIssuePrompt(issue as AccessIssue) as Lang.String {
    switch (issue) {
        case AccessIssues.NoPermission: return "Grant Access:";
        case AccessIssues.ReadFailed: return "Read Failed:";
        case AccessIssues.Disabled: return "Disabled:";
    }
    return "Unknown Issue:";
}