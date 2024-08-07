using Toybox.Communications;
using Toybox.Timer;
using Toybox.Lang;
using Toybox.Application;
using Toybox.System;

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
        if (isBeepOnCommuncationEnabled()) {
            beep(BEEP_TYPE_BEEP);
        }
        attemptNumber = attemptNumber + 1;
        attemptsRemaining = attemptsRemaining - 1;
        dump(formatTag("transmit"), {"attempt" => attemptNumber, "msg" => msg});
        Communications.transmit(msg, null, self);
    }

    function onComplete() {
        if (isBeepOnCommuncationEnabled()) {
            beep(BEEP_TYPE_SUCCESS);
        }
        dump(formatTag("onComplete.attempt"), attemptNumber);
        wrappedListener.onComplete();
    }

    function onError() {
        dump(formatTag("onError.connectionAvailable"), System.getDeviceSettings().connectionAvailable);
        dump(formatTag("onError.connectionInfo"), dumpConnectionInfos(System.getDeviceSettings().connectionInfo));
        if (isBeepOnCommuncationEnabled()) {
            beep(BEEP_TYPE_ERROR);
        }
        dump(formatTag("onError.attempt"), attemptNumber);
        dump(formatTag("onError.attemptsRemaining"), attemptsRemaining);
        if (retransmitTimer != null) {
            retransmitTimer.stop();
        }
        if (attemptsRemaining > 0) {
            if (retransmitTimer == null) {
                retransmitTimer = new Timer.Timer();
            }
            (retransmitTimer as Timer.Timer).start(method(:transmit), retransmitDelay, false);
            return;
        }
        wrappedListener.onError();
    }
}

function dumpConnectionInfos(connectionInfos as Lang.Dictionary<Lang.Symbol, System.ConnectionInfo>) as Lang.Object {
    var result = {} as Lang.Dictionary<Lang.String, Lang.Object>;
    var wifi = connectionInfos[:wifi];
    if (wifi != null) {
        result["wifi"] = dumpConnectionInfo(wifi);
    }
    var lte = connectionInfos[:lte];
    if (lte != null) {
        result["lte"] = dumpConnectionInfo(lte);
    }
    var bluetooth = connectionInfos[:bluetooth];
    if (bluetooth != null) {
        result["bluetooth"] = dumpConnectionInfo(bluetooth);
    }
    return result;
}

function dumpConnectionInfo(connectionInfo as System.ConnectionInfo) as Lang.Object {
    switch (connectionInfo.state) {
        case System.CONNECTION_STATE_NOT_INITIALIZED: {
            return "NOT_INITIALIZED";
        }
        case System.CONNECTION_STATE_NOT_CONNECTED: {
            return "NOT_CONNECTED";
        }
        case System.CONNECTION_STATE_CONNECTED: {
            return "CONNECTED";
        }
        default:
            System.error("unknownConnectionState: " + connectionInfo.state);
    }
}