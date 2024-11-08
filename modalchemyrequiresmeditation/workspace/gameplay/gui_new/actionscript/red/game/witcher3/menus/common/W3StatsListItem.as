/***********************************************************************
/** Tooltip stats list item renderer
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.utils.CommonUtils;

	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.data.ListData;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import flash.events.MouseEvent;

	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.controls.BaseListItem;

	public class W3StatsListItem extends BaseListItem
	{
		protected static const MAX_LABLE_WIDTH_OFFSET:Number = 10;

		public var mcComparisonIcon : MovieClip;
		public var mcStatIcon		: MovieClip;
		public var tfStatValue 		: TextField;

		override public function setData( data:Object ):void
		{
			super.setData( data );
			if ( !data )
			{
				return;
			}

			if (data.color)
			{
				var prefix:String = "<font color=\"#";
				var color:String = data.color;
				var suffix:String = "\">";
				label = prefix + data.color + suffix + data.name + "</font>";
			}
			else
			{
				label = data.name;
			}
			tfStatValue.htmlText = data.value;

			if (mcComparisonIcon)
			{
				if (data.icon)
				{
					mcComparisonIcon.gotoAndStop(data.icon);
					mcComparisonIcon.visible = true;
				}
				else
				{
					mcComparisonIcon.visible = false;
				}
			}
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
		}

		override protected function updateText():void
		{
            if (_label != null && textField != null)
			{
                textField.htmlText = _label;
				textField.width = textField.textWidth + CommonConstants.SAFE_TEXT_PADDING;
            }
			
			//update the value field and the icon positioning based on the length of the attribute text
			/*
			tfStatValue.x = textField.x + Math.min(textField.textWidth + MAX_LABLE_WIDTH_OFFSET, textField.width);
			mcComparisonIcon.x = tfStatValue.x + tfStatValue.textWidth + MAX_LABLE_WIDTH_OFFSET + mcComparisonIcon.width / 2;
			*/

			tfStatValue.x = textField.x + textField.width + 5;
			mcComparisonIcon.x = tfStatValue.x + tfStatValue.textWidth + 5 + mcComparisonIcon.width / 2;
		}

		override protected function updateAfterStateChange():void { };
	}
}
