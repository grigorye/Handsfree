(:background, :glance)
function appConfigDidChange() as Void {
    Req.requestSubjects(appConfigSubject);
}
