import Toybox.Application;
import Toybox.Lang;

(:background, :lowMemory)
function trackRawRemoteMessageReceived() as Void {
}

(:background, :noLowMemory)
function trackRawRemoteMessageReceived() as Void {
    var rawRemoteMessagesCount = getRawRemoteMessagesCount();
    rawRemoteMessagesCount++;
    Storage.setValue("rawRemoteMessagesCount.v1", rawRemoteMessagesCount);
    statsDidChange();
}

(:background, :noLowMemory)
function trackValidRemoteMessageReceived() as Void {
    var validRemoteMessagesCount = getValidRemoteMessagesCount();
    validRemoteMessagesCount++;
    Storage.setValue("validRemoteMessagesCount.v1", validRemoteMessagesCount);
    statsDidChange();
}

(:background, :glance, :noLowMemory)
function getRawRemoteMessagesCount() as Lang.Number {
    var rawRemoteMessagesCount = Storage.getValue("rawRemoteMessagesCount.v1") as Lang.Number or Null;
    if (rawRemoteMessagesCount == null) {
        rawRemoteMessagesCount = 0;
    }
    return rawRemoteMessagesCount;
}

(:background, :glance, :noLowMemory)
function getValidRemoteMessagesCount() as Lang.Number {
    var validRemoteMessagesCount = Storage.getValue("validRemoteMessagesCount.v1") as Lang.Number or Null;
    if (validRemoteMessagesCount == null) {
        validRemoteMessagesCount = 0;
    }
    return validRemoteMessagesCount;
}
