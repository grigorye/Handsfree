using Toybox.System;

(:background)
class DummyServiceDelegate extends System.ServiceDelegate {

    function initialize() {
        ServiceDelegate.initialize();
    }
}