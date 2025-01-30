import Toybox.Lang;

typedef Recent as Lang.Dictionary<Lang.String, Lang.String or Lang.Number or Lang.Boolean or Null>;
typedef RecentsList as Lang.Array<Recent>;
typedef Recents as Lang.Dictionary<Lang.String, RecentsList | AccessIssue>;

(:glance)
const RecentsField_list as Lang.String = "r";
const RecentsField_accessIssue as Lang.String = "a";

(:inline)
function getRecentName(recent as Recent) as Lang.String or Null {
    return recent[RecentField_name] as Lang.String or Null;
}

(:inline, :glance)
function getRecentDate(recent as Recent) as Lang.Number {
    return recent[RecentField_date] as Lang.Number;
}

(:inline, :glance)
function getRecentType(recent as Recent) as Lang.Number {
    return recent[RecentField_type] as Lang.Number;
}

(:inline, :glance)
function getRecentIsNew(recent as Recent) as Lang.Number {
    return recent[RecentField_isNew] as Lang.Number;
}

(:inline)
function getRecentDuration(recent as Recent) as Lang.Number {
    return recent[RecentField_duration] as Lang.Number;
}

(:inline)
function getRecentNumber(recent as Recent) as Lang.String {
    return recent[RecentField_number] as Lang.String;
}