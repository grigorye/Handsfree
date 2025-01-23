import Toybox.System;

function newPhonesView() as PhonesScreen.View {
    return new PhonesScreen.View(X.phones.value());
}