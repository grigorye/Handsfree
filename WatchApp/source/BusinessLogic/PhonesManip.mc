function getPhones() as Phones {
    return appStateImp.phones;
}

function setPhones(phones as Phones) as Void {
    appStateImp.phones = phones;
    router.updateRoute();
}
