import Toybox.Lang;

(:background, :glance)
class DismissedCallInProgress extends CallStateImp {
    var phone as Phone;
    
    function initialize(phone as Phone) {
        CallStateImp.initialize();
        self.phone = phone;
    }

    function toString() as Lang.String {
        return "DismissedCallInProgress(" + phone[PhoneField_number] + ")";
    }
}
