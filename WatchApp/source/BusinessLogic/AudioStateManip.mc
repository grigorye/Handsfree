import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

module AudioStateManip {

(:background, :glance, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function updateUIForAudioStateIfRelevant() as Void {
    if (activeUiKind.equals(ACTIVE_UI_GLANCE)) {
        WatchUi.requestUpdate();
        return;
    }
    if (!isActiveUiKindApp) {
        return;
    }

    var audioState = X.audioState.value();

    updateCallInProgressView();
    WatchUi.requestUpdate();
    var isHeadsetConnected = getIsHeadsetConnected(audioState);
    var needToast;
    var oldAudioStateImp = X.audioState.oldValue;
    if (oldAudioStateImp != null) {
        var oldIsHeadsetConnected = getIsHeadsetConnected(oldAudioStateImp);
        needToast = isHeadsetConnected != oldIsHeadsetConnected;
    } else {
        needToast = true;
    }
    if (needToast) {
        if (WatchUi has :showToast) {
            if (isHeadsetConnected != null && isHeadsetConnected && oldAudioStateImp == null) {
                // do nothing
            } else if (isHeadsetConnected) {
                WatchUi.showToast("Headset on", null);
            } else {
                WatchUi.showToast("No headset", null);
            }
        }
    }
}

function setPendingAudioState(state as AudioState) as Void {
    AudioStateImp.pendingAudioStateImp = state;
    updateCallInProgressView();
}

(:inline)
function getIsHeadsetConnected(audioState as AudioState) as Lang.Boolean | Null {
    var isHeadsetConnected = audioState[isHeadsetConnectedK] as Lang.Boolean | Null;
    return isHeadsetConnected;
}

(:inline, :glance)
function getSpeakerWouldBeUsed() as Lang.Boolean | Null {
    var audioState = X.audioState.value();
    var isHeadsetConnected = audioState[isHeadsetConnectedK] as Lang.Boolean | Null;
    var speakerWouldBeUsed = isHeadsetConnected != null && !isHeadsetConnected;
    return speakerWouldBeUsed;
}

(:inline)
function getAudioVolume(audioState as AudioState) as RelVolume {
    var audioVolume = audioState[volumeK] as RelVolume;
    return audioVolume;
}

(:inline)
function getActiveAudioDeviceName(audioState as AudioState) as Lang.String? {
    var audioDevice = audioState[activeAudioDeviceK] as Lang.String or Null;
    if (audioDevice != null) {
        switch (audioDevice) {
            case "h": {
                return "Headset";
            }
            case "s": {
                return "Speaker";
            }
            case "e": {
                return "Phone";
            }
            case "w": {
                return "Wired";
            }
            default: {
                return "Unknown (" + audioDevice + ")";
            }
        }
    } else {
        return null;
    }
}

(:inline)
function getActiveAudioDeviceAbbreviation(audioState as AudioState) as Lang.String or Null {
    var audioDevice = audioState[activeAudioDeviceK] as Lang.String or Null;
    if (audioDevice != null) {
        switch (audioDevice) {
            case "h": {
                return "HSET";
            }
            case "s": {
                return "SPKR";
            }
            case "e": {
                return "PHNE";
            }
            case "w": {
                return "WHST";
            }
            default: {
                return audioDevice + "?";
            }
        }
    } else {
        return null;
    }
}

function updateCallInProgressView() as Void {
    var callInProgressView = VT.viewWithTag(V.callInProgress) as CallInProgressView | Null;
    if (callInProgressView != null) {
        var callInProgressState = getCallState() as CallInProgress | Null;
        if (callInProgressState != null) {
            callInProgressView.updateFromPhone(callInProgressState.phone, isOptimisticCallState(callInProgressState));
        }
    }
}

}
