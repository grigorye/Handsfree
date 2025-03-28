import Toybox.WatchUi;

class SchedulingCallViewDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() {
        VT.trackBackFromView();
        var callState = getCallState();
        if (debug) { _3(L_USER_ACTION, "schedulingCall.onBack.callState", callState); }
        if (!(callState instanceof SchedulingCall)) {
            System.error("badCallState: " + callState);
        }
        setCallStateIgnoringRouting(new Idle());
        return true;
    }
}
