import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time;

module X {

(:background)
var recents as RecentsWrapper = new RecentsWrapper();

class RecentsWrapper extends VersionedSubject {
    
    function initialize() {
        VersionedSubject.initialize(
            2,
            1,
            "recents"
        );
    }

    function setSubjectValue(value as SubjectValue) as Void {
        VersionedSubject.setSubjectValue(value);
        updateMissedRecents();
        RecentsManip.updateUIForRecentsIfInApp(value as Recents);
    }

    function defaultSubjectValue() as SubjectValue | Null {
        return { RecentsField_list => [] as RecentsList } as Recents as SubjectValue;
    }

    (:background)
    function value() as Recents {
        return subjectValue() as Recents;
    }
}

}
module RecentsManip {

(:background)
function getRecentsList() as RecentsList {
    var recents = X.recents.value();
    var recentsList = recents[RecentsField_list] as RecentsList;
    return recentsList;
}

(:background, :typecheck([disableBackgroundCheck]))
function updateUIForRecentsIfInApp(recents as Recents) as Void {
    if (!isActiveUiKindApp) {
        return;
    }
    updateRecentsMenuItem();
    updateRecentsView();
    WatchUi.requestUpdate();
}

(:inline)
function updateRecentsView() as Void {
    var recentsView = VT.viewWithTag(V_recents) as RecentsScreen.View or Null;
    if (recentsView != null) {
        recentsView.update();
    }
}

function recentsDidOpen() as Void {
    setLastRecentsCheckDate(Time.now().value());
    updateMissedRecents();
    updateRecentsMenuItem();
}

}
