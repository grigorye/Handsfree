using Toybox.System;
using Toybox.Lang;
using Toybox.WatchUi;

typedef Phone as Lang.Dictionary<Lang.String, Lang.String>;
typedef Phones as Lang.Array<Phone>;

var phonesImp as Phones = [
    { "number" => "1233", "name" => "Crash Me", "id" => -1 },
    { "number" => "1233", "name" => "VoiceMail", "id" => 23 }
];

function getPhones() as Phones {
    return phonesImp;
}

function setPhones(phones as Phones) {
    phonesImp = phones;
}

//

class DismissedCallInProgress {
    var phone as Phone;
    
    function initialize(phone as Phone) {
        self.phone = phone;
    }
}

class CallInProgress {
    var phone as Phone;
    
    function initialize(phone as Phone) {
        self.phone = phone;
    }
}

class Ringing {
    var phone as Phone;

    function initialize(phone as Phone) {
        self.phone = phone;
    }
}

class Idle {
    function initialize() {
    }
}

//

typedef CallState as Idle or Ringing or CallInProgress or DismissedCallInProgress;

var callStateImp as CallState = new Idle(); // new CallInProgress({ "number" => "1233", "name" => "VoiceMail", "id" => 23 });

function getCallState() as CallState {
    return callStateImp;
}

function setCallState(callState as CallState) {
    callStateImp = callState;
    dumpCallState("setCallState", callState);
    router.updateRoute();
}

function dumpCallState(tag as Lang.String, callState as CallState) {
    switch(callState) {
        case instanceof Ringing:
            dump(tag, "Ringing");
            break;
        case instanceof CallInProgress:
            dump(tag, "CallInProgress(" + callState.phone["number"] + ")");
            break;
        case instanceof DismissedCallInProgress:
            dump(tag, "DismissedCallInProgress(" + callState.phone["number"] + ")");
            break;
        default:
            dump(tag, "null");
            break;
    }
}

//

function phoneForNumber(number as Lang.String) as Phone {
    var phones = getPhones();
    for (var i = 0; i < phones.size(); i++) {
        if(phones[i]["number"] == number) {
            return phones[i];
        }
    }
    return {
        "number" => number,
        "name" => "Unknown",
        "id" => 0
    };
}

function setCallInProgress(number as Lang.String) {
    var phones = getPhones();
    for (var i = 0; i < phones.size(); i++) {
        if(phones[i]["number"] == number) {
            setCallState(new CallInProgress(phones[i]));
            return;
        }
    }
}
