import Toybox.Lang;
import Toybox.Application;

(:inline)
function setFocusedPhonesViewItemId(id as Lang.String or Null) as Void {
    Storage.setValue("focusedPhonesViewItemId.v1", id);
}

(:inline)
function getFocusedPhonesViewItemId() as Lang.String or Null {
    return Storage.getValue("focusedPhonesViewItemId.v1") as Lang.String or Null;
}