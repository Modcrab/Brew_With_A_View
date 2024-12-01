// Author: Modcrab

@addField(W3PlayerWitcher)
public var modcrabIsAbortingMeditation : bool;

@addField(W3PlayerWitcher)
public var modcrabShouldReopenMeditationClockMenu : bool;

@addField(W3PlayerWitcher)
public var modcrabMeditationCampfireInstance : W3Campfire;

@addField(W3PlayerWitcher)
private var modcrabCameraFOVVel : float;

@addField(W3PlayerWitcher)
private var modcrabMeditationNoSaveLock : int;

@addMethod(W3PlayerWitcher) public function ModcrabOnMeditationStart()
{
	var blockedInputExceptions : array< EInputActionBlock >;
	
	if (ModcrabIsPlayerSleeping())
	{
		return;
	}

	// reset logic
	modcrabIsAbortingMeditation = false;
	modcrabShouldReopenMeditationClockMenu = false;
	modcrabMeditationCampfireInstance = NULL;
	modcrabCameraFOVVel = 0;
	
	// check to spawn campfire and play ignite animation
	if (ModcrabWillUseCampfireDuringMeditation())
	{
		ModcrabCreateCampfireForMeditation();
		SetBehaviorVariable('MeditateWithIgnite', 1);
	}
	else
	{
		SetBehaviorVariable('MeditateWithIgnite', 0);
	}
	
	// this stops the player being able to move the camera around
	thePlayer.EnableManualCameraControl(false, 'modAlchemyRequiresMeditation');
	
	// this will prevent the player from doing anything other than interacting with the menus
	// we use the parameter which allows menu actions, but for some reason we still need to manually allow the glossary
	blockedInputExceptions.PushBack( EIAB_OpenGlossary );
	thePlayer.BlockAllActions('modAlchemyRequiresMeditationDuring', true, blockedInputExceptions, true);
	
	// this fixes an ugly camera snap if the player was sprinting when starting meditation
	if (playerMoveType == PMT_Sprint)
		EnableSprintingCamera(false);
		
	theGame.CreateNoSaveLock('modAlchemyRequiresMeditation', modcrabMeditationNoSaveLock);
}
	
@addMethod(W3PlayerWitcher) public function ModcrabOnMeditationStop() : void
{
	if (ModcrabIsPlayerSleeping())
	{
		return;
	}

	// campfire will despawn faster if we are aborting meditation
	if (modcrabMeditationCampfireInstance)
	{
		if (modcrabIsAbortingMeditation)
		{
			modcrabMeditationCampfireInstance.AddTimer('ModcrabDestroyCampfire', 0.45, false);
		}
		else
		{
			modcrabMeditationCampfireInstance.AddTimer('ModcrabToggleFireOff', 1.5, false);
			modcrabMeditationCampfireInstance.AddTimer('ModcrabDestroyCampfire', 5, false);
		}
	}
	
	modcrabMeditationCampfireInstance = NULL;		
	
	// this time we put in a block with no expections, until the player is completely out of the meditation state
	thePlayer.BlockAllActions('modAlchemyRequiresMeditationStop', true);
}

@addMethod(W3PlayerWitcher) public function ModcrabUnblockAllActions() 
{
	// unblock everything we blocked
	thePlayer.EnableManualCameraControl(true, 'modAlchemyRequiresMeditation');
	thePlayer.BlockAllActions('modAlchemyRequiresMeditationDuring', false);
	thePlayer.BlockAllActions('modAlchemyRequiresMeditationStop', false);
	theGame.ReleaseNoSaveLock(modcrabMeditationNoSaveLock);
}

@addMethod(W3PlayerWitcher) public function ModcrabWillUseCampfireDuringMeditation() : bool
{
	var playerPos : Vector;
	var campfirePos	: Vector;
	
	// simple checks
	if (IsInInterior() || IsInSettlement() || isOnBoat || isInShallowWater || IsThreatened())
	{
		return false;
	}
	
	// player underwater
	playerPos = GetWorldPosition();
	if (playerPos.Z <= theGame.GetWorld().GetWaterLevel(playerPos, true))
	{
		return false;
	}

	// campfire underwater
	campfirePos = ModcrabGetCampfirePositionForMeditation();
	if (campfirePos.Z <= theGame.GetWorld().GetWaterLevel(campfirePos, true))
	{
		return false;
	}
	
	// don't spawn the campfire if it would be very far away from the player
	if (AbsF(campfirePos.Z - playerPos.Z) > 0.5)
	{
		return false;
	}
	
	return true;
}

@addMethod(W3PlayerWitcher) private function ModcrabGetCampfirePositionForMeditation() : Vector
{
	var pos : Vector;
	var z : float;
	var distanceAheadOfPlayer : float;
	
	// we need to make adjustments if the player is running or sprinting as otherwise the campfire ends up underneath Geralt
	if (playerMoveType == PMT_Sprint)
	{
		distanceAheadOfPlayer = 1.5;
	}
	else if (playerMoveType == PMT_Run)
	{
		distanceAheadOfPlayer = 1.1;
	}
	else
	{
		distanceAheadOfPlayer = 0.8;
	}
	
	// directly ahead of the player, a little bit in front
	pos = GetWorldPosition() + VecFromHeading( thePlayer.GetHeading() ) * Vector(distanceAheadOfPlayer, distanceAheadOfPlayer, 0);
	
	// fix the z value to the floor
	if( theGame.GetWorld().NavigationComputeZ( pos, pos.Z - 128, pos.Z + 128, z ) )
	{
		pos.Z = z;
	}
	if( theGame.GetWorld().PhysicsCorrectZ( pos, z ) )
	{
		pos.Z = z;
	}
	
	return pos;
}

@addMethod(W3PlayerWitcher) private function ModcrabCreateCampfireForMeditation() : void
{
	var template : CEntityTemplate;
	var pos : Vector;
	var rot : EulerAngles;
	
	// load and instantiate the campfire
	template = (CEntityTemplate)LoadResource( "environment\decorations\light_sources\campfire\campfire_01.w2ent", true);
	pos = ModcrabGetCampfirePositionForMeditation();
	rot = thePlayer.GetWorldRotation();
	modcrabMeditationCampfireInstance = (W3Campfire)theGame.CreateEntity(template, pos, rot);
	
	// this is timed to match the ignite animation
	modcrabMeditationCampfireInstance.AddTimer('ModcrabToggleFireOn', 4.9);
}

@addMethod(W3PlayerWitcher) public function ModcrabRequestMeditationClockMenu()
{
	// cancel any requests to reopen the menu
	ModcrabSetShouldReopenMeditationClockMenu(false);
	
	// by requesting the menu with itself as the background, this let's see you see Geralt behind the menu
	theGame.RequestMenuWithBackground( 'MeditationClockMenu', 'MeditationClockMenu' );
}

@addMethod(W3PlayerWitcher) public function ModcrabSetShouldReopenMeditationClockMenu( value : bool )
{
	modcrabShouldReopenMeditationClockMenu = value;
}

@addMethod(W3PlayerWitcher) public function ModcrabRequestAlchemyMenuDuringMeditation()
{	
	// this will close the meditation clock menu, so we will have to reopen it manually (inside Meditation state)
	theGame.RequestMenuWithBackground( 'AlchemyMenu', 'CommonMenu' );
}

@addMethod(W3PlayerWitcher) public function ModcrabUpdateCameraDuringMeditation( out moveData : SCameraMovementData, timeDelta : float )
{
	var pos : Vector;
	var rotation : EulerAngles;
	var dir : Vector;
	var origin : Vector;
		
	// change pivot point to be just ahead of where the campfire would be
	dir = VecFromHeading( thePlayer.GetHeading() );
	dir = VecNormalize(dir);
	pos = thePlayer.GetWorldPosition() + (0.9 * dir);
	moveData.pivotPositionController.SetDesiredPosition( pos, 0.2 );
	moveData.pivotPositionController.offsetZ = 0.85;

	// I think this changes how far the camera is from the pivot point
	moveData.pivotDistanceController.SetDesiredDistance( 6.0 );
	
	// rotate around to look back at Geralt
	rotation = GetWorldRotation();
	moveData.pivotRotationController.SetDesiredHeading( rotation.Yaw + 240, 0.3 );
	moveData.pivotRotationController.SetDesiredPitch( -1.0, 0.2 );
	
	// I think this changes how close the cam can be to Geralt, but not exactly sure, either way it looks better with
	DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( -0.6 , 1.5, 0.6  ), 0.6, timeDelta );
	
	ModcrabUpdateCameraFOVForMeditation( timeDelta );
}

@addMethod(W3PlayerWitcher) public function ModcrabUpdateCameraLeavingMeditation( out moveData : SCameraMovementData, timeDelta : float )
{
	// we only need to approximately reset things as the camera will transition back to normal after we leave the meditation state
	// we are just trying to make that transition less noticeable
	var targetPos : Vector;
	var posSpeed : float;
	var offsetZ : float;
	var targetHeading : float;
	var headingSpeed : float;
	var targetPitch : float;
	var pitchSpeed : float;
	var targetDistance : float;
	var distanceSpeed : float;
	var targetLocalSpaceOffset : Vector;
	var playerRotation : EulerAngles;
	
	playerRotation = GetWorldRotation();
	
	targetPos = GetWorldPosition();
	posSpeed = 0.2;
	
	offsetZ = 1.5f;
	
	targetHeading = playerRotation.Yaw;
	headingSpeed = 0.18;
	
	targetPitch = playerRotation.Pitch;
	pitchSpeed = 0.18;
	
	targetDistance = 1.5f;
	distanceSpeed = 0.2f;
	
	targetLocalSpaceOffset = Vector( 0, 0, 0.225 );

	if (interiorCamera) // over the shoulder camera in interior
	{	
		if (thePlayer.GetExplCamera()) // player is using Close exploration camera setting
		{
			offsetZ = 1.15;
			headingSpeed = 0.25;
			targetPitch = -10.f;
			targetLocalSpaceOffset = Vector( 0.74 , -0.38, 0.345 );
		}
		else // player is using Default exploration camera setting
		{
			offsetZ = 1.3;
			headingSpeed = 0.25;
			targetPitch = -10.f;
			targetDistance = 1.1f;			
			targetLocalSpaceOffset = Vector( 0.3f, 0.f, 0.3f );
		}
	}
	else // normal exterior camera
	{	
		if (thePlayer.GetExplCamera()) // player is using Close exploration camera setting
		{
			offsetZ = 1.15;
			targetLocalSpaceOffset = Vector( 0.74 , -0.38, 0.345 );
		}
		else // player is using Default exploration camera setting
		{
			targetDistance = 3.3f;
			distanceSpeed = 0.15;
		}
	}
	
	// approximately reset the camera position
	moveData.pivotPositionController.SetDesiredPosition( targetPos , posSpeed );
	moveData.pivotPositionController.offsetZ = offsetZ;
	
	// approximately reset the distance 
	moveData.pivotDistanceController.SetDesiredDistance( targetDistance, distanceSpeed );
	
	// approximately reset the camera rotation
	moveData.pivotRotationController.SetDesiredHeading( targetHeading, headingSpeed );
	moveData.pivotRotationController.SetDesiredPitch( targetPitch, pitchSpeed );
	
	// approximately reset the local space offset
	DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, targetLocalSpaceOffset, 0.6, timeDelta );
	
	ModcrabUpdateCameraFOVForMeditation( timeDelta );
}

@addMethod(W3PlayerWitcher) public function ModcrabUpdateCameraFOVForMeditation( timeDelta : float )
{
	var camera : CCustomCamera;
	
	camera = theGame.GetGameCamera();
	
	if (camera)
	{
		DampFloatSpring( camera.fov, modcrabCameraFOVVel, 60.f, 1.0, timeDelta );
	}
}

@addMethod(W3PlayerWitcher) public function ModcrabIsPlayerInMeditationState() : bool
{
	return GetCurrentStateName() == 'Meditation';
}

@addMethod(W3PlayerWitcher) public function ModcrabCanOpenAlchemyMenuDuringMeditation() : bool
{
	// use IsAnyMenu so it requires meditation clock menu to be showing
	return ModcrabIsPlayerInMeditationState() && theGame.GetGuiManager().IsAnyMenu();
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

@addMethod(W3PlayerWitcher) public function ModcrabCantMeditateFeedback()
{
	theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt( "menu_cannot_perform_action_now" ), , true );
	theSound.SoundEvent("gui_global_denied");
}