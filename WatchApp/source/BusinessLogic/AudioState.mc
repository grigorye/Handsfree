import Toybox.Lang;
import Toybox.Application;

typedef AudioState as Lang.Dictionary<String, Application.PropertyValueType>;

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

(:background, :glance)
function getAudioState() as AudioState {
    if (audioStateImp == null) {
        var loadedAudioState = loadAudioState();
        if (loadedAudioState != null) {
            audioStateImp = loadedAudioState;
        } else {
            audioStateImp = {
                "isHeadsetConnected" => false,
                "isMuted" => false,
                "audioVolume" => 0.5
            } as AudioState;
        }
    }
    return audioStateImp as AudioState;
}
