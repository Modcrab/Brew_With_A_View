// Author: Modcrab

@addMethod(W3Campfire) public timer function ModcrabToggleFireOn(dt : float, id : int)
{
	ToggleFire( true );
}

@addMethod(W3Campfire) public timer function ModcrabToggleFireOff(dt : float, id : int)
{
	ToggleFire( false );
}

@addMethod(W3Campfire) public timer function ModcrabDestroyCampfire(dt : float, id : int)
{
	ToggleFire( false );
	((CEntity)this).Destroy();
}

@addMethod(W3Campfire) public function ModcrabIsOnFire() : bool
{
	return IsOnFire();
}