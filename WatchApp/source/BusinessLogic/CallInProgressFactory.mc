using Toybox.WatchUi;

function newCallInProgressView(phone as Phone) as CallInProgressView {
    return new CallInProgressView(phone);
}

function newCallInProgressViewDelegate(phone as Phone) as CallInProgressViewDelegate {
    return new CallInProgressViewDelegate(phone);
}
