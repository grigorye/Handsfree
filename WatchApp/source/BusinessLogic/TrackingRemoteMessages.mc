using Toybox.Application;
using Toybox.Lang;

(:background, :noLowMemory)
function trackRawRemoteMessageReceived() as Void {
    var rawRemoteMessagesCount = getRawRemoteMessagesCount();
    rawRemoteMessagesCount++;
    Application.Storage.setValue("rawRemoteMessagesCount.v1", rawRemoteMessagesCount);
    statsDidChange();
}

(:background, :noLowMemory)
function trackValidRemoteMessageReceived() as Void {
    var validRemoteMessagesCount = getValidRemoteMessagesCount();
    validRemoteMessagesCount++;
    Application.Storage.setValue("validRemoteMessagesCount.v1", validRemoteMessagesCount);
    statsDidChange();
}

(:background, :glance, :noLowMemory)
function getRawRemoteMessagesCount() as Lang.Number {
    var rawRemoteMessagesCount = Application.Storage.getValue("rawRemoteMessagesCount.v1") as Lang.Number;
    if (rawRemoteMessagesCount == null) {
        rawRemoteMessagesCount = 0;
    }
    return rawRemoteMessagesCount;
}

(:background, :glance, :noLowMemory)
function getValidRemoteMessagesCount() as Lang.Number {
    var validRemoteMessagesCount = Application.Storage.getValue("validRemoteMessagesCount.v1") as Lang.Number;
    if (validRemoteMessagesCount == null) {
        validRemoteMessagesCount = 0;
    }
    return validRemoteMessagesCount;
}
