package red.core
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import red.game.witcher3.managers.InputManager;
	
	import red.core.CoreHud;
	import red.core.events.GameEvent;
	
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.gfx.Extensions;
	import flash.display.Sprite;
		
	public class CoreHudModule extends CoreComponent
	{
		protected var dot:Sprite = new Sprite();

		public function CoreHudModule()
		{
			super();
		}
		
		// For override
		public function get moduleName():String
		{
			throw new Error("Override this");
			return "";
		}
				
		override protected function configUI():void
		{
			super.configUI();
		}
		
		override protected function onCoreInit():void
		{
			registerModule();
			validateNow();
		}
		
		override protected function onCoreCleanup():void
		{
			unregisterModule();
		}
		
		private function registerModule():void
		{
			if ( ! moduleName )
			{
				throw new Error("No module name was set.");
			}
			
			var hud:CoreHud = getHud();
			
			if ( hud )
			{
				hud.registerChild( this, moduleName );
			}
			else
			{
				//TBD: Need a "Extensions.isGame"
				if ( Extensions.isScaleform && ! Extensions.isGFxPlayer )
				{
					throw new Error("Can't find HUD");
				}
				else
				{
					// Probably publishing the file and the exception
					// would probably cause other errors
					trace("Can't find HUD");
				}
			}
		}
		
		private function unregisterModule():void
		{
			// asymmetrical for the moment.
			unregisterChild();
		}
		
		private function getHud():CoreHud
		{
			var prevParent:DisplayObject = null;
			var curParent:DisplayObject = parent;
			
			while ( prevParent != curParent && curParent && ! (curParent is CoreHud) )
			{
				prevParent = curParent;
				curParent = curParent.parent;
			}
			
			if ( ! (curParent is CoreHud) )
			{
				return null;
			}
			
			return CoreHud(curParent );
		}
		
		public function get stageWidth():Number { return stage.stageWidth; }

        public function get stageHeight():Number { return stage.stageHeight; }

	}
}
