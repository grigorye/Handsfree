import Toybox.WatchUi;
import Toybox.Lang;

(:companion)
module Views {

class InstallCompanionView extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({
            :title => companionStatus() == CompanionStatus_notInstalled
                ? Rez.Strings.installActionRequired
                : Rez.Strings.installUpdateRequired
        });
        addItem(new MenuItem(
            Rez.Strings.installInstallCompanion,
            formatIfResources(Rez.Strings.installVersionOrLater, [minCompanionVersionName]),
            :installCompanionApp,
            null
        ));
    }
}

function newInstallCompanionView() as WatchUi.Views {
    return new InstallCompanionView();
}

}
