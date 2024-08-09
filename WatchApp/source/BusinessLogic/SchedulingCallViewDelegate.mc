using Toybox.WatchUi;

class SchedulingCallViewDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        WatchUi.BehaviorDelegate.initialize();
    }

    function onBack() {
        trackBackFromView();
        var callState = getCallState();
        dump("onBackFromSchedulingCall", callState);
        if (!(callState instanceof SchedulingCall)) {
            dump("badCallState", callState);
            System.error("badCallState");
        }
        setCallStateIgnoringRouting(new Idle());
        return true;
    }
}
