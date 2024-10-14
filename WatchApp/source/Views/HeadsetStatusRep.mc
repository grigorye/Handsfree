import Toybox.Lang;

(:glance, :noLowMemory)
function headsetStatusRep() as Lang.String or Null {
    if (!getIsHeadsetConnected(getAudioState())) {
        return "#";
    } else {
        return null;
    }
}
