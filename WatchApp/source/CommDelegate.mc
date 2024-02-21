using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.Lang;

typedef Phone as Lang.Dictionary<Lang.String, Lang.String>;

class CommListener extends Communications.ConnectionListener {
    var progressBar as WatchUi.ProgressBar;
    var phone as Phone;
    var timer = new Timer.Timer();

    function initialize(phone as Phone) {
        self.phone = phone;
        self.progressBar = new WatchUi.ProgressBar(
            "Calling" + "\n" + phone["number"],
            null
        );
        Communications.ConnectionListener.initialize();
    }

    function onStart() {
        WatchUi.pushView(
            progressBar,
            null,
            WatchUi.SLIDE_DOWN
        );
    }

    function onComplete() {
        progressBar.setProgress(100.0);
        progressBar.setDisplayString("Completed.");
        timer.start(method(:dismiss), 1000, false);
    }

    function onError() {
        progressBar.setProgress(0.0);
        progressBar.setDisplayString("Dialing failed.");
        timer.start(method(:dismiss), 1000, false);
    }

    function dismiss() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

class CommInputDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        var menu = new Menu2({:title=>"Call"});
        var phones = getPhones();
        for(var i = 0; i < phones.size(); i++) {
            var phone = phones[i];
            var item = new MenuItem(
                phone["name"], // label
                phone["number"], // subLabel
                phone["id"], // identifier
                {}
            );
            menu.addItem(item);
        }
        var delegate = new BaseMenuDelegate();
        pushView(menu, delegate, SLIDE_IMMEDIATE);

        return true;
    }

    function onTap(event) {
        requestUpdate();
        return true;
    }
}

class BaseMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        var selectedPhone = null as Phone or Null;
        var phones = getPhones();
        for(var i = 0; i < phones.size(); i++) {
            var phone = phones[i];
            if(phone["id"] == id) {
                selectedPhone = phone;
                break;
            }
        }
        if(selectedPhone == null) {
            return;
        }
        new CallTask(selectedPhone).launch();
    }
}

class CallTask {
    var phone as Phone;
    var timer = new Timer.Timer();
    var listener as CommListener;

    function initialize(phone as Phone) {
        self.phone = phone;
        self.listener = new CommListener(phone);
    }

    function transmit() {
        Communications.transmit(phone["number"], null, listener);
    }

    function launch() {
        listener.onStart();
        timer.start(method(:transmit), 1000, false);
    }
}