using Toybox.Communications;
using Toybox.Lang;

const companionInstallationUrl = "https://grigorye.github.io/handsfree/Installation";

var didRequestCompanionInstallation as Lang.Boolean = false;

function requestCompanionInstallation() as Void {
    Communications.openWebPage(companionInstallationUrl, null, null);
    didRequestCompanionInstallation = true;
}