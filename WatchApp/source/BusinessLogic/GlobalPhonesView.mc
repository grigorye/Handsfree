import Toybox.System;

function newPhonesView() as PhonesScreen.View {
    return new PhonesScreen.View(PhonesManip.getPhones());
}