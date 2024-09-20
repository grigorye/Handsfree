using Toybox.Lang;

(:background, :glance)
class CallInProgress extends CallStateImp {
    var phone as Phone;
    
    function initialize(phone as Phone) {
        CallStateImp.initialize();
        self.phone = phone;
    }

    function toString() as Lang.String {
        var optimisticElement;
        if (optimistic) {
            optimisticElement = ", optimistic";
        } else {
            optimisticElement = "";
        }
        return "CallInProgress(" + phone + optimisticElement + ")";
    }
}
