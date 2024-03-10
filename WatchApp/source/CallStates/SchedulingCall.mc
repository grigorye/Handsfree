using Toybox.Lang;

(:background, :glance)
class SchedulingCall extends CallStateImp {
    var phone as Phone;
    var commStatus as CommStatus;
    
    function initialize(phone as Phone, commStatus as CommStatus) {
        CallStateImp.initialize();
        self.phone = phone;
        self.commStatus = commStatus;
    }

    function clone() as SchedulingCall {
        return new SchedulingCall(phone, commStatus);
    }

    function dumpRep() as Lang.String {
        return "SchedulingCall(" + phone + ", " + commStatus + ")";
    }
}
