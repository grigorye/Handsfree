using Toybox.Communications;

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
