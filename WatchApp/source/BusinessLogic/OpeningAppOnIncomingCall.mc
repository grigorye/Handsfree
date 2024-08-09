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
    if (activeUiKind.equals(ACTIVE_UI_APP)) {
        startRequestingAttentionIfInApp();
    } else {
        openAppOnIncomingCall(phone);
    }
}

(:background, :glance)
function openAppFailed(message as Lang.String) as Void {
    dump("openAppFailed.requestingApplicationWake", message);
    Background.requestApplicationWake(message);
}

(:background, :glance)
function openAppOnIncomingCall(phone as Phone) as Void {
    var message = messageForApplicationWake(phone);
    if (isIncomingOpenAppViaCompanionEnabled()) {
        var msg = {
            "cmd" => "openMe",
            "args" => {
                "messageForWakingUp" => message
            }
        };
        dump("outMsg", msg);
        Communications.transmit(msg, null, new DummyCommListener("openMe"));
    }
    if (isIncomingOpenAppViaWakeUpEnabled()) {
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