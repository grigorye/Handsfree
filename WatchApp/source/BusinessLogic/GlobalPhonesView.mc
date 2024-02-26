var phonesViewImp as PhonesView or Null;

function getPhonesView() as PhonesView {
    if (phonesViewImp == null) {
        fatalError("phonesView is not set yet");
    }
    return phonesViewImp as PhonesView;
}

function setPhonesView(phonesView as PhonesView) as Void {
    if (phonesViewImp != null) {
        fatalError("phonesView is already set");
    }
    phonesViewImp = phonesView;
}
