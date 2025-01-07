import Toybox.Application;
import Toybox.Background;
import Toybox.WatchUi;
import Toybox.System;

(:background)
class App extends AppCore {
    function initialize() {
        AppCore.initialize();
    }

    function getServiceDelegate() as [System.ServiceDelegate] {
        return AppCore.getServiceDelegate();
    }

    function onBackgroundData(data as Application.PersistableType) as Void {
        AppCore.onBackgroundData(data);
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        return AppCore.getInitialView();
    }
}
