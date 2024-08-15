using Toybox.Communications;
using Toybox.Timer;
using Toybox.Lang;
using Toybox.Application;
using Toybox.System;

const L_OUT_RETRYING as LogComponent = ">";

(:background)
const L_OUT_COMM as LogComponent = ">";

function transmitWithRetry(tagLiteral as Lang.String, msg as Application.PersistableType, listener as Communications.ConnectionListener) as Void {
    var tag = formatCommTag(tagLiteral);
    var proxy = new RetryingCommListenerProxy(tag, msg, listener);
    proxy.launch();
}

(:background)
function formatCommTag(tag as Lang.String) as Lang.String {
    return "'" + tag + "'";
}

class RetryingCommListenerProxy extends Communications.ConnectionListener {
    private var tag as Lang.String;
    private var msg as Application.PersistableType;
    private var attemptsRemaining as Lang.Number = 3;
    private var attemptNumber as Lang.Number = 0;
    private var wrappedListener as Communications.ConnectionListener;
    private var retransmitDelay as Lang.Number = 500;
    private var retransmitTimer as Timer.Timer or Null = null;

    function initialize(tag as Lang.String, msg as Application.PersistableType, wrappedListener as Communications.ConnectionListener) {
        Communications.ConnectionListener.initialize();
        self.tag = tag;
        self.msg = msg;
        self.wrappedListener = wrappedListener;
    }

    function launch() as Void {
        _3(L_OUT_COMM, tag + ".requesting", msg);
        transmit();
    }

    function transmit() as Void {
        beep(BEEP_TYPE_BEEP);
        attemptNumber = attemptNumber + 1;
        attemptsRemaining = attemptsRemaining - 1;
        _2(L_OUT_RETRYING, tag + ".attempt." + attemptNumber);
        Communications.transmit(msg, null, self);
    }

    function onComplete() {
        beep(BEEP_TYPE_SUCCESS);
        var attemptsSuffix;
        if (attemptNumber > 1) {
            attemptsSuffix = "(attempts: " + attemptNumber + ")";
        } else {
            attemptsSuffix = "";
        }
        _2(L_OUT_COMM, tag + ".succeeded" + attemptsSuffix);
        wrappedListener.onComplete();
    }

    function onError() {
        _3(L_OUT_RETRYING, tag + ".onError.connectionAvailable", System.getDeviceSettings().connectionAvailable);
        _3(L_OUT_RETRYING, tag + ".onError.connectionInfo", dumpConnectionInfos(System.getDeviceSettings().connectionInfo));
        beep(BEEP_TYPE_ERROR);
        _3(L_OUT_RETRYING, tag + ".onError.attempt", attemptNumber);
        _3(L_OUT_RETRYING, tag + ".onError.attemptsRemaining", attemptsRemaining);
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
        _2(L_OUT_COMM, tag + ".failed");
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