using Toybox.WatchUi;
using Toybox.Lang;

class SchedulingCallViewEdge extends WatchUi.View {
    var message as Lang.String;

    function onUpdate(dc) {
        dc.setColor(Toybox.Graphics.COLOR_WHITE, Toybox.Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            0,
            dc.getHeight() / 2,
            Toybox.Graphics.FONT_SYSTEM_MEDIUM,
            message,
            Toybox.Graphics.TEXT_JUSTIFY_LEFT | Toybox.Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function initialize(callState as SchedulingCall) {
        View.initialize();

        var commStatus = callState.commStatus;
        dump("commStatus", commStatus);
        var destination;
        var name = callState.phone["name"] as Lang.String or Null;
        if (name != null && !name.equals("")) {
            destination = name;
        } else {
            destination = callState.phone["number"];
        }
        switch (callState.commStatus) {
            case PENDING:
                message = "Pending" + "\n" + destination;
                break;
            case SUCCEEDED:
                message = "Calling" + "\n" + destination;
                break;
            case FAILED:
                message = "Companion app\ndid not respond";
                break;
            default:
                System.error("Unknown commStatus");
        }
    }
}

class SchedulingCallView extends WatchUi.ProgressBar {
    function initialize(callState as SchedulingCall) {
        var commStatus = callState.commStatus;
        dump("commStatus", commStatus);
        var message = "";
        var destination;
        var name = callState.phone["name"] as Lang.String or Null;
        if (name != null && !name.equals("")) {
            destination = name;
        } else {
            destination = callState.phone["number"];
        }
        switch (callState.commStatus) {
            case PENDING:
                message = "Pending" + "\n" + destination;
                break;
            case SUCCEEDED:
                message = "Calling" + "\n" + destination;
                break;
            case FAILED:
                message = "Companion app\ndid not respond";
                break;
            default:
                System.error("Unknown commStatus");
        }
        WatchUi.ProgressBar.initialize(message, 0.0);
    }
}
