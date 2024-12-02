// Author: Modcrab

@wrapMethod(CR4CommonMenu) function OnRequestMenu( MenuName : name, MenuState : string)
{
	if( MenuName == (name)'MeditationClockMenu' && GetWitcherPlayer().ModcrabIsPlayerSleeping() == false)
	{
		if (GetWitcherPlayer().Meditate())
		{
			// will go to meditation
		}
		else
		{
			GetWitcherPlayer().ModcrabCantMeditateFeedback();
		}
		CloseMenu();
		return false;
	}
	else
	{
		wrappedMethod( MenuName , MenuState );
	}
}