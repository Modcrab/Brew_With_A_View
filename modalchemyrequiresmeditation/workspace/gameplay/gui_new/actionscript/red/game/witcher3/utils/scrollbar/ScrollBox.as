package red.game.witcher3.utils.scrollbar
{
	import red.game.witcher3.utils.Math2;

	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	public class ScrollBox extends EventDispatcher
	{
		public var mc_content:MovieClip;
		public var mc_mask:MovieClip;
		public var mc_scrollBar:ScrollBar;
		
		public var marginAtBottom:Number = 35;
		
		public function ScrollBox(mc_content:MovieClip,mc_mask:MovieClip,mc_scrollBar:ScrollBar=null):void
		{
			this.mc_scrollBar = mc_scrollBar;
			this.mc_mask = mc_mask;
			this.mc_content = mc_content;
			mc_content.mask = mc_mask;
			
			if (mc_content&&mc_content&&mc_mask)
			{
				init();
			}
		
		}
		
		public function init(s:Stage=null):void 
		{
			if (mc_scrollBar) 
			{
				mc_scrollBar.addEventListener(ScrollBarEvent.VALUE_CHANGED, hChange);
			}
			
		
		}
		
		
		protected function hChange(e:ScrollBarEvent):void
		{
			
			var myY:Number = mc_mask.y-Math2.getValueFromPercent(0, mc_content.height - mc_mask.height+marginAtBottom, e.value);
			
			mc_content.y = myY;
			
		}
		public function updateContent():Boolean
		{
			var bool:Boolean = mc_content.height > mc_mask.height?true:false;
			if (mc_scrollBar) 
			{
				
				mc_scrollBar.thumb.mouseEnabled = bool;
			
			}
			return bool;
		}
		public function updateScrollPosition():void 
		{
			var percent:Number = Math2.getPercentFromValue(0 + mc_mask.y, mc_mask.y +mc_content.height - mc_mask.height +marginAtBottom, mc_mask.y - mc_content.y);
			if (mc_scrollBar) 
			{
				mc_scrollBar.setPositionFromPercent(percent);
			}
			
			
		}
		public function setPercent(percent:Number):void 
		{
			percent = Math2.between(percent, 0, 100);
			var value :Number = Math2.getValueFromPercent(0, mc_content.height - mc_mask.height + marginAtBottom, percent);
			
			var myY:Number = mc_mask.y - value;
			mc_content.y = myY;
			
		}
		
		public function getPercent():Number
		{
			
			
			 //mc_mask.y -
			var percent:int = Math2.getPercentFromValue(0, mc_content.height - mc_mask.height + marginAtBottom, mc_mask.y - mc_content.y );
		
			return percent;
			//return Math2.getPercentFromValue(0 + mc_mask.y, mc_mask.y +mc_content.height - mc_mask.height +marginAtBottom, mc_mask.y - mc_content.y);
			
			
		}
		
	}
}