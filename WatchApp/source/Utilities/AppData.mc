using Toybox.Application;

(:background)
function eraseAppData() as Void {
    _2(L_APP_LIFE_CYCLE, "erasingAppData");
    Application.Storage.clearValues();
}

(:background)
function eraseAppDataIfNecessary() as Void {
    if (!isEraseAppDataOnNextLaunchEnabled()) {
        return;
    }
    eraseAppData();
    clearEraseAppDataOnNextLaunch();
}