import Toybox.Application;
import Toybox.Lang;

(:background)
function loadValueWithDefault(key as Lang.String, defaultValue as Lang.Object) as Lang.Object {
    var storedValue = Storage.getValue(key);
    if (storedValue != null) {
        return storedValue as Lang.Object;
    }
    return defaultValue;
}

(:background)
function storeVersion(key as Lang.String, version as Lang.Number) as Void {
    if (minDebug) { _3(L_APP, "storeVersion", [key, version]); }
    Storage.setValue(key, version);
}

(:background)
function storeValue(key as Lang.String, value as Lang.Object) as Void {
    var listValue;
    switch (key) {
        case Recents_valueKey:
            listValue = (value as Recents)[RecentsField_list] as Lang.Array;
            break;
        case Phones_valueKey:
            listValue = (value as Phones)[PhonesField_list] as Lang.Array;
            break;
        default:
            listValue = null;
    }
    var valueSuffix;
    if (listValue != null) {
        valueSuffix = " (" + listValue.size() + ")";
    } else {
        valueSuffix = "";
    }
    if (memDebug) { dumpF(L_APP, "storeValue: " + key + valueSuffix); }
    switch (key) {
        case AudioState_valueKey:
            AudioState_oldValue = Storage.getValue(key) as AudioState | Null;
            break;
    }
    Storage.setValue(key, value as Application.PropertyValueType);
    switch (key) {
        case AudioState_valueKey:
            AudioStateManip.updateUIForAudioStateIfRelevant(value as AudioState);
            break;
        case CompanionInfo_valueKey:
            Routing.companionInfoDidChangeIfInApp();
            break;
        case Phones_valueKey:
            PhonesManip.updateUIForPhonesIfInApp(value as Phones);
            break;
        case ReadinessInfo_valueKey:
            Routing.readinessInfoDidChangeIfInApp();
            break;
        case Recents_valueKey:
            if (!lowMemory || isActiveUiKindApp) {
                RecentsManip.updateUIForRecentsIfInApp();
            }
            break;
        case PhoneState_valueKey:
            Req.handlePhoneStateChanged(value as PhoneState);
            break;
    }
}