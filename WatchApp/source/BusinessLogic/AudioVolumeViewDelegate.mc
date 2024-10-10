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
        if (lastSelectedVolumeLevel == maxAudioLevel) {
            return;
        }
        lastSelectedVolumeLevel = lastSelectedVolumeLevel + 1;
        invalidateLastSelectedAudioVolume();
    }

    function decreaseVolume() as Void {
        if (lastSelectedVolumeLevel == 0) {
            return;
        }
        lastSelectedVolumeLevel = lastSelectedVolumeLevel - 1;
        invalidateLastSelectedAudioVolume();
    }

    function invalidateLastSelectedAudioVolume() as Void {
        setAudioVolume(1.0 * lastSelectedVolumeLevel / maxAudioLevel);
        WatchUi.requestUpdate();
    }
}