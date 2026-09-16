import Toybox.Lang;

(:background, :glance)
var msgIndex as Lang.Number = 0;

(:background, :glance)
function formatCommTag(tag as Lang.String) as Lang.String {
    msgIndex++;
    return Lang.format("'$1$'.$2$", [tag, msgIndex]);
}
