package red.game.witcher3.hud.modules
{
	import flash.display.MovieClip;
	import red.core.CoreHudModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;

	import flash.text.TextField;
	import red.game.witcher3.utils.motion.TweenEx;
	import fl.transitions.easing.Strong;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import red.game.witcher3.utils.CommonUtils;

	public class HudModuleTimeLapse extends HudModuleBase
	{
		public var textField : TextField;
		public var textFieldSmall : TextField;
		public var mcBackground : MovieClip;
		
		protected var hideTimer : Timer;

		protected static const FADE_DURATION_TIME_LAPSE : Number = 2000;

		public function HudModuleTimeLapse()
		{
			super();
			isAlwaysDynamic = true;
		}

		override public function get moduleName():String
		{
			return "TimeLapseModule";
		}

		override protected function configUI():void
		{
			super.configUI();

			visible = false;
			alpha = 0;

			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}

		public function handleTimelapseTextSet( value : String)
		{	
			textField.htmlText = CommonUtils.toUpperCaseSafe(value);
			textField.width = textField.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			textField.x = -textField.width;
			
			scaleBackground();
			
			dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
		}

		public function handleTimelapseAdditionalTextSet( value : String)
		{	
			textFieldSmall.htmlText = CommonUtils.toUpperCaseSafe(value);
			textFieldSmall.width = textFieldSmall.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			textFieldSmall.x = -textFieldSmall.width;			
		}

		private function scaleBackground() : void
		{
			//take into consideration both individual textfields
			var totalWidth = Math.max(textField.textWidth, textFieldSmall.textWidth) + 30; //padding
			var totalHeight = textField.textHeight + textFieldSmall.textHeight + 20; //compensate for the amount of dead space between the 2 textfields
			
			mcBackground.width = totalWidth;			
			mcBackground.height = totalHeight;			
		}
		
		
		public function SetShowTime( value : Number ) : void
		{
			RemoveUpdateTimer();
			UPDATE_FADE_TIME = value;
		}

		override public function SetScaleFromWS( scale : Number ) : void { };
		
		override public function onCutsceneStartedOrEnded( started : Boolean )
		{
			trace( "Minimap2 HudModuleTimeLapse::onCutsceneStartedOrEnded " + started );
			
			if ( started )
			{
				if ( !isInCutscene )
				{
					isInCutscene = true;
					x -= 440;
				}
			}
			else
			{
				if ( isInCutscene )
				{
					isInCutscene = false;
					x += 440;
				}
			}
		}

	}
}
