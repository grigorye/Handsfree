using Toybox.WatchUi;

class CallActingViewDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        WatchUi.BehaviorDelegate.initialize();
    }

    function onBack() {
        trackBackFromView();
        var callState = getCallState();
        dumpCallState("onBackFromCallActing", callState);
        if (!(callState instanceof CallActing)) {
            dumpCallState("badCallState", callState);
            System.error("badCallState");
        }
        setCallStateIgnoringRouting(new Idle());
        return true;
    }
}
