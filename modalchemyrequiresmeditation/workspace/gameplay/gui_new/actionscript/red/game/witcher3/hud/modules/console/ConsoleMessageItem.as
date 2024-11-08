package red.game.witcher3.hud.modules.console
{
	import com.gskinner.motion.GTween;
	import fl.motion.easing.Exponential;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import com.gskinner.motion.GTweener;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * Item renderer for console message
	 * @author Yaroslav Getsevich
	 */
	public class ConsoleMessageItem extends UIComponent
	{
		protected static const SAFE_TEXT_PADDING:Number = 5;
		protected static const ANIM_DURATION:Number = .5;
		protected static const VANISHING_SCALE:Number = .5;
		protected static const VANISHING_ROT:Number = -50;
		protected static const VANISHING_X_OFFSET:Number = -30;
		protected static const APPEARING_SCALE:Number = .8;
		protected static const APPEARING_ROT:Number = -50;
		protected static const APPEARING_X_OFFSET:Number = 30;
		
		public var textField:TextField;
		protected var _vanishingTween:GTween;
		protected var _pendingKill:Boolean;
		protected var _lifeTimer:Timer;
		
		public function init(text:String, lifetime:Number, width:Number)
		{
			textField.htmlText = text;
			textField.width = width;
			textField.multiline = true;
			textField.height = textField.textHeight + SAFE_TEXT_PADDING;
			
			//textField.scaleX = textField.scaleY = APPEARING_SCALE;
			textField.x = 0;//APPEARING_X_OFFSET;
			//textField.alpha = 0;//APPEARING_X_OFFSET;
			//textField.rotationY = APPEARING_ROT;
			
			//GTweener.to(textField, ANIM_DURATION, { /*x:0,*/ alpha:1/*, scaleX:1, scaleY:1*/ }, { ease:Exponential.easeOut } );
			
			_lifeTimer = new Timer(lifetime);
			_lifeTimer.addEventListener(TimerEvent.TIMER, handleLifeTimer, false, 0, true);
			_lifeTimer.start();
		}
		
		public function forceRemove():void
		{
			if (!_pendingKill) startHidding();
		}
		
		public function isVanishing():Boolean
		{
			return _vanishingTween != null;
		}
		
		public function destroy():void
		{
			_pendingKill = true;
			/*
			GTweener.pauseTweens(textField);			
			if (_vanishingTween)
			{
				_vanishingTween.paused = true;
				_vanishingTween = null;
			}
			*/
		}
		
		protected function handleLifeTimer(event:TimerEvent = null):void
		{
			startHidding();
		}
		
		protected function startHidding():void
		{			
			/*
			var tweenValues:Object = { alpha:0 };
			var tweenProps:Object = { ease:Exponential.easeIn, onComplete:handleHidden };
			
			GTweener.pauseTweens(textField);
			_vanishingTween = new GTween(textField, ANIM_DURATION, tweenValues, tweenProps);
			
			_pendingKill = true;
			*/
			
			alpha = 0;
			handleHidden();
		}
		
		protected function handleHidden(instTween:GTween = null):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
			//GTweener.pauseTweens(this);
			destroy();
			_pendingKill = true;
		}
	}
}
