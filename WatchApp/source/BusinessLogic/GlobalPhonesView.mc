using Toybox.System;

function newPhonesView() as PhonesView {
    return new PhonesView(getPhones());
}