using Toybox.Lang;
using Toybox.Application.Storage;

(:background, :glance)
function everSeenCompanion() as Lang.Boolean {
    if (!isCompanionOnboardingEnabled()) {
        return true;
    }
    var storedValue = Storage.getValue("everSeenCompanion") as Lang.Boolean or Null;
    if (storedValue == null) {
        return false;
    }
    return storedValue;
}

(:background, :glance)
function setEverSeenCompanion(value as Lang.Boolean) as Void {
    Storage.setValue("everSeenCompanion", value);
}

(:background, :glance)
function didSeeCompanion() as Void {
    if (everSeenCompanion()) {
        return;
    }
    _2(L_COMPANION_TRACK, "sawTheCompanionFirstTime");
    setEverSeenCompanion(true);
    updateForDidSeeCompanion();
}

(:background, :glance, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function updateForDidSeeCompanion() as Void {
    _3(L_COMPANION_TRACK, "updateForDidSeeCompanion.activeUiKind", getActiveUiKind());
    if (!getActiveUiKind().equals(ACTIVE_UI_APP)) {
        return;
    }
    updatePhonesView();
}
