package red.game.witcher3.hud
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import scaleform.gfx.InteractiveObjectEx;
		
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.gfx.Extensions;
	
	import red.core.CoreHudModule;
	
	public class HudModule extends CoreHudModule
	{
		public function HudModule()
		{
			super();
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}
	}
}