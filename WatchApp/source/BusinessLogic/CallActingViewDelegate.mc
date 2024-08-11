using Toybox.WatchUi;

class CallActingViewDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        WatchUi.BehaviorDelegate.initialize();
    }

    function onBack() {
        trackBackFromView();
        var callState = getCallState();
        _([L_USER_ACTION, "callActing.onBack.callState", callState]);
        if (!(callState instanceof CallActing)) {
            System.error("badCallState: " + callState);
        }
        setCallStateIgnoringRouting(new Idle());
        return true;
    }
}
