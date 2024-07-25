using Toybox.WatchUi;
using Toybox.Lang;

var useCallInProgress2 as Lang.Boolean = true;

function newCallInProgressView(phone as Phone) as CallInProgressView or CallInProgressView2 {
    if (useCallInProgress2) {
        return new CallInProgressView2(phone);
    } else {
        return new CallInProgressView(phone);
    }
}

function newCallInProgressViewDelegate(phone as Phone) as CallInProgressViewDelegate or CallInProgressView2Delegate {
    if (useCallInProgress2) {
        return new CallInProgressView2Delegate(phone);
    } else {
        return new CallInProgressViewDelegate(phone);
    }
}
