using Toybox.Application;
using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;

class CommExample extends Application.AppBase {

    var isSupportedPlatform as Lang.Boolean = getIsSupportedPlatform();
    var readyToSync as Lang.Boolean = false;

    function initialize() {
        dump("initialize", true);
        Application.AppBase.initialize();
        if (!isSupportedPlatform) {
            return;
        }
        dump("registerForPhoneAppMessages", true);
        Communications.registerForPhoneAppMessages(method(:onPhone));
        readyToSync = true;
    }

    function onStart(state) {
        dump("onStart", state);
        Application.AppBase.onStart(state);
        requestSync();
    }

    function onStop(state) {
        dump("onStop", state);
        Application.AppBase.onStop(state);
    }

    function getInitialView() {
        dump("getInitialView", true);
        if (isSupportedPlatform) {
            return [new CommView()];
        } else {
            return [new WatchUi.ProgressBar("No support", 0.0)];
        }
    }

    function onPhone(msg as Communications.Message) as Void {
        if (!readyToSync) {
            dump("flushedMsg", msg);
            return;
        }
        handleRemoteMessage(msg);
    }
}

function getIsSupportedPlatform() as Lang.Boolean {
    var hasRegisterForAppMessages = Communications has :registerForPhoneAppMessages;
    dump("hasRegisterForAppMessages", hasRegisterForAppMessages);
    return hasRegisterForAppMessages;
}
