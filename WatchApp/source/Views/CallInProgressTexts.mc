using Toybox.Lang;

typedef CallInProgressTexts as Lang.Dictionary<Lang.Symbol, Lang.String>;

enum CallInProgressAction {
    CALL_IN_PROGRESS_ACTION_HANGUP = "Hangup",
    CALL_IN_PROGRESS_ACTION_ACCEPT = "Accept"
}

function textsForCallInProgress(phone as Phone) as CallInProgressTexts {
    var name = phone["name"] as Lang.String or Null;
    var number = phone["number"] as Lang.String or Null;
    var isIncomingCall = isIncomingCallPhone(phone);

    var prefix;
    if (name != null) {
        prefix = name;
    } else if (number != null) {
        prefix = number;
    } else {
        if (isIncomingCall) {
            prefix = "Incoming call.";
        } else {
            prefix = "Call in progress.";
        }
    }
    var message;
    var action;
    if (isIncomingCall) {
        message = "Accept?";
        action = CALL_IN_PROGRESS_ACTION_ACCEPT;
    } else {    
        message = "Hang up?";
        action = CALL_IN_PROGRESS_ACTION_HANGUP;
    }
    return {
        :title => prefix,
        :prompt => message,
        :action => action
    };
}
