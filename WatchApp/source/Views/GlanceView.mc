using Toybox.WatchUi;

class GlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onShow() {
        dump("glanceOnShow", true);
    }

    function onHide() {
        dump("glanceOnHide", true);
    }

    function onUpdate(dc) {
        dump("glanceOnUpdate", { :width => dc.getWidth(), :height => dc.getHeight() });
        dc.setColor(Toybox.Graphics.COLOR_WHITE, Toybox.Graphics.COLOR_TRANSPARENT);
        var text = "Handsfree";
        dc.drawText(
            0,
            dc.getHeight() / 2,
            Toybox.Graphics.FONT_GLANCE,
            text,
            Toybox.Graphics.TEXT_JUSTIFY_LEFT | Toybox.Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}