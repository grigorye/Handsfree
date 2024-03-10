using Toybox.Lang;

(:background, :glance)
class Ringing extends CallStateImp {
    var phone as Phone;

    function initialize(phone as Phone) {
        CallStateImp.initialize();
        self.phone = phone;
    }

    function dumpRep() as Lang.String {
        return "Ringing(" + phone["number"] + ")";
    }
}
