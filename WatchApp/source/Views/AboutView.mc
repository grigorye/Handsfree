import Toybox.WatchUi;
import Toybox.Application;

module Views {

class AboutView extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({ :title => "About" });
        addItem(watchAppVersionItem());
        addItem(companionVersionItem());
    }

    function watchAppVersionItem() as WatchUi.MenuItem {
        var title = "Watch App";
        var subtitle = sourceVersion;
        return new MenuItem(title, subtitle, :more, null);
    }

    function companionVersionItem() as WatchUi.MenuItem {
        var companionInfo = Storage.getValue(CompanionInfo_valueKey) as CompanionInfo | Null;
        if (companionInfo == null) {
            return new MenuItem("Install", "Companion App", :installCompanionApp, null);
        } else {
            var versionCode = CompanionInfoImp.getCompanionVersionCode(companionInfo);
            var versionName = CompanionInfoImp.getCompanionVersionName(companionInfo);
            var sourceVersion = CompanionInfoImp.getCompanionSourceVersion(companionInfo);
            var title = "Companion App";
            var subtitle = versionName + " (" + versionCode + ") " + sourceVersion;
            return new MenuItem(title, subtitle, :installCompanionApp, null);
        }
    }
}

function newAboutView() as WatchUi.Views {
    var aboutView = new AboutView();
    return aboutView;
}

}