import Toybox.Lang;

(:glance)
function headsetStatusRep() as Lang.String or Null {
    if (!getIsHeadsetConnected(getAudioState())) {
        return "#";
    } else {
        return null;
    }
}
