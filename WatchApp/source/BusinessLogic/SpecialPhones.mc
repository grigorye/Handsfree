using Toybox.System;

function preprocessSpecialPhone(phone as Phone) as Void {
    if (getPhoneName(phone).equals("Crash Me")) {
        System.error("Crashing!");
    }
}
