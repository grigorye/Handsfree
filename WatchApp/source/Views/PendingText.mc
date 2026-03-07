import Toybox.Lang;
import Toybox.WatchUi;

(:inline)
function pendingText(text as Lang.String or Lang.ResourceId) as Lang.String {
    if (text instanceof Lang.ResourceId) {
        text = WatchUi.loadResource(text) as Lang.String;
    }
    return Lang.format(AppSettings.pendingValueFormat, [text]);
}
