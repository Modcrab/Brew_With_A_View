package red.game.witcher3.menus.worldmap 
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.utils.CommonUtils;
	
	/**
	 * ...
	 * @author Getsevich Yaroslav
	 */
	public class FilteredPinRenderer extends BaseListItem
	{
		private static const ICON_PADDING:Number = -5;
		private static const SHOWN_TEXT_COLOR:Number = 0xCCCCCC;
		private static const HIDDEN_TEXT_COLOR:Number = 0x999999;
		
		public var mcIconHidden:MovieClip;
		public var mcIcon:MovieClip;
		public var tfAmount:TextField;
		
		public function FilteredPinRenderer() 
		{
			tfAmount.text = "";
			mcIcon.visible = false;
			mcIconHidden.visible = true;
			mcIcon.mcPinRadius.visible = false;
			mcIcon.mcPinGlow.visible = false;
		}
		
		override public function setData(data:Object):void
		{
			const TEXT_DEFAUL_X = 24;
			
			super.setData(data);
			
			if (data.threeDots)
			{
				mcIconHidden.visible = false;
				mcIcon.visible = false;
				tfAmount.x = 0;
				tfAmount.text = "...";
				tfAmount.width = tfAmount.textWidth + CommonConstants.SAFE_TEXT_PADDING;
				return;
			}						
			
			mcIcon.visible = true;
			mcIcon.mcPinIcon.gotoAndStop(data.type);
			
			tfAmount.x = TEXT_DEFAUL_X;
			tfAmount.text = data.amount;
			tfAmount.width = tfAmount.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			tfAmount.x = mcIcon.x + mcIcon.width / 2 + ICON_PADDING;
			
			if (data.enabled)
			{
				tfAmount.textColor = SHOWN_TEXT_COLOR;
				mcIconHidden.visible = false;
				mcIcon.filters = [];
			}
			else
			{
				tfAmount.textColor = HIDDEN_TEXT_COLOR;
				mcIconHidden.visible = true;
				mcIcon.filters = [CommonUtils.getDesaturateFilter()];
			}
		}
		
		override public function getRendererWidth():Number 
		{
			var baseWidth:Number = (mcIcon.visible ? mcIcon.width : 0) + ICON_PADDING + tfAmount.width;
			return baseWidth;
		}
		
	}
}
