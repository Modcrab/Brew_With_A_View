package red.game.witcher3.utils
{
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Jason Slama sept 2014
	 */
		
	public class FiniteStateMachine
	{
		private var stateList:Dictionary;
		private var currentStateName:String = "";
		private var nextState:String = "";
		private var prevStateName:String = "";
		private var updateTimer : Timer;
		private var disallowStateChangeFunc:Function;
		
		function FiniteStateMachine()
		{
			super();
			stateList = new Dictionary();
			
			updateTimer = new Timer(20, 0);
			updateTimer.addEventListener(TimerEvent.TIMER, updateStates);
			updateTimer.start();
		}
		
		public function get previousState():String
		{
			return prevStateName;
		}
		
		public function get currentState():String
		{
			return currentStateName;
		}
		
		public function set pauseOnStateChangeIfFunc(value:Function):void
		{
			disallowStateChangeFunc = value;
		}
		
		public function get awaitingNextState():Boolean
		{
			return currentStateName != nextState;
		}
		
		public function AddState(stateName:String, enterFunc:Function, updateFunc:Function, leaveFunc:Function) : void
		{
			var newState:FSMState = new FSMState();
			newState.stateTag = stateName;
			newState.enterStateCallback = enterFunc;
			newState.updateStateCallback = updateFunc;
			newState.leaveStateCallback = leaveFunc;
			
			stateList[stateName] = newState;
			
			if (currentStateName == "" && nextState == "")
			{
				nextState = stateName;
			}
		}
		
		public function ChangeState(targetStateName:String) : void
		{
			if (stateList[nextState])
			{
				nextState = targetStateName;
			}
			else
			{
				trace("GFX - [WARNING] Tried to change to an unknown state:", targetStateName);
			}
		}
		
		public function ForceUpdateState() : void
		{
			updateStates();
		}
		
		private function updateStates(event : TimerEvent = null ) : void
		{
			if (nextState != currentStateName && disallowStateChangeFunc && disallowStateChangeFunc())
			{
				return;
			}
			
			// Allow for state changes before state update called
			if (nextState != currentStateName && stateList[nextState] != null)
			{
				trace("GFX - [FSM] Switching from: ", currentStateName, ", to:", nextState);
				if (stateList[currentStateName] && stateList[currentStateName].leaveStateCallback)
				{
					stateList[currentStateName].leaveStateCallback();
				}
				
				prevStateName = currentStateName;
				currentStateName = nextState;
				
				if (stateList[nextState] && stateList[nextState].enterStateCallback)
				{
					stateList[nextState].enterStateCallback();
				}
			}
			
			if (currentStateName == "")
			{
				return;
			}
			else
			{
				if (stateList[currentStateName].updateStateCallback)
				{
					stateList[currentStateName].updateStateCallback();
				}
			}
			
			if (nextState != currentStateName && disallowStateChangeFunc && disallowStateChangeFunc())
			{
				return;
			}
			
			// Also allow state changes after update called
			if (nextState != currentStateName && stateList[nextState] != null)
			{
				trace("GFX - [FSM] Switching from: ", currentStateName, ", to:", nextState);
				if (stateList[currentStateName] && stateList[currentStateName].leaveStateCallback)
				{
					stateList[currentStateName].leaveStateCallback();
				}
				
				prevStateName = currentStateName;
				currentStateName = nextState;
				
				if (stateList[nextState] && stateList[nextState].enterStateCallback)
				{
					stateList[nextState].enterStateCallback();
				}
			}
		}
	}
}
