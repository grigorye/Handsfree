using Toybox.WatchUi;
using Toybox.Lang;

class CallInProgressView extends Toybox.WatchUi.Confirmation {
    function initialize(phone as Phone) {
        var texts = textsForCallInProgress(phone);
        var actions = texts[:actions] as CallInProgressActions;
        var message = texts[:title] + "\n" + actions[0][:prompt] + "?";
        Confirmation.initialize(message);
    }
}
