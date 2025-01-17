import Toybox.Lang;

(:background, :glance, :inline)
function objectsEqual(a as Lang.Object | Null, b as Lang.Object | Null) as Lang.Boolean {
    if (a != null && b != null) {
        return (a as Lang.Object).toString().equals((b as Lang.Object).toString());
    }
    return (a == null && b == null);
}

(:background, :glance, :inline)
function objectsEqualOrNull(a as Lang.Object | Null, b as Lang.Object | Null) as Lang.Boolean {
    var equal;
    if (a == null || b == null) {
        equal = a == b;
    } else {
        equal = objectsEqual(a, b);
    }
    return equal;
}