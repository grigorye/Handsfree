import Toybox.Lang;
import Toybox.Application;

(:inline)
function setFocusedPhonesViewItemId(id as Lang.String or Null) as Void {
    Storage.setValue(Storage_focusedPhonesViewItemId, id);
}

(:inline)
function getFocusedPhonesViewItemId() as Lang.String or Null {
    return Storage.getValue(Storage_focusedPhonesViewItemId) as Lang.String or Null;
}