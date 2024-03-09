using Toybox.Application;
using Toybox.Background;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;

(:glance, :background)
class App extends Application.AppBase {

    function initialize() {
        dump("initialize", true);
        dump("deviceSettings", deviceSettingsDumpRep(System.getDeviceSettings()));
        Application.AppBase.initialize();
        Background.registerForPhoneAppMessageEvent();
    }

    function onStart(state) {
        dump("onStart", state);
        Application.AppBase.onStart(state);
    }

    function onStop(state) {
        dump("onStop", state);
        Application.AppBase.onStop(state);
    }

    (:typecheck([disableGlanceCheck]))
    function getServiceDelegate() as Lang.Array<System.ServiceDelegate> {
        isRunningInBackground = true;
        dump("getServiceDelegate", true);
        return [new BackgroundServiceDelegate()] as Lang.Array<System.ServiceDelegate>;
    }

    function onBackgroundData(data as Application.PersistableType) as Void {
        dump("onBackgroundData", data);
        Application.AppBase.onBackgroundData(data);
    }

    (:typecheck([disableGlanceCheck, disableBackgroundCheck]))
    function getInitialView() {
        dump("getInitialView", true);
        return [new CommView()] as Lang.Array<WatchUi.Views or WatchUi.InputDelegates> or Null;
    }

    (:typecheck([disableGlanceCheck, disableBackgroundCheck]))
    function getGlanceView() {
        return [new GlanceView()] as Lang.Array<WatchUi.GlanceView or Toybox.WatchUi.GlanceViewDelegate> or Null;
    }
}

(:glance, :background)
function deviceSettingsDumpRep(deviceSettings as System.DeviceSettings) as Lang.String {
    return ""
        + Lang.format("monkey: $1$.$2$.$3$", deviceSettings.monkeyVersion) 
        + ", "
        + Lang.format("firmware: $1$", deviceSettings.firmwareVersion)
        + ", "
        + Lang.format("part: $1$", [deviceSettings.partNumber]);
}

function onAppWillFinishLaunching() as Void {
    dump("onAppWillFinishLaunching", true);
    phonesImp = loadPhones();
}

function onAppDidFinishLaunching() as Void {
    dump("onAppDidFinishLaunching", true);
    getSync().checkIn();
}

(:background)
var isRunningInBackground as Lang.Boolean = false;
