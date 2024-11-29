import Toybox.WatchUi;

class InstallCompanionView extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({ :title => "Install" });
        addItem(new MenuItem("Companion App", minCompanionVersionName + " or later", :installCompanionApp, null));
    }
}

function newInstallCompanionView() as WatchUi.Views {
    return new InstallCompanionView();
}