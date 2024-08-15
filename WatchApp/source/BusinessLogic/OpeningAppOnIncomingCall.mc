using Toybox.Communications;
using Toybox.Background;
using Toybox.Lang;
using Toybox.Application;

(:background)
const L_OPEN_ME as LogComponent = "openMe";

(:background)
function openAppOnIncomingCallIfNecessary(phone as Phone) as Void {
    _3(L_OPEN_ME, "isOpenAppOnIncomingCallEnabled", isOpenAppOnIncomingCallEnabled());
    if (!isOpenAppOnIncomingCallEnabled()) {
        return;
    }
    _3(L_OPEN_ME, "activeUiKind", activeUiKind);
    if (isActiveUiKindApp) {
        startRequestingAttentionIfInApp();
    } else {
        openAppOnIncomingCall(phone);
    }
}

(:background)
function openAppFailed(message as Lang.String) as Void {
    _3(L_OPEN_ME, "openAppFailed.requestingApplicationWake", message);
    Background.requestApplicationWake(message);
}

(:background)
function openAppOnIncomingCall(phone as Phone) as Void {
    var message = messageForApplicationWake(phone);
    if (isIncomingOpenAppViaCompanionEnabled()) {
        var msg = {
            "cmd" => "openMe",
            "args" => {
                "messageForWakingUp" => message
            }
        } as Lang.Object as Application.PersistableType;
        var tag = formatCommTag("openMe");
        _3(L_OUT_COMM, tag + ".requesting", msg);
        Communications.transmit(msg, null, new DummyCommListener(tag));
    }
    if (isIncomingOpenAppViaWakeUpEnabled()) {
        _3(L_OPEN_ME, "requestingApplicationWake", message);
        Background.requestApplicationWake(message);
    }
}

(:background)
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