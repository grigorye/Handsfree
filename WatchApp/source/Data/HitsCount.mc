import Toybox.Lang;
import Toybox.Application;

(:background)
const L_HITS_STORAGE as LogComponent = "hits";

(:background, :noLowMemory)
function setHitsCount(hitsCount as Lang.Number) as Void {
    saveHitsCount(hitsCount);
    statsDidChange();
}

(:background, :glance, :noLowMemory)
const Storage_hitsCount = "H" + valueKeySuffix;

(:background, :glance, :noLowMemory)
function getHitsCount() as Lang.Number {
    var hitsCount = Storage.getValue(Storage_hitsCount) as Lang.Number or Null;
    if (hitsCount != null) {
        return hitsCount;
    } else {
        return 0 as Lang.Number;
    }
}

(:background, :noLowMemory)
function saveHitsCount(hitsCount as Lang.Number) as Void {
    if (debug) { _3(L_HITS_STORAGE, "saveHitsCount", hitsCount); }
    Storage.setValue(Storage_hitsCount, hitsCount);
}
