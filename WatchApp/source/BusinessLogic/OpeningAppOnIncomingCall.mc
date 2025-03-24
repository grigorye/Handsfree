import Toybox.Communications;
import Toybox.Background;
import Toybox.Lang;
import Toybox.Application;
import Toybox.System;
import Toybox.Notifications;

(:background)
const LX_OPEN_ME as LogComponent = "openMe";

module Req {

(:background)
function openAppOnIncomingCallIfNecessary(phone as Phone) as Void {
    if (debug) { _3(LX_OPEN_ME, "isOpenAppOnIncomingCallEnabled", BackgroundSettings.isOpenAppOnIncomingCallEnabled()); }
    if (!BackgroundSettings.isOpenAppOnIncomingCallEnabled()) {
        return;
    }
    if (debug) { _3(LX_OPEN_ME, "activeUiKind", activeUiKind); }
    if (isActiveUiKindApp) {
        startRequestingAttentionIfInAppAndNotDeactivated();
    } else {
        openAppOnIncomingCall(phone);
    }
}

(:background, :lowMemory)
function handleOpenMeCompleted(args as Lang.Dictionary<Lang.String, Lang.Object>) as Void {
    System.error("");
}

(:background, :noLowMemory)
function handleOpenMeCompleted(args as Lang.Dictionary<Lang.String, Lang.Object>) as Void {
    if (debug) { _3(LX_OPEN_ME, "handleOpenMeCompleted", args); }
    var succeeded = args[OpenMeCompletedArgs_succeeded] as Lang.Boolean;
    if (succeeded) {
        openMeSucceeded();
    } else {
        var message = args[OpenMeCompletedArgs_messageForWakingUp] as Lang.String;
        openMeFailed(message);
    }
}

(:background, :noLowMemory)
function openMeSucceeded() as Void {
    if (debug) { _2(LX_OPEN_ME, "openMeSucceeded"); }
    startRequestingAttentionIfInAppAndNotDeactivated();
}

(:background, :noLowMemory)
function openMeFailed(message as Lang.String) as Void {
    if (debug) { _3(LX_OPEN_ME, "openMeFailed.promptingForIncomingCall", message); }
    promptForIncomingCall(message);
}

(:background)
function openAppOnIncomingCall(phone as Phone) as Void {
    var message = messageForApplicationWake(phone);
    if (BackgroundSettings.isIncomingOpenAppViaCompanionEnabled) {
        var msg = {
            cmdK => Cmd_openMe,
            OpenMeArgsK_messageForWakingUp => message
        };
        transmitWithoutRetry("openMe", msg);
    } else {
        promptForIncomingCall(message);
    }
}

(:background, :widgetBuild)
function promptForIncomingCall(message as Lang.String) as Void {
    Background.requestApplicationWake(message);
}

(:background, :watchAppBuild)
function promptForIncomingCall(message as Lang.String) as Void {
    if (Notifications has :showNotification) {
        Notifications.showNotification(message, "Incoming Call", {
            :actions => [
                { :label => "Launch", :data => 1 }
            ],
        } as ShowNotificationOptions);
    } else {
        Background.requestApplicationWake(message);
    }
}

(:background, :watchAppBuild)
function messageForApplicationWake(phone as Phone) as Lang.String {
    if (Notifications has :showNotification) {
        var name = phone[PhoneField_name] as Lang.String or Null;
        if (name != null) {
            return name;
        }
        var number = phone[PhoneField_number] as Lang.String or Null;
        if (number != null) {
            return number;
        }
        return "Unknown number";
    } else {
        var name = phone[PhoneField_name] as Lang.String or Null;
        if (name != null) {
            return incomingCallMessage(name);
        }
        var number = phone[PhoneField_number] as Lang.String or Null;
        if (number != null) {
            return incomingCallMessage(number);
        }
        return "Incoming call";
    }
}

(:background, :widgetBuild)
function messageForApplicationWake(phone as Phone) as Lang.String {
    var name = phone[PhoneField_name] as Lang.String or Null;
    if (name != null) {
        return incomingCallMessage(name);
    }
    var number = phone[PhoneField_number] as Lang.String or Null;
    if (number != null) {
        return incomingCallMessage(number);
    }
    return "Incoming call";
}

(:background)
function incomingCallMessage(phone as Lang.String) as Lang.String {
    return Lang.format(CommonSettings.incomingCallMessageFormat, [phone]);
}

}