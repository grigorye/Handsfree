using Toybox.Lang;


(:background, :glance)
class HangingUp extends CallActing {
    function initialize(phone as Phone, commStatus as CommStatus) {
        CallActing.initialize(phone, commStatus);
    }

    function clone() as CallActing {
        return new HangingUp(phone, commStatus);
    }

    function className() as Lang.String {
        return "HangingUp";
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

    function className() as Lang.String {
        return "Declining";
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

    function className() as Lang.String {
        return "Accepting";
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

    function className() as Lang.String {
        return "CallActing";
    }

    function toString() as Lang.String {
        return className() + "(" + { "phone" => phone, "commStatus" => commStatus } + ")";
    }
}
