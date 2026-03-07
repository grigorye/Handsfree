import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
function joinComponents(components as Lang.Array<Lang.String or Lang.ResourceId or Null>, separator as Lang.String) as Lang.String {
    var result = "";
    for (var i = 0; i < components.size(); i++) {
        var component = components[i];
        if (component == null) {
            continue;
        }

        var adjustedComponent;
        if (component instanceof Lang.ResourceId) {
            adjustedComponent = WatchUi.loadResource(component) as Lang.String;
        } else {
            adjustedComponent = component as Lang.String;
        }

        if (result.equals("")) {
            result = adjustedComponent;
        } else {
            result = result + separator + adjustedComponent;
        }
    }
    return result;
}

(:noLowMemory)
function substring(value as Lang.String, start as Lang.Number, end as Lang.Number or Null) as Lang.String {
    var endIndex;
    if (end == null) {
        endIndex = value.length();
    } else {
        endIndex = end as Lang.Number;
    }
    return value.substring(start, endIndex) as Lang.String;
}

(:noLowMemory, :logging)
function stringComponentsJoinedBySeparator(joined as Lang.String, separator as Lang.String) as Lang.Array<Lang.String> {
    var components = [] as Lang.Array<Lang.String>;

    var tail = joined;
    while (true) {
        var end = tail.find(";");
        var component = substring(tail, 0, end);
        components.add(component);
        if (end == null) {
            break;
        }
        tail = substring(tail, end + 1, null);
    }
    return components;
}
