using Toybox.Lang;

class DismissedCallInProgress extends CallStateImp {
    var phone as Phone;
    
    function initialize(phone as Phone) {
        CallStateImp.initialize();
        self.phone = phone;
    }

    function dumpRep() as Lang.String {
        return "DismissedCallInProgress(" + phone["number"] + ")";
    }
}
