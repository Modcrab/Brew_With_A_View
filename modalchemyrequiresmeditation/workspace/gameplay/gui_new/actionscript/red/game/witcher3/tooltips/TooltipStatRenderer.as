package red.game.witcher3.tooltips
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import red.core.CoreComponent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.BaseListItem;
	
	/**
	 * red.game.witcher3.tooltips.TooltipStatRenderer
	 * Item renderer for inventory tooltip
	 * @author Getsevich Yaroslav
	 */
	public class TooltipStatRenderer extends BaseListItem
	{
		public static var showComparison:Boolean = false;
		
		protected var STRAIGHTEN_COLUMN_PADDING:Number = 10;
		protected var TEXT_PADDING:Number = 1;
		private static const COMPARE_PADDING:Number = 4;
		
		public var tfStatValue:TextField;
		public var mcEnchanted:MovieClip;
		public var mcHitArea:MovieClip;
		public var mcCompareArrow:MovieClip;
		public var tfDiffValue:TextField;
		
		protected var _iconShift:Number = 0;
		protected var _columnPadding:Number = 0;
		
		public function get columnPadding() { return _columnPadding; }
		public function set columnPadding(value:Number):void
		{
			_columnPadding = value;
			
			if (tfStatValue)
			{
				tfStatValue.x = _columnPadding - tfStatValue.width;
			}
			
			updateTextFieldSize();
		}
		
		protected function updateTextFieldSize():void
		{
			if (textField)
			{
				
				var itemWidth:Number = mcHitArea ? mcHitArea.width : this.width;
				var curWidth:Number = 0;
				
				if (mcCompareArrow && mcCompareArrow.visible)
				{
					itemWidth -= mcCompareArrow.width + COMPARE_PADDING;
				}
				
				if (tfDiffValue && tfDiffValue.text)
				{
					itemWidth -= tfDiffValue.textWidth + COMPARE_PADDING;
				}
				
				textField.x = _columnPadding + STRAIGHTEN_COLUMN_PADDING;
				if (!CoreComponent.isArabicAligmentMode)
				{
					textField.width	= itemWidth - textField.x;
				}
				
				textField.height = textField.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				
				curWidth = textField.x + textField.width + COMPARE_PADDING;
				
				if (mcCompareArrow)
				{
					mcCompareArrow.x = curWidth + mcCompareArrow.width / 2;
					curWidth += mcCompareArrow.width + COMPARE_PADDING;
				}
				
				if (tfDiffValue)
				{
					tfDiffValue.x = curWidth;
					curWidth += tfDiffValue.textWidth + COMPARE_PADDING;
				}
			}
		}
		
		override public function setData(data:Object):void
		{
			super.setData(data);
			
			updateText();
		}
		
		override protected function updateText():void
		{
			if (!data)
			{
				visible = false;
				return;
			}
			
			visible = true;
			
			var safe_padding:Number = CommonConstants.SAFE_TEXT_PADDING;
			var curWidth:Number = _iconShift;
			
			if (mcEnchanted)
			{
				mcEnchanted.visible = data.enchanted;
				
				if (mcEnchanted.x > 0 && data.enchanted)
				{
					curWidth += mcEnchanted.width + TEXT_PADDING * 2;
				}
			}
			
			if (!isNaN(data.diff) && showComparison)
			{
				var targetFrame:String;
				var diffColor:Number;
				var diffPrefix:String;
				var forced:Boolean = false;
				
				if (data.diff > 0)
				{
					targetFrame = "better";
					diffColor = 0x4aba00;
					diffPrefix = "+";
				}
				else
				if (data.diff < 0)
				{
					targetFrame = "worse";
					diffColor = 0xba0000;
					diffPrefix = "";
				}
				else
				{
					diffColor = 0x535353;
					targetFrame = "equal";
					diffPrefix = "";
					data.diff = 0;
					data.isPercentageValue = true;
					forced = true;
				}
				
				if (mcCompareArrow)
				{
					mcCompareArrow.gotoAndStop(targetFrame);
					mcCompareArrow.visible = true;
				}
				
				if (tfDiffValue)
				{
					if (data.diff || forced)
					{
						var finalValue:String = "";
						
						if (data.isPercentageValue)
						{
							finalValue = Math.round(data.diff * 100) + " %";
						}
						else
						{
							finalValue = String(Math.round(data.diff));
						}
						
						tfDiffValue.htmlText = diffPrefix + finalValue;
						tfDiffValue.width = tfDiffValue.textWidth + CommonConstants.SAFE_TEXT_PADDING;
						tfDiffValue.textColor = diffColor;
						tfDiffValue.visible = true;
					}
					else
					{
						tfDiffValue.visible = false;
					}
				}
			}
			else
			{
				if (mcCompareArrow)
				{
					mcCompareArrow.visible = false;
				}
				if (tfDiffValue)
				{
					tfDiffValue.visible = false;
					tfDiffValue.text = "";
				}
			}
			
			if (tfStatValue && data.value)
			{
				tfStatValue.x = curWidth;
				tfStatValue.htmlText = data.value;
				tfStatValue.width = tfStatValue.textWidth + safe_padding;
				curWidth += tfStatValue.width + TEXT_PADDING;
			}
			
			if (textField && data.name)
			{
				
				textField.htmlText = data.name;				
				if (isNaN(_columnPadding) || _columnPadding <= 0)
				{
					textField.width = textField.textWidth + safe_padding;
					textField.height = textField.textHeight + CommonConstants.SAFE_TEXT_PADDING;
					textField.x = curWidth;
					curWidth += textField.textWidth + COMPARE_PADDING;
				}
				else
				{
					updateTextFieldSize();
				}
			}
		}
		
		override public function get height():Number
		{
			/*
			if (mcHitArea)
			{
				return mcHitArea.height;
			}
			else
			*/
			if (textField && textField.text)
			{
				return textField.height;
			}
			
			return super.height;
		}
		
	}
}
