using Toybox.WatchUi;
class HangingUpViewDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        WatchUi.BehaviorDelegate.initialize();
    }

    function onBack() {
        trackBackFromView();
        var callState = getCallState();
        dumpCallState("onBackFromHangingUp", callState);
        if (!(callState instanceof HangingUp)) {
            dumpCallState("badCallState", callState);
            System.error("badCallState");
        }
        setCallStateIgnoringRouting(new Idle());
        return true;
    }
}
