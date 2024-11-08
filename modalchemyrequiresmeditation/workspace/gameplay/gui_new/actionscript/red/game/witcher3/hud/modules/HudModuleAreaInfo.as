package red.game.witcher3.hud.modules
{
	import red.core.events.GameEvent;
    import flash.text.TextField;
	import red.game.witcher3.utils.motion.TweenEx;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import red.game.witcher3.utils.CommonUtils;

	public class HudModuleAreaInfo extends HudModuleBase
	{
		public var textField : TextField;
		private var showTimer : Timer;

		public function HudModuleAreaInfo()
		{
			super();
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function get moduleName():String
		{
			return "AreaInfoModule";
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function configUI():void
		{
			super.configUI();

			visible = true;
			alpha = 0;

			//registerDataBinding('hud.questupdate', OnQuestUpdate);
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}

		public function SetText( value : String ) : void
		{
			textField.htmlText = CommonUtils.toUpperCaseSafe(value);
			SetShowTimer();
		}

		public function SetShowTimer( ) : void
		{
			if ( !showTimer )
			{
				showTimer = new Timer(UPDATE_FADE_TIME, 1);
				showTimer.addEventListener(TimerEvent.TIMER, ShowTimerFinishedCounting);
			}
			else
			{
				showTimer.reset();
			}
			showTimer.start();
		}

		public function ResetShowTimer() : void
		{
			if ( showTimer )
			{
				showTimer.reset();
				showTimer.start();
			}
		}

		public function RemoveShowTimer() : void
		{
			if ( showTimer )
			{
				showTimer.stop();
				showTimer = null;
			}
		}

		function ShowTimerFinishedCounting( event : TimerEvent ) : void
		{
			RemoveShowTimer();
			//ShowElementFromState(false, false);
		}

		override public function SetScaleFromWS( scale : Number ) : void { };

	}

}
