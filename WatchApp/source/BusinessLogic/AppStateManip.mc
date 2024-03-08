function getAppState() as AppState {
    if (appStateImp == null) {
        appStateImp = new AppState();
    }
    return appStateImp as AppState;
}

var appStateImp as AppState or Null;
