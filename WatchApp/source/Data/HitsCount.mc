using Toybox.Lang;
using Toybox.Application;

(:background)
const L_HITS_STORAGE as LogComponent = "hits";

(:background, :noLowMemory)
function setHitsCount(hitsCount as Lang.Number) as Void {
    saveHitsCount(hitsCount);
    statsDidChange();
}

(:background, :glance, :noLowMemory)
function getHitsCount() as Lang.Number {
    var hitsCount = Application.Storage.getValue("hitsCount.v1") as Lang.Number or Null;
    if (hitsCount != null) {
        return hitsCount;
    } else {
        return 0 as Lang.Number;
    }
}

(:background)
function saveHitsCount(hitsCount as Lang.Number) as Void {
    _3(L_HITS_STORAGE, "saveHitsCount", hitsCount);
    Application.Storage.setValue("hitsCount.v1", hitsCount);
}
