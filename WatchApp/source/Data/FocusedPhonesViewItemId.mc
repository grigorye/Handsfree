using Toybox.Lang;
using Toybox.Application;

function setFocusedPhonesViewItemId(id as Lang.String or Null) as Void {
    Application.Storage.setValue("focusedPhonesViewItemId.v1", id);
}

function getFocusedPhonesViewItemId() as Lang.String or Null {
    return Application.Storage.getValue("focusedPhonesViewItemId.v1") as Lang.String or Null;
}