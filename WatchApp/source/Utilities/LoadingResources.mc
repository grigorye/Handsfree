import Toybox.WatchUi;
import Toybox.Lang;

function loadIfResource(value as Lang.ResourceId | Lang.String | Null) as Lang.String | Null {
    if (value == null) {
        return null;
    }
    if (value instanceof Lang.ResourceId) {
        return WatchUi.loadResource(value) as Lang.String;
    }
    return value;
}