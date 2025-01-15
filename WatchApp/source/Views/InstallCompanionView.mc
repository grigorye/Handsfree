import Toybox.WatchUi;

module Views {
class InstallCompanionView extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({ :title => "Connect" });
        addItem(new MenuItem("Companion App", minCompanionVersionName + " or later", :installCompanionApp, null));
    }
}

function newInstallCompanionView() as WatchUi.Views {
    return new InstallCompanionView();
}

}
