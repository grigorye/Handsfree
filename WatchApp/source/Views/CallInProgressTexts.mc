import Toybox.WatchUi;
import Toybox.Lang;

enum CallInProgressAction {
    CALL_IN_PROGRESS_ACTION_HANGUP = "hangup",
    CALL_IN_PROGRESS_ACTION_ACCEPT = "accept",
    CALL_IN_PROGRESS_ACTION_REJECT = "reject",
    CALL_IN_PROGRESS_ACTION_IGNORE = "ignore",
    CALL_IN_PROGRESS_ACTION_MUTE = "mute",
    CALL_IN_PROGRESS_ACTION_AUDIO_VOLUME = "audioVolume",
}

// `MenuItem` accepts a resource id for its label, so prompts can be either a `Lang.String`
// (for dynamically composed prompts) or a `Lang.ResourceId` (for static prompts).
typedef CallInProgressPrompt as StringOrResource;
typedef CallInProgressActionSelector as Lang.Dictionary<Lang.Symbol, CallInProgressPrompt or CallInProgressAction>;
typedef CallInProgressActions as Lang.Array<CallInProgressActionSelector>;
typedef CallInProgressTexts as Lang.Dictionary<Lang.Symbol, CallInProgressPrompt or CallInProgressActions>;

function textsForCallInProgress(phone as Phone) as CallInProgressTexts {
    var isIncomingCall = isIncomingCallPhone(phone);
    var prefix = displayTextForPhone(phone);
    var actions = [] as CallInProgressActions;
    if (isIncomingCall) {
        actions.add({
            :prompt => Rez.Strings.callPromptAnswer,
            :command => CALL_IN_PROGRESS_ACTION_ACCEPT,
        } as CallInProgressActionSelector);
        actions.add({
            :prompt => Rez.Strings.callPromptDecline,
            :command => CALL_IN_PROGRESS_ACTION_REJECT
        } as CallInProgressActionSelector);
        actions.add({
            :prompt => Rez.Strings.callPromptIgnore,
            :command => CALL_IN_PROGRESS_ACTION_IGNORE
        } as CallInProgressActionSelector);
    } else {
        actions.add({
            :prompt => Rez.Strings.callPromptHangUp,
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
    var volumeSuffix = formatIfResources(Rez.Strings.callPromptVolumePercentFormat, [percents]);
    if (!audioVolumeIsUpToDate) {
        volumeSuffix = pendingText(volumeSuffix);
    }
    var activeAudioDevice = AudioStateManip.getActiveAudioDeviceName(lastKnownAudioState);
    var volumePrompt;
    if (activeAudioDevice != null) {
        volumePrompt = formatIfResources("$1$: $2$", [Rez.Strings.callPromptVolume, volumeSuffix]);
    } else {
        volumePrompt = Rez.Strings.callPromptVolume;
    }
    actions.add({
        :prompt => volumePrompt,
        :subLabel => activeAudioDevice,
        :command => CALL_IN_PROGRESS_ACTION_AUDIO_VOLUME
    } as CallInProgressActionSelector);

    var isMuted = AudioStateImp.getIsMuted(audioState);
    var muteLabel = isMuted ? Rez.Strings.callPromptUnmute : Rez.Strings.callPromptMute;
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