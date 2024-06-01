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
        dump("glanceOnUpdate", { "width" => dc.getWidth(), "height" => dc.getHeight() });
        dc.setColor(Toybox.Graphics.COLOR_WHITE, Toybox.Graphics.COLOR_TRANSPARENT);

        dump("shouldShowCallState", isShowingCallStateOnGlanceEnabled());
        var appName = "Handsfree" + headsetStatusSuffix();
        if (!isShowingCallStateOnGlanceEnabled()) {
            dc.drawText(
                0,
                dc.getHeight() / 2,
                Toybox.Graphics.FONT_SYSTEM_MEDIUM,
                appName,
                Toybox.Graphics.TEXT_JUSTIFY_LEFT | Toybox.Graphics.TEXT_JUSTIFY_VCENTER
            );
        } else {
            var callState = getCallState();
            var title;
            var subtitle;
            switch (callState) {
                case instanceof CallInProgress:
                    title = (callState as CallInProgress).phone["name"] as Lang.String or Null;
                    if (title == null) {
                        title = appName;
                    }
                    var number = (callState as CallInProgress).phone["number"] as Lang.String or Null;
                    if (number != null) {
                        subtitle = number;
                    } else {
                        subtitle = "Call in progress.";
                    }
                    break;
                default:
                    title = appName;
                    if (isShowingSourceVersionEnabled()) {
                        subtitle = sourceVersion();
                    } else {
                        subtitle = "Idle";
                    }
                    break;
            }

            dc.drawText(
                0,
                dc.getHeight() / 2,
                Toybox.Graphics.FONT_SYSTEM_TINY,
                title + "\n" + subtitle,
                Toybox.Graphics.TEXT_JUSTIFY_LEFT | Toybox.Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
    }
}

(:glance)
function headsetStatusSuffix() as Lang.String {
    if (!getIsHeadsetConnected()) {
        return " #";
    } else {
        return "";
    }
}