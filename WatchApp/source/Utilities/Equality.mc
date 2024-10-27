import Toybox.Lang;

(:background, :glance, :inline)
function objectsEqual(a as Lang.Object, b as Lang.Object) as Lang.Boolean {
    return a.toString().equals(b.toString());
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