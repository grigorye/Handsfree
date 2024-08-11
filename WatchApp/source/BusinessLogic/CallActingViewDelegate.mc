using Toybox.WatchUi;

class CallActingViewDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        WatchUi.BehaviorDelegate.initialize();
    }

    function onBack() {
        trackBackFromView();
        var callState = getCallState();
        dump("onBackFromCallActing", callState);
        if (!(callState instanceof CallActing)) {
            System.error("badCallState: " + callState);
        }
        setCallStateIgnoringRouting(new Idle());
        return true;
    }
}
