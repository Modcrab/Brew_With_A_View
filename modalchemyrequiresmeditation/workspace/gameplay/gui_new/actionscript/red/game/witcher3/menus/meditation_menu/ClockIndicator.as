package red.game.witcher3.menus.meditation_menu 
{
	import flash.display.Sprite;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * Clock Indicator
	 * @author Yaroslav Getsevich
	 */
	public class ClockIndicator extends UIComponent
	{
		public var indicatorImage:Sprite;
		protected var _progress:Number;
		
		public function ClockIndicator() 
		{
		}
		
		public function get progress():Number { return _progress }
		public function set progress(value:Number):void
		{	
			if (_progress == value)
			{
				return;
			}
			_progress = value;
			this.gotoAndStop(_progress);
		}
		
	}
}