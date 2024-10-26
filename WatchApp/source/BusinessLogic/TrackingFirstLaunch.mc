import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;

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
        cmdK => Cmd.didFirstLaunch
    } as Lang.Object as Application.PersistableType;
    var tag = formatCommTag("didFirstLaunch");
    if (minDebug) { _3(LX_OUT_COMM, tag + ".requesting", msg); }
    Communications.transmit(msg, null, new DummyCommListener(tag));
}
