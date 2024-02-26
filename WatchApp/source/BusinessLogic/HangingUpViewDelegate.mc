using Toybox.WatchUi;
class HangingUpViewDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        WatchUi.BehaviorDelegate.initialize();
    }

    function onBack() {
        var callState = getCallState();
        dumpCallState("onBackFromHangingUp", callState);
        if (!(callState instanceof HangingUp)) {
            dumpCallState("badCallState", callState);
            fatalError("badCallState");
            return false;
        }
        setCallStateIgnoringRouting(new Idle());
        return true;
    }
}
