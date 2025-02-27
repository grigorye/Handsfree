import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;
import Rez.Styles;

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
        var lastKnownAudioState = loadValueWithDefault(AudioState_valueKey, AudioState_defaultValue) as AudioState;
        var audioDevice = AudioStateManip.getActiveAudioDeviceAbbreviation(lastKnownAudioState);
        var line1 = audioDevice;
        var audioVolume = AudioStateManip.getAudioVolume(audioState);
        var volumeIndex = audioVolume[indexK] as Lang.Integer;
        var maxVolumeIndex = audioVolume[maxK] as Lang.Integer;
        var line2 = "" + 100 * volumeIndex / maxVolumeIndex;
        var lastKnownAudioVolume = AudioStateManip.getAudioVolume(lastKnownAudioState);
        var isUpToDate = objectsEqual(lastKnownAudioVolume, audioVolume);
        if (!isUpToDate) {
            line2 = pendingText(line2);
        }
        var text = joinComponents([line1, line2], "\n");

        var x = dc.getWidth() / 2;
        var y = dc.getHeight() / 2;
        var r = (dc.getWidth() * 2 / 7).toLong();
        var start = 90;
        var end = 90 - 360 * volumeIndex / maxVolumeIndex - 0.1;
        dc.drawText(
            x,
            y,
            Graphics.FONT_SYSTEM_MEDIUM,
            text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.setPenWidth(1);
        var progressStrokeHalfWidth = 4;
        dc.drawCircle(x, y, r - progressStrokeHalfWidth);
        dc.setColor(Styles.audio_volume.foreground, Graphics.COLOR_BLACK);
        dc.setPenWidth(progressStrokeHalfWidth * 2);
        dc.drawArc(x, y, r - progressStrokeHalfWidth, Graphics.ARC_CLOCKWISE, start, end);
    }
}
