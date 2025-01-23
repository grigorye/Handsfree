import Toybox.Lang;

(:glance)
function headsetStatusRep() as Lang.String or Null {
    if (!AudioStateManip.getIsHeadsetConnected(X.audioState.value())) {
        return "#";
    } else {
        return null;
    }
}

(:glance, :noLowMemory)
function headsetStatusHumanReadable() as Lang.String or Null {
    if (!AudioStateManip.getIsHeadsetConnected(X.audioState.value())) {
        return "No headset";
    } else {
        return null;
    }
}

(:glance)
function embeddingHeadsetStatusRep(title as Lang.String) as Lang.String {
    var adjustedTitle = joinComponents([title, headsetStatusRep()], " ");
    return adjustedTitle;
}