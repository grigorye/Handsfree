import Toybox.Lang;

enum CallInProgressAction {
    CALL_IN_PROGRESS_ACTION_HANGUP = "hangup",
    CALL_IN_PROGRESS_ACTION_ACCEPT = "accept",
    CALL_IN_PROGRESS_ACTION_REJECT = "reject",
    CALL_IN_PROGRESS_ACTION_IGNORE = "ignore",
    CALL_IN_PROGRESS_ACTION_MUTE = "mute",
    CALL_IN_PROGRESS_ACTION_AUDIO_VOLUME = "audioVolume",
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
        actions.add({
            :prompt => "Ignore",
            :command => CALL_IN_PROGRESS_ACTION_IGNORE
        } as CallInProgressActionSelector);
    } else {
        actions.add({
            :prompt => "Hang Up",
            :command => CALL_IN_PROGRESS_ACTION_HANGUP
        } as CallInProgressActionSelector);
        addAudioActions(actions);
    }
    var texts = {
        :title => prefix,
        :actions => actions
    } as CallInProgressTexts;
    return texts;
}

function addAudioActions(actions as CallInProgressActions) as Void {
    var audioState = AudioStateImp.getPendingAudioState();
    var lastKnownAudioState = loadValueWithDefault(AudioState_valueKey, AudioState_defaultValue) as AudioState;
    var audioVolume = AudioStateManip.getAudioVolume(audioState);
    var percents = toPercents(audioVolume);
    var lastKnownAudioVolume = AudioStateManip.getAudioVolume(lastKnownAudioState);
    var audioVolumeIsUpToDate = percents == toPercents(lastKnownAudioVolume);
    var volumeSuffix = percents + "%";
    if (!audioVolumeIsUpToDate) {
        volumeSuffix = pendingText(volumeSuffix);
    }
    var activeAudioDevice = AudioStateManip.getActiveAudioDeviceName(lastKnownAudioState);
    var volumePrompt = (activeAudioDevice != null) ? "Volume: " + volumeSuffix : "Volume";
    actions.add({
        :prompt => volumePrompt,
        :subLabel => activeAudioDevice,
        :command => CALL_IN_PROGRESS_ACTION_AUDIO_VOLUME
    } as CallInProgressActionSelector);

    var isMuted = AudioStateImp.getIsMuted(audioState);
    var muteLabel = isMuted ? "Unmute" : "Mute";
    var isMutedIsUpToDate = isMuted != AudioStateImp.getIsMuted(lastKnownAudioState);
    if (isMutedIsUpToDate) {
        muteLabel = pendingText(muteLabel);
    }
    actions.add({
        :prompt => muteLabel,
        :command => CALL_IN_PROGRESS_ACTION_MUTE
    } as CallInProgressActionSelector);
}

(:inline)
function toPercents(volume as RelVolume) as Lang.Number {
    var value = volume[indexK] as Lang.Number;
    var max = volume[maxK] as Lang.Number;
    return value * 100 / max;
}