package red.game.witcher3.menus.startscreen
{
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import flash.display.MovieClip;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.NavigationCode;
	import red.game.witcher3.constants.PlatformType;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import red.core.CoreMenu;
	
	public class StartScreenMenuEP2 extends CoreMenu
	{
		protected var closeTimer : Timer;
		protected var soundLerpTimer : Timer;
		protected var _fadeTime : Number;
		public var mcTextShadow : MovieClip;
		public var mcGameLogo : MovieClip;
		public var textField : TextField;
		//public var mcVideo : W3StartScreenVideoObject;

		//protected var _soundVolume : Number = 1.0;
		//protected var _soundVolumeStep : Number = 0.05;
		//protected var _soundTimerUpdateTime : int = 25;
		//protected var movieName : String = "mainmenu.usm";
		//protected var loop : Boolean = true;

		public function StartScreenMenuEP2()
		{
			super();
			upToCloseEnabled = false;
		}

		override protected function get menuName():String
		{
			return "StartScreenMenuEP2";
		}

		protected override function configUI():void
		{
			super.configUI();
			//GameInterface.createBindingHandler( 'startscreen.fade.duration', setFadeDuration ); //here
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			//mcVideo.OpenVideo(movieName,loop);
		}

		override public function setPlatform(platformType:uint):void
		{
			super.setPlatform(platformType);
			textField.htmlText = PlatformType.getPlatformSpecificResourceString(platformType, "panel_button_press_any");
		}
		
		public function setDisplayedText(string:String):void
		{
			textField.htmlText = string;
		}

		override public function handleInput( event:InputEvent ):void
		{
			// Any button press handled by login system
			var details:InputDetails = event.details;
			var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);

			//trace("Bidon: rmHI key:" + details.value + " code " + details.code + " navE " + details.navEquivalent);

			if ( keyPress && !details.fromJoystick)
			{
				stage.removeEventListener(InputEvent.INPUT, handleInput, false);
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnKeyPress" ) );
			}
		}

		override protected function handleInputNavigate(event:InputEvent):void
		{

		}

		public function startClosingTimer():void
		{
			closeTimer.addEventListener(TimerEvent.TIMER, TimerFinishedCounting);
			closeTimer.start();
		}

		function TimerFinishedCounting(event:TimerEvent):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnCloseMenu" ) );
		}

		function TimerSoundVolume(event:TimerEvent):void
		{
			/*_soundVolume -= _soundVolumeStep;
			mcVideo.SetSoundVolume(_soundVolume);
			if (_soundVolume <= 0.0001)
			{
				//trace("Bidon: _soundVolume "+_soundVolume);
				soundLerpTimer.removeEventListener(TimerEvent.TIMER, TimerSoundVolume);
			}*/
		}

		public function SetFadeDuration( fadeTime:Number ):void
		{
			_fadeTime = fadeTime;
			closeTimer = new Timer(_fadeTime+0.1, 1);

			//_soundVolumeStep = Number((_fadeTime / _soundTimerUpdateTime));
			//_soundVolumeStep = Number(1 / _soundVolumeStep);
			//trace("Bidon set volume step "+_soundVolumeStep);
			//soundLerpTimer = new Timer(_soundTimerUpdateTime, 0);
		}

		public function SetIsStageDemo( value : Boolean ):void
		{
			if (value)
			{
				gotoAndStop(2);
			}
			else
			{
				gotoAndStop(1);
			}
		}

		public function setGameLogoLanguage(  language : String ) : void
		{
			if ( mcGameLogo )
			{
				mcGameLogo.gotoAndStop(language);
			}
		}
	}
}
