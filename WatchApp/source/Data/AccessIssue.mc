import Toybox.WatchUi;
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
        case AccessIssues.Disabled: return "Not Enabled:";
    }
    return "Unknown Issue:";
}

function accessIssueMenuItem(label as Lang.String, issue as AccessIssue, itemId as Lang.Object) as WatchUi.MenuItem {
    var prompt = accessIssuePrompt(issue);
    return new WatchUi.MenuItem(prompt, label, itemId, {});
}