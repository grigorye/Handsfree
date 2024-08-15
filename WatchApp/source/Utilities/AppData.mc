using Toybox.Application;

(:background)
function eraseAppData() as Void {
    _2(L_APP, "erasingAppData");
    Application.Storage.clearValues();
}

function eraseAppDataIfNecessary() as Void {
    if (!AppSettings.isEraseAppDataOnNextLaunchEnabled) {
        return;
    }
    eraseAppData();
    AppSettings.clearEraseAppDataOnNextLaunch();
}