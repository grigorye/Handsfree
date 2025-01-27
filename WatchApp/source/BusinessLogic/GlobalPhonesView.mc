import Toybox.System;

function newPhonesView() as PhonesScreen.View {
    return new PhonesScreen.View(loadValueWithDefault(Phones_valueKey, Phones_defaultValue) as Phones);
}
