import Toybox.WatchUi;

const extraMenuItemPrefix = "• ";

function statusMenu() as WatchUi.Menu2 or Null {
    return viewWithTag("phones") as WatchUi.Menu2 or Null;
}

function recentsItemMenu() as WatchUi.Menu2 or Null {
    return viewWithTag("phones") as WatchUi.Menu2 or Null;
}
