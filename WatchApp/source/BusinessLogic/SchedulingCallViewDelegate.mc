using Toybox.WatchUi;

class SchedulingCallViewDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        WatchUi.BehaviorDelegate.initialize();
    }

    function onBack() {
        var callState = getCallState();
        if (!(callState instanceof SchedulingCall)) {
            dumpCallState("badCallState", callState);
            fatalError("badCallState");
            return false;
        }
        setCallState(new Idle());
        return true;
    }
}
