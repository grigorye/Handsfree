using Toybox.Communications;

class HangupCommListener extends Communications.ConnectionListener {
    function initialize() {
        Communications.ConnectionListener.initialize();
    }

    function onComplete() {
        var oldState = getCallState() as HangingUp;
        if (!(oldState instanceof HangingUp)) {
            crash();
            return;
        }
        var newState = oldState.clone();
        newState.commStatus = SUCCEEDED;
        setCallState(newState);
    }

    function onError() {
        var oldState = getCallState() as HangingUp;
        if (!(oldState instanceof HangingUp)) {
            crash();
            return;
        }
        var newState = oldState.clone();
        newState.commStatus = FAILED;
        setCallState(newState);
    }
}
