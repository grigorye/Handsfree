import Toybox.WatchUi;
import Toybox.Lang;

class AudioVolumeViewDelegate extends WatchUi.InputDelegate {
    function initialize() {
        InputDelegate.initialize();
    }

    (:noLowMemory)
    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Lang.Boolean {
        var direction = swipeEvent.getDirection();
        switch (direction) {
            case WatchUi.SWIPE_UP: {
                increaseVolume();
                break;
            }
            case WatchUi.SWIPE_DOWN: {
                decreaseVolume();
                break;
            }
            case WatchUi.SWIPE_RIGHT: {
                onBack();
                break;
            }
            default: {
                return false;
            }
        }
        return true;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Lang.Boolean {
        var key = keyEvent.getKey();
        switch (key) {
            case WatchUi.KEY_UP: {
                increaseVolume();
                break;
            }
            case WatchUi.KEY_DOWN: {
                decreaseVolume();
                break;
            }
            case WatchUi.KEY_ESC: {
                onBack();
                break;
            }
            default: {
                return false;
            }
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
        Req.sendAudioVolume(newAudioVolume);
        WatchUi.requestUpdate();
    }

    function onBack() as Void {
        VT.popView(WatchUi.SLIDE_RIGHT);
    }
}
