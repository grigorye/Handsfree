import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

(:background, :typecheck(disableBackgroundCheck))
function setAudioState(audioState as AudioState) as Void {
    setAudioStateImp(audioState);
    switch (activeUiKind) {
        case ACTIVE_UI_NONE: {
            return;
        }
        case ACTIVE_UI_GLANCE: {
            WatchUi.requestUpdate();
            return;
        }
        case ACTIVE_UI_APP: {
            var callInProgressView = viewWithTag("callInProgress") as CallInProgressView | Null;
            if (callInProgressView != null) {
                var callInProgressState = getCallState() as CallInProgress | Null;
                if (callInProgressState != null) {
                    callInProgressView.updateFromPhone(callInProgressState.phone, isOptimisticCallState(callInProgressState));
                }
            }
            var isHeadsetConnected = getIsHeadsetConnected(audioState);
            if ((oldAudioStateImp == null) || !isHeadsetConnected.equals(getIsHeadsetConnected(oldAudioStateImp))) {
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

(:inline, :background, :glance)
function getIsHeadsetConnected(audioState as AudioState) as Lang.Boolean {
    var isHeadsetConnected = audioState["isHeadsetConnected"] as Lang.Boolean | Null;
    if (isHeadsetConnected != null) {
        return isHeadsetConnected;
    }
    return false;
}

(:inline)
function getAudioVolume(audioState as AudioState) as RelVolume {
    var audioVolume = audioState["audioVolume"] as RelVolume;
    return audioVolume;
}

(:inline)
function getAudioLevel(audioState as AudioState) as Lang.Number {
    var relVolume = getAudioVolume(audioState);
    var audioLevel = (relVolume * maxAudioLevel).toNumber();
    return audioLevel;
}

(:inline, :background)
function setAudioStateVersion(version as Version) as Void {
    if (debug) { _3(L_RECENTS_STORAGE, "setAudioStateVersion", version); }
    Storage.setValue("audioStateVersion.v1", version);
}

(:inline, :background)
function getAudioStateVersion() as Version {
    var version = Storage.getValue("audioStateVersion.v1") as Version;
    return version;
}
