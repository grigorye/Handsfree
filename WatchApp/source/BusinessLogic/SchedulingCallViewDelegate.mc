using Toybox.WatchUi;

class SchedulingCallViewDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        WatchUi.BehaviorDelegate.initialize();
    }

    function onBack() {
        trackBackFromView();
        var callState = getCallState();
        _([L_USER_ACTION, "schedulingCall.onBack.callState", callState]);
        if (!(callState instanceof SchedulingCall)) {
            System.error("badCallState: " + callState);
        }
        setCallStateIgnoringRouting(new Idle());
        return true;
    }
}
