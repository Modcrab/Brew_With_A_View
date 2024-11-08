package red.game.witcher3.menus.gwint
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import red.game.witcher3.utils.CommonUtils;
	
	/**
	 * 
	 * @author Getsevich Yaroslav
	 */
	public class CardTweenManager extends EventDispatcher
	{
		protected static const FLIP_TIMELAPSE_DURATION:Number = .5;
		protected static const FLIP_TIMELAPSE_SCALE:Number = 1.4;
		protected static const FLIP_MIN_SCALE:Number = .001; // edge scale
		protected static const FLIP_SCALE:Number = 1.2;	// max scaling for flip animation
		protected static const DEFAULT_TWEEN_DURATION:Number = 1; // [sec] for scale animation without moving
		protected static const MOVE_TWEEN_SPEED:Number = 2000; // 1000; // [px per sec]
		
		protected var _cardTweens:Dictionary = new Dictionary(true);
		protected var _cardPositions:Dictionary = new Dictionary(true);
		
		protected static var _instance:CardTweenManager;
		public static function getInstance():CardTweenManager
		{
			if (!_instance) _instance = new CardTweenManager();
			return _instance;
		}
		
		/*
		 * 	API
		 */
		
		public function tweenTo(card:CardSlot, targetX:Number, targetY:Number, finishCallback:Function = null):GTween
		{
			if (!card) 
			{
				trace("GFX [WARNING] <CardTweenManager.tweenTo> card is undefined");
				return null;
			}
			tryStopCardTween(card, false);
			
			if (targetX == card.x && targetY == card.y)
			{
				return null;
			}
			var curTween:GTween;
			var tweenDuration:Number = calcTweenDuration(card.x, card.y, targetX, targetY);
			var tweenConfig:Object = { };
			
			if (finishCallback != null)
			{
				tweenConfig.onComplete = finishCallback;
			}
			
			tweenConfig.ease = Sine.easeInOut;
			
			curTween = new GTween(card, tweenDuration, { x:targetX, y:targetY }, tweenConfig);
			_cardTweens[card] = curTween;
			return curTween;
		}
		
		public function flipTo(card:CardSlot, targetState:String, targetX:Number = NaN, targetY:Number = NaN, finishCallback:Function = null):GTween
		{
			if (!card) 
			{
				trace("GFX [WARNING] <CardTweenManager.flipTo> card is undefined");
				return null;
			}
			tryStopCardTween(card, false);
			
			// ------------------------------
			
			var movePosition:Boolean;
			var startPoint:Point;
			var flippedPoint:Point;
			var middlePoint:Point;
			var finishPoint:Point;
			var tweenDuration:Number;
			
			if (!isNaN(targetX) && !isNaN(targetY)) 
			{
				movePosition = true;
				startPoint = new Point(card.x, card.y);
				finishPoint = new Point(targetX, targetY);
				middlePoint = new Point((startPoint.x + finishPoint.x) / 2, (startPoint.y + finishPoint.y) / 2);
				flippedPoint = new Point((startPoint.x + middlePoint.x) / 2, (startPoint.y + middlePoint.y) / 2);
			}
			tweenDuration = calcTweenDuration(card.x, card.y, targetX, targetY);
			
			// ----------- stage 1 ----------- 
			
			var startFlipTween:GTween;
			var startFlipValues:Object = { };
			var startFlipProps:Object = { };
			
			if (movePosition)
			{
				startFlipValues.x = flippedPoint.x;
				startFlipValues.y = flippedPoint.y;
			}
			
			startFlipValues.rotationY = 90;
			//startFlipProps.ease = Exponential.easeIn;
			startFlipProps.data = targetState;
			startFlipProps.onComplete = onStartFlipComplete;
			
			startFlipTween = new GTween(card, tweenDuration / 3, startFlipValues, startFlipProps);
			
			// ----------- stage 2 ----------- 
			
			var middleFlipTween:GTween;
			var middleFlipValue:Object = { };
			var middleFlipProps:Object = { };
			
			if (movePosition)
			{
				middleFlipValue.x = middlePoint.x;
				middleFlipValue.y = middlePoint.y;
			}
			
			middleFlipValue.rotationY = 0;
			middleFlipTween = new GTween(card, tweenDuration / 3, middleFlipValue, middleFlipProps);
			middleFlipTween.paused = true;
			startFlipTween.nextTween = middleFlipTween;
			
			// ----------- stage 3 ----------- 
			
			var finishFlipTween:GTween;
			var finishFlipValue:Object = { };
			var finishFlipProps:Object = { };
			
			if (movePosition)
			{
				finishFlipValue.x = finishPoint.x;
				finishFlipValue.y = finishPoint.y;
			}
			
			finishFlipProps.onComplete = finishCallback;
			finishFlipTween = new GTween(card, tweenDuration / 3, finishFlipValue, finishFlipProps);
			finishFlipTween.paused = true;
			middleFlipTween.nextTween = finishFlipTween;
			
			return null;
		}
		
		public function onStartFlipComplete(tweenInstance:GTween):void
		{
			var targetCard:CardSlot = tweenInstance.target as CardSlot;
			if (targetCard)
			{
				targetCard.cardState = tweenInstance.data as String;
				targetCard.rotationY = -90;
			}
		}
		
		public function flip(card:CardSlot, targetState:String):void
		{
			card.cardState = targetState;
			// #Y TODO: flip animation ?
		}
		
		public function getPosition(card:CardSlot):Point
		{
			return _cardPositions[card];
		}
		
		public function setPosition(card:CardSlot, x:Number, y:Number):void
		{
			_cardPositions[card] = new Point(x, y);
			card.x = x;
			card.y = y;
		}
		
		public function storePosition(card:CardSlot):void
		{
			_cardPositions[card] = new Point(card.x, card.y);
		}
		
		public function restorePosition(card:CardSlot, enableTween:Boolean = false):Boolean
		{
			var defaultPos:Point = _cardPositions[card];
			if (defaultPos)
			{
				if (enableTween)
				{
					tweenTo(card, defaultPos.x, defaultPos.y);
				}
				else
				{
					card.x = defaultPos.x;
					card.y = defaultPos.y;
				}
				return true;
			}
			return false;
		}
		
		public function isCardMoving(card:CardSlot):Boolean
		{
			return _cardTweens[card];
		}
		
		public function isAnyCardMoving():Boolean
		{
			var curTween:GTween;
			for each (curTween in _cardTweens)
			{
				if (curTween && !curTween.paused)
				{
					return true;
				}
			}
			return false;
		}
		
		/*
		 * 	Underhood
		 */
		
		private function calcTweenDuration(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			if (isNaN(x1) || isNaN(y1) || isNaN(x2) || isNaN(y2))
			{
				return DEFAULT_TWEEN_DURATION;
			}
			else
			{
				var distance:Number = Point.distance(new Point(x1, y1), new Point(x2, y2));
				return distance / MOVE_TWEEN_SPEED;
			}
		}
		
		private function getCardTween(card:CardSlot):GTween
		{
			return _cardTweens[card] as GTween;
		}
		
		private function getCardDefaultPosition(card:CardSlot):Point
		{
			return _cardPositions[card] as Point;
		}
		
		private function tryStopCardTween(card:CardSlot, useCallback:Boolean = true):Boolean
		{
			var curTween:GTween = getCardTween(card);
			if (curTween)
			{
				if (curTween.onComplete != null && useCallback)
				{
					curTween.onComplete(curTween);
				}
				curTween.paused = true;
				curTween = null;
				return true;
			}
			return false;
		}
		
	}
}
