using Toybox.Lang;

typedef CallInProgressTexts as Lang.Dictionary<Lang.Symbol, Lang.String>;

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
    if (isIncomingCall) {
        message = "Accept?";
    } else {    
        message = "Hang up?";
    }
    return {
        :title => prefix,
        :prompt => message
    };
}
