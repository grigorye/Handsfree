using Toybox.Application;
using Toybox.Background;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.Communications;

(:glance, :background)
class App extends Application.AppBase {

    var backgroundServiceEnabled as Lang.Boolean;
    
    function initialize() {
        dump("initialize", true);
        dump("deviceSettings", deviceSettingsDumpRep(System.getDeviceSettings()));
        Application.AppBase.initialize();
        backgroundServiceEnabled = Application.Properties.getValue("backgroundServiceEnabled") as Lang.Boolean;
        dump("backgroundServiceEnabled", backgroundServiceEnabled);
        dump("getPhoneAppMessageEventRegistered", Background.getPhoneAppMessageEventRegistered());
        if (backgroundServiceEnabled) {
           Background.registerForPhoneAppMessageEvent();
        } else {
            Background.deletePhoneAppMessageEvent();
            
        }
    }

    function onStart(state) {
        dump("onStart", state);
        Application.AppBase.onStart(state);
    }

    function onStop(state) {
        dump("onStop", state);
        Application.AppBase.onStop(state);
    }

    (:background, :typecheck(disableGlanceCheck))
    function getServiceDelegate() as Lang.Array<System.ServiceDelegate> {
        isRunningInBackground = true;
        dump("getServiceDelegate", true);
        if (!backgroundServiceEnabled) {
            return [] as Lang.Array<System.ServiceDelegate>;
        }
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
}

function onAppDidFinishLaunching() as Void {
    dump("onAppDidFinishLaunching", true);
    getSync().checkIn();
}

(:glance, :background)
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
