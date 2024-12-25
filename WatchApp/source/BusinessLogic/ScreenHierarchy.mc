import Toybox.WatchUi;

const extraMenuItemPrefix = "• ";

function statusMenu() as WatchUi.Menu2 or Null {
    return VT.viewWithTag(V.phones) as WatchUi.Menu2 or Null;
}

function recentsItemMenu() as WatchUi.Menu2 or Null {
    return VT.viewWithTag(V.phones) as WatchUi.Menu2 or Null;
}
