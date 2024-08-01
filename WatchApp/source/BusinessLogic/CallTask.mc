using Toybox.Communications;

class CallTask {
    var phone as Phone;

    function initialize(phone as Phone) {
        self.phone = phone;
    }

    function transmit() as Void {
        var msg = {
            "cmd" => "call",
            "args" => {
                "number" => phone["number"]
            }
        };
        dump("outMsg", msg);
        transmitWithRetry("call", msg, new CallTaskCommListener(phone));
    }

    function launch() as Void {
        setCallState(new SchedulingCall(phone, PENDING));
        transmit();
    }
}
