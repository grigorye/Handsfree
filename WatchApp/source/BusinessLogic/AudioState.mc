import Toybox.Lang;
import Toybox.Application;

typedef AudioState as Lang.Dictionary<String, Application.PropertyValueType>;

module X {

(:background, :glance)
var audioState as AudioStateWrapper = new AudioStateWrapper();

class AudioStateWrapper extends VersionedSubject {

    function initialize() {
        VersionedSubject.initialize(
            1,
            1,
            "audioState"
        );
    }

    function setSubjectValue(value as SubjectValue) as Void {
        oldValue = value();
        VersionedSubject.setSubjectValue(value);
        AudioStateManip.updateUIForAudioStateIfRelevant();
    }

    var oldValue as AudioState | Null = null;

    function defaultSubjectValue() as SubjectValue | Null {
        return {
            isHeadsetConnectedK => false,
            activeAudioDeviceK => "speaker",
            volumeK => {
                indexK => 0,
                maxK => 10
            },
            isMutedK => false
        } as AudioState as SubjectValue;
    }

    function defaultValue() as AudioState {
        return defaultSubjectValue() as AudioState;
    }

    (:background, :glance)
    function value() as AudioState {
        return subjectValue() as AudioState;
    }

    (:background)
    function setValue(value as AudioState) as Void {
        setSubjectValue(value as SubjectValue);
    }
}

}

module AudioStateImp {

(:inline, :background)
function resetAudioState() as Void {
    var oldAudioState = X.audioState.value();
    var newAudioState = X.audioState.defaultValue();
    newAudioState[isHeadsetConnectedK] = oldAudioState[isHeadsetConnectedK];
    X.audioState.setValue(newAudioState);
    X.audioState.setVersion(0);
}

(:inline)
function getIsMuted(state as AudioState) as Lang.Boolean {
    return state[isMutedK] as Lang.Boolean;
}

(:background)
var pendingAudioStateImp as AudioState | Null = null;

(:background)
function getPendingAudioState() as AudioState {
    return (pendingAudioStateImp != null) ? pendingAudioStateImp : X.audioState.value();
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
