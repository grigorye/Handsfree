import Toybox.Lang;

(:background, :glance)
var msgIndex as Lang.Number = 0;

(:background, :glance)
function formatCommTag(tag as Lang.String) as Lang.String {
    msgIndex++;
    return "'" + tag + "'." + msgIndex;
}
