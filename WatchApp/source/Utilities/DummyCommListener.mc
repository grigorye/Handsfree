using Toybox.Communications;
using Toybox.Lang;

(:background, :glance)
class DummyCommListener extends Communications.ConnectionListener {
    var tag as Lang.String;
    
    function initialize(tag as Lang.String) {
        self.tag = tag;
        ConnectionListener.initialize();
        dump(tag, "initialize");
    }

    function onComplete() {
        dump(tag, "complete");
    }

    function onError() {
        dump(tag, "error");
    }
}