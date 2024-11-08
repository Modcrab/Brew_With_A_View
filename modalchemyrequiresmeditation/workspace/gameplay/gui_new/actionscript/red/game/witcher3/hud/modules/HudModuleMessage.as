package red.game.witcher3.hud.modules
{
	import red.core.CoreHudModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.utils.motion.TweenEx;
	import fl.transitions.easing.Strong;

	import flash.utils.Timer;
	import flash.events.TimerEvent;

	import scaleform.clik.controls.Label;

	public class HudModuleMessage extends HudModuleBase
	{
		public var mcMessage : Label; // #B change to new element when applying animations
		private static const INITIAL_Y_POSITION : Number = 0;
		private static const MESSAGE_SHOW_DURATION : Number = 3500;
		private static const MESSAGE_FADE_DURATION : Number = 300;
		private static const DESTINATION_Y : Number = 0;
		private var hideTimer : Timer;

		public function HudModuleMessage()
		{
			super();
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function get moduleName():String
		{
			return "MessageModule";
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function configUI():void
		{
			super.configUI();

			//x = 170.55;
			//y = 155.05;
			//z = 100;
			//scaleX = 1;
			//scaleY = 1;
			visible = false;
			alpha = 0;

			registerDataBinding('hud.message', OnNewHudMessage);
			hideTimer = new Timer(MESSAGE_SHOW_DURATION, 1);
			hideTimer.addEventListener(TimerEvent.TIMER_COMPLETE, OnHideTimerComplete);

			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );

			trace("Minimap OnNewHudMessage::configUI");
		}

		private function OnNewHudMessage( value : String ) : void
		{
			if (value.length == 0 )
			{
				// just a cleanup, don't show
				mcMessage.htmlText = "";
				mcMessage.alpha  = 0;
				pauseTweenOn(mcMessage);
				return;
			}
			mcMessage.htmlText = value;
			mcMessage.alpha  = 0;
			mcMessage.y  = - 10 - mcMessage.height;
			mcMessage.invalidateSize();
			mcMessage.validateNow();
			var tweenEx : TweenEx;
			
			visible = true;
			// TODO unpause
			pauseTweenOn(mcMessage);
			tweenEx = TweenEx.to(MESSAGE_FADE_DURATION*4, mcMessage, { alpha : 1 }, { paused:false, ease:Strong.easeOut, onComplete : StartHideTimer } );
			// TODO unpause
			targetTweens.push(tweenEx);
			trace("Minimap OnNewHudMessage::OnNewHudMessage");
		}

		private function StartHideTimer() : void
		{
			hideTimer.reset();
			hideTimer.start();
			trace("Minimap OnNewHudMessage::StartHideTimer");
		}

		private function OnHideTimerComplete( event : TimerEvent ) : void
		{
			var tweenEx : TweenEx;
			// TODO unpause
			pauseTweenOn(mcMessage);
			tweenEx = TweenEx.to(MESSAGE_FADE_DURATION, mcMessage, { alpha : 0 }, { paused:false, ease:Strong.easeOut, onComplete : OnMessageHidden } );
			// TODO unpause
			targetTweens.push(tweenEx);
			
			trace("Minimap OnNewHudMessage::OnHideTimerComplete");
		}

		private function OnMessageHidden() : void
		{
			// TODO unpause
			pauseTweenOn(mcMessage);
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnMessageHidden' ) );
			visible = false;
			trace("Minimap OnNewHudMessage::OnMessageHidden");
		}
	}
}
