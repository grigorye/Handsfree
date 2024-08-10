using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

(:glance, :background)
class NoArgPlaceholder {}

(:glance, :background)
var noArg as NoArgPlaceholder = new NoArgPlaceholder();

(:glance, :background)
var isLogAllEnforced as Lang.Boolean = true;

(:glance, :background)
class LogComponent {
    var name as Lang.String;
    var enabled as Lang.Boolean;

    function initialize(name as Lang.String, enabled as Lang.Boolean) {
        self.name = name;
        self.enabled = enabled;
    }

    function toString() as Lang.String {
        return self.name;
    }
}

typedef LogArgsWithValue as [LogComponent, Lang.String, Lang.Object or Null];
typedef LogArgsWithoutValue as [LogComponent, Lang.String];

(:glance, :background)
function _(info as LogArgsWithoutValue or LogArgsWithValue) as Void {
    var component = info[0] as LogComponent;
    var tag = info[1] as Lang.String;
    var value;
    if (info.size() == 3) {
        value = info[2] as Lang.Object or Null;
    } else {
        value = noArg as Lang.Object;
    }
    if (!component.enabled && !isLogAllEnforced) {
        return;
    }
    var qualifiedTag = component.toString() + "." + tag;
    dump(qualifiedTag, value);
}

(:glance, :background)
function dump(tag as Lang.String, output as Lang.Object or Null) as Void {
    var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

    if (newSession) {
        newSession = false;
        System.println("");
        var dateFormatted =
            (info.year as Lang.Number).format("%02d") + "/" +
            (info.month as Lang.Number).format("%02d") + "/" +
            info.day.format("%02d");

        //             "23:57:28 "
        System.println("-------- " + dateFormatted + " (" + sourceVersion() + ")");
    }

    var timePrefix =
        info.hour.format("%02d") + ":" +
        info.min.format("%02d") + ":" +
        info.sec.format("%02d") + " ";
    if (output instanceof NoArgPlaceholder) {
        System.println(timePrefix + tag);
    } else {
        System.println(timePrefix + tag + ": " + output);
    }
}

(:glance, :background)
var newSession as Lang.Boolean = true;
