
package red.game.witcher3.tooltips
{
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.menus.common.W3StatsListItem;
	
	/**
	 * ONLY FOR CRAFTING AND ALCHEMY
	 * #Y TEMP
	 * @author Getsevich Yaroslav
	 */
	public class TooltipStatRenderer_Craft extends W3StatsListItem
	{
		private static const TEXT_PADDING:Number = 1;
		private static const TEXT_PADDING_NO_ICOM:Number = 3;
		
		override protected function updateText():void
		{
            textField.htmlText = _label;
			textField.width = textField.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			
			tfStatValue.width = tfStatValue.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			tfStatValue.height = tfStatValue.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			
			textField.x = 0;
			
			if (_data.icon != "none")
			{
				textField.x = -(textField.width + mcComparisonIcon.width / 2 + TEXT_PADDING);
				tfStatValue.x = mcComparisonIcon.x + mcComparisonIcon.width / 2 + TEXT_PADDING;
			}
			else
			{
				textField.x = -textField.width - TEXT_PADDING_NO_ICOM;
				tfStatValue.x = TEXT_PADDING_NO_ICOM;
			}
			
			/*
			const two_lines_y = -10;
			const one_line_y = -2;
			const max_widths = 300;
			if (textField.numLines > 1)
			{
				textField.multiline = true;
				textField.height = textField.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				textField.y = two_lines_y;
			}
			else
			{
				textField.y = one_line_y;
			}
			*/
		}

	}

}
