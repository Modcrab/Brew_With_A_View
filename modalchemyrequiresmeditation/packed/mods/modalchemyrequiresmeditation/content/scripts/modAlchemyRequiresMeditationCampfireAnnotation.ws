// Author: Modcrab

@addField(W3Campfire)
private var modcrabMeditationCampfireState : int; // 0 - init, 1 - lit, 2 - unlit, 3 - despawn

@addField(W3Campfire)
private var modcrabWasFireTurnedOn : bool;	

@addMethod(W3Campfire) public function TurnOnCampfireForMeditation()
{
	modcrabMeditationCampfireState = 0;
	AddTimer('BufferedTurnOnCampfireForMeditation', 4.9, false);
}

@addMethod(W3Campfire) timer function BufferedTurnOnCampfireForMeditation(dt : float, id : int)
{
	if (modcrabMeditationCampfireState < 1)
	{
		modcrabMeditationCampfireState = 1;
		modcrabWasFireTurnedOn = true;
		ToggleFire( true );
	}
}

@addMethod(W3Campfire) public function ModcrabWasFireTurnedOn() : bool
{
	return modcrabWasFireTurnedOn;
}

@addMethod(W3Campfire) public function TurnOffCampfireForMeditation(isAborting : bool)
{
	if (isAborting)
	{
		AddTimer('BufferedTurnOffCampfireForMeditation', 0.1, false);
		AddTimer('BufferedDestroyCampfireForMeditation', 0.5, false);
	}
	else
	{
		AddTimer('BufferedTurnOffCampfireForMeditation', 1.5, false);
		AddTimer('BufferedDestroyCampfireForMeditation', 5, false);
	}
}

@addMethod(W3Campfire) timer function BufferedTurnOffCampfireForMeditation(dt : float, id : int)
{
	if (modcrabMeditationCampfireState < 2)
	{
		modcrabMeditationCampfireState = 2;
		ToggleFire( false );
	}
}

@addMethod(W3Campfire) timer function BufferedDestroyCampfireForMeditation(dt : float, id : int)
{
	if (modcrabMeditationCampfireState < 3)
	{
		modcrabMeditationCampfireState = 3;
		((CEntity)this).Destroy();	
	}
}