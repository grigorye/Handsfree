using Toybox.Application;

(:background, :glance)
function eraseAppData() as Void {
    dump("erasingAppData", true);
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