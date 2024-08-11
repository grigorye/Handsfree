using Toybox.Lang;

function displayTextForPhone(phone as Phone) as Lang.String {
    var name = phone["name"] as Lang.String or Null;
    var number = phone["number"] as Lang.String or Null;
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