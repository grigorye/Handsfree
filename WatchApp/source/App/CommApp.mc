using Toybox.Application;
using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;

class CommExample extends Application.AppBase {

    function initialize() {
        Application.AppBase.initialize();

        router = new Router();
        
        var phoneMethod = method(:onPhone);
        if(Communications has :registerForPhoneAppMessages) {
            Communications.registerForPhoneAppMessages(phoneMethod);
        } else {
            // hasDirectMessagingSupport = false;
        }
    }

    function onStart(state) {
        var msg = {
            "cmd" => "syncMe"
        };
        dump("outMsg", msg);
        Communications.transmit(msg, null, new SyncCommListener());
    }

    function onStop(state) {
    }

    function getInitialView() {
        return [new CommView()];
    }

    function onPhone(msg as Communications.Message) as Void {
        handleRemoteMessage(msg);
    }
}

class SyncCommListener extends Communications.ConnectionListener {

    function initialize() {
        dump("sync", "initialize");
        ConnectionListener.initialize();
    }

    function onComplete() {
        dump("sync", "complete");
    }

    function onError() {
        dump("sync", "error");
    }
}
