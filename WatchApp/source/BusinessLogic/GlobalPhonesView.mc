using Toybox.System;

var phonesViewImp as PhonesView or Null;

function getPhonesView() as PhonesView {
    if (phonesViewImp == null) {
        dump("settingInitialPhonesView", true);
        var phonesView = new PhonesView();
        phonesView.updateFromCallState(getOldCallState());
        phonesView.updateFromPhones(getPhones());
        phonesViewImp = phonesView;
    }
    return phonesViewImp as PhonesView;
}

function setPhonesView(phonesView as PhonesView) as Void {
    if (phonesViewImp != null) {
        System.error("phonesView is already set");
    }
    setPhonesViewImp(phonesView);
}

function setPhonesViewImp(phonesView as PhonesView or Null) as Void {
    phonesViewImp = phonesView;
}
