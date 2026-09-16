import Toybox.Lang;

(:glance, :widget)
function joinComponents(components as Lang.Array<StringOrResource>, separator as Lang.String) as Lang.String {
    return joinNonNullComponents(components as Lang.Array<StringOrResource | Null>, separator);
}

(:glance)
function joinNonNullComponents(components as Lang.Array<StringOrResource | Null>, separator as Lang.String) as Lang.String {
    var result = "";
    var size = components.size();
    for (var i = 0; i < size; i++) {
        var component = components[i];
        if (component == null) {
            continue;
        }

        var adjustedComponent = loadIfResource(component);

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

(:background)
function deleteSubstring(string as Lang.String, substring as Lang.String) as Lang.String | Null {
    var index = string.find(substring);
    if (index == null) {
        return null;
    }
    var stringLength = string.length();
    var substringLength = substring.length();
    var before = index == 0 ? "" : string.substring(0, index) as Lang.String;
    var after = index + substringLength >= stringLength ? "" : string.substring(index + substringLength, stringLength) as Lang.String;
    return before + after;
}