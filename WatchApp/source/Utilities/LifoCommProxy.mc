import Toybox.Communications;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Timer;

const simulatedCommDelay = false ? 2000 : 0;

class LifoCommProxy extends Communications.ConnectionListener {
    private var tag as Lang.String | Null;
    private var msg as Application.PersistableType | Null;
    private var queuedTag as Lang.String | Null;
    private var queuedMsg as Application.PersistableType | Null;
    private var wrappedListener as Communications.ConnectionListener;
    private var simDelayTimer as Timer.Timer | Null;
    private var followUpTimer as Timer.Timer | Null;

    function initialize(wrappedListener as Communications.ConnectionListener) {
        ConnectionListener.initialize();
        self.wrappedListener = wrappedListener;
    }

    function send(tag as Lang.String, msg as Application.PersistableType) as Void {
        if (self.msg == null) {
            self.msg = msg;
            self.tag = tag;
            transmit();
        } else {
            if (minDebug) {
                 if (self.queuedTag != null) {
                    _2(LX_OUT_COMM, self.queuedTag + ".dropping");
                 }
                _3(LX_OUT_COMM, tag + ".queueing", msg);
            }
            self.queuedMsg = msg;
            self.queuedTag = tag;
        }
    }

    function transmit() as Void {
        if (debug) { beep(BEEP_TYPE_BEEP); }
        if (minDebug) { _3(L_OUT_RETRYING, tag + ".transmit", msg); }
        Communications.transmit(msg, null, self);
    }

    function onComplete() as Void {
        if (!simDelay(method(:onCompleteWithSimDelay))) {
            onCompleteImp();
        }
    }
    
    function onCompleteWithSimDelay() as Void {
        simDelayTimer = null;
        onCompleteImp();
    }

    function onCompleteImp() as Void {
        if (debug) { beep(BEEP_TYPE_SUCCESS); }
        if (minDebug) { _2(LX_OUT_COMM, tag + ".succeeded"); }
        wrappedListener.onComplete();
        followUp();
    }

    function onError() as Void {
        if (!simDelay(method(:onErrorWithSimDelay))) {
            onErrorImp();
        }
    }
    
    function onErrorWithSimDelay() as Void {
        simDelayTimer = null;
        onErrorImp();
    }

    function onErrorImp() as Void {
        if (debug) { beep(BEEP_TYPE_ERROR); }
        if (minDebug) { _2(LX_OUT_COMM, tag + ".failed"); }
        wrappedListener.onError();
        followUp();
    }

    function simDelay(method as Method() as Void) as Lang.Boolean {
        if (simulatedCommDelay <= 0) {
            return false;
        }
        if (simDelayTimer != null) {
            System.error("simDelayTimerIsNotNull");
        }
        var timer = new Timer.Timer();
        simDelayTimer = timer;
        timer.start(method, simulatedCommDelay, false);
        return true;
    }

    function followUp() as Void {
        msg = null;
        tag = null;
        if (queuedMsg != null) {
            if (followUpTimer != null) {
                followUpTimer.stop();
            }
            var timer = new Timer.Timer();
            followUpTimer = timer;
            timer.start(method(:transmitNext), AppSettings.followUpCommDelay, false);
        } else {
            if (minDebug) { _2(LX_OUT_COMM, "queueIsEmpty"); }
        }
    }

    function transmitNext() as Void {
        msg = queuedMsg;
        tag = queuedTag;
        if (minDebug) { _2(LX_OUT_COMM, tag + ".followingUp"); }
        queuedMsg = null;
        queuedTag = null;
        transmit();
    }
}
