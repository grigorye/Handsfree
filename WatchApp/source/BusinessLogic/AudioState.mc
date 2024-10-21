import Toybox.Lang;
import Toybox.Application;

typedef AudioState as Lang.Dictionary<String, Application.PropertyValueType>;

module AudioStateImp {

(:background, :glance)
var audioStateImp as AudioState or Null = null;
(:background)
var oldAudioStateImp as AudioState or Null = null;

(:background, :glance)
const L_AUDIO_STATE as LogComponent = "audioState";

(:inline, :background)
function setAudioStateImp(audioState as AudioState) as Void {
    if (debug) { _3(L_AUDIO_STATE, "audioState", audioState); }
    oldAudioStateImp = getAudioState();
    audioStateImp = audioState;
    saveAudioState(audioState);
}

(:inline, :background, :glance)
function loadAudioState() as AudioState or Null {
    return Storage.getValue("audioState.v1") as AudioState or Null;
}

(:inline, :background)
function saveAudioState(audioState as AudioState) as Void {
    Storage.setValue("audioState.v1", audioState as Application.PropertyValueType);
}

(:inline, :background)
function resetAudioState() as Void {
    var audioState = getAudioState();
    audioState[isMutedK] = false;
    AudioStateManip.setAudioState(audioState);
}

(:background, :glance)
function getAudioState() as AudioState {
    var audioState;
    if (audioStateImp != null) {
        audioState = audioStateImp;
    } else {
        var loadedAudioState = loadAudioState();
        if (loadedAudioState != null) {
            audioState = loadedAudioState;
        } else {
            audioState = defaultAudioState();
        }
    }
    return audioState;
}

(:background, :glance)
function defaultAudioState() as AudioState {
    return {
        isHeadsetConnectedK => false,
        volumeK => {
            indexK => 5,
            maxK => 10
        },
        isMutedK => false
    } as AudioState;
}

(:inline)
function getIsMuted(state as AudioState) as Lang.Boolean {
    return state[isMutedK] as Lang.Boolean;
}

(:background)
var pendingAudioStateImp as AudioState | Null = null;

(:background)
function getPendingAudioState() as AudioState {
    return (pendingAudioStateImp != null) ? pendingAudioStateImp : getAudioState();
}

(:background, :inline)
function clone(state as AudioState) as AudioState {
    var volume = state[volumeK] as RelVolume;
    return {
        isHeadsetConnectedK => state[isHeadsetConnectedK],
        volumeK => {
            indexK => volume[indexK],
            maxK => volume[maxK]
        },
        isMutedK => state[isMutedK]
    } as AudioState;
}

}
