using Toybox.WatchUi;

function getPhones() as Phones {
    return appStateImp.phones;
}

function setPhones(phones as Phones) as Void {
    appStateImp.phones = phones;
    getPhonesView().updateFromPhones(phones);
    WatchUi.requestUpdate();
}
