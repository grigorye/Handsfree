using Toybox.Lang;
using Toybox.Application;

(:background, :glance)
var isHeadsetConnectedImp as Lang.Boolean or Null = null;
(:background, :glance)
var oldIsHeadsetConnectedImp as Lang.Boolean or Null = null;

(:background, :glance)
const L_HEADSET as LogComponent = new LogComponent("headset", false);

(:background, :glance)
function setIsHeadsetConnectedImp(isHeadsetConnected as Lang.Boolean) as Void {
    _([L_HEADSET, "isHeadsetConnected", isHeadsetConnected]);
    oldIsHeadsetConnectedImp = getIsHeadsetConnected();
    isHeadsetConnectedImp = isHeadsetConnected;
    saveIsHeadsetConnected(isHeadsetConnected);
}

(:background, :glance)
function loadIsHeadsetConnected() as Lang.Boolean or Null {
    return Application.Storage.getValue("isHeadsetConnected") as Lang.Boolean or Null;
}

(:background, :glance)
function saveIsHeadsetConnected(isHeadsetConnected as Lang.Boolean) as Void {
    Application.Storage.setValue("isHeadsetConnected", isHeadsetConnected);
}

(:background, :glance)
function getIsHeadsetConnected() as Lang.Boolean {
    if (isHeadsetConnectedImp == null) {
        var loadedIsHeadsetConnected = loadIsHeadsetConnected();
        if (loadedIsHeadsetConnected != null) {
            isHeadsetConnectedImp = loadedIsHeadsetConnected;
        } else {
            isHeadsetConnectedImp = false;
        }
    }
    return isHeadsetConnectedImp as Lang.Boolean;
}
