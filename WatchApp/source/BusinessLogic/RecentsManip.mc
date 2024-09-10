using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Lang;

function getRecents() as Recents {
    var recents = Application.Storage.getValue("recents.v1") as Recents or Null;
    if (recents != null) {
        return recents;
    } else {
        return [] as Recents;
    }
}

(:background)
function saveRecents(recents as Recents) as Void {
    _3(L_STORAGE, "saveRecents", recents);
    Application.Storage.setValue("recents.v1", recents as [Application.PropertyValueType]);
}

(:background)
function setRecents(recents as Recents) as Void {
    saveRecents(recents);
    updateUIForRecentsIfInApp(recents);
}

(:background, :typecheck([disableBackgroundCheck]))
function updateUIForRecentsIfInApp(recents as Recents) as Void {
    if (!isActiveUiKindApp) {
        return;
    }
    updateUIForRecents(recents);
}

function updateUIForRecents(recents as Recents) as Void {
    var recentsView = viewWithTag("recents") as RecentsView or Null;
    if (recentsView != null) {
        recentsView.updateFromRecents(recents);
    }
}