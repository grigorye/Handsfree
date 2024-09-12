using Toybox.Lang;

(:background, :noLowMemory)
function trackHits(isHit as Lang.Boolean) as Void {
    var hitsCount = getHitsCount();
    if (isHit) {
        setHitsCount(hitsCount + 1);
    } else {
        setHitsCount(0);
    }
}

(:background, :typecheck([disableBackgroundCheck]), :noLowMemory)
function hitsCountDidChange() as Void {
    if (!isActiveUiKindApp) {
        return;
    }
    var mainMenu = viewWithTag("mainMenu") as MainMenu or Null;
    if (mainMenu != null) {
        mainMenu.update();
    }
}

(:glance, :noLowMemory)
function hitsCountRep() as Lang.String or Null {
    if (!GlanceLikeSettings.isHitsCountTrackingEnabled) {
        return null;
    }
    var hitsCount = getHitsCount();
    if (hitsCount == 0) {
        return null;
    } else {
        return "@" + hitsCount;
    }
}