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

    // onStart() is called on application start up
    function onStart(state) {
        var msg = {
            "cmd" => "syncMe"
        };
        dump("outMsg", msg);
        Communications.transmit(msg, null, new SyncCommListener());
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [new CommView()];
    }

    function onPhone(msg as Communications.Message) as Void {
        handleRemoteMessage(msg);
        router.updateRoute();
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
