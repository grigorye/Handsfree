using Toybox.Lang;

(:glance)
function headsetStatusRep() as Lang.String or Null {
    if (!getIsHeadsetConnected()) {
        return "#";
    } else {
        return null;
    }
}
