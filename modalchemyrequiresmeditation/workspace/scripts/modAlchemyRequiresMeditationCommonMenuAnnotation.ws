// Author: Modcrab

@wrapMethod(CR4CommonMenu) function OnRequestMenu( MenuName : name, MenuState : string)
{
	var currentSubMenu : CR4MenuBase;	
	currentSubMenu = (CR4MenuBase)GetSubMenu();

	if( MenuName == (name)'MeditationClockMenu' && GetWitcherPlayer())
	{
		GetWitcherPlayer().ModcrabSetClockMenuShouldConfirmIntent( false );
		
		if (GetWitcherPlayer().ModcrabIsPlayerSleeping() == false)
		{
			if (currentSubMenu && ModcrabAlchemyRequiresMeditationGetConfigValueAsBool( 'modAlchemyRequiresMeditationConfirmIntent' ))
			{
				GetWitcherPlayer().ModcrabSetClockMenuShouldConfirmIntent( true );
			}
			
			
			if (GetWitcherPlayer().modcrabClockMenuShouldConfirmIntent)
			{
				// do nothing, open the menu as usual
			}
			else
			{
			
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
	}

	wrappedMethod( MenuName , MenuState );
}