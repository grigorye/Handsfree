using Toybox.Application;
using Toybox.Lang;

(:background, :glance)
function sourceVersion() as Lang.String {
    return Application.Properties.getValue("sourceVersion") as Lang.String;
}