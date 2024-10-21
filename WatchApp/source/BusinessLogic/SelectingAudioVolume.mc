import Toybox.WatchUi;

function selectAudioVolume() as Void {
    pushView(volumeK, new AudioVolumeView(), new AudioVolumeViewDelegate(), WatchUi.SLIDE_BLINK);
}