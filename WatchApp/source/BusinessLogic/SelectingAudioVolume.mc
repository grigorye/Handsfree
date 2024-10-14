import Toybox.WatchUi;

function selectAudioVolume() as Void {
    pushView("volume", new AudioVolumeView(), new AudioVolumeViewDelegate(), WatchUi.SLIDE_BLINK);
}