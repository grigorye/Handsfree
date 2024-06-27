using Toybox.Lang;
using Toybox.Application.Storage;

(:background, :glance)
function everSeenCompanion() as Lang.Boolean {
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
function hasTracesOfCompanion() as Lang.Boolean {
    return getPhones().size() > 0;
}

(:background, :glance)
function didSeeCompanion() as Void {
    if (everSeenCompanion()) {
        return;
    }
    dump("sawTheCompanionFirstTime", true);
    setEverSeenCompanion(true);
    updateForDidSeeCompanion.invoke();
}

(:background, :glance)
var updateForDidSeeCompanion as Lang.Method = new Lang.Method($, :dummyUpdateForDidSeeCompanion);

function dummyUpdateForDidSeeCompanion() as Void {
    dump("dummyUpdateForDidSeeCompanion", true);
}
