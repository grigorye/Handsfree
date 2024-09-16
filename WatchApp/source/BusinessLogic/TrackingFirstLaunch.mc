using Toybox.Application;
using Toybox.Communications;
using Toybox.Lang;

(:background)
function trackFirstLaunch() as Void {
    var everLaunched = Application.Storage.getValue("everLaunched.v1") as Lang.Boolean or Null;
    if (everLaunched == null) {
        Application.Storage.setValue("everLaunched.v1", true);
        didFirstLaunch();
    }
}

(:background)
function didFirstLaunch() as Void {
    _2(L_APP_STAT, "didFirstLaunch");
    var msg = {
        "cmd" => "didFirstLaunch"
    } as Lang.Object as Application.PersistableType;
    var tag = formatCommTag("didFirstLaunch");
    _3(LX_OUT_COMM, tag + ".requesting", msg);
    Communications.transmit(msg, null, new DummyCommListener(tag));
}
