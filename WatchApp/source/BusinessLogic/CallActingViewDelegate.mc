import Toybox.WatchUi;

class CallActingViewDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() {
        VT.trackBackFromView();
        var callState = getCallState();
        if (debug) { _3(L_USER_ACTION, "callActing.onBack.callState", callState); }
        if (!(callState instanceof CallActing)) {
            System.error("badCallState: " + callState);
        }
        setCallStateIgnoringRouting(new Idle());
        return true;
    }
}
