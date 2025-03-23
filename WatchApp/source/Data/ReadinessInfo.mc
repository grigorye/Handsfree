import Toybox.Lang;
import Toybox.Application;

typedef ReadinessInfo as Lang.Dictionary<String, Application.PropertyValueType>;

(:background, :glance, :readiness)
const ReadinessField_essentials = "e";
(:background, :glance, :readiness)
const ReadinessField_outgoingCalls = "o";
(:background, :glance, :readiness)
const ReadinessField_recents = "r";
(:background, :glance, :readiness)
const ReadinessField_incomingCalls = "i";
(:background, :glance, :readiness)
const ReadinessField_starredContacts = "s";

(:background, :glance, :noReadiness)
const ReadinessInfo_valueKey = "?";

(:background, :glance, :readiness)
const ReadinessInfo_valueKey = readinessInfoSubject + valueKeySuffix;
(:background, :glance, :readiness)
const ReadinessInfo_versionKey = readinessInfoSubject + versionKeySuffix;
