import Toybox.Lang;

typedef Phone as Lang.Dictionary<Lang.String, Lang.String or Lang.Number or Lang.Boolean or Null>;
typedef PhoneList as Lang.Array<Phone>;
typedef Phones as Lang.Dictionary<Lang.String, PhoneList | AccessIssue>;

(:background)
const Phones_defaultValue as Phones = { PhonesField_list => [] as PhoneList } as Phones;

const PhonesField_list = "c";
const PhonesField_accessIssue = "a";

(:inline, :background)
function setPhoneName(phone as Phone, name as Lang.String) as Void {
    phone[PhoneField_name] = name;
}

(:inline)
function getPhoneName(phone as Phone) as Lang.String {
    return phone[PhoneField_name] as Lang.String;
}

(:inline)
function getPhoneId(phone as Phone) as Lang.String {
    return phone[PhoneField_id] as Lang.String;
}

(:inline, :background)
function getPhoneNumber(phone as Phone) as Lang.String or Null {
    return phone[PhoneField_number] as Lang.String or Null;
}

(:inline)
function dropRingingFromPhone(phone as Phone) as Void {
    phone[PhoneField_ringing] = false;
}

(:inline, :background, :glance)
function isIncomingCallPhone(phone as Phone) as Lang.Boolean {
    var ringing = phone[PhoneField_ringing] as Lang.Boolean or Null;
    var isIncoming = (ringing != null) && (ringing as Lang.Boolean);
    return isIncoming;
}