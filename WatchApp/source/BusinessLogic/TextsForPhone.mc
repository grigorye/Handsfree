import Toybox.Lang;

function displayTextForPhone(phone as Phone) as Lang.String {
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
            text = "Incoming Call";
        } else {
            text = "In Progress";
        }
    }
    return text;
}

(:glance)
function getPhoneRep(phone as Phone) as Lang.String or Null {
    var phoneName = phone[PhoneField_name] as Lang.String or Null;
    var number = phone[PhoneField_number] as Lang.String or Null;
    var rep;
    if (phoneName != null && !phoneName.equals("")) {
        rep = phoneName;
    } else if (number == null) {
        rep = null;
    } else if (number.equals("")) {
        rep = "Private Number";
    } else {
        rep = number;
    }
    return rep;
}
