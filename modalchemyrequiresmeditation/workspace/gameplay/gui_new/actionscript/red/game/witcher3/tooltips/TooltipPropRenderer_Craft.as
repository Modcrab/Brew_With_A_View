package red.game.witcher3.tooltips
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.core.CoreComponent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.menus.common.W3StatsListItem;
	
	/**
	 * ONLY FOR CRAFTING AND ALCHEMY
	 * @author Getsevich Yaroslav
	 */
	public class TooltipPropRenderer_Craft extends BaseListItem
	{
		private const ICON_PADDING:Number = 10;
		private const BLOCK_PADDING:Number = 5;
		private const MAX_TEXT_WIDTHS:Number = 320;
		private const ICON_SINGLE_Y:Number = 12;
		private const ICON_DOUBLE_Y:Number = 12; //24;
		private const VALUE_DOUBLE_Y:Number = 0; //11;
		private const RIGHT_ANCHOR : Number = 485;
		private const TEXT_PADDING: Number = 5;
		
		public var tfDiffValue:TextField;
		public var tfStatValue:TextField;
		public var mcComparisonIcon:MovieClip;
		
		override public function getRendererHeight():Number
		{
			return textField.textHeight;
		}
		
		override protected function updateText():void
		{
			
			textField.width = MAX_TEXT_WIDTHS;
			textField.htmlText = addArabicWrapper(_data.name);
			textField.height = textField.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			textField.width = textField.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			
			tfDiffValue.htmlText = _data.diffValue;
			tfDiffValue.width = tfDiffValue.textWidth + TEXT_PADDING;
			
			tfStatValue.text = _data.value;
			tfStatValue.width = tfStatValue.textWidth + TEXT_PADDING;

			if (!CoreComponent.isArabicAligmentMode)
			{
				textField.x = tfStatValue.x + tfStatValue.width;
				
				if (mcComparisonIcon)
				{
					if (data.icon)
					{
						mcComparisonIcon.visible = true;
						mcComparisonIcon.gotoAndStop(data.icon);
						mcComparisonIcon.x = textField.x + textField.width + ICON_PADDING;
					}
					else
					{
						mcComparisonIcon.visible = false;
					}
					
					if (data.diffValue)
					{
						tfDiffValue.htmlText = data.diffValue;
						tfDiffValue.width = tfDiffValue.textWidth + CommonConstants.SAFE_TEXT_PADDING;
						tfDiffValue.x = mcComparisonIcon.x + ICON_PADDING;
					}
					else
					{
						tfDiffValue.visible = false;
					}
				}
			}
			else
			{
				if (mcComparisonIcon)
				{
					if (data.diffValue)
					{
						tfDiffValue.htmlText = data.diffValue;
						tfDiffValue.width = tfDiffValue.textWidth + CommonConstants.SAFE_TEXT_PADDING;
						tfDiffValue.x = RIGHT_ANCHOR - tfDiffValue.width;
					}
					else
					{
						tfDiffValue.visible = false;						
					}
					if (data.icon)
					{
						mcComparisonIcon.visible = true;
						mcComparisonIcon.gotoAndStop(data.icon);
						mcComparisonIcon.x = RIGHT_ANCHOR - tfDiffValue.textWidth - mcComparisonIcon.width;
						if (data.icon == "none" )
						{
							textField.x = RIGHT_ANCHOR - textField.width;
						}
						else
						{
						textField.x = mcComparisonIcon.x - mcComparisonIcon.width - textField.width;	
						}
						
					}
					else
					{
						mcComparisonIcon.visible = false;
						
					}
					
					tfStatValue.x = textField.x + textField.width - textField.textWidth - tfStatValue.width;
					
				}
				
				
			}
			
			if (textField.numLines > 1)
			{
				tfDiffValue.y = VALUE_DOUBLE_Y;
				tfStatValue.y = VALUE_DOUBLE_Y;
				mcComparisonIcon.y = ICON_DOUBLE_Y;
			}
			else
			{
				tfDiffValue.y = 0;
				tfStatValue.y = 0;
				mcComparisonIcon.y = ICON_SINGLE_Y;
			}
		}
		
		private function addArabicWrapper(value:String):String
		{
			if ( CoreComponent.isArabicAligmentMode )
			{
				return "<p align=\"right\">" + value + "</p>";
			}
			else
			{
				return value;
			}
		}
		
	}
}
