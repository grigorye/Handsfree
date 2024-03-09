using Toybox.WatchUi;

class SchedulingCallViewDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        WatchUi.BehaviorDelegate.initialize();
    }

    function onBack() {
        var callState = getCallState();
        dumpCallState("onBackFromSchedulingCall", callState);
        if (!(callState instanceof SchedulingCall)) {
            dumpCallState("badCallState", callState);
            System.error("badCallState");
        }
        setCallStateIgnoringRouting(new Idle());
        return true;
    }
}
