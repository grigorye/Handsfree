using Toybox.WatchUi;
class HangingUpViewDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        WatchUi.BehaviorDelegate.initialize();
    }

    function onBack() {
        var callState = getCallState();
        if (!(callState instanceof HangingUp)) {
            dumpCallState("badCallState", callState);
            fatalError("badCallState");
            return false;
        }
        setCallState(new Idle());
        return true;
    }
}
