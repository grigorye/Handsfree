import Toybox.Lang;
import Toybox.Application;

function setFocusedPhonesViewItemId(id as Lang.String or Null) as Void {
    Storage.setValue("focusedPhonesViewItemId.v1", id);
}

function getFocusedPhonesViewItemId() as Lang.String or Null {
    return Storage.getValue("focusedPhonesViewItemId.v1") as Lang.String or Null;
}