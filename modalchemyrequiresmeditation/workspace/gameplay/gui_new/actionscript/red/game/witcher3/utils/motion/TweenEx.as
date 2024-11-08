package red.game.witcher3.utils.motion
{
	import scaleform.clik.motion.Tween;
	
	public class TweenEx extends Tween
	{
		public function TweenEx( duration:Number, target:Object = null, props:Object = null, quickSet:Object = null )
		{
			super( duration, target, props, quickSet );
		}
		
		// Pausing removes the tween from the internal linked list as well
		public static function pauseTweenOn( target:Object )
		{
			var targetTweens:Vector.<Tween> = new Vector.<Tween>();
			
			var tween:Tween;
			
			for ( tween = firstTween; tween != null; tween = tween.nextTween )
			{
				if ( tween.target == target )
				{
					targetTweens.push( tween );
				}
			}
			
			for each ( tween in targetTweens )
			{
				tween.paused = true;
			}
		}
		
		 /**
         * Create a new Tween.
         * @param duration The duration of the tween in milliseconds.
         * @param target The DisplayObject to be tweened.
         * @param props An Object containing the properties and values that should be tweened to.
         * @param quickSet An Object containing properties for the tween including paused, ease, onComplete, loop, delay, and nextTween.
         */
		public static function to( duration:Number, target:Object = null, props:Object = null, quickSet:Object = null ):TweenEx
		{
			return new TweenEx( duration, target, props, quickSet );
		}
	}
}