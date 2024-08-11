using Toybox.Communications;
using Toybox.Lang;

(:background, :glance)
class DummyCommListener extends Communications.ConnectionListener {
    var tag as Lang.String;
    
    function initialize(tag as Lang.String) {
        self.tag = tag;
        ConnectionListener.initialize();
    }

    function onComplete() {
        _([L_OUT_COMM, tag + ".completed"]);
    }

    function onError() {
        _([L_OUT_COMM, tag + ".failed"]);
    }
}