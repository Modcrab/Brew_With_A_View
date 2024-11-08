/***********************************************************************
/** OnDemand State for state machine
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.hud.states
{
	import red.game.witcher3.hud.modules.HudModuleBase;
	
	public class OnDemandState extends BaseState
	{
		
		public function OnDemandState( owner : HudModuleBase )
		{
			super(owner);
		}
		
		override public function enter():void
		{
			var restoreState : Boolean = ownerModule.GetSavedShowState();
			ownerModule.ShowElementFromState( restoreState, false );
		}
		
		override public function ShowElement( bShow : Boolean, bImmediately : Boolean = false ):void
		{
			ownerModule.ShowElementFromState( bShow, bImmediately );
			ownerModule.SaveShowState( bShow );
		}
	}
}
