// Author: Modcrab

@wrapMethod(CPlayerInput) function OnCbtAttackHeavy( action : SInputAction )
{
	// modcrab
	if ( theInput.LastUsedGamepad() && IsPressed( action ) && GetWitcherPlayer().ModcrabIsPlayerInMeditationOrMeditationWaitingState() )
	{
		GetWitcherPlayer().ModcrabRequestAlchemyMenuDuringMeditationFromGamepadOrMouseClick();
	}
	else
	{
		wrappedMethod(action);
	}                                                                                                                                                 
}