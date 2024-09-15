using Toybox.Lang;

typedef Recent as Lang.Dictionary<Lang.String, Lang.String or Lang.Number or Lang.Boolean>;
typedef Recents as Lang.Array<Recent>;

function getRecentName(recent as Recent) as Lang.String or Null {
    return recent["name"] as Lang.String or Null;
}

(:background)
function getRecentDate(recent as Recent) as Lang.Number {
    return recent["date"] as Lang.Number;
}

(:background)
function getRecentType(recent as Recent) as Lang.Number {
    return recent["type"] as Lang.Number;
}

(:background)
function getRecentIsNew(recent as Recent) as Lang.Number {
    return recent["isNew"] as Lang.Number;
}

function getRecentDuration(recent as Recent) as Lang.Number {
    return recent["duration"] as Lang.Number;
}

function getRecentNumber(recent as Recent) as Lang.String {
    return recent["number"] as Lang.String;
}