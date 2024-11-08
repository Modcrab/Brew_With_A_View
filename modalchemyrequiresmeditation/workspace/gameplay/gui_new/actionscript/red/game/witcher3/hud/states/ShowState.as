/***********************************************************************
/** Show State for state machine
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.hud.states
{
	import red.game.witcher3.hud.modules.HudModuleBase;
	import red.core.events.GameEvent;
	
	public class ShowState extends BaseState
	{
		
		public function ShowState( owner : HudModuleBase )
		{
			super(owner);
		}
		
		override public function enter():void
		{
			//ownerModule.dispatchEvent(new GameEvent(GameEvent.CALL, 'OnBreakPoint', [("ShowState enter for "+ownerModule.moduleName )]));
			ownerModule.ShowElementFromState( true, false );
		}
		
		override public function ShowElement( bShow : Boolean, bImmediately : Boolean = false ):void
		{
			ownerModule.SaveShowState( bShow );
		}
	}
}
