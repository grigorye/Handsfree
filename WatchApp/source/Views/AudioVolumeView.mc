import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;

const maxAudioLevel = 14;

(:audioVolumeView)
class AudioVolumeView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var line1;
        if (getIsHeadsetConnected(getAudioState())) {
            line1 = "HSET";
        } else {
            line1 = "SPKR";
        }
        var audioLevel = getAudioLevel(getAudioState());
        var line2 = 100 * audioLevel / maxAudioLevel;
        var text = line1 + "\n" + line2;

        var x = dc.getWidth() / 2;
        var y = dc.getHeight() / 2;
        var r = dc.getWidth() / 4;
        var start = 90;
        var end = 90 - 360 * audioLevel / maxAudioLevel - 0.1;
        dc.setPenWidth(1);
        dc.drawCircle(x, y, r - 1);
        dc.setPenWidth(6);
        dc.drawArc(x, y, r, Graphics.ARC_CLOCKWISE, start, end);
        dc.drawText(
            x,
            y,
            Graphics.FONT_SYSTEM_MEDIUM,
            text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}