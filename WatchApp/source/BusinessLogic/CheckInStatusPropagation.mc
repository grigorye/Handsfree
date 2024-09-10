function updateForCheckInStatus() as Void {
    var mainMenu = viewWithTag("mainMenu") as MainMenu;
    if (getCallState() instanceof Idle) {
        mainMenu.update();
    }
}