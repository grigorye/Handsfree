import Toybox.Lang;

(:glance, :noLowMemory)
function headsetStatusRep() as Lang.String or Null {
    if (!AudioStateManip.getIsHeadsetConnected(AudioStateImp.getAudioState())) {
        return "#";
    } else {
        return null;
    }
}
