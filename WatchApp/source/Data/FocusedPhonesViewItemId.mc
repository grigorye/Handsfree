using Toybox.Lang;
using Toybox.Application;

var focusedPhonesViewItemId as Lang.Number or Null;

function setFocusedPhonesViewItemId(id as Lang.String or Null) as Void {
    Application.Properties.setValue("focusedPhonesViewItemId", id);
}

function getFocusedPhonesViewItemId() as Lang.String or Null {
    return Application.Properties.getValue("focusedPhonesViewItemId") as Lang.String or Null;
}