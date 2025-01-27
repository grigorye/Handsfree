import Toybox.Lang;
import Toybox.Application;

typedef ReadinessInfo as Lang.Dictionary<String, Application.PropertyValueType>;

(:background, :glance)
const ReadinessField_essentials = "e";
(:background, :glance)
const ReadinessField_outgoingCalls = "o";
(:background, :glance)
const ReadinessField_recents = "r";
(:background, :glance)
const ReadinessField_incomingCalls = "i";
(:background, :glance)
const ReadinessField_starredContacts = "s";

(:background, :glance)
const ReadinessInfo_valueKey = "readinessInfo.v1";
(:background, :glance)
const ReadinessInfo_versionKey = "readinessInfoVersion.v1";
