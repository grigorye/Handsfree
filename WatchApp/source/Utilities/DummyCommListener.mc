import Toybox.Communications;
import Toybox.Lang;

(:background)
class DummyCommListener extends Communications.ConnectionListener {
    var tag as Lang.String;
    
    function initialize(tag as Lang.String) {
        self.tag = tag;
        ConnectionListener.initialize();
    }

    function onComplete() {
        if (debug) { _2(LX_OUT_COMM, tag + ".completed"); }
    }

    function onError() {
        if (debug) { _2(LX_OUT_COMM, tag + ".failed"); }
    }
}