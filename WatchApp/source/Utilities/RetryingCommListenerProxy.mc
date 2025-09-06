import Toybox.Communications;
import Toybox.Timer;
import Toybox.Lang;
import Toybox.Application;
import Toybox.System;

const L_OUT_RETRYING as LogComponent = ">";

(:background, :glance)
const LX_OUT_COMM as LogComponent = ">";

module Req {

(:background, :glance, :lowMemory)
function transmitWithoutRetry(tagLiteral as Lang.String, msg as Lang.Object) as Void {
    var tag = formatCommTag(tagLiteral);
    if (memDebug) { dumpF(L_APP, "transmitWithoutRetry.preTransmit"); }
    Communications.transmit(msg as Application.PersistableType, null, new DummyCommListener(tag));
}

(:background, :glance, :noLowMemory)
function transmitWithoutRetry(tagLiteral as Lang.String, msg as Lang.Object) as Void {
    var tag = formatCommTag(tagLiteral);
    if (minDebug) { _3(LX_OUT_COMM, tag + ".requesting", msg); }
    Communications.transmit(msg as Application.PersistableType, null, new DummyCommListener(tag));
}

function transmitWithRetry(tagLiteral as Lang.String, msg as Lang.Object, listener as Communications.ConnectionListener) as Void {
    var tag = formatCommTag(tagLiteral);
    var proxy = new RetryingCommListenerProxy(tag, msg as Application.PersistableType, listener);
    proxy.launch();
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
        ConnectionListener.initialize();
        self.tag = tag;
        self.msg = msg;
        self.wrappedListener = wrappedListener;
    }

    function launch() as Void {
        if (minDebug) { _3(LX_OUT_COMM, tag + ".requesting", msg); }
        transmit();
    }

    function transmit() as Void {
        if (debug) { beep(BEEP_TYPE_BEEP); }
        attemptNumber = attemptNumber + 1;
        attemptsRemaining = attemptsRemaining - 1;
        if (debug) { _2(L_OUT_RETRYING, tag + ".attempt." + attemptNumber); }
        Communications.transmit(msg, null, self);
    }

    function onComplete() {
        if (debug) { beep(BEEP_TYPE_SUCCESS); }
        if (minDebug) {
            var attemptsSuffix;
            if (attemptNumber > 1) {
                attemptsSuffix = "(attempts: " + attemptNumber + ")";
            } else {
                attemptsSuffix = "";
            }
            _2(LX_OUT_COMM, tag + ".succeeded" + attemptsSuffix);
        }
        wrappedListener.onComplete();
    }

    function onError() {
        if (debug) { _3(L_OUT_RETRYING, tag + ".onError.connectionAvailable", System.getDeviceSettings().connectionAvailable); }
        if (debug) { _3(L_OUT_RETRYING, tag + ".onError.connectionInfo", dumpConnectionInfos(System.getDeviceSettings().connectionInfo)); }
        if (debug) { beep(BEEP_TYPE_ERROR); }
        if (debug) { _3(L_OUT_RETRYING, tag + ".onError.attempt", attemptNumber); }
        if (debug) { _3(L_OUT_RETRYING, tag + ".onError.attemptsRemaining", attemptsRemaining); }
        if (retransmitTimer != null) {
            retransmitTimer.stop();
        }
        if (attemptsRemaining > 0) {
            var timer;
            if (retransmitTimer != null) {
                timer = retransmitTimer;
            } else {
                timer = new Timer.Timer();
                retransmitTimer = timer;
            }
            timer.start(method(:transmit), retransmitDelay, false);
            return;
        }
        if (minDebug) { _2(LX_OUT_COMM, tag + ".failed"); }
        wrappedListener.onError();
    }
}

(:lowMemory)
function dumpConnectionInfos(connectionInfos as Lang.Dictionary<Lang.Symbol, System.ConnectionInfo>) as Lang.Object {
    return "";
}

(:noLowMemory)
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

(:noLowMemory)
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
            if (errorDebug) {
                System.error("unknownConnectionState: " + connectionInfo.state);
            } else {
                System.error("");
            }
    }
}

}