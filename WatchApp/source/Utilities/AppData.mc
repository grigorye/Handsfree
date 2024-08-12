using Toybox.Application;

(:background, :glance)
function eraseAppData() as Void {
    _2(L_APP_LIFE_CYCLE, "erasingAppData");
    Application.Storage.clearValues();
}

(:background, :glance)
function eraseAppDataIfNecessary() as Void {
    if (!isEraseAppDataOnNextLaunchEnabled()) {
        return;
    }
    eraseAppData();
    clearEraseAppDataOnNextLaunch();
}