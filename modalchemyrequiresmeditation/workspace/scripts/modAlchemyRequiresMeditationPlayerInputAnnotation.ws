// Author: Modcrab

@wrapMethod(CPlayerInput) function OnCbtAttackHeavy( action : SInputAction )
{
	// modcrab
	if ( theInput.LastUsedGamepad() && IsPressed( action ) && GetWitcherPlayer().ModcrabCanOpenAlchemyMenuDuringMeditation() )
	{
		GetWitcherPlayer().ModcrabRequestAlchemyMenuDuringMeditation();
	}
	else
	{
		wrappedMethod(action);
	}                                                                                                                                                 
}