package red.game.witcher3.hud.modules.wolfHead
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import scaleform.clik.controls.StatusIndicator;
	import red.game.witcher3.utils.motion.TweenEx;
	
	public class W3StatIndicator extends StatusIndicator
	{
		public var mcBackgroundHealth:MovieClip;
		
		// is it needed?
		override public function setActualSize(newWidth:Number, newHeight:Number):void
		{
			
		}
	}

}