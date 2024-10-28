import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

const L_VIEW_TRACKING as LogComponent = "$$";

typedef ViewTag as Lang.String;
class ViewStackEntry extends Lang.Object {

    function initialize(tag as ViewTag, view as WatchUi.Views, delegate as Null or WatchUi.InputDelegates) {
        self.tag = tag;
        self.view = view;
        self.delegate = delegate;
    }

    var tag as ViewTag;
    var view as WatchUi.Views;
    var delegate as Null or WatchUi.InputDelegates;
}

typedef ViewStack as Lang.Array<ViewStackEntry>;
var viewStack as ViewStack = [];

function viewStackTags() as Lang.Array<ViewTag> {
    var tags = [] as Lang.Array<ViewTag>;
    for (var i = 0; i < viewStack.size(); i++) {
        tags.add(viewStack[i].tag);
    }
    return tags;
}

function switchToView(tag as ViewTag, view as WatchUi.Views, delegate as WatchUi.InputDelegates or Null, transition as WatchUi.SlideType) as Void {
    viewStack[viewStack.size() - 1] = new ViewStackEntry(tag, view, delegate);
    dumpViewStack("switchToView");
    WatchUi.switchToView(view, delegate, transition);
}

function pushView(tag as ViewTag, view as WatchUi.Views, delegate as WatchUi.InputDelegates or Null, transition as WatchUi.SlideType) as Lang.Boolean {
    viewStack.add(new ViewStackEntry(tag, view, delegate));
    dumpViewStack("pushView");
    assertViewStackIsSane();
    return WatchUi.pushView(view, delegate, transition);
}

function popView(transition as WatchUi.SlideType) as Void {
    dumpViewStack("popView");
    viewStack = viewStack.slice(null, -1);
    WatchUi.popView(transition);
}

function trackBackFromView() as Void {
    viewStack = viewStack.slice(null, -1);
    dumpViewStack("backFromView");
}

function trackInitialView(tag as ViewTag, view as WatchUi.Views, delegate as Null or WatchUi.InputDelegates) as Void {
    viewStack.add(new ViewStackEntry(tag, view, delegate));
    dumpViewStack("initialView");
}

function dumpViewStack(tag as Lang.String) as Void {
    if (viewDebug) { _3(L_VIEW_TRACKING, tag, viewStackTags()); }
}

function topView() as WatchUi.Views or Null {
    if (viewStack.size() == 0) {
        return null;
    }
    return topViewStackEntry().view;
}

function topViewIs(tag as ViewTag) as Lang.Boolean {
    return topViewStackEntry().tag.equals(tag);
}

function topViewStackEntry() as ViewStackEntry {
    return viewStack[viewStack.size() - 1];
}

function assertViewStackIsSane() as Void {
    var uniqueViewTags = [] as Lang.Array<ViewTag>;
    for (var i = 0; i < viewStack.size(); i++) {
        if (uniqueViewTags.indexOf(viewStack[i].tag) != -1) {
            dumpViewStack("messedUp");
            if (viewDebug) { _3(L_VIEW_TRACKING, "nonUniqueView", viewStack[i]); }
            System.error("viewStackIsMessedUp");
        }
    }
}

function viewStackSize() as Lang.Number {
    return viewStack.size();
}

function viewStackTagsEqual(other as Lang.Array<ViewTag>) as Lang.Boolean {
    if (viewStack.size() != other.size()) {
        return false;
    }
    for (var i = 0; i < viewStack.size(); i++) {
        if (!viewStack[i].tag.equals(other[i])) {
            return false;
        }
    }
    return true;
}

function viewWithTag(tag as ViewTag) as WatchUi.Views or Null {
    for (var i = 0; i < viewStack.size(); i++) {
        if (viewStack[i].tag.equals(tag)) {
            return viewStack[i].view;
        }
    }
    return null;
}