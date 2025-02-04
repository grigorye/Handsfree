import Toybox.Lang;

typedef Recent as Lang.Dictionary<Lang.String, Lang.String or Lang.Number or Lang.Boolean or Null>;
typedef Recents as Lang.Array<Recent>;

(:inline)
function getRecentName(recent as Recent) as Lang.String or Null {
    return recent[RecentField.name] as Lang.String or Null;
}

(:inline, :background)
function getRecentDate(recent as Recent) as Lang.Number {
    return recent[RecentField.date] as Lang.Number;
}

(:inline, :background)
function getRecentType(recent as Recent) as Lang.Number {
    return recent[RecentField.type] as Lang.Number;
}

(:inline, :background)
function getRecentIsNew(recent as Recent) as Lang.Number {
    return recent[RecentField.isNew] as Lang.Number;
}

(:inline)
function getRecentDuration(recent as Recent) as Lang.Number {
    return recent[RecentField.duration] as Lang.Number;
}

(:inline)
function getRecentNumber(recent as Recent) as Lang.String {
    return recent[RecentField.number] as Lang.String;
}