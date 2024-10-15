import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;
import Rez.Styles;

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

        var audioState = AudioStateImp.getPendingAudioState();
        var line1;
        if (AudioStateManip.getIsHeadsetConnected(audioState)) {
            line1 = "HSET";
        } else {
            line1 = "SPKR";
        }
        var audioLevel = AudioStateManip.getAudioLevel(audioState);
        var line2 = 100 * audioLevel / maxAudioLevel;
        var lastKnownAudioLevel = AudioStateManip.getAudioLevel(AudioStateImp.getAudioState());
        var isUpToDate = (lastKnownAudioLevel == audioLevel);
        if (!isUpToDate) {
            line2 = "|" + line2 + "|";
        }
        var text = line1 + "\n" + line2;

        var x = dc.getWidth() / 2;
        var y = dc.getHeight() / 2;
        var r = dc.getWidth() * 2 / 7;
        var start = 90;
        var end = 90 - 360 * audioLevel / maxAudioLevel - 0.1;
        dc.drawText(
            x,
            y,
            Graphics.FONT_SYSTEM_MEDIUM,
            text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.setPenWidth(2);
        dc.drawCircle(x, y, r - 1);
        dc.setColor(Styles.audio_volume.foreground, Graphics.COLOR_BLACK);
        dc.setPenWidth(6);
        dc.drawArc(x, y, r, Graphics.ARC_CLOCKWISE, start, end);
    }
}
