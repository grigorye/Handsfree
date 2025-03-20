import Toybox.Lang;
import Toybox.Application;

typedef ReadinessInfo as Lang.Dictionary<String, Application.PropertyValueType>;

(:background, :glance, :noLowMemory)
const ReadinessField_essentials = "e";
(:background, :glance, :noLowMemory)
const ReadinessField_outgoingCalls = "o";
(:background, :glance, :noLowMemory)
const ReadinessField_recents = "r";
(:background, :glance, :noLowMemory)
const ReadinessField_incomingCalls = "i";
(:background, :glance, :noLowMemory)
const ReadinessField_starredContacts = "s";

(:background, :glance)
const ReadinessInfo_valueKey = readinessInfoSubject + ".1";
(:background, :glance)
const ReadinessInfo_versionKey = readinessInfoSubject + "v.1";
