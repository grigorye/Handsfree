using Toybox.Lang;

class CallInProgress extends CallStateImp {
    var phone as Phone;
    
    function initialize(phone as Phone) {
        CallStateImp.initialize();
        self.phone = phone;
    }

    function dumpRep() as Lang.String {
        return "CallInProgress(" + phone["number"] + ")";
    }
}
