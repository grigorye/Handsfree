using Toybox.Communications;
using Toybox.Background;
using Toybox.Lang;
using Toybox.Application;

(:background, :glance)
const L_OPEN_ME as LogComponent = new LogComponent("openMe", false);

(:background, :glance)
function openAppOnIncomingCallIfNecessary(phone as Phone) as Void {
    _([L_OPEN_ME, "isOpenAppOnIncomingCallEnabled", isOpenAppOnIncomingCallEnabled()]);
    if (!isOpenAppOnIncomingCallEnabled()) {
        return;
    }
    var activeUiKind = getActiveUiKind();
    _([L_OPEN_ME, "activeUiKind", activeUiKind]);
    if (activeUiKind.equals(ACTIVE_UI_APP)) {
        startRequestingAttentionIfInApp();
    } else {
        openAppOnIncomingCall(phone);
    }
}

(:background, :glance)
function openAppFailed(message as Lang.String) as Void {
    _([L_OPEN_ME, "openAppFailed.requestingApplicationWake", message]);
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
        } as Lang.Object as Application.PersistableType;
        var tag = formatCommTag("openMe");
        _([L_OUT_COMM, tag + ".requesting", msg]);
        Communications.transmit(msg, null, new DummyCommListener(tag));
    }
    if (isIncomingOpenAppViaWakeUpEnabled()) {
        _([L_OPEN_ME, "requestingApplicationWake", message]);
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