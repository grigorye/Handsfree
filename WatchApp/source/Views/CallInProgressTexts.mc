import Toybox.Lang;

enum CallInProgressAction {
    CALL_IN_PROGRESS_ACTION_HANGUP = "hangup",
    CALL_IN_PROGRESS_ACTION_ACCEPT = "accept",
    CALL_IN_PROGRESS_ACTION_REJECT = "reject",
    CALL_IN_PROGRESS_ACTION_SPEAKER = "speaker"
}

typedef CallInProgressActionSelector as Lang.Dictionary<Lang.Symbol, Lang.String or CallInProgressAction>;
typedef CallInProgressActions as Lang.Array<CallInProgressActionSelector>;
typedef CallInProgressTexts as Lang.Dictionary<Lang.Symbol, Lang.String or CallInProgressActions>;

function textsForCallInProgress(phone as Phone) as CallInProgressTexts {
    var isIncomingCall = isIncomingCallPhone(phone);
    var prefix = displayTextForPhone(phone);
    var actions = [] as CallInProgressActions;
    if (isIncomingCall) {
        actions.add({
            :prompt => "Answer",
            :command => CALL_IN_PROGRESS_ACTION_ACCEPT,
        } as CallInProgressActionSelector);
        actions.add({
            :prompt => "Decline",
            :command => CALL_IN_PROGRESS_ACTION_REJECT
        } as CallInProgressActionSelector);
    } else {
        actions.add({
            :prompt => "Hang Up",
            :command => CALL_IN_PROGRESS_ACTION_HANGUP
        } as CallInProgressActionSelector);
        actions.add({
            :prompt => "Speaker",
            :command => CALL_IN_PROGRESS_ACTION_SPEAKER
        } as CallInProgressActionSelector);
    }
    var texts = {
        :title => prefix,
        :actions => actions
    } as CallInProgressTexts;
    return texts;
}
