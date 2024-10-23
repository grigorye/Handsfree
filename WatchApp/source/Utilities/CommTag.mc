import Toybox.Lang;

(:background)
var msgIndex as Lang.Number = 0;

(:background)
function formatCommTag(tag as Lang.String) as Lang.String {
    msgIndex++;
    return "'" + tag + "'." + msgIndex;
}
