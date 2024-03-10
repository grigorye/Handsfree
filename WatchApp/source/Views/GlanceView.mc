using Toybox.WatchUi;
using Toybox.Lang;

(:glance, :background)
var showingGlance as Lang.Boolean = false;

(:glance)
class GlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onShow() {
        showingGlance = true;
        dump("glanceOnShow", true);
    }

    function onHide() {
        dump("glanceOnHide", true);
        showingGlance = false;
    }

    function onUpdate(dc) {
        dump("glanceOnUpdate", { :width => dc.getWidth(), :height => dc.getHeight() });
        dc.setColor(Toybox.Graphics.COLOR_WHITE, Toybox.Graphics.COLOR_TRANSPARENT);

        var text;
        var callState = getCallState();
        switch (callState) {
            case instanceof CallInProgress:
                text = (callState as CallInProgress).phone["number"] as Lang.String;
                break;
            default:
                text = "Handsfree";
                break;
        }
        dc.drawText(
            0,
            dc.getHeight() / 2,
            Toybox.Graphics.FONT_SYSTEM_MEDIUM,
            text,
            Toybox.Graphics.TEXT_JUSTIFY_LEFT | Toybox.Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}