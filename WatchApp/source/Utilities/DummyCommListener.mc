using Toybox.Communications;
using Toybox.Lang;

(:background)
class DummyCommListener extends Communications.ConnectionListener {
    var tag as Lang.String;
    
    function initialize(tag as Lang.String) {
        self.tag = tag;
        ConnectionListener.initialize();
    }

    function onComplete() {
        _2(LX_OUT_COMM, tag + ".completed");
    }

    function onError() {
        _2(LX_OUT_COMM, tag + ".failed");
    }
}