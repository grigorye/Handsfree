using Toybox.WatchUi;
using Toybox.Graphics;

class CallInProgressView extends Toybox.WatchUi.Confirmation {
    function initialize(phone as Phone) {
        var name = phone["name"];
        var message;
        if (name == null) {
            message = phone["number"] + "\n" + "Hang up?";
        } else {
            message = name + "\n" + "Hang up?";
        }
        Confirmation.initialize(message);
    }
}
