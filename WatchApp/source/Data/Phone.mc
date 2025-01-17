import Toybox.Lang;

typedef Phone as Lang.Dictionary<Lang.String, Lang.String or Lang.Number or Lang.Boolean or Null>;
typedef PhoneList as Lang.Array<Phone>;
typedef Phones as Lang.Dictionary<Lang.String, PhoneList | AccessIssue>;

const noPhones as Phones = { PhonesField.phoneList => [] as PhoneList } as Phones;

module PhonesField {
    const phoneList as Lang.String = "c";
    const accessIssue as Lang.String = "a";
}

(:inline, :background)
function setPhoneName(phone as Phone, name as Lang.String) as Void {
    phone[PhoneField.name] = name;
}

(:inline)
function getPhoneName(phone as Phone) as Lang.String {
    return phone[PhoneField.name] as Lang.String;
}

(:inline)
function getPhoneId(phone as Phone) as Lang.String {
    return phone[PhoneField.id] as Lang.String;
}

(:inline, :background)
function getPhoneNumber(phone as Phone) as Lang.String or Null {
    return phone[PhoneField.number] as Lang.String or Null;
}

(:inline)
function dropRingingFromPhone(phone as Phone) as Void {
    phone[PhoneField.ringing] = false;
}

(:inline, :background, :glance)
function isIncomingCallPhone(phone as Phone) as Lang.Boolean {
    var ringing = phone[PhoneField.ringing] as Lang.Boolean or Null;
    var isIncoming = (ringing != null) && (ringing as Lang.Boolean);
    return isIncoming;
}