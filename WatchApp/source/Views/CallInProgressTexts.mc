using Toybox.Lang;

enum CallInProgressAction {
    CALL_IN_PROGRESS_ACTION_HANGUP = "hangup",
    CALL_IN_PROGRESS_ACTION_ACCEPT = "accept",
    CALL_IN_PROGRESS_ACTION_REJECT = "reject"
}

typedef CallInProgressActions as Lang.Array<Lang.Dictionary<Lang.Symbol, Lang.String or CallInProgressAction>>;
typedef CallInProgressTexts as Lang.Dictionary<Lang.Symbol, Lang.String or CallInProgressActions>;

function textsForCallInProgress(phone as Phone) as CallInProgressTexts {
    var isIncomingCall = isIncomingCallPhone(phone);
    var prefix = displayTextForPhone(phone);
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
            :prompt => "Hang Up",
            :command => CALL_IN_PROGRESS_ACTION_HANGUP
        });
    }
    return {
        :title => prefix,
        :actions => actions
    };
}
