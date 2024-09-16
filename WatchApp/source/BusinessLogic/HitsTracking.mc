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
function statsDidChange() as Void {
    if (!isActiveUiKindApp) {
        return;
    }
    var mainMenu = viewWithTag("mainMenu") as MainMenu or Null;
    if (mainMenu != null) {
        mainMenu.update();
    }
}

(:glance, :noLowMemory)
function statsRep() as Lang.String or Null {
    if (!GlanceLikeSettings.isHitsCountTrackingEnabled) {
        return null;
    }
    var hitsCount = getHitsCount();
    var hitsCountRep;
    if (hitsCount == 0) {
        hitsCountRep = null;
    } else {
        hitsCountRep = hitsCount.toString();
    }
    var validMessagesCount = getValidRemoteMessagesCount();
    var rawMessagesCount = getRawRemoteMessagesCount();
    var messagesCountRep = validMessagesCount + "." + (rawMessagesCount - validMessagesCount);
    return joinComponents([messagesCountRep, hitsCountRep], ".");
}