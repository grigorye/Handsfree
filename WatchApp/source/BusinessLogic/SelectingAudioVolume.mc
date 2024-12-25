import Toybox.WatchUi;

function selectAudioVolume() as Void {
    VT.pushView(volumeK, new AudioVolumeView(), new AudioVolumeViewDelegate(), WatchUi.SLIDE_BLINK);
}