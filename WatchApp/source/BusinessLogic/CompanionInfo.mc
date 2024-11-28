import Toybox.Lang;
import Toybox.Application;

typedef CompanionInfo as Lang.Dictionary<String, Application.PropertyValueType>;
typedef VersionInfo as Lang.Dictionary<String, Application.PropertyValueType>;

module CompanionInfoImp {

(:inline, :background, :glance)
const versionK = "v";

// VersionInfo keys
(:inline, :background, :glance)
const versionNameK = "n";
(:inline, :background, :glance)
const versionCodeK = "c";
(:inline, :background, :glance)
const versionSourceVersionK = "s";
(:inline, :background, :glance)
const versionBuildTypeK = "t";

(:background, :glance)
var companionInfoImp as CompanionInfo or Null = null;
(:background)
var oldCompanionInfoImp as CompanionInfo or Null = null;

(:background, :glance)
const L_COMPANION_INFO as LogComponent = "companionInfo";

(:inline, :background)
function setCompanionInfoImp(companionInfo as CompanionInfo) as Void {
    if (debug) { _3(L_COMPANION_INFO, "companionInfo", companionInfo); }
    oldCompanionInfoImp = getCompanionInfo();
    companionInfoImp = companionInfo;
    saveCompanionInfo(companionInfo);
}

(:inline, :background, :glance)
function loadCompanionInfo() as CompanionInfo or Null {
    return Storage.getValue("companionInfo.v1") as CompanionInfo or Null;
}

(:inline, :background)
function saveCompanionInfo(companionInfo as CompanionInfo) as Void {
    Storage.setValue("companionInfo.v1", companionInfo as Application.PropertyValueType);
}

(:background, :glance)
function getCompanionInfo() as CompanionInfo or Null {
    var companionInfo;
    if (companionInfoImp != null) {
        companionInfo = companionInfoImp;
    } else {
        var loadedCompanionInfo = loadCompanionInfo();
        if (loadedCompanionInfo != null) {
            companionInfo = loadedCompanionInfo;
        } else {
            companionInfo = null;
        }
    }
    return companionInfo;
}

(:inline)
function getCompanionVersionCode(companionInfo as CompanionInfo) as Lang.Number {
    var versionInfo = companionInfo[versionK] as VersionInfo;
    return versionInfo[versionCodeK] as Lang.Number;
}

(:inline)
function getCompanionVersionName(companionInfo as CompanionInfo) as Lang.String {
    var versionInfo = companionInfo[versionK] as VersionInfo;
    return versionInfo[versionNameK] as Lang.String;
}

(:inline)
function getCompanionSourceVersion(companionInfo as CompanionInfo) as Lang.String {
    var versionInfo = companionInfo[versionK] as VersionInfo;
    return versionInfo[versionSourceVersionK] as Lang.String;
}

}
