import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Lang;

(:settings)
module Views {

class AboutView extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({ :title => Rez.Strings.menuAbout });
        addItem(watchAppVersionItem());
        if (companionInfoEnabled) {
            addItem(companionVersionItem());
        }
    }

    function watchAppVersionItem() as WatchUi.MenuItem {
        var subtitle = sourceVersion;
        return new MenuItem(Rez.Strings.aboutWatchApp, subtitle, :more, null);
    }

    (:noCompanion)
    function companionVersionItem() as WatchUi.MenuItem {
        if (errorDebug) {
            System.error("Missed companionInfoEnabled check");
        }
        return new MenuItem(Rez.Strings.aboutCompanionApp, null, :more, null);
    }

    (:companion)
    function companionVersionItem() as WatchUi.MenuItem {
        var companionInfo = Storage.getValue(CompanionInfo_valueKey) as CompanionInfo | Null;
        if (companionInfo == null) {
            return new MenuItem(
                Rez.Strings.aboutInstall,
                Rez.Strings.aboutCompanionApp,
                :installCompanionApp,
                null
            );
        } else {
            var versionCode = CompanionInfoImp.getCompanionVersionCode(companionInfo);
            var versionName = CompanionInfoImp.getCompanionVersionName(companionInfo);
            var sourceVersion = CompanionInfoImp.getCompanionSourceVersion(companionInfo);
            var subtitle = Lang.format("$1$ ($2$) $3$", [versionName, versionCode, sourceVersion]);
            return new MenuItem(Rez.Strings.aboutCompanionApp, subtitle, :installCompanionApp, null);
        }
    }
}

function newAboutView() as WatchUi.Views {
    var aboutView = new AboutView();
    return aboutView;
}

}