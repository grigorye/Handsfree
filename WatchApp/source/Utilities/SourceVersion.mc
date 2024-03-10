using Toybox.Lang;
using Toybox.Application;

(:background, :glance)
function sourceVersion() as Lang.String {
    return Application.Properties.getValue("sourceVersion") as Lang.String;
}