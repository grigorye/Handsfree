import Toybox.System;

function newPhonesView() as PhonesView {
    return new PhonesView(PhonesManip.getPhones());
}