using Toybox.Communications;
using Toybox.Timer;
using Toybox.Lang;

class HangupCommTask extends Communications.ConnectionListener {
    var attemptsRemaining as Lang.Number = 3;
    var phone as Phone;
    var retransmitDelay as Lang.Number = 500;
    var retransmitTimer as Timer.Timer or Null = null;

    function initialize(phone as Phone) {
        Communications.ConnectionListener.initialize();
        self.phone = phone;
    }

    function launch() as Void {
        dump("Hangup.launch", true);
        transmit();
    }

    function transmit() as Void {
        var cmd;
        if (isIncomingCallPhone(phone)) {
            cmd = "accept";
        } else {
            cmd = "hangup";
        }
        var msg = {
            "cmd" => cmd
        };
        dump("HangUp.outMsg", msg);
        setCallState(new HangingUp(phone, PENDING));
        Communications.transmit(msg, null, self);
    }

    function onComplete() {
        var oldState = getCallState() as HangingUp;
        if (!(oldState instanceof HangingUp)) {
            // We may already go back, and hence change the call state to Idle.
            dumpCallState("Hangup.onComplete.callStateInvalidated", oldState);
            return;
        }
        dump("Hangup.onComplete", true);
        var newState = oldState.clone();
        newState.commStatus = SUCCEEDED;
        setCallState(newState);
    }

    function onError() {
        var oldState = getCallState() as HangingUp;
        if (!(oldState instanceof HangingUp)) {
            // We may already go back, and hence change the call state to Idle.
            dumpCallState("Hangup.onError.callStateInvalidated", oldState);
            return;
        }
        if (attemptsRemaining > 0) {
            dump("Hangup.attemptsRemainingOnError", attemptsRemaining);
            attemptsRemaining = attemptsRemaining - 1;
            var timer = new Timer.Timer();
            retransmitTimer = timer;
            retransmitTimer.start(method(:transmit), retransmitDelay, false);
            return;
        }
        dump("Hangup.onError", true);
        var newState = oldState.clone();
        newState.commStatus = FAILED;
        setCallState(newState);
    }
}
