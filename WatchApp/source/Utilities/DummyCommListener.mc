import Toybox.Communications;
import Toybox.Lang;

module Req {

(:background, :glance)
class DummyCommListener extends Communications.ConnectionListener {
    var tag as Lang.String;
    
    function initialize(tag as Lang.String) {
        self.tag = tag;
        ConnectionListener.initialize();
    }

    function onComplete() {
        if (minDebug || lowMemory) { _2(LX_OUT_COMM, tag + ".completed"); }
    }

    function onError() {
        if (debug || lowMemory) { _2(LX_OUT_COMM, tag + ".failed"); }
    }
}

}