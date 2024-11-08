/***********************************************************************
/** Tooltip stats list item renderer
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.BaseListItem;
	import red.core.CoreComponent;
	import red.game.witcher3.utils.CommonUtils;
	
	public class FullStatsListItem extends W3StatisticsListItem
	{
		private static const TEXT_POSITION:Number = 145;
		private static const TEXT_PADDING:Number = 10;
		
		public var mcColorCoding:MovieClip;
		public var mcBackground:MovieClip;
		public var mcIcon:MovieClip;
		public var tfStatValueMax:TextField;
		
		override public function setData( data:Object ):void
		{
			const VALUE_TEXT_SIZE:Number = 30;
			const VALUE_TEXT_SIZE_ARAB:Number = 24;
			
			super.setData( data );
			
			if (data)
			{
				mcIcon.gotoAndStop(data.iconTag);
				
				// reduce font size for arabic
				if (CoreComponent.isArabicAligmentMode)
				{
					_statValue = "<font size = '" + VALUE_TEXT_SIZE_ARAB + "'>" +  data.value + "</font>";
				}
				
				if (data.maxValue)
				{
					tfStatValueMax.text = data.maxValue;
					tfStatValueMax.width = tfStatValueMax.textWidth + CommonConstants.SAFE_TEXT_PADDING;
					tfStatValueMax.visible = true;
				}
				else
				{
					tfStatValueMax.visible = false;
				}
				
				var targetColor:String = data.itemColor ? data.itemColor : "Brown";
				
				mcColorCoding.gotoAndStop(targetColor);
				mcBackground.gotoAndStop(targetColor);
				
				validateNow();
			}
		}
		
		override protected function updateText():void
		{
			super.updateText();
			
			const DBL_TEXT_POS:Number = 3;
			const MAX_TEXT_SIZE:Number = 350;
			const DEFAULT_LABEL_POS_X:Number = 168;
			const DEFAULT_LABEL_PADDING:Number = 5;
			
			textField.width = MAX_TEXT_SIZE;
			textField.htmlText = CommonUtils.toUpperCaseSafe(textField.htmlText);
			textField.width = textField.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			textField.height = textField.textHeight + CommonConstants.SAFE_TEXT_PADDING;
						
			const ICON_BORDER = -5;
			var textPadding:Number = TEXT_POSITION;
			var iconEdge:Number = mcIcon.x + mcIcon.width / 2 + ICON_BORDER;
			
			if (iconEdge > TEXT_POSITION - tfStatValueMax.textWidth)
			{
				tfStatValueMax.x = iconEdge - ICON_BORDER;
			}
			else
			{
				tfStatValueMax.x = TEXT_POSITION - tfStatValueMax.textWidth;
			}
			
			if (iconEdge > TEXT_POSITION - tfStatValue.textWidth)
			{
				tfStatValue.x = iconEdge - ICON_BORDER;
			}
			else
			{
				tfStatValue.x = TEXT_POSITION - tfStatValue.textWidth;
			}
			
			if (tfStatValue.x + tfStatValue.textWidth > DEFAULT_LABEL_POS_X - DEFAULT_LABEL_PADDING)
			{
				textField.x = tfStatValue.x + tfStatValue.textWidth + DEFAULT_LABEL_PADDING;
			}
			else
			{
				textField.x = DEFAULT_LABEL_POS_X;
			}
			
			textField.y = mcIcon.y - textField.height / 2;
			
			if (tfStatValueMax.visible)
			{
				tfStatValue.y = DBL_TEXT_POS;
			}
			else
			{
				tfStatValue.y = mcIcon.y - tfStatValue.height / 2;
			}
			
		}
	}
}
