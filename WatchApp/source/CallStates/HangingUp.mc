using Toybox.Lang;

(:background, :glance)
class HangingUp extends CallStateImp {
    var commStatus as CommStatus;
    var phone as Phone;
    
    function initialize(phone as Phone, commStatus as CommStatus) {
        CallStateImp.initialize();
        self.commStatus = commStatus;
        self.phone = phone;
    }

    function clone() as HangingUp {
        return new HangingUp(phone, commStatus);
    }

    function dumpRep() as Lang.String {
        return "HangingUp(" + { "phone" => phone, "commStatus" => commStatus } + ")";
    }
}
