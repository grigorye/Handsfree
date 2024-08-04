using Toybox.Lang;

enum CallInProgressAction {
    CALL_IN_PROGRESS_ACTION_HANGUP = "hangup",
    CALL_IN_PROGRESS_ACTION_ACCEPT = "accept",
    CALL_IN_PROGRESS_ACTION_REJECT = "reject"
}

typedef CallInProgressActions as Lang.Array<Lang.Dictionary<Lang.Symbol, Lang.String or CallInProgressAction>>;
typedef CallInProgressTexts as Lang.Dictionary<Lang.Symbol, Lang.String or CallInProgressActions>;

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
            prefix = "Incoming call";
        } else {
            prefix = "Call in progress";
        }
    }
    var actions = [] as CallInProgressActions;
    if (isIncomingCall) {
        actions.add({
            :prompt => "Answer",
            :command => CALL_IN_PROGRESS_ACTION_ACCEPT,
        });
        actions.add({
            :prompt => "Decline",
            :command => CALL_IN_PROGRESS_ACTION_REJECT
        });
    } else {
        actions.add({
            :prompt => "Hang up",
            :command => CALL_IN_PROGRESS_ACTION_HANGUP
        });
    }
    return {
        :title => prefix,
        :actions => actions
    };
}
