// Author: Modcrab

@wrapMethod(CPlayerInput) function OnCbtAttackHeavy( action : SInputAction )
{
	// modcrab
	if ( theInput.LastUsedGamepad() && IsPressed( action ) && GetWitcherPlayer().ModcrabIsPlayerInMeditationOrMeditationWaitingState() )
	{
		GetWitcherPlayer().ModcrabRequestAlchemyMenuDuringMeditation();
	}
	else
	{
		wrappedMethod(action);
	}                                                                                                                                                 
}