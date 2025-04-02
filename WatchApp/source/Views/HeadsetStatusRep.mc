import Toybox.Lang;

(:glance)
function headsetStatusRep() as Lang.String or Null {
    var speakerWouldBeUsed = AudioStateManip.getSpeakerWouldBeUsed();
    if (speakerWouldBeUsed) {
        return "#";
    } else {
        return null;
    }
}

(:glance, :noLowMemory)
function headsetStatusHumanReadable() as Lang.String or Null {
    var speakerWouldBeUsed = AudioStateManip.getSpeakerWouldBeUsed();
    if (speakerWouldBeUsed) {
        return "No Headset";
    } else {
        return null;
    }
}

(:glance)
function embeddingHeadsetStatusRep(title as Lang.String) as Lang.String {
    var adjustedTitle = joinComponents([title, headsetStatusRep()], " ");
    return adjustedTitle;
}