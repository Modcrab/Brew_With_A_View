/***********************************************************************
/** Tooltip stats list item renderer
/***********************************************************************
/** Copyright © 2015 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import red.core.CoreComponent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.utils.CommonUtils;
	
	// #J NOTE: I created another class instead of using W3StatisticsListItem because in some cases it's being derived from and this was
	// safest way with short time I have to change PlayerFullStatsModule to new design while minimizing risk of new bugs
	public class AdaptiveStatsListItem extends W3StatisticsListItem
	{
		private const MAX_LABEL_WIDTH = 390;
		private const MAX_LABEL_WIDTH_ARAB = 370;
		private const EMPTY_ROW_HEIGHT:Number = 15;
		private const EMPTY_ROW_HEIGHT_ARAB:Number = -8;
		private const HEADER_SUPER_POS_Y:Number = 16;
		private const HEADER_SUPER_POS_X:Number = 18;
		private const HEADER_POS_Y:Number = 0;
		private const HEADER_POS_X:Number = 0;
		
		private var otherTextFormat: TextFormat;
		private var lTextFormat : TextFormat;
		
		public var tfHeader      : TextField;
		public var mcBackground  : MovieClip;
		
		public function AdaptiveStatsListItem()
		{
			mcBackground.visible = false;
			lTextFormat = new TextFormat("$NormalFont", 24);
			otherTextFormat = new TextFormat("$NormalFont", 22);
			
			lTextFormat.font = "$NormalFont";
			otherTextFormat.font = "$NormalFont";
			//otherTextFormat.color = 0xFFFFFF;
		}
		
		
		override public function setData( data:Object ):void
		{
			super.setData( data );
						
			if (data)
			{
				validateNow();
				
				textField.multiline = true;
				if (CoreComponent.isArabicAligmentMode)
				{
					textField.width = MAX_LABEL_WIDTH_ARAB;
					textField.defaultTextFormat = otherTextFormat;			
					textField.setTextFormat(otherTextFormat);
				}
				else
				{
					textField.width = MAX_LABEL_WIDTH;
					textField.defaultTextFormat = lTextFormat;			
					textField.setTextFormat(lTextFormat);
				}
				textField.htmlText = textField.htmlText;
				textField.height = textField.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				
				if (data.tag == "Header" || data.tag == "SuperHeader")
				{
					tfStatValue.visible = false;
					textField.visible = false;
					tfHeader.visible = true;
					
					var strValue:String = data.name;
					
					mcBackground.visible = false;
					
					if (data.tag == "SuperHeader")
					{
						strValue =  strValue;
						
						if (data.backgroundColor)
						{
							mcBackground.gotoAndStop(data.backgroundColor);
							mcBackground.visible = true;
							
							tfHeader.x = HEADER_SUPER_POS_X;
							tfHeader.y = HEADER_SUPER_POS_Y;
							tfHeader.textColor = 0xffffff;
							
						}
					}
					else
					{
						tfHeader.x = HEADER_POS_X;
						tfHeader.y = HEADER_POS_Y;
						tfHeader.textColor = 0x887a5f;
					}
					
					if (CoreComponent.isArabicAligmentMode)
					{
						tfHeader.htmlText = "<p align=\"right\">" + strValue + "</p>";
					}
					else
					{
						tfHeader.htmlText = strValue;
						tfHeader.htmlText = CommonUtils.toUpperCaseSafe(tfHeader.htmlText);
					}
				}
				else
				{
					tfStatValue.visible = true;
					textField.visible = true;
					tfHeader.visible = false;
				}
				
			}
		}
		
		override protected function updateText():void 
		{
			super.updateText();
			if (CoreComponent.isArabicAligmentMode)
				{
					textField.width = MAX_LABEL_WIDTH_ARAB;
					textField.defaultTextFormat = otherTextFormat;			
					textField.setTextFormat(otherTextFormat);
				}
				else
				{
					textField.width = MAX_LABEL_WIDTH;
					textField.defaultTextFormat = lTextFormat;			
					textField.setTextFormat(lTextFormat);
				}
			
		}
		
		public function get rendererHeight():Number
		{
			if (tfStatValue.text == "" && textField.text == "")
			{
				if (CoreComponent.isArabicAligmentMode)
				{
					return EMPTY_ROW_HEIGHT_ARAB;
				}
				else
				{
					return EMPTY_ROW_HEIGHT;
				}
			}
			else
			if (mcBackground && mcBackground.visible)
			{
				return mcBackground.height;
			}
			else
			if (tfHeader && tfHeader.visible)
			{
				return tfHeader.textHeight;
			}
			else
			if (textField)
			{
				return textField.height;
			}
			else
			{
				return super.actualHeight;
			}
		}
		
	}
}
