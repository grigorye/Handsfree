import Toybox.Lang;
import Toybox.Application;

const Storage_focusedPhonesViewItemId = "focusedPhonesViewItemId.v1";

(:inline)
function setFocusedPhonesViewItemId(id as Lang.String or Null) as Void {
    Storage.setValue(Storage_focusedPhonesViewItemId, id);
}

(:inline)
function getFocusedPhonesViewItemId() as Lang.String or Null {
    return Storage.getValue(Storage_focusedPhonesViewItemId) as Lang.String or Null;
}