using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;

class CommExample extends Application.AppBase {

    function initialize() {
        dump("initialize", true);
        dump("deviceSettings", deviceSettingsDumpRep(System.getDeviceSettings()));
        Application.AppBase.initialize();
        phonesImp = loadPhones();
        syncImp = new Sync();
    }

    function onStart(state) {
        dump("onStart", state);
        Application.AppBase.onStart(state);
        getSync().checkIn();
    }

    function onStop(state) {
        dump("onStop", state);
        Application.AppBase.onStop(state);
    }

    function getInitialView() {
        dump("getInitialView", true);
        return [new CommView()] as Lang.Array<WatchUi.Views or WatchUi.InputDelegates> or Null;
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
