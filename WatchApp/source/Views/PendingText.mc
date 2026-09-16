import Toybox.Lang;

(:inline)
function pendingText(text as StringOrResource) as Lang.String {
    return formatIfResources(AppSettings.pendingValueFormat, [text]);
}
