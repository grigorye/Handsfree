using Toybox.Communications;
using Toybox.Background;
using Toybox.Lang;
using Toybox.Application;

(:background)
const L_OPEN_ME as LogComponent = "openMe";

(:background)
function openAppOnIncomingCallIfNecessary(phone as Phone) as Void {
    _3(L_OPEN_ME, "isOpenAppOnIncomingCallEnabled", BackgroundSettings.isOpenAppOnIncomingCallEnabled);
    if (!BackgroundSettings.isOpenAppOnIncomingCallEnabled) {
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
function handleOpenMeCompleted(args as Lang.Dictionary<Lang.String, Lang.Object>) as Void {
    _3(L_OPEN_ME, "handleOpenMeCompleted", args);
    var succeeded = args["succeeded"] as Lang.Boolean;
    if (succeeded) {
        openMeSucceeded();
    } else {
        var message = args["messageForWakingUp"] as Lang.String;
        openMeFailed(message);
    }
}

(:background)
function openMeSucceeded() as Void {
    _2(L_OPEN_ME, "openMeSucceeded");
    startRequestingAttentionIfInApp();
}

(:background)
function openMeFailed(message as Lang.String) as Void {
    _3(L_OPEN_ME, "openMeFailed.requestingApplicationWake", message);
    Background.requestApplicationWake(message);
}

(:background)
function openAppOnIncomingCall(phone as Phone) as Void {
    var message = messageForApplicationWake(phone);
    if (BackgroundSettings.isIncomingOpenAppViaCompanionEnabled) {
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
    if (BackgroundSettings.isIncomingOpenAppViaWakeUpEnabled) {
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
    return Lang.format(CommonSettings.incomingCallMessageFormat, [phone]);
}