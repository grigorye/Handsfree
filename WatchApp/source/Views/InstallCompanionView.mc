import Toybox.WatchUi;

(:companion)
module Views {

class InstallCompanionView extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({ :title => companionStatus() == CompanionStatus_notInstalled ? "Action Required" : "Update Required" });
        addItem(new MenuItem("Install Companion", "v" + minCompanionVersionName + " or later", :installCompanionApp, null));
    }
}

function newInstallCompanionView() as WatchUi.Views {
    return new InstallCompanionView();
}

}
