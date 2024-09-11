using Toybox.System;
using Toybox.Lang;

function preprocessSpecialPhone(phone as Phone) as Lang.Boolean {
    if (getPhoneName(phone).equals("Crash Me")) {
        crashMe();
        return true;
    } else {
        return false;
    }
}
