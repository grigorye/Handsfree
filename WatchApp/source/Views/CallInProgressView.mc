using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Lang;

class CallInProgressView extends Toybox.WatchUi.Confirmation {
    function initialize(phone as Phone) {
        var name = phone["name"];
        var number = phone["number"];
        var isIncomingCall = isIncomingCallPhone(phone);

        var prefix;
        if (name != null) {
            prefix = name + "\n";
        } else if (number != null) {
            prefix = number + "\n";
        } else {
            if (isIncomingCall) {
                prefix = "Incoming call." + "\n";
            } else {
                prefix = "Call in progress." + "\n";
            }
        }
        var message;
        if (isIncomingCall) {
            message = prefix + "Accept?";
        } else {    
            message = prefix + "Hang up?";
        }
        Confirmation.initialize(message);
    }
}
