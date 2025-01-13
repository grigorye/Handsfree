import Toybox.Lang;

(:glance)
function headsetStatusRep() as Lang.String or Null {
    if (!AudioStateManip.getIsHeadsetConnected(AudioStateImp.getAudioState())) {
        return "#";
    } else {
        return null;
    }
}

(:glance, :noLowMemory)
function headsetStatusHumanReadable() as Lang.String or Null {
    if (!AudioStateManip.getIsHeadsetConnected(AudioStateImp.getAudioState())) {
        return "No headset";
    } else {
        return null;
    }
}
