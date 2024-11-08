package red.game.witcher3.popups
{
	import com.gskinner.motion.easing.Elastic;
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	import red.game.witcher3.constants.CommonConstants;
	import scaleform.clik.core.UIComponent;
	import red.game.witcher3.utils.CommonUtils;
	import flash.geom.Rectangle;
	import red.core.CoreComponent;

	/**
	 * Simple notification about items added/removed to the inventory, controller change, etc
	 * Used in the OverlayPopupMenu
	 * @author Getsevich Yaroslav
	 */
	public class NotificationModule extends UIComponent
	{
		private static const TEXT_WIDTH_MAX:Number = 400;
		private static const TEXT_WIDTH_MIN:Number = 200;
		private static const TEXT_WIDTH_PADDING:Number = 40;
		private static const TEXT_HEIGHT_PADDING:Number = 20;
		private static const DEF_DURATION:Number = 4000;
		private static const ANIMATION_DURATION:Number = .3;

		public var tfMessage:TextField;
		public var mcBackground:Sprite;

		protected var _timer:Timer;
		protected var _message:String;
		protected var _duration:Number;
		protected var _shown:Boolean;

		public function NotificationModule()
		{
			_shown = false;
			visible = false;
		}

		public function show(msgText:String, msgDuration:Number = 0):void
		{
			_message = msgText;
			_duration = msgDuration;
			if (_message)
			{
				var safeRect:Rectangle = CommonUtils.getScreenRect();
				var safeOffsetX:Number = safeRect.width * .05;
				var safeOffsetY:Number = safeRect.height * .95;
					
				populateData();
				y = safeOffsetY - (mcBackground.y + mcBackground.height);
				
				if (!_shown)
				{
					visible = true;
					x = 0;
					alpha = 0;
					
					GTweener.removeTweens(this);
					GTweener.to(this, ANIMATION_DURATION, { x : safeOffsetX, alpha:1 }, { ease:Exponential.easeOut, onComplete:handleShown } );
				}
				_shown = true;
				initTimer();				
			}
			else
			{
				trace("GFX WARNING: <NotificationModule> invalid data");
				dispatchEvent(new Event(Event.DEACTIVATE));
			}
		}

		public function hide():void
		{
			playHideTween();
		}

		public function isShown():Boolean
		{
			return _shown;
		}

		protected function playHideTween():void
		{
			if (_shown)
			{
				GTweener.removeTweens(this);
				GTweener.to(this, ANIMATION_DURATION, { x : 0/*-width / 2*/, alpha:0 }, { ease:Exponential.easeOut, onComplete:handleHidden } );
			}
		}

		protected function initTimer():void
		{
			_duration = _duration ? _duration : DEF_DURATION;
			if (_timer)
			{
				_timer.removeEventListener(TimerEvent.TIMER, handleTimer, false);
				_timer.stop();
				_timer = null;
			}
			_timer = new Timer(_duration)
			_timer.addEventListener(TimerEvent.TIMER, handleTimer, false, 0, true);
			_timer.start();
		}

		protected function populateData():void
		{
			tfMessage.width = TEXT_WIDTH_MAX;
			//tfMessage.autoSize = TextFieldAutoSize.LEFT;
			//tfMessage.wordWrap = false; // #Y hack to calculate textWidth properly
			tfMessage.htmlText = _message;
			var textWidth:Number = Math.max(Math.min(tfMessage.textWidth, TEXT_WIDTH_MAX), TEXT_WIDTH_MIN);
			//tfMessage.wordWrap = true;
			tfMessage.width = textWidth + CommonConstants.SAFE_TEXT_PADDING;
			tfMessage.height = tfMessage.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			mcBackground.height = tfMessage.height + TEXT_HEIGHT_PADDING;
			mcBackground.width = tfMessage.width + TEXT_WIDTH_PADDING;
			if ( CoreComponent.isArabicAligmentMode )
			{
				tfMessage.htmlText = "<p align=\"right\">" + _message+"</p>";
			}
		}

		protected function handleTimer(event:TimerEvent):void
		{
			playHideTween();
		}

		protected function handleHidden(tweemInstance:GTween):void
		{
			_shown = false;
			visible = false;
			dispatchEvent(new Event(Event.DEACTIVATE));
		}

		protected function handleShown(tweemInstance:GTween):void
		{
			// #Y test feature
			//var targetX:Number = x + 20;
			//GTweener.to(this, _duration / 1000, { x:targetX } );
		}

	}
}
