import Toybox.Lang;

(:background, :noLowMemory)
function trackHits(isHit as Lang.Boolean) as Void {
    var hitsCount = getHitsCount();
    if (isHit) {
        setHitsCount(hitsCount + 1);
    } else {
        setHitsCount(0);
    }
}
