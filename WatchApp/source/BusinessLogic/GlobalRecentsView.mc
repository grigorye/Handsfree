import Toybox.Lang;

function newRecentsView() as RecentsScreen.View {
    var lastRecentsCheckDate = getLastRecentsCheckDate();
    return new RecentsScreen.View(lastRecentsCheckDate);
}
