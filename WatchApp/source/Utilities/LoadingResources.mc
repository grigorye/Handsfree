import Toybox.Application;
import Toybox.Lang;

typedef StringOrResource as Lang.String | Lang.ResourceId;

(:glance, :background)
function loadIfResource(value as Lang.Object) as Lang.String {
    if (value instanceof Lang.ResourceId) {
        return Application.loadResource(value) as Lang.String;
    }
    return value as Lang.String;
}

(:glance)
function formatIfResources(format as StringOrResource, arguments as Lang.Array) as Lang.String {
    var adjustedArguments = [] as Lang.Array;
    for (var i = 0; i < arguments.size(); ++i) {
        var argument = arguments[i] as Lang.Object;
        adjustedArguments.add(loadIfResource(argument));
    }
    var adjustedFormat = loadIfResource(format);
    return Lang.format(adjustedFormat, adjustedArguments);
}