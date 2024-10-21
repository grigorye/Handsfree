import Toybox.Communications;
import Toybox.Background;
import Toybox.Lang;
import Toybox.Application;

(:background)
const LX_OPEN_ME as LogComponent = "openMe";

(:background)
function openAppOnIncomingCallIfNecessary(phone as Phone) as Void {
    if (debug) { _3(LX_OPEN_ME, "isOpenAppOnIncomingCallEnabled", BackgroundSettings.isOpenAppOnIncomingCallEnabled); }
    if (!BackgroundSettings.isOpenAppOnIncomingCallEnabled) {
        return;
    }
    if (debug) { _3(LX_OPEN_ME, "activeUiKind", activeUiKind); }
    if (isActiveUiKindApp) {
        startRequestingAttentionIfInApp();
    } else {
        openAppOnIncomingCall(phone);
    }
}

(:background)
function handleOpenMeCompleted(args as Lang.Dictionary<Lang.String, Lang.Object>) as Void {
    if (debug) { _3(LX_OPEN_ME, "handleOpenMeCompleted", args); }
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
    if (debug) { _2(LX_OPEN_ME, "openMeSucceeded"); }
    startRequestingAttentionIfInApp();
}

(:background)
function openMeFailed(message as Lang.String) as Void {
    if (debug) { _3(LX_OPEN_ME, "openMeFailed.requestingApplicationWake", message); }
    Background.requestApplicationWake(message);
}

(:background)
function openAppOnIncomingCall(phone as Phone) as Void {
    var message = messageForApplicationWake(phone);
    if (BackgroundSettings.isIncomingOpenAppViaCompanionEnabled) {
        var msg = {
            cmdK => "openMe",
            argsK => {
                "messageForWakingUp" => message
            }
        } as Lang.Object as Application.PersistableType;
        var tag = formatCommTag("openMe");
        if (debug) { _3(LX_OUT_COMM, tag + ".requesting", msg); }
        Communications.transmit(msg, null, new DummyCommListener(tag));
    }
    if (BackgroundSettings.isIncomingOpenAppViaWakeUpEnabled) {
        if (debug) { _3(LX_OPEN_ME, "requestingApplicationWake", message); }
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

(:background)
function incomingCallMessage(phone as Lang.String) as Lang.String {
    return Lang.format(CommonSettings.incomingCallMessageFormat, [phone]);
}