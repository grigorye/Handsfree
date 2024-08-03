using Toybox.Lang;

(:glance)
function joinComponents(components as Lang.Array<Lang.String or Null>, separator as Lang.String) as Lang.String {
    var result = "";
    for (var i = 0; i < components.size(); i++) {
        var component = components[i];
        if (component == null) {
            continue;
        }
        if (result.equals("")) {
            result = component;
        } else {
            result = result + separator + component;
        }
    }
    return result;
}
