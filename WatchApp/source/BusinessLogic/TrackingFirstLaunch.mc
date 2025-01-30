import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;

module Req {

(:background)
function trackFirstLaunch() as Void {
    var everLaunched = Storage.getValue("everLaunched.v1") as Lang.Boolean or Null;
    if (everLaunched == null) {
        Storage.setValue("everLaunched.v1", true);
        didFirstLaunch();
    }
}

(:background)
function didFirstLaunch() as Void {
    if (debug) { _2(L_APP_STAT, "didFirstLaunch"); }
    var msg = {
        cmdK => Cmd_didFirstLaunch
    };
    transmitWithoutRetry("didFirstLaunch", msg);
}

}