import Toybox.Lang;

(:inline)
function pendingText(text as Lang.String) as Lang.String {
    return Lang.format(AppSettings.pendingValueFormat, [text]);
}
