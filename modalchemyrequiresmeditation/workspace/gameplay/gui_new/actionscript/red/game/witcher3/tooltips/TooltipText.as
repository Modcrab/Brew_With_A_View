package red.game.witcher3.tooltips
{
	import flash.display.Sprite;
	import flash.text.TextField;
	// #B #Y obsolete
	/**
	 * Simple tooltip with text
	 * @author Yaroslav Getsevich
	 */
	public class TooltipText extends TooltipBase
	{
		public var background:Sprite;
		public var tfDescription:TextField;

		protected var _maxWidth:Number = 500;
		protected var _minWidth:Number = 50;

		public function TooltipText()
		{
			background.mouseChildren = background.mouseEnabled = false;
			tfDescription.mouseEnabled = false;
		}

		[Inspectable(name = "Max width", defaultValue = "500")]
		public function get maxWidth():Number { return _maxWidth }
		public function set maxWidth(value:Number):void
		{
			_maxWidth = value;
			invalidateSize();
		}

		[Inspectable(name = "Max width", defaultValue = "50")]
		public function get minWidth():Number { return _minWidth }
		public function set minWidth(value:Number):void
		{
			_minWidth = value;
			invalidateSize();
		}

		override protected function populateData():void
		{
			super.populateData();
			tfDescription.htmlText = String(_data);
		}

		override protected function updateSize():void
		{
			var requiredWidth:Number = tfDescription.textWidth + _padding.left + _padding.right;
			tfDescription.width = Math.max(Math.min(requiredWidth, _maxWidth), _minWidth);
			tfDescription.height = tfDescription.textHeight;
			background.width = tfDescription.width + _padding.left + _padding.right;
			background.height = tfDescription.height + _padding.top + _padding.bottom;

			tfDescription.x = _padding.left;
			tfDescription.y = _padding.top;

			super.updateSize();
		}
	}
}