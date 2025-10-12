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
            if (errorDebug) {
                _3(L_APP, "schedulingCall.onBack.badCallState", callState);
            }
            return true;
        }
        setCallStateIgnoringRouting(new Idle());
        return true;
    }
}
