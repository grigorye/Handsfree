using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;

class App extends Application.AppBase {

    function initialize() {
        dump("initialize", true);
        dump("deviceSettings", deviceSettingsDumpRep(System.getDeviceSettings()));
        Application.AppBase.initialize();
    }

    function onStart(state) {
        dump("onStart", state);
        Application.AppBase.onStart(state);
    }

    function onStop(state) {
        dump("onStop", state);
        Application.AppBase.onStop(state);
    }

    function getInitialView() {
        dump("getInitialView", true);
        return [new CommView()] as Lang.Array<WatchUi.Views or WatchUi.InputDelegates> or Null;
    }

    function getGlanceView() {
        return [new GlanceView()] as Lang.Array<WatchUi.GlanceView or Toybox.WatchUi.GlanceViewDelegate> or Null;
    }
}

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
    syncImp = new Sync();
    getSync().checkIn();
}
