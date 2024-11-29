import Toybox.WatchUi;

class InstallCompanionView extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({ :title => "Setup" });
        addItem(new MenuItem("Install Companion App", null, :installCompanionApp, null));
    }
}

function newInstallCompanionView() as WatchUi.Views {
    return new InstallCompanionView();
}