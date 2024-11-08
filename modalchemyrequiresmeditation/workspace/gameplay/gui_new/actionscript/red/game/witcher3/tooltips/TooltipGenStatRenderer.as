package red.game.witcher3.tooltips 
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.BaseListItem;
	
	/**
	 * ...
	 * @author Getsevich Yaroslav
	 */
	public class TooltipGenStatRenderer extends BaseListItem
	{
		protected static const TEXT_VALUE_PADDING:Number = 5;
		
		public var mcComparisonIcon : MovieClip;
		public var mcStatIcon		: MovieClip;
		public var tfValue			: TextField;
		
		public function TooltipGenStatRenderer() 
		{
			if (mcComparisonIcon) mcComparisonIcon.visible = false;
			if (mcStatIcon) mcStatIcon.visible = false;
			if (tfValue) tfValue.visible = false;
		}
		
		override public function setData( data:Object ):void
		{
			super.setData(data);
			
			if (mcStatIcon)
			{
				if (data.type)
				{
					mcStatIcon.gotoAndStop(data.type);
					mcStatIcon.visible = true;
				}
				else
				{
					mcStatIcon.visible = false;
				}
			}
			
			if (tfValue)
			{
				if (data.value)
				{
					tfValue.visible = true;
					tfValue.text = String(data.value);
					tfValue.width = tfValue.textWidth + CommonConstants.SAFE_TEXT_PADDING;
				}
				else
				{
					tfValue.visible = false;
				}
			}
			
			if (mcComparisonIcon)
			{
				if (data.icon)
				{
					mcComparisonIcon.gotoAndStop(data.icon);
					mcComparisonIcon.visible = true;
					
					if (tfValue && tfValue.visible)
					{
						mcComparisonIcon.x = tfValue.x + tfValue.textWidth + TEXT_VALUE_PADDING;
					}
					else
					{
						mcComparisonIcon.x = tfValue.x + TEXT_VALUE_PADDING;
					}
				}
				else
				{
					mcComparisonIcon.visible = false;
				}
			}
			
			//trace("GFX ---------------------<", tfValue, ">--- type: ", data.type,"; value: ", data.value, "; label: ", data.label);
		}
		
		override public function getRendererWidth():Number 
		{
			var actSize:Number = 0;
			if (mcStatIcon.visible) actSize += mcStatIcon.width;			
			if (tfValue && tfValue.visible) actSize += tfValue.textWidth;
			if (mcComparisonIcon.visible) actSize += (mcComparisonIcon.width + TEXT_VALUE_PADDING);
			
			return actSize;
		}
		
	}
}
