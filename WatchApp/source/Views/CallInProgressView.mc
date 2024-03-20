using Toybox.WatchUi;
using Toybox.Graphics;

class CallInProgressView extends Toybox.WatchUi.Confirmation {
    function initialize(phone as Phone) {
        var name = phone["name"];
        var number = phone["number"];
        var prefix;
        if (name != null) {
            prefix = name + "\n";
        } else if (number != null) {
            prefix = number + "\n";
        } else {
            prefix = "<Unreadable>" + "\n";
        }
        var message = prefix + "Hang up?";
        Confirmation.initialize(message);
    }
}
