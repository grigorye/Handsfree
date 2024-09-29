using Toybox.Application;

(:background, :noLowMemory)
function eraseAppData() as Void {
    if (debug) { _2(L_APP, "erasingAppData"); }
    Application.Storage.clearValues();
}

(:noLowMemory)
function eraseAppDataIfNecessary() as Void {
    if (!AppSettings.isEraseAppDataOnNextLaunchEnabled) {
        return;
    }
    eraseAppData();
    AppSettings.clearEraseAppDataOnNextLaunch();
}