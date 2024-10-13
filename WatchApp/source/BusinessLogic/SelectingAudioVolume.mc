import Toybox.WatchUi;

function selectAudioVolume() as Void {
    lastSelectedAudioVolumeImp = getAudioState()["audioVolume"] as RelVolume | Null;
    if (lastSelectedAudioVolumeImp != null) {
        lastSelectedVolumeLevel = (lastSelectedAudioVolumeImp * maxAudioLevel).toNumber();
    }
    pushView("volume", new AudioVolumeView(), new AudioVolumeViewDelegate(), WatchUi.SLIDE_BLINK);
}