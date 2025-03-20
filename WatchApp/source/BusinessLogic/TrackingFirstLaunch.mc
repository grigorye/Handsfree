import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;

module Req {

(:background)
const Storage_everLaunched = "E.1";

(:background)
function trackFirstLaunch() as Void {
    var everLaunched = Storage.getValue(Storage_everLaunched) as Lang.Boolean or Null;
    if (everLaunched == null) {
        Storage.setValue(Storage_everLaunched, true);
        didFirstLaunch();
    }
}

(:background)
function didFirstLaunch() as Void {
    if (debug) { _2(L_APP_STAT, "didFirstLaunch"); }
    requestSubjects(allSubjects);
}

}