package red.game.witcher3.utils 
{
	
	import flash.events.EventDispatcher;
	import scaleform.clik.core.UIComponent;
	/**
	 * ...
	 * @author @ Paweł
	 */
	public class ActiveObject extends EventDispatcher 
	
	{
		private static var _initialized:Boolean=false;
		static private var _instance:ActiveObject;
		
		public var focus:UIComponent;
				
		public function ActiveObject() 
		{
			if (_initialized==false)
			{
				throw new Error("You must use initialize() static method first.");
			}
		}
		
		private static function initialize():void 
		{
			if (_initialized==false)
			{
				_initialized = true;
				_instance = new ActiveObject();
			}
		}
		public static function getInstance():ActiveObject
		
		{
			if (!_initialized)
			{
				initialize();
			}
			if (!_instance)
			{
				throw new Error("You must use initialize() static method first.");
			}
			return _instance;
		}
	}
}