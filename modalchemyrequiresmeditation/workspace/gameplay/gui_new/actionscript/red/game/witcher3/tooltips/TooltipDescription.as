package red.game.witcher3.tooltips
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.RenderersList;
	import red.game.witcher3.utils.CommonUtils;

	/**
	 * Simple tooltip for all inventory items except weapons/armors/potions/bombs
	 * @author Getsevich Yaroslav
	 */
	public class TooltipDescription extends TooltipBase
	{
		public var tfItemName:TextField;
		public var tfItemType:TextField;
		public var tfDescription:TextField;

		public var propsList:RenderersList;
		public var listStats:RenderersList;
		
		public var delTitle:Sprite;

		public function TooltipDescription()
		{
			visible = false;
		}

		override protected function populateData():void
		{
			super.populateData();
			if (!_data) return;

			var descriptionText:String = "";
			var commonDescription:String = _data.description;
			var uniqDescription:String = _data.UniqueDescription;
			visible = true;
			applyTextValue(tfItemType, _data.ItemType, false,true);
			applyTextValue(tfItemName, _data.ItemName, true, true);
			
			// #Y Hardcode
			const ONE_LINE_NAME_Y = 6;
			const TWO_LINES_NAME_Y = -16;
			const ONE_LINE_HEIGHT = 30;
			tfItemName.height = tfItemName.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			if (tfItemName.textHeight > ONE_LINE_HEIGHT)
			{
				tfItemName.y = TWO_LINES_NAME_Y;
			}
			else
			{
				tfItemName.y = ONE_LINE_NAME_Y;
			}
			
			propsList.dataList = _data.PropertiesList as Array;

			if (commonDescription && commonDescription.charAt(0) != "#" )
			{
				descriptionText = commonDescription;
			}
			if (uniqDescription && uniqDescription.charAt(0) != "#" )
			{
				if (descriptionText.length > 0 )
				{
					descriptionText += ("<br>" + uniqDescription);
				}
				else
				{
					descriptionText += uniqDescription;
				}
			}
			applyTextValue(tfDescription, descriptionText, false, true);
			tfDescription.height = tfDescription.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			if (listStats && _data.StatsList)
			{
				listStats.visible = true;
				delTitle.visible = true;
				listStats.dataList = _data.StatsList;
				listStats.y = tfDescription.y + tfDescription.textHeight + 15;
			}
			else
			{
				listStats.visible = false;
				delTitle.visible = false;
			}
		}
	}
}
