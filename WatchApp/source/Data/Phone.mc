using Toybox.Lang;

typedef Phone as Lang.Dictionary<Lang.String, Lang.String or Lang.Number or Lang.Boolean>;
typedef Phones as Lang.Array<Phone>;

(:background)
function setPhoneName(phone as Phone, name as Lang.String) as Void {
    phone["name"] = name;
}

function getPhoneName(phone as Phone) as Lang.String {
    return phone["name"] as Lang.String;
}

function getPhoneId(phone as Phone) as Lang.Number {
    return phone["id"] as Lang.Number;
}

function getPhoneNumber(phone as Phone) as Lang.String or Null {
    return phone["number"] as Lang.String or Null;
}

function dropRingingFromPhone(phone as Phone) as Void {
    phone["ringing"] = false;
}
