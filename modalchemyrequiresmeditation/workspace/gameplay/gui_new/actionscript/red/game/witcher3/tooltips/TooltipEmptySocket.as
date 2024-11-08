package red.game.witcher3.tooltips
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;

	/**
	 * Tooltip for empty sockets
	 * @author Getsevich Yaroslav
	 */
	public class TooltipEmptySocket extends TooltipBase
	{
		public var tfItemType:TextField;
		public var tfDescription:TextField;
		public var mcBackground:MovieClip;
		public var delTitle:MovieClip;
		
		public function TooltipEmptySocket()
		{
			visible = false;
		}
		
		override protected function populateData():void
		{
			super.populateData();
			
			if (_data)
			{
				applyTextValue(tfItemType, _data.ItemType,false,true);
				applyTextValue(tfDescription, _data.Description, false, true);
				visible = true;
				
				const BK_PADDING = 10;
				const MIN_WIDTH = 175;
				tfItemType.width = tfItemType.textWidth + CommonConstants.SAFE_TEXT_PADDING;
				tfDescription.width = tfDescription.textWidth+ CommonConstants.SAFE_TEXT_PADDING;
				mcBackground.width = Math.max( Math.max( tfDescription.textWidth, tfItemType.textWidth ) + BK_PADDING * 2, MIN_WIDTH );
			}
		}
		
		override public function set backgroundVisibility(value:Boolean):void 
		{
			super.backgroundVisibility = value;
			if (mcBackground)
			{
				mcBackground.gotoAndStop(_backgroundVisibility ? "solid" : "transparent");
			}
			
			if (delTitle)
			{
				delTitle.visible = !value;
			}
		}

	}

}
