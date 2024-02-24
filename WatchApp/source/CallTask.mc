using Toybox.Communications;

class CallTask {
    var phone as Phone;
    var timer = new Timer.Timer();
    var listener as CallTaskCommListener;

    function initialize(phone as Phone) {
        self.phone = phone;
        self.listener = new CallTaskCommListener(phone);
    }

    function transmit() {
        var msg = {
            "cmd" => "call",
            "args" => {
                "number" => phone["number"]
            }
        };
        dump("outMsg", msg);
        Communications.transmit(msg, null, listener);
    }

    function launch() {
        listener.onStart();
        timer.start(method(:transmit), 50, false);
    }
}