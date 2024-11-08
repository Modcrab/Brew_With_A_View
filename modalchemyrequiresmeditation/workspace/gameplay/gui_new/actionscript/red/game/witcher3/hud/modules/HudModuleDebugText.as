package red.game.witcher3.hud.modules
{
	import red.core.CoreHudModule;
	import red.core.events.GameEvent;
	
	import flash.text.TextField;
	import flash.display.MovieClip;
	import scaleform.clik.core.UIComponent;
	import flash.events.Event;
	import red.game.witcher3.utils.motion.TweenEx;
	
	public class HudModuleDebugText extends HudModuleBase
	{
		public var tfText	: TextField;

		private static const FADE_DURATION:Number = 250;
		
		private var _bShowDescription:Boolean;
		
		public function HudModuleDebugText() 
		{
			super();
			_bShowDescription = false;
		}

		override public function get moduleName():String
		{
			return "DebugTextModule";
		}

		override protected function configUI():void
		{
			super.configUI();	
			
			visible = true;
			alpha = 0;
			focused = 0;
			
			registerDataBinding( 'debugtext.text', handleSetText );

			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}
		
		override public function ShowElement( bShow : Boolean, bImmediately : Boolean = false ) : void
		{
			if ( bShow != _bShowDescription )
			{
				_bShowDescription = bShow;
				
				if ( _bShowDescription )
				{
					effectFade( this, 1, FADE_DURATION );
				}
				else
				{
					effectFade( this, 0, FADE_DURATION );
				}
			}
		}
		
		private function handleSetText( value : String ) : void
		{
			tfText.text = value;
		}
	}
}
