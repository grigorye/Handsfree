import Toybox.Lang;
import Toybox.Application;

typedef PermissionInfo as Lang.Dictionary<String, Application.PropertyValueType>;

module PermissionInfoImp {

(:inline, :background, :glance)
const permissionEssentialsK = "e";
(:inline, :background, :glance)
const permissionOutgoingCallsK = "o";
(:inline, :background, :glance)
const permissionRecentsK = "r";
(:inline, :background, :glance)
const permissionIncomingCallsK = "i";
(:inline, :background, :glance)
const permissionStarredContactsK = "s";

(:background, :glance)
var permissionInfoImp as PermissionInfo or Null = null;
(:background)
var oldPermissionInfoImp as PermissionInfo or Null = null;

(:background, :glance)
const L_COMPANION_INFO as LogComponent = "permissionInfo";

(:inline, :background)
function setPermissionInfoImp(permissionInfo as PermissionInfo) as Void {
    if (debug) { _3(L_COMPANION_INFO, "permissionInfo", permissionInfo); }
    oldPermissionInfoImp = getPermissionInfo();
    permissionInfoImp = permissionInfo;
    savePermissionInfo(permissionInfo);
}

(:inline, :background, :glance)
function loadPermissionInfo() as PermissionInfo or Null {
    return Storage.getValue("permissionInfo.v1") as PermissionInfo or Null;
}

(:inline, :background)
function savePermissionInfo(permissionInfo as PermissionInfo) as Void {
    Storage.setValue("permissionInfo.v1", permissionInfo as Application.PropertyValueType);
}

(:background, :glance)
function getPermissionInfo() as PermissionInfo or Null {
    var permissionInfo;
    if (permissionInfoImp != null) {
        permissionInfo = permissionInfoImp;
    } else {
        var loadedPermissionInfo = loadPermissionInfo();
        if (loadedPermissionInfo != null) {
            permissionInfo = loadedPermissionInfo;
        } else {
            permissionInfo = null;
        }
    }
    return permissionInfo;
}

}
