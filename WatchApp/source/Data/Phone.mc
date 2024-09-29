import Toybox.Lang;

typedef Phone as Lang.Dictionary<Lang.String, Lang.String or Lang.Number or Lang.Boolean>;
typedef Phones as Lang.Array<Phone>;

(:background)
function setPhoneName(phone as Phone, name as Lang.String) as Void {
    phone["name"] = name;
}

function getPhoneName(phone as Phone) as Lang.String {
    return phone["name"] as Lang.String;
}

function getPhoneId(phone as Phone) as Lang.String {
    return phone["id"] as Lang.String;
}

(:background)
function getPhoneNumber(phone as Phone) as Lang.String or Null {
    return phone["number"] as Lang.String or Null;
}

function dropRingingFromPhone(phone as Phone) as Void {
    phone["ringing"] = false;
}

(:background, :glance)
function isIncomingCallPhone(phone as Phone) as Lang.Boolean {
    var ringing = phone["ringing"] as Lang.Boolean or Null;
    var isIncoming = (ringing != null) && (ringing as Lang.Boolean);
    return isIncoming;
}