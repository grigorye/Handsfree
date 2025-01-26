import Toybox.WatchUi;
import Toybox.Lang;

typedef AccessIssue as Lang.String;

const AccessIssues_NoPermission as AccessIssue = "p";
const AccessIssues_ReadFailed as AccessIssue = "r";
const AccessIssues_Disabled as AccessIssue = "d";

function accessIssuePrompt(issue as AccessIssue) as Lang.String {
    switch (issue) {
        case AccessIssues_NoPermission: return "Give Permissions:";
        case AccessIssues_ReadFailed: return "Read Failed:";
        case AccessIssues_Disabled: return "Not Enabled:";
    }
    return "Unknown Issue:";
}

function accessIssueMenuItem(label as Lang.String, issue as AccessIssue, itemId as Lang.Object) as WatchUi.MenuItem {
    var prompt = accessIssuePrompt(issue);
    return new WatchUi.MenuItem(prompt, label, itemId, {});
}