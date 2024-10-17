import Toybox.Lang;

(:background, :glance, :inline)
function objectsEqual(a as Lang.Object | Null, b as Lang.Object | Null) as Lang.Boolean {
    if (a == null || b == null) {
        return a == b;
    }
    return a.toString().equals(b.toString());
}