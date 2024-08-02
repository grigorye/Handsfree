using Toybox.Lang;

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

    function dumpRep() as Lang.String {
        return "CallActing(" + { "phone" => phone, "commStatus" => commStatus } + ")";
    }
}
