using Toybox.Lang;


(:background, :glance)
class HangingUp extends CallActing {
    function initialize(phone as Phone, commStatus as CommStatus) {
        CallActing.initialize(phone, commStatus);
    }

    function clone() as CallActing {
        return new HangingUp(phone, commStatus);
    }

    function stateId() as Lang.String {
        return "hangingUp";
    }
}

(:background, :glance)
class Declining extends CallActing {
    function initialize(phone as Phone, commStatus as CommStatus) {
        CallActing.initialize(phone, commStatus);
    }

    function clone() as CallActing {
        return new Declining(phone, commStatus);
    }

    function stateId() as Lang.String {
        return "declining";
    }
}

(:background, :glance)
class Accepting extends CallActing {
    function initialize(phone as Phone, commStatus as CommStatus) {
        CallActing.initialize(phone, commStatus);
    }

    function clone() as CallActing {
        return new Accepting(phone, commStatus);
    }

    function stateId() as Lang.String {
        return "accepting";
    }
}

(:background, :glance)
class CallActing extends CallStateImp {
    var commStatus as CommStatus;
    var phone as Phone;
    
    function initialize(phone as Phone, commStatus as CommStatus) {
        CallStateImp.initialize();
        self.commStatus = commStatus;
        self.phone = phone;
    }

    function clone() as CallActing {
        return new CallActing(phone, commStatus);
    }

    function stateId() as Lang.String {
        // Align with CallStateEncoding.mc.
        return "";
    }

    function toString() as Lang.String {
        return stateId() + "(" + { "phone" => phone, "commStatus" => commStatus } + ")";
    }
}
