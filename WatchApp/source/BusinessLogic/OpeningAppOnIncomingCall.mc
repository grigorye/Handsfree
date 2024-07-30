using Toybox.Communications;

(:background, :glance)
function openAppOnIncomingCallIfNecessary() as Void {
    if (!isOpenAppOnIncomingCallEnabled()) {
        return;
    }
    var activeUiKind = getActiveUiKind();
    dump("activeUiKind", activeUiKind);
    if (activeUiKind != ACTIVE_UI_APP) {
        requestOpeningApp();
    }
}

(:background, :glance)
function requestOpeningApp() as Void {
    var msg = {
        "cmd" => "openMe"
    };
    dump("outMsg", msg);
    Communications.transmit(msg, null, new DummyCommListener("openMe"));
}
