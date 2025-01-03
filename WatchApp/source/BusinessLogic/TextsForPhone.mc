import Toybox.Lang;

function displayTextForPhone(phone as Phone) as Lang.String {
    var name = phone[PhoneField.name] as Lang.String or Null;
    var number = phone[PhoneField.number] as Lang.String or Null;
    var isIncomingCall = isIncomingCallPhone(phone);
    var text;
    if (name != null) {
        text = name;
    } else if (number != null) {
        text = number;
    } else {
        if (isIncomingCall) {
            text = "Incoming Call";
        } else {
            text = "Call in Progress";
        }
    }
    return text;
}

(:glance)
function getPhoneRep(phone as Phone) as Lang.String or Null {
    var phoneName = phone[PhoneField.name] as Lang.String or Null;
    var number = phone[PhoneField.number] as Lang.String or Null;
    var rep;
    if (phoneName != null && !phoneName.equals("")) {
        rep = phoneName;
    } else if (number != null) {
        rep = number;
    } else {
        rep = null;
    }
    return rep;
}
