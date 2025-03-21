import Toybox.Lang;
import Toybox.Application;

typedef CompanionInfo as Lang.Dictionary<String, Application.PropertyValueType>;
typedef VersionInfo as Lang.Dictionary<String, Application.PropertyValueType>;

(:background, :glance)
const CompanionInfo_valueKey = companionInfoSubject + valueKeySuffix;
(:background, :glance)
const CompanionInfo_versionKey = companionInfoSubject + versionKeySuffix;

(:noLowMemory)
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

(:inline, :glance)
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
