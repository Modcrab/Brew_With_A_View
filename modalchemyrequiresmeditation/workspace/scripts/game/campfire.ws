/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



 

class W3Campfire extends CGameplayEntity
{
	editable var dontCheckForNPCs : bool;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if( !dontCheckForNPCs )
		{
			AddTimer('CheckForNPCs', 3.0, true);
		}
	}

	event OnDestroyed()
	{
		if( !dontCheckForNPCs )
		{
			RemoveTimer('CheckForNPCs');
		}
	}
	
		
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		if ( activator == thePlayer && interactionComponentName == "ApplyDamage" )
		{
			ApplyDamage ();
			AddTimer ( 'ApplyDamageTimer', 3.0f, true );
		}
	}
	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity )
	{
		if ( activator == thePlayer && interactionComponentName == "ApplyDamage"  )
		{
			RemoveTimer ( 'ApplyDamageTimer' );
		}
	}
	
	function ApplyDamage ()
	{
		if ( IsOnFire() )
		{
			thePlayer.AddEffectDefault(EET_Burning, this, 'environment');
		}
	}
	
	timer function ApplyDamageTimer ( dt : float, id : int )
	{
		ApplyDamage ();
	}
	
	timer function CheckForNPCs( dt : float, id : int )
	{
		var range : float;
		var entities : array< CGameplayEntity >;
		var i : int;
		var actor : CActor;

		
		range = 30.f;
		if ( VecDistanceSquared( GetWorldPosition(), thePlayer.GetWorldPosition() ) <= range*range )
			return;

		FindGameplayEntitiesInRange(entities, this, 20.0, 10,, 2);

		
		if ( entities.Size() == 0 )
		{
			ToggleFire( false );		
		}
		else
		{
			
			for ( i = 0; i < entities.Size(); i+=1 )
			{
				actor = (CActor)entities[i];

				
				if ( actor.IsHuman() )
				{
					ToggleFire( true );
					return;
				}
			}
			
			
			
			ToggleFire( false );
		}
	}

	function IsOnFire () : bool
	{
		var gameLightComp : CGameplayLightComponent;		
		gameLightComp = (CGameplayLightComponent)GetComponentByClassName('CGameplayLightComponent');
		
		return gameLightComp.IsLightOn();
	}
	
	function ToggleFire( toggle : bool )
	{
		var gameLightComp : CGameplayLightComponent;		
		gameLightComp = (CGameplayLightComponent)GetComponentByClassName('CGameplayLightComponent');

		if(gameLightComp)
			gameLightComp.SetLight( toggle );		
	}
	
	// modcrab
	
	private var playerMeditationState : int; // 0 - init, 1 - lit, 2 - unlit, 3 - despawn
	
	public function TurnOnCampfireForMeditation()
	{
		playerMeditationState = 0;
		AddTimer('BufferedTurnOnCampfireForMeditation', 4.9, false);
	}
	
	timer function BufferedTurnOnCampfireForMeditation(dt : float, id : int)
	{
		if (playerMeditationState < 1)
		{
			playerMeditationState = 1;
			ToggleFire( true );
		}
	}
	
	public function TurnOffCampfireForMeditation(isAborting : bool)
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
	
	timer function BufferedTurnOffCampfireForMeditation(dt : float, id : int)
	{
		if (playerMeditationState < 2)
		{
			playerMeditationState = 2;
			ToggleFire( false );
		}
	}
	
	timer function BufferedDestroyCampfireForMeditation(dt : float, id : int)
	{
		if (playerMeditationState < 3)
		{
			playerMeditationState = 3;
			((CEntity)this).Destroy();	
		}
	}
	
	// -------
}	
