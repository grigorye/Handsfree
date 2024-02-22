using Toybox.WatchUi;
using Toybox.System;

class CommView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onUpdate(dc) {
        router.updateRoute();
    }
}
