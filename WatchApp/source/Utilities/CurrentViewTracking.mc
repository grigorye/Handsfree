using Toybox.WatchUi;
using Toybox.Lang;
using Toybox.System;

typedef ViewStack as Lang.Array<Lang.String>;
var viewStack as ViewStack = [];

function switchToView(tag as Lang.String, view as $.Toybox.WatchUi.Confirmation or $.Toybox.WatchUi.Menu or $.Toybox.WatchUi.NumberPicker or $.Toybox.WatchUi.ProgressBar or $.Toybox.WatchUi.TextPicker or $.Toybox.WatchUi.View or $.Toybox.WatchUi.ViewLoop, delegate as Null or $.Toybox.WatchUi.InputDelegates, transition as $.Toybox.WatchUi.SlideType) as Void {
    viewStack[viewStack.size() - 1] = tag;
    dump("$$switchToView", viewStack);
    WatchUi.switchToView(view, delegate, transition);
}

function pushView(tag as Lang.String, view as $.Toybox.WatchUi.Confirmation or $.Toybox.WatchUi.Menu or $.Toybox.WatchUi.NumberPicker or $.Toybox.WatchUi.ProgressBar or $.Toybox.WatchUi.TextPicker or $.Toybox.WatchUi.View or $.Toybox.WatchUi.ViewLoop, delegate as Null or $.Toybox.WatchUi.InputDelegates, transition as $.Toybox.WatchUi.SlideType) as $.Toybox.Lang.Boolean {
    viewStack.add(tag);
    dump("$$pushView", viewStack);
    assertViewStackIsSane(viewStack);
    return WatchUi.pushView(view, delegate, transition);
}

function popView(transition as $.Toybox.WatchUi.SlideType) as Void {
    viewStack = viewStack.slice(null, -1);
    dump("$$popView", viewStack);
    WatchUi.popView(transition);
}

function trackBackFromView() as Void {
    viewStack = viewStack.slice(null, -1);
    dump("$$backFromView", viewStack);
}

function trackInitialView(tag as Lang.String) as Void {
    viewStack.add(tag);
    dump("$$initialView", viewStack);
}

function dumpViewStack(tag as Lang.String) as Void {
    dump("$$" + tag, viewStack);
}

function topViewIs(tag as Lang.String) as Lang.Boolean {
    return viewStack[viewStack.size() - 1].equals(tag);
}

function assertViewStackIsSane(viewStack as ViewStack) as Void {
    var uniqueViews = [] as ViewStack;
    for (var i = 0; i < viewStack.size(); i++) {
        if (uniqueViews.indexOf(viewStack[i]) != -1) {
            dumpViewStack("messedUpViewStack");
            dump("nonUniqueView", viewStack[i]);
            System.error("viewStackIsMessedUp");
        }
    }
}
function viewStackEquals(other as ViewStack) as Lang.Boolean {
    if (viewStack.size() != other.size()) {
        return false;
    }
    for (var i = 0; i < viewStack.size(); i++) {
        if (!viewStack[i].equals(other[i])) {
            return false;
        }
    }
    return true;
}
