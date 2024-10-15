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
        var audioState = AudioStateImp.getAudioState();
        var audioLevel = AudioStateManip.getAudioLevel(audioState);
        var newAudioLevel = audioLevel + delta;
        if (newAudioLevel <= 0) {
            newAudioLevel = 0;
        }
        if (newAudioLevel >= maxAudioLevel) {
            newAudioLevel = maxAudioLevel;
        }
        var newAudioVolume = 1.0 * newAudioLevel / maxAudioLevel;
        sendAudioVolume(newAudioVolume);
        WatchUi.requestUpdate();
    }
}
