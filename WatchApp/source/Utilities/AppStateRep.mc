using Toybox.Lang;

(:background, :glance, :noLowMemory)
function appStateRep(state as Lang.Dictionary or Null) as Lang.Object | Null {
    if (state == null) {
        return null;
    }
    var stateRep = [] as Lang.Array<Lang.String>;
    var resume = state[:resume] as Lang.Boolean | Null;
    if (resume) {
        stateRep.add("resume");
    }
    var launchedFromGlance = state[:launchedFromGlance] as Lang.Boolean | Null;
    if (launchedFromGlance) {
        stateRep.add("launchedFromGlance");
    }
    var launchedFromComplication = state[:launchedFromComplication] as Lang.Boolean | Null;
    if (launchedFromComplication) {
        stateRep.add("launchedFromComplication");
    }
    var launchedFromPostInstall = state[:launchedFromPostInstall] as Lang.Boolean | Null;
    if (launchedFromPostInstall) {
        stateRep.add("launchedFromPostInstall");
    }
    var launchedFromWatchFaceSettingsEditor = state[:launchedFromWatchFaceSettingsEditor] as Lang.Boolean | Null;
    if (launchedFromWatchFaceSettingsEditor) {
        stateRep.add("launchedFromWatchFaceSettingsEditor");
    }
    var configId = state[:configId] as Lang.Object | Null;
    if (configId != null) {
        stateRep.add("configId(" + configId + ")");
    }
    return stateRep;
}
