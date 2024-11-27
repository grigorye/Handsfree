import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

module AudioStateManip {

(:background)
const L_AUDIO_STATE_STORAGE as LogComponent = "audioState";

(:background, :typecheck(disableBackgroundCheck))
function setAudioState(audioState as AudioState) as Void {
    AudioStateImp.setAudioStateImp(audioState);
    switch (activeUiKind) {
        case ACTIVE_UI_NONE: {
            return;
        }
        case ACTIVE_UI_GLANCE: {
            WatchUi.requestUpdate();
            return;
        }
        case ACTIVE_UI_APP: {
            updateCallInProgressView();
            WatchUi.requestUpdate();
            var isHeadsetConnected = getIsHeadsetConnected(audioState);
            var needToast;
            var oldAudioStateImp = AudioStateImp.oldAudioStateImp;
            if (oldAudioStateImp != null) {
                var oldIsHeadsetConnected = getIsHeadsetConnected(oldAudioStateImp);
                needToast = isHeadsetConnected != oldIsHeadsetConnected;
            } else {
                needToast = true;
            }
            if (needToast) {
                if (WatchUi has :showToast) {
                    if (isHeadsetConnected && oldAudioStateImp == null) {
                        // do nothing
                    } else if (isHeadsetConnected) {
                        WatchUi.showToast("Headset on", null);
                    } else {
                        WatchUi.showToast("No headset", null);
                    }
                }
            }
            return;
        }
    }
}

function setPendingAudioState(state as AudioState) as Void {
    AudioStateImp.pendingAudioStateImp = state;
    updateCallInProgressView();
}

(:inline, :background, :glance)
function getIsHeadsetConnected(audioState as AudioState) as Lang.Boolean {
    var isHeadsetConnected = audioState[isHeadsetConnectedK] as Lang.Boolean | Null;
    return (isHeadsetConnected != null) ? isHeadsetConnected : false;
}

(:inline)
function getAudioVolume(audioState as AudioState) as RelVolume {
    var audioVolume = audioState[volumeK] as RelVolume;
    return audioVolume;
}

(:inline, :background)
function setAudioStateVersion(version as Version) as Void {
    if (debug) { _3(L_AUDIO_STATE_STORAGE, "setAudioStateVersion", version); }
    Storage.setValue("audioStateVersion.v1", version);
}

(:inline, :background)
function getAudioStateVersion() as Version {
    var version = Storage.getValue("audioStateVersion.v1") as Version;
    return version;
}

function updateCallInProgressView() as Void {
    var callInProgressView = viewWithTag(V.callInProgress) as CallInProgressView | Null;
    if (callInProgressView != null) {
        var callInProgressState = getCallState() as CallInProgress | Null;
        if (callInProgressState != null) {
            callInProgressView.updateFromPhone(callInProgressState.phone, isOptimisticCallState(callInProgressState));
        }
    }
}

}
