using Toybox.Lang;

(:background)
function firstElement(array as Lang.Array) as Lang.Object or Null {
    var element;
    if (array.size() > 0) {
        element = array[0] as Lang.Object;
    } else {
        element = null;
    }
    return element;
}