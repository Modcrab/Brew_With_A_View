/***********************************************************************
/** Hud Modules state machine
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.hud.states
{
	//import red.game.witcher3.hud.modules.HudModuleBase;
	
	public class StateMachine
	{
		public var current:String;
		public var previous:String;
		
		private var states:Object;
		
		//public var tickCount:int = 0;
		
		public function StateMachine()
		{
			states = new Object();
		}
		
		public function getState():String
		{
			return current;
		}
		
		public function setState(name:String):void
		{
			if(current == null)
			{
				current = name;
				states[current].state.enter();
				return;
			}
			
			if(current == name)
			{
				//
				//trace("HUD this object is already in the " + name + " state.");
				//
				return;
			}
			states[current].state.exit();
			previous = current;
			current = name;
			states[current].state.enter();
		}
		
		public function ShowElement( bShow : Boolean, bImmediately : Boolean = false ) : void
		{
			states[current].state.ShowElement( bShow, bImmediately );
		}
		
		public function addState(name:String, stateObj:BaseState, fromStates:Array):void
		{
			states[name] = {state:stateObj, from:fromStates.toString()};
		}
	}
}
