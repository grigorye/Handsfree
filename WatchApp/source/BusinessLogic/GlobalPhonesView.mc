using Toybox.System;

var phonesViewImp as PhonesView or Null;

const L_PHONES_VIEW_INIT as LogComponent = new LogComponent("phonesView", false);

function getPhonesView() as PhonesView {
    if (phonesViewImp == null) {
        _([L_PHONES_VIEW_INIT, "settingInitialView"]);
        var phonesView = new PhonesView();
        phonesView.updateFromCallState(getCallState());
        phonesView.setFromPhones(getPhones());
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
