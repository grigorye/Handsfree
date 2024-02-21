using Toybox.Application;
using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;

var phonesImp = [{ "number" => "1233", "name" => "VoiceMail", "id" => 23 }] as Lang.Array<Phone>;

function setPhones(phones as Lang.Array<Phone>) {
    phonesImp = phones;
    WatchUi.requestUpdate();
}

function getPhones() as Lang.Array<Phone> {
    return phonesImp;
}

var phoneMethod;
var hasDirectMessagingSupport = true;

class CommExample extends Application.AppBase {

    function initialize() {
        Application.AppBase.initialize();

        phoneMethod = method(:onPhone);
        if(Communications has :registerForPhoneAppMessages) {
            Communications.registerForPhoneAppMessages(phoneMethod);
        } else {
            hasDirectMessagingSupport = false;
        }
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [new CommView(), new CommInputDelegate()];
    }

    function onPhone(msg) {
        setPhones(msg.data as Lang.Array<Phone>);
    }
}