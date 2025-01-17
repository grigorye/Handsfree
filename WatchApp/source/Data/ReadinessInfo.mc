import Toybox.Lang;
import Toybox.Application;

typedef ReadinessInfo as Lang.Dictionary<String, Application.PropertyValueType>;

module ReadinessField {

(:inline, :background, :glance)
const essentials = "e";
(:inline, :background, :glance)
const outgoingCalls = "o";
(:inline, :background, :glance)
const recents = "r";
(:inline, :background, :glance)
const incomingCalls = "i";
(:inline, :background, :glance)
const starredContacts = "s";

}

module ReadinessInfoImp {

(:background, :glance)
var readinessInfoImp as ReadinessInfo or Null = null;
(:background)
var oldReadinessInfoImp as ReadinessInfo or Null = null;

(:background, :glance)
const L_COMPANION_INFO as LogComponent = "readinessInfo";

(:inline, :background)
function setReadinessInfoImp(readinessInfo as ReadinessInfo) as Void {
    if (debug) { _3(L_COMPANION_INFO, "readinessInfo", readinessInfo); }
    oldReadinessInfoImp = getReadinessInfo();
    readinessInfoImp = readinessInfo;
    saveReadinessInfo(readinessInfo);
}

(:inline, :background, :glance)
function loadReadinessInfo() as ReadinessInfo or Null {
    return Storage.getValue("readinessInfo.v1") as ReadinessInfo or Null;
}

(:inline, :background)
function saveReadinessInfo(readinessInfo as ReadinessInfo) as Void {
    Storage.setValue("readinessInfo.v1", readinessInfo as Application.PropertyValueType);
}

(:background, :glance)
function getReadinessInfo() as ReadinessInfo or Null {
    var readinessInfo;
    if (readinessInfoImp != null) {
        readinessInfo = readinessInfoImp;
    } else {
        var loadedReadinessInfo = loadReadinessInfo();
        if (loadedReadinessInfo != null) {
            readinessInfo = loadedReadinessInfo;
        } else {
            readinessInfo = null;
        }
    }
    return readinessInfo;
}

}
