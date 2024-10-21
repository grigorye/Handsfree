import Toybox.WatchUi;
import Toybox.Lang;

class AudioVolumeViewDelegate extends WatchUi.InputDelegate {
    function initialize() {
        InputDelegate.initialize();
    }

    (:noLowMemory)
    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Lang.Boolean {
        var direction = swipeEvent.getDirection();
        if (direction != WatchUi.SWIPE_UP && direction != WatchUi.SWIPE_DOWN) {
            return false;
        }
        if (direction == WatchUi.SWIPE_UP) {
            increaseVolume();
        } else {
            decreaseVolume();
        }
        return true;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Lang.Boolean {
        var key = keyEvent.getKey();
        if (key != WatchUi.KEY_UP && key != WatchUi.KEY_DOWN) {
            return false;
        }
        if (key == WatchUi.KEY_UP) {
            increaseVolume();
        } else {
            decreaseVolume();
        }
        return true;
    }

    function increaseVolume() as Void {
        adjustAudioLevel(+1);
    }

    function decreaseVolume() as Void {
        adjustAudioLevel(-1);
    }

    function adjustAudioLevel(delta as Lang.Number) as Void {
        var audioVolume = AudioStateManip.getAudioVolume(AudioStateImp.getPendingAudioState());
        var newVolumeIndex = audioVolume[indexK] as Lang.Number + delta;
        var maxVolumeIndex = audioVolume[maxK] as Lang.Number;
        if (newVolumeIndex < 0) {
            newVolumeIndex = 0;
        }
        if (newVolumeIndex > maxVolumeIndex) {
            newVolumeIndex = maxVolumeIndex;
        }
        var newAudioVolume = {
            indexK => newVolumeIndex,
            maxK => maxVolumeIndex
        } as RelVolume;
        sendAudioVolume(newAudioVolume);
        WatchUi.requestUpdate();
    }
}
