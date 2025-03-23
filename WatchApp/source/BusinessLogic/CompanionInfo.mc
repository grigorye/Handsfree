import Toybox.Lang;
import Toybox.Application;

(:companion)
typedef CompanionInfo as Lang.Dictionary<String, Application.PropertyValueType>;
(:companion)
typedef VersionInfo as Lang.Dictionary<String, Application.PropertyValueType>;

(:background, :glance, :noCompanion)
const CompanionInfo_valueKey = "?";

(:background, :glance, :companion)
const CompanionInfo_valueKey = companionInfoSubject + valueKeySuffix;
(:background, :glance, :companion)
const CompanionInfo_versionKey = companionInfoSubject + versionKeySuffix;

(:companion)
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
