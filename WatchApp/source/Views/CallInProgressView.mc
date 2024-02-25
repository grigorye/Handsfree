using Toybox.WatchUi;
using Toybox.Graphics;

class CallInProgressView extends Toybox.WatchUi.Confirmation {
    function initialize(phone as Phone) {
        var name = phone["name"];
        var message;
        if (name == null) {
            message = phone["number"] + "\n" + "Keep call?";
        } else {
            message = name + "\n" + "Keep call?";
        }
        Confirmation.initialize(message);
    }
}
