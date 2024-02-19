using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.Lang;

class CommListener extends Communications.ConnectionListener {
    function initialize() {
        Communications.ConnectionListener.initialize();
    }

    function onComplete() {
        System.println("Transmit Complete");
    }

    function onError() {
        System.println("Transmit Failed");
    }
}

class CommInputDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        WatchUi.BehaviorDelegate.initialize();
    }

    function onMenu() {
        var menu = new WatchUi.Menu2({:title=>"Call"});
        for(var i = 0; i < phones.size(); i++) {
            var phone = phones[i] as Lang.Dictionary<Lang.String, Lang.String>;
            var item = new MenuItem(
                phone["name"], // label
                phone["number"], // subLabel
                phone["id"], // identifier
                {}
            );
            menu.addItem(item);
        }
        var delegate = new BaseMenuDelegate();
        WatchUi.pushView(menu, delegate, SLIDE_IMMEDIATE);

        return true;
    }

    function onTap(event) {
        if(page == 0) {
            page = 1;
        } else {
            page = 0;
        }
        WatchUi.requestUpdate();
        return true;
    }
}

class BaseMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        WatchUi.Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        var selectedPhone = null as Lang.Dictionary<Lang.String, Lang.String> or Null;
        for(var i = 0; i < phones.size(); i++) {
            var phone = phones[i] as Lang.Dictionary<Lang.String, Lang.String>;
            if(phone["id"] == id) {
                selectedPhone = phone;
                break;
            }
        }
        if(selectedPhone == null) {
            return;
        }
        var listener = new CommListener();
        Communications.transmit(selectedPhone["number"], null, listener);

        WatchUi.popView(SLIDE_IMMEDIATE);
    }
}
