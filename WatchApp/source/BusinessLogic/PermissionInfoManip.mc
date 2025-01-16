import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

module PermissionInfoManip {

(:background)
const L_STORAGE as LogComponent = "permissionInfo";

(:inline, :background, :typecheck(disableBackgroundCheck))
function setPermissionInfo(permissionInfo as PermissionInfo) as Void {
    PermissionInfoImp.setPermissionInfoImp(permissionInfo);
    if (isActiveUiKindApp) {
        Routing.permissionInfoDidChange();
    }
}

(:inline)
function hasStarredContactsPermission() as Lang.Boolean {
    var permissionInfo = PermissionInfoImp.getPermissionInfo();
    if (permissionInfo != null) {
        return permissionInfo[PermissionInfoImp.permissionStarredContactsK] as Lang.Boolean == true;
    } else {
        return false;
    }
}

function hasRecentsPermission() as Lang.Boolean {
    var permissionInfo = PermissionInfoImp.getPermissionInfo();
    if (permissionInfo != null) {
        return permissionInfo[PermissionInfoImp.permissionRecentsK] as Lang.Boolean == true;
    } else {
        return false;
    }
}

function hasOutgoingCallsPermission() as Lang.Boolean {
    var permissionInfo = PermissionInfoImp.getPermissionInfo();
    if (permissionInfo != null) {
        return permissionInfo[PermissionInfoImp.permissionOutgoingCallsK] as Lang.Boolean == true;
    } else {
        return false;
    }
}

(:inline, :background)
function setPermissionInfoVersion(version as Version) as Void {
    if (debug) { _3(L_STORAGE, "setPermissionInfoVersion", version); }
    Storage.setValue("permissionInfoVersion.v1", version);
}

(:inline, :glance, :background)
function getPermissionInfoVersion() as Version | Null {
    var version = Storage.getValue("permissionInfoVersion.v1") as Version | Null;
    return version;
}

}
