(:background, :glance)
function settingsDidChange() as Void {
    Req.requestSubjects(appConfigSubject);
}
