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

(:background, :glance)
function stringComponentsJoinedBySeparator(joined as Lang.String, separator as Lang.String) as Lang.Array<Lang.String> {
    var components = [];

    var tail = joined;
    while (true) {
        var end = tail.find(";");
        var component = tail.substring(0, end) as Lang.String;
        components.add(component);
        if (end == null) {
            break;
        }
        tail = tail.substring(end + 1, null);
    }
    return components;
}
