// Author: Modcrab

// Summary: different ways in which the meditation clock menu can operate
enum EModcrabMeditationClockMode
{
	EMMCM_Default,      // geralt is visible behind the clock, use the clock to advance time
	EMMCM_Rest,         // like Default, but only used for sleeping in a bed, and you can't see Geralt behind
	EMMCM_ConfirmIntent // only shows when switching CommonMenu tabs, and appears to prompt the user to confirm that they want to start meditation, so they don't get booted out of the menu by accident
};

// Summary: different configurations for the camera during meditation
enum EModcrabMeditationCameraStyle
{
	EMMCS_Default,      // brew with a view default
	EMMCS_Close,        // immersive meditation style
}

// Summary: checks if the clock menu is currently active, and returns a reference to it
function ModcrabIsClockMenuShowing(out clockMenu : CR4MeditationClockMenu) : bool
{
	clockMenu = NULL;
	if (theGame.GetGuiManager().IsAnyMenu() == false)
		return false;
	if (!theGame.GetGuiManager().GetRootMenu())
		return false;	
	clockMenu = (CR4MeditationClockMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild();
	if (!clockMenu)
		return false;
	return true;
}

// --- Debug ---

function ModcrabDebugLog( message : string )
{
	theGame.GetGuiManager().ShowNotification(message,, true);
}