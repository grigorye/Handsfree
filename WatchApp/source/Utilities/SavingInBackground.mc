import Toybox.System;
import Toybox.Lang;

(:background, :glance)
function canSaveInBackground() as Lang.Boolean {
    var monkeyVersion = System.getDeviceSettings().monkeyVersion;
    return monkeyVersion[0] > 3 or (monkeyVersion[0] == 3 and monkeyVersion[1] >= 2);
}
