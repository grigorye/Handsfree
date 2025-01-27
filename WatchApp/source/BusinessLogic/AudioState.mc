import Toybox.Lang;
import Toybox.Application;

typedef AudioState as Lang.Dictionary<String, Application.PropertyValueType>;

(:background, :glance)
const AudioState_valueKey = "audioState.v1";
(:background, :glance)
const AudioState_versionKey = "audioStateVersion.v1";

(:background)
const AudioState_defaultValue = {
    isHeadsetConnectedK => false,
    activeAudioDeviceK => null,
    volumeK => {
        indexK => 0,
        maxK => 10
    },
    isMutedK => false
} as AudioState;

(:background)
var AudioState_oldValue as AudioState | Null = null;

module AudioStateImp {

(:inline)
function getIsMuted(state as AudioState) as Lang.Boolean {
    return state[isMutedK] as Lang.Boolean;
}

(:background)
var pendingAudioStateImp as AudioState | Null = null;

(:background)
function getPendingAudioState() as AudioState {
    return (pendingAudioStateImp != null) ? pendingAudioStateImp : (loadValueWithDefault(AudioState_valueKey, AudioState_defaultValue) as AudioState);
}

(:background, :inline)
function clone(state as AudioState) as AudioState {
    var volume = state[volumeK] as RelVolume;
    return {
        isHeadsetConnectedK => state[isHeadsetConnectedK],
        activeAudioDeviceK => state[activeAudioDeviceK],
        volumeK => {
            indexK => volume[indexK],
            maxK => volume[maxK]
        },
        isMutedK => state[isMutedK]
    } as AudioState;
}

}
