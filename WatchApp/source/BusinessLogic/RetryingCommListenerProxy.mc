using Toybox.Communications;
using Toybox.Timer;
using Toybox.Lang;
using Toybox.Application;

function transmitWithRetry(tag as Lang.String, msg as Application.PersistableType, listener as Communications.ConnectionListener) as Void {
    var proxy = new RetryingCommListenerProxy(tag, msg, listener);
    proxy.launch();
}

class RetryingCommListenerProxy extends Communications.ConnectionListener {
    var tag as Lang.String;
    var msg as Application.PersistableType;
    var attemptsRemaining as Lang.Number = 3;
    var attemptNumber as Lang.Number = 0;
    var wrappedListener as Communications.ConnectionListener;
    var retransmitDelay as Lang.Number = 500;
    var retransmitTimer as Timer.Timer or Null = null;

    function initialize(tag as Lang.String, msg as Application.PersistableType, wrappedListener as Communications.ConnectionListener) {
        Communications.ConnectionListener.initialize();
        self.tag = tag;
        self.msg = msg;
        self.wrappedListener = wrappedListener;
    }

    function formatTag(suffix as Lang.String) as Lang.String {
        return tag + "." + suffix;
    }

    function launch() as Void {
        dump(formatTag("launch"), true);
        transmit();
    }

    function transmit() as Void {
        attemptNumber = attemptNumber + 1;
        dump(formatTag("transmit"), {"attempt" => attemptNumber, "msg" => msg});
        Communications.transmit(msg, null, self);
    }

    function onComplete() {
        dump(formatTag("onComplete.attempt"), attemptNumber);
        wrappedListener.onComplete();
    }

    function onError() {
        dump(formatTag("onError.attempt"), attemptNumber);
        dump(formatTag("onError.attemptsRemaining"), attemptsRemaining);
        if (attemptsRemaining > 0) {
            attemptsRemaining = attemptsRemaining - 1;
            var timer = new Timer.Timer();
            retransmitTimer = timer;
            retransmitTimer.start(method(:transmit), retransmitDelay, false);
            return;
        }
        wrappedListener.onError();
    }
}
