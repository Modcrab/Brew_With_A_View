// Author: Modcrab

@wrapMethod(CR4CommonMenu) function OnRequestMenu( MenuName : name, MenuState : string)
{
	var requestingMeditationViaTab : bool;
	var currentSubMenu : CR4MenuBase;
		
	currentSubMenu = (CR4MenuBase)GetSubMenu();
	requestingMeditationViaTab = false;

	if( MenuName == (name)'MeditationClockMenu' && GetWitcherPlayer().ModcrabIsPlayerSleeping() == false)
	{
		if (currentSubMenu)
		{
			requestingMeditationViaTab = true;
			GetWitcherPlayer().ModcrabSetRequestedClockMenuViaTab( true );
		}
		else
		{
			GetWitcherPlayer().ModcrabSetRequestedClockMenuViaTab( false );
		
			if (GetWitcherPlayer().Meditate())
			{
				// will go to meditation
			}
			else
			{
				GetWitcherPlayer().ModcrabCantMeditateFeedback( true );
			}
			CloseMenu();
			return false;
		}
	}

	wrappedMethod( MenuName , MenuState );
}