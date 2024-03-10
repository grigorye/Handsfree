using Toybox.WatchUi;
using Toybox.Lang;

(:glance, :typecheck(disableBackgroundCheck))
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

        dc.drawText(
            0,
            dc.getHeight() / 2,
            Toybox.Graphics.FONT_SYSTEM_MEDIUM,
            glanceTitle(),
            Toybox.Graphics.TEXT_JUSTIFY_LEFT | Toybox.Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}

(:glance)
function glanceTitle() as Lang.String {
    var text;

    var shouldShowCallState = isShowingCallStateOnGlanceEnabled();
    dump("shouldShowCallState", shouldShowCallState);
    if (!shouldShowCallState) {
        text = "Handsfree";
    } else {
        var callState = getCallState();
        switch (callState) {
            case instanceof CallInProgress:
                text = (callState as CallInProgress).phone["number"] as Lang.String;
                break;
            default:
                text = "Handsfree";
                break;
        }
    }
    return text;
}