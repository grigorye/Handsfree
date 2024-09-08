using Toybox.WatchUi;
using Toybox.Lang;
using Toybox.Graphics;
using Rez.Styles;

(:glance, :watchApp)
class GlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Graphics.Dc) {
        var defaultTitle = "HANDSFREE";
        var font;
        font = Styles.glance_font.font;
        var foregroundColor;
        var backgroundColor;
        foregroundColor = Graphics.COLOR_WHITE;
        backgroundColor = Graphics.COLOR_TRANSPARENT;
        dc.setColor(foregroundColor, backgroundColor);

        var title;
        title = defaultTitle;
        var text = title;
        dc.drawText(
            0,
            dc.getHeight() / 2,
            font,
            text,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
