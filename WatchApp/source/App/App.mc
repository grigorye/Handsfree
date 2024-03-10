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
        onBackgroundDataImp(data);
        Application.AppBase.onBackgroundData(data);
    }

    (:typecheck([disableGlanceCheck, disableBackgroundCheck]))
    function getInitialView() {
        dump("getInitialView", true);
        return [new CommView()] as Lang.Array<WatchUi.Views or WatchUi.InputDelegates> or Null;
    }

    (:typecheck([disableGlanceCheck, disableBackgroundCheck]))
    function getGlanceView() {
        onAppWillFinishLaunching();
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

(:glance)
function onAppWillFinishLaunching() as Void {
    dump("onAppWillFinishLaunching", true);
    phonesImp = loadPhones();
}

function onAppDidFinishLaunching() as Void {
    dump("onAppDidFinishLaunching", true);
    getSync().checkIn();

(:typecheck(disableBackgroundCheck), :glance)
function onBackgroundDataImp(data as Application.PersistableType) as Void {
    dump("onBackgroundData", data);
    switch (data) {
        case instanceof Lang.String: {
            switch (data as Lang.String) {
                case "onPhoneAppMessage": {
                    setPhones(loadPhones());
                    var loadedCallState = loadCallState();
                    if (loadedCallState != null) {
                        setCallState(loadedCallState);
                    }
                    break;
                }
                default:
                    System.error("Unexpected data");
            }
            break;
        }
        default:
            System.error("Unexpected data type");
    }
}

(:background)
var isRunningInBackground as Lang.Boolean = false;
