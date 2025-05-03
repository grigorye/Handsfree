(:background, :glance)
const Storage_temporalBroadcastListening = "B" + valueKeySuffix;

(:background, :glance, :noLowMemory)
const Storage_rawRemoteMessagesCount = "M" + valueKeySuffix;

(:background, :glance, :noLowMemory)
const Storage_validRemoteMessagesCount = "V" + valueKeySuffix;

(:background, :glance)
const Storage_callState = "S" + valueKeySuffix; // The value stored *is not* phoneState subject.

const Storage_focusedPhonesViewItemId = "F" + valueKeySuffix;

(:background, :glance, :noLowMemory)
const Storage_hitsCount = "H" + valueKeySuffix;

(:glance)
const Storage_lastRecentsCheckDate = "D" + valueKeySuffix;

(:glance)
const Storage_missingRecents = "R" + valueKeySuffix;

(:background)
const Storage_optimisticCallStates = "O" + valueKeySuffix;

(:background)
const Storage_backgroundSystemStats = "T" + valueKeySuffix;

(:background, :glance)
const Storage_subjectsConfirmed = "C" + valueKeySuffix;
