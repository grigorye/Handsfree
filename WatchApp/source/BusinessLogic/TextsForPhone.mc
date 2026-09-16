import Toybox.Lang;
import Toybox.WatchUi;

function displayTextForPhone(phone as Phone) as StringOrResource {
    var name = phone[PhoneField_name] as Lang.String or Null;
    var number = phone[PhoneField_number] as Lang.String or Null;
    var isIncomingCall = isIncomingCallPhone(phone);
    var text;
    if (name != null && !name.equals("")) {
        text = name;
    } else if (number != null) {
        text = number;
    } else {
        if (isIncomingCall) {
            text = Rez.Strings.glanceIncomingCall;
        } else {
            text = Rez.Strings.glanceInProgress;
        }
    }
    return text;
}

(:glance)
function getPhoneRep(phone as Phone) as StringOrResource | Null {
    var phoneName = phone[PhoneField_name] as Lang.String or Null;
    var number = phone[PhoneField_number] as Lang.String or Null;
    var rep;
    if (phoneName != null && !phoneName.equals("")) {
        rep = phoneName;
    } else if (number == null) {
        rep = null;
    } else if (number.equals("")) {
        rep = Rez.Strings.glanceInProgress;
    } else {
        rep = number;
    }
    return rep;
}
