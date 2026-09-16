import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
function headsetStatusRep() as StringOrResource | Null {
    var speakerWouldBeUsed = AudioStateManip.getSpeakerWouldBeUsed();
    if (speakerWouldBeUsed) {
        return Rez.Strings.headsetStatusMarker;
    } else {
        return null;
    }
}

(:glance, :noLowMemory)
function headsetStatusHumanReadable() as StringOrResource | Null {
    var speakerWouldBeUsed = AudioStateManip.getSpeakerWouldBeUsed();
    if (speakerWouldBeUsed) {
        return Rez.Strings.headsetNoHeadset;
    } else {
        return null;
    }
}

(:glance)
function embeddingHeadsetStatusRep(title as Lang.String) as Lang.String {
    var headsetStatus = headsetStatusRep();
    var adjustedTitle = joinNonNullComponents([title, headsetStatus], " ");
    return adjustedTitle;
}