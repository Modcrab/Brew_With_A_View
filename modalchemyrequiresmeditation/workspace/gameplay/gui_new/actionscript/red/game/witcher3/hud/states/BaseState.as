/***********************************************************************
/** Base State for state machine - abstract class, don't use it as state
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.hud.states
{
	import red.game.witcher3.hud.modules.HudModuleBase;
	
	public class BaseState
	{
		protected var ownerModule : HudModuleBase;
		
		public function BaseState( owner : HudModuleBase )
		{
			ownerModule = owner;
		}
		
		public function enter():void{}
		//function update(tickCount:int):void;
		public function exit():void{}
		
		public function ShowElement( bShow : Boolean, bImmediately : Boolean = false ):void{}
	}
}
