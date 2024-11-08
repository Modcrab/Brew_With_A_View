package red.core
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import red.game.witcher3.managers.InputManager;

	import scaleform.gfx.InteractiveObjectEx;
	import scaleform.gfx.Extensions;
		
	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;
	
	public class CorePopup extends CoreComponent
	{							
		public function CorePopup() 
		{
			super();
		}
		
		override protected function onCoreInit():void
		{
			registerPopup();
		}
		
		public function getPopupName():String
		{
			return popupName;
		}
		
		protected function get popupName():String
		{
			throw new Error("Override this");
			return "";
		}
		
		override protected function configUI():void
		{		
			super.configUI();		
		}
		
		override public function toString():String 
		{
			return "CorePopup [ " + this.name + "; " + popupName + " ]";
		}
		
		private function registerPopup():void
		{
			if ( Extensions.isScaleform )
			{				
				ExternalInterface.call( "registerPopup", popupName, this );
			}
		}
		
		public function setGameLanguage( value : String )
		{
			CoreComponent.gameLanguage = value;
		}
	}
}
