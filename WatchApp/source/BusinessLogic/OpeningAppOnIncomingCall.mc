using Toybox.Communications;
using Toybox.Background;
using Toybox.Lang;

(:background, :glance)
function openAppOnIncomingCallIfNecessary(phone as Phone) as Void {
    dump("isOpenAppOnIncomingCallEnabled", isOpenAppOnIncomingCallEnabled());
    if (!isOpenAppOnIncomingCallEnabled()) {
        return;
    }
    var activeUiKind = getActiveUiKind();
    dump("activeUiKind", activeUiKind);
    if (activeUiKind != ACTIVE_UI_APP) {
        openAppOnIncomingCall(phone);
    }
}

(:background, :glance)
function openAppOnIncomingCall(phone as Phone) as Void {
    if (isIncomingOpenAppViaCompanionEnabled()) {
        var msg = {
            "cmd" => "openMe"
        };
        dump("outMsg", msg);
        Communications.transmit(msg, null, new DummyCommListener("openMe"));
    }
    if (isIncomingOpenAppViaWakeUpEnabled()) {
        var message = messageForApplicationWake(phone);
        dump("requestingApplicationWake", message);
        Background.requestApplicationWake(message);
    }
}

(:background, :glance)
function messageForApplicationWake(phone as Phone) as Lang.String {
    var name = phone["name"] as Lang.String or Null;
    if (name != null) {
        return incomingCallMessage(name);
    }
    var number = phone["number"] as Lang.String or Null;
    if (number != null) {
        return incomingCallMessage(number);
    }
    return "Incoming call";
}

(:background, :glance)
function incomingCallMessage(phone as Lang.String) as Lang.String {
    return Lang.format(incomingCallMessageFormat(), [phone]);
}