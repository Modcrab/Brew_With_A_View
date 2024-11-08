package red.game.witcher3.utils
{
	/**
	 * ...
	 * @author Jason Slama sept 2014
	 */
		
	public class FSMState
	{
		public var stateTag:String;
		public var enterStateCallback:Function;
		public var updateStateCallback:Function;
		public var leaveStateCallback:Function;
	}
}