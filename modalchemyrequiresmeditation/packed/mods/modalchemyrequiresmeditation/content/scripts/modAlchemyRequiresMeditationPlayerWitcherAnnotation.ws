// Author: Modcrab

@addField(W3PlayerWitcher)
public var modcrabIsMeditating : bool;

@addField(W3PlayerWitcher)
public var modcrabIsAbortingMeditation : bool;

@addField(W3PlayerWitcher)
public var modcrabShouldReopenMeditationClockMenu : bool;

@addField(W3PlayerWitcher)
public var modcrabMeditationCampfireInstance : W3Campfire;

@addMethod(W3PlayerWitcher) public function ModcrabMeditationWillUseCampfire() : int
{
	var willUseCampfire : int;
	if (IsInInterior() || IsInSettlement())
	{
		willUseCampfire = 0;
	}
	else
	{
		willUseCampfire = 1;
	}
	return willUseCampfire;
}

@addMethod(W3PlayerWitcher) public function ModcrabOnMeditationStart()
{
	var blockedInputExceptions : array< EInputActionBlock >;
	
	if (ModcrabIsPlayerSleeping())
	{
		return;
	}

	// reset logic
	modcrabIsMeditating = true;
	modcrabIsAbortingMeditation = false;
	modcrabShouldReopenMeditationClockMenu = false;
	modcrabMeditationCampfireInstance = NULL;

	if (ModcrabMeditationWillUseCampfire() == 1)
		ModcrabMeditationCreateCampfire();
	
	// this stops the player being able to move the camera around
	thePlayer.EnableManualCameraControl(false, 'modAlchemyRequiresMeditation');
	
	// this will prevent the player from doing anything other than interacting with the meditation menu
	// they can also open the fast menu
	// make an exception for glossary, so the player can access the entire fast menu (except meditation)
	blockedInputExceptions.PushBack( EIAB_OpenGlossary );
	thePlayer.BlockAllActions('modAlchemyRequiresMeditationDuring', true, blockedInputExceptions, true);
}
	
@addMethod(W3PlayerWitcher) public function ModcrabOnMeditationStop() : void
{
	if (ModcrabIsPlayerSleeping())
	{
		return;
	}

	modcrabIsMeditating = false;

	// campfire will despawn faster if we are aborting meditation
	if (modcrabMeditationCampfireInstance)
		modcrabMeditationCampfireInstance.TurnOffCampfireForMeditation(modcrabIsAbortingMeditation);
	modcrabMeditationCampfireInstance = NULL;		
	
	// this time we put in a block with no expections, until the player is completely out of the meditation state
	thePlayer.BlockAllActions('modAlchemyRequiresMeditationStop', true);
	
	// keep looping until the player is out of the state, then unblock
	AddTimer('ModcrabUnblockAllActions', 0.2, false);
}

@addMethod(W3PlayerWitcher) timer function ModcrabUnblockAllActions( dt : float, id : int ) 
{
	if (GetWitcherPlayer().GetCurrentStateName() != 'Meditation')
	{
		// unblock everything
		thePlayer.EnableManualCameraControl(true, 'modAlchemyRequiresMeditation');
		thePlayer.BlockAllActions('modAlchemyRequiresMeditationDuring', false);
		thePlayer.BlockAllActions('modAlchemyRequiresMeditationStop', false);
	}
	else
	{
		// if not out of the state, try again after a short delay
		AddTimer('ModcrabUnblockAllActions', 0.2, false);
	}
}

@addMethod(W3PlayerWitcher) private function ModcrabMeditationCreateCampfire() : void
{
	var pos : Vector;
	var rot : EulerAngles;
	var template : CEntityTemplate;
	var z : float;
	
	template = (CEntityTemplate)LoadResource( "environment\decorations\light_sources\campfire\campfire_01.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecFromHeading( thePlayer.GetHeading() ) * Vector(0.8, 0.8, 0);
	if( theGame.GetWorld().NavigationComputeZ( pos, pos.Z - 128, pos.Z + 128, z ) )
	{
		pos.Z = z;
	}
	if( theGame.GetWorld().PhysicsCorrectZ( pos, z ) )
	{
		pos.Z = z;
	}
	rot = thePlayer.GetWorldRotation();
	modcrabMeditationCampfireInstance = (W3Campfire)theGame.CreateEntity(template, pos, rot);
	modcrabMeditationCampfireInstance.TurnOnCampfireForMeditation();
}

@addMethod(W3PlayerWitcher) public function ModcrabMeditationRequestMeditationClockMenu()
{
	ModcrabSetShouldReopenMeditationClockMenu(false);
	
	// by requesting the menu with itself as the background, this let's see you see Geralt behind the menu
	theGame.RequestMenuWithBackground( 'MeditationClockMenu', 'MeditationClockMenu' );
}

@addMethod(W3PlayerWitcher) public function ModcrabSetShouldReopenMeditationClockMenu( value : bool )
{
	modcrabShouldReopenMeditationClockMenu = value;
}

@addMethod(W3PlayerWitcher) public function ModcrabMeditationRequestAlchemyMenu()
{	
	// this will close the meditation clock menu, so we will have to reopen it manually (inside Meditation state)
	theGame.RequestMenuWithBackground( 'AlchemyMenu', 'CommonMenu' );
}

@addMethod(W3PlayerWitcher) public function ModcrabMeditationUpdateCamera( out moveData : SCameraMovementData, timeDelta : float )
{
	var pos : Vector;
	var rotation : EulerAngles = GetWorldRotation();

	theGame.GetGameCamera().ChangePivotRotationController( 'ExplorationInterior' );
	theGame.GetGameCamera().ChangePivotDistanceController( 'Default' );
	theGame.GetGameCamera().ChangePivotPositionController( 'Default' );
		
	pos = thePlayer.GetWorldPosition() + VecFromHeading( thePlayer.GetHeading() ) * Vector(0.6, 0.6, 0);
	moveData.pivotPositionController.SetDesiredPosition( pos, 15.f );
	moveData.pivotPositionController.offsetZ = 0.3f;

	moveData.pivotDistanceController.SetDesiredDistance( 6.0 );
	
	DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( -0.6 , 1.5, 0.6  ), 0.6, timeDelta );
	
	moveData.pivotRotationController.SetDesiredPitch( -1.0, 0.2 );
	moveData.pivotRotationController.SetDesiredHeading( rotation.Yaw + 240, 0.3 );
}

@addMethod(W3PlayerWitcher) public function ModcrabCanDoAlchemy() : bool
{
	// only allowed during meditation state, which means not in shops or whilst advancing time
	return GetCurrentStateName() == 'Meditation' && modcrabIsMeditating;
}

@addMethod(W3PlayerWitcher) public function ModcrabCanOpenAlchemyMenu() : bool
{
	// also requires meditation clock menu to be showing
	return ModcrabCanDoAlchemy() && theGame.GetGuiManager().IsAnyMenu();
}

@addMethod(W3PlayerWitcher) public function ModcrabAdvanceTimeDueToAlchemy() : int
{			
	var gameMinutesToAdvance : int;	
	var gameSecondsToAdvance : int;
	var realTimeSecondsToAdvance : float;
	
	// you can change 15 to anything you like
	gameMinutesToAdvance = 15;
	gameSecondsToAdvance = 60 * gameMinutesToAdvance;
	realTimeSecondsToAdvance = ConvertGameSecondsToRealTimeSeconds( gameSecondsToAdvance );
	
	// move game time forward, and advance effects on player too
	theGame.SetGameTime( theGame.GetGameTime() + GameTimeCreateFromGameSeconds( gameSecondsToAdvance ), false );
	effectManager.PerformUpdate( realTimeSecondsToAdvance );
	
	return gameMinutesToAdvance;
}

@addMethod(W3PlayerWitcher) public function ModcrabIsPlayerSleeping() : bool
{
	var bed : W3WitcherBed;
	bed = (W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' );
	if (bed) return bed.GetWasUsed();
	
	return false;
}