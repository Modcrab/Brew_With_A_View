package red.core
{
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import red.game.witcher3.managers.InputManager;

	import scaleform.gfx.Extensions;
	
	//import red.core.GameInterface;
	import red.core.events.GameEvent;
	
	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;
	
	public class CoreHud extends CoreComponent
	{						
		public function CoreHud() 
		{
			super();
			_enableHoldEmulation = false;
			_enableInputDeviceCheck = false;
		}
		
		// For override
		public function get hudName():String
		{ 
			throw new Error("Override this");
			return "";
		} 
		
		override protected function onCoreInit():void
		{
			registerHud();
		}
		
		override public function toString():String 
		{
			return "CoreHud [ " + this.name + "; " + hudName + " ]";
		}
		
		private function registerHud():void
		{
			trace("registerHud");
			if ( Extensions.isScaleform )
			{				
				ExternalInterface.call( "registerHud", hudName, this );
			}
		}
						
		protected function loadModule( moduleName:String, userData:int ):void // abstract for override
		{
		}
		
		protected function unloadModule( moduleName:String, userData:int ):void // abstract for override
		{
		}
		
		// Called from C++. Override loadModule and unloadModule instead of calling this from Flash.
		public function _HOOK_loadModule( moduleName:String, userData:int = -1 ):void
		{
			loadModule( moduleName, userData );
		}
		
		public function _HOOK_unloadModule( moduleName:String, userData:int = -1 ):void
		{
			unloadModule( moduleName, userData );
		}
	}
}
