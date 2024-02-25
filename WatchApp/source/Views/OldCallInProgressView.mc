using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Communications;
using Toybox.System;
using Toybox.Lang;

class OldCallInProgressView extends WatchUi.View {
    var phone as Phone;

    function initialize(phone as Phone) {
        View.initialize();
        self.phone = phone;
    }

    public function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    function onUpdate(dc) {
        View.onUpdate(dc);

        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    }
}

class OldCallInProgressViewDelegate extends WatchUi.InputDelegate {
    function initialize() {
        WatchUi.InputDelegate.initialize();
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Lang.Boolean {
        var key = keyEvent.getKey();
        dump("onKey", key);
        switch(key) {
            default:
                hangupCallInProgress();
                return true;
        }
    }
}

