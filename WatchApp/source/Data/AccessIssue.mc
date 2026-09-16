import Toybox.WatchUi;
import Toybox.Lang;

typedef AccessIssue as Lang.String;

const AccessIssues_NoPermission as AccessIssue = "p";
const AccessIssues_ReadFailed as AccessIssue = "r";
const AccessIssues_Disabled as AccessIssue = "d";

function accessIssuePrompt(issue as AccessIssue) as StringOrResource {
    switch (issue) {
        case AccessIssues_NoPermission: return Rez.Strings.accessGivePermissions;
        case AccessIssues_ReadFailed: return Rez.Strings.accessReadFailed;
        case AccessIssues_Disabled: return Rez.Strings.accessNotEnabled;
    }
    return Rez.Strings.accessUnknownIssue;
}

function accessIssueMenuItem(label as StringOrResource, issue as AccessIssue, itemId as Lang.Object) as WatchUi.MenuItem {
    var prompt = accessIssuePrompt(issue);
    return new WatchUi.MenuItem(prompt, label, itemId, {});
}