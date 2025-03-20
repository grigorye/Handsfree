import Toybox.Application;
import Toybox.Lang;

(:background, :lowMemory)
function trackRawRemoteMessageReceived() as Void {
}

(:background, :glance, :noLowMemory)
const Storage_rawRemoteMessagesCount = "M.1";

(:background, :glance, :noLowMemory)
const Storage_validRemoteMessagesCount = "V.1";

(:background, :noLowMemory)
function trackRawRemoteMessageReceived() as Void {
    var rawRemoteMessagesCount = getRawRemoteMessagesCount();
    rawRemoteMessagesCount++;
    Storage.setValue(Storage_rawRemoteMessagesCount, rawRemoteMessagesCount);
    statsDidChange();
}

(:background, :noLowMemory)
function trackValidRemoteMessageReceived() as Void {
    var validRemoteMessagesCount = getValidRemoteMessagesCount();
    validRemoteMessagesCount++;
    Storage.setValue(Storage_validRemoteMessagesCount, validRemoteMessagesCount);
    statsDidChange();
}

(:background, :glance, :noLowMemory)
function getRawRemoteMessagesCount() as Lang.Number {
    var rawRemoteMessagesCount = Storage.getValue(Storage_rawRemoteMessagesCount) as Lang.Number or Null;
    if (rawRemoteMessagesCount == null) {
        rawRemoteMessagesCount = 0;
    }
    return rawRemoteMessagesCount;
}

(:background, :glance, :noLowMemory)
function getValidRemoteMessagesCount() as Lang.Number {
    var validRemoteMessagesCount = Storage.getValue(Storage_validRemoteMessagesCount) as Lang.Number or Null;
    if (validRemoteMessagesCount == null) {
        validRemoteMessagesCount = 0;
    }
    return validRemoteMessagesCount;
}
