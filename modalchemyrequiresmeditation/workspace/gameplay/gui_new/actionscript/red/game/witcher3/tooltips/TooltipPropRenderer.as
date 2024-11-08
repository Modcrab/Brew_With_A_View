package red.game.witcher3.tooltips
{	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.BaseListItem;
	
	/**
	 * Item renderer for inventory tooltip
	 * @author Getsevich Yaroslav
	 */
	public class TooltipPropRenderer extends BaseListItem
	{
		protected static const TEXT_PADDING:Number = 4;
		
		public var mcIcon:MovieClip;
		public var tfStatValue:TextField;
		
		override public function setData(data:Object):void
		{
			super.setData(data);
			
			if (!data)
			{
				visible = false;
				return;
			}
			
			visible = true;
			
			var curWidth:Number = 0;
			
			if (tfStatValue)
			{
				if (data.value)
				{
					tfStatValue.x = 0;
					tfStatValue.htmlText = data.value;
					tfStatValue.width = tfStatValue.textWidth + CommonConstants.SAFE_TEXT_PADDING;
					curWidth += (tfStatValue.width + TEXT_PADDING)
					tfStatValue.visible = true;
				}
				else
				{
					tfStatValue.x = 0;
					tfStatValue.width = 1;
					tfStatValue.text = " ";
					tfStatValue.visible = false;
					curWidth = TEXT_PADDING;
				}
			}
			
			if (mcIcon && data.type)
			{
				mcIcon.x = curWidth;
				mcIcon.gotoAndStop(data.type);
			}
			
		}
		
		override public function getRendererWidth():Number 
		{
			var actSize:Number = 0;
			if (mcIcon && mcIcon.visible)
			{
				actSize += (mcIcon.width);
			}
			if (tfStatValue && tfStatValue.visible) 
			{
				actSize += (tfStatValue.width + TEXT_PADDING);
			}
			return actSize;
		}
		
	}
}
