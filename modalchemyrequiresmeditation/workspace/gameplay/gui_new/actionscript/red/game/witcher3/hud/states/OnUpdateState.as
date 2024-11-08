/***********************************************************************
/** OnUpdate State for state machine
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.hud.states
{
	import red.game.witcher3.hud.modules.HudModuleBase;
	import red.core.events.GameEvent;
	
	public class OnUpdateState extends BaseState
	{
		
		public function OnUpdateState( owner : HudModuleBase )
		{
			super(owner);
		}
		
		override public function enter():void
		{
			ownerModule.ShowElementFromState( false, false );
			ownerModule.addEventListener(GameEvent.UPDATE, ownerModule.OnUpdate, false, 0, true);
			//ownerModule.dispatchEvent(new GameEvent(GameEvent.CALL, 'OnBreakPoint', [("OnUpdateState enter for "+ownerModule.moduleName )]));
		}
		
		
		override public function exit():void
		{
			//ownerModule.ShowElementFromState( false, false );
			ownerModule.removeEventListener(GameEvent.UPDATE, ownerModule.OnUpdate, false);
			ownerModule.RemoveUpdateTimer();
			//ownerModule.dispatchEvent(new GameEvent(GameEvent.CALL, 'OnBreakPoint', [("OnUpdateState EXIT for "+ownerModule.moduleName )]));
		}
	}
}
