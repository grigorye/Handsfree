import Toybox.Lang;

function newRecentsView() as RecentsView {
    var lastRecentsCheckDate = getLastRecentsCheckDate();
    return new RecentsView(lastRecentsCheckDate);
}
