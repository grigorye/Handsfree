using Toybox.WatchUi;
using Toybox.Lang;

class WidgetView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc) {
        View.onUpdate(dc);

        dump("widgetOnUpdate", { "width" => dc.getWidth(), "height" => dc.getHeight() });
        dc.setColor(Toybox.Graphics.COLOR_WHITE, Toybox.Graphics.COLOR_TRANSPARENT);

        dump("shouldShowCallState", isShowingCallStateOnGlanceEnabled());
        var appName = "Handsfree";
        if (!isShowingCallStateOnGlanceEnabled()) {
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() / 2,
                Toybox.Graphics.FONT_SYSTEM_MEDIUM,
                appName + "\n" + headsetStatusForWidget(),
                Toybox.Graphics.TEXT_JUSTIFY_CENTER | Toybox.Graphics.TEXT_JUSTIFY_VCENTER
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
                dc.getWidth() / 2,
                dc.getHeight() / 2,
                Toybox.Graphics.FONT_SYSTEM_MEDIUM,
                title + "\n" + subtitle + "\n" + headsetStatusForWidget(),
                Toybox.Graphics.TEXT_JUSTIFY_CENTER | Toybox.Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
    }
}

function headsetStatusForWidget() as Lang.String {
    if (!getIsHeadsetConnected()) {
        return "(no headset)";
    } else {
        return "";
    }
}