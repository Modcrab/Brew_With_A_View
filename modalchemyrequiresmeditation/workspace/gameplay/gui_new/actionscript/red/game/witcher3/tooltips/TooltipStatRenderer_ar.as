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
	public class TooltipStatRenderer_ar extends BaseListItem
	{
		public static var showComparison:Boolean = false;
		
		protected var STRAIGHTEN_COLUMN_PADDING:Number = 10;
		protected var TEXT_PADDING:Number = 1;
		protected var AR_TEXT_PADDING:Number = 8;
		protected var RIGHT_TEXT_ANCHOR:Number = 430;
		protected var TEXTFIELD_WIDTH_COMPARE:Number = 280;
		protected var TEXTFIELD_WIDTH_NO_COMPARE:Number = 380;
		
		
		private static const COMPARE_PADDING:Number = 4;
		
		public var tfStatValue:TextField;
		public var mcEnchanted:MovieClip;
		public var mcHitArea:MovieClip;
		public var mcCompareArrow:MovieClip;
		public var tfDiffValue:TextField;
		
		protected var _iconShift:Number = 0;
		protected var _columnPadding:Number = 0;
		
		public function get columnPadding() { return _columnPadding; }
		public function set columnPaddingcolumnPadding(value:Number):void
		{
			_columnPadding = value;
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
				mcEnchanted.x = RIGHT_TEXT_ANCHOR - mcEnchanted.width/2 ;
			}
			if (tfStatValue && data.value)
			{
				//tfStatValue.x = curWidth;
				tfStatValue.htmlText = data.value;
				if (mcEnchanted.visible)
				{
					tfStatValue.x = mcEnchanted.x - mcEnchanted.width - tfStatValue.textWidth;
				}
				else
				{
					tfStatValue.x = RIGHT_TEXT_ANCHOR - tfStatValue.textWidth;
				}
				//tfStatValue.width = tfStatValue.textWidth + safe_padding;
				//curWidth += tfStatValue.width + TEXT_PADDING;
			}
			
			if (textField && data.name)
			{
				textField.htmlText = data.name;
				//textField.width = textField.textWidth + safe_padding;
				textField.height = textField.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				textField.x = tfStatValue.x  - textField.textWidth - AR_TEXT_PADDING;
				//textField.x = curWidth;
				//curWidth += textField.textWidth + COMPARE_PADDING;

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
						//tfDiffValue.width = tfDiffValue.textWidth + CommonConstants.SAFE_TEXT_PADDING;
						tfDiffValue.textColor = diffColor;
						tfDiffValue.visible = true;
						tfDiffValue.x = textField.x - tfDiffValue.textWidth - AR_TEXT_PADDING ;
						textField.width = TEXTFIELD_WIDTH_COMPARE;
					}
					else
					{
						tfDiffValue.visible = false;
						textField.width = TEXTFIELD_WIDTH_NO_COMPARE;
					}
				}
				if (mcCompareArrow)
				{
					mcCompareArrow.gotoAndStop(targetFrame);
					mcCompareArrow.visible = true;
					mcCompareArrow.x = tfDiffValue.x - AR_TEXT_PADDING;
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
			
			
		}
		
		override public function get height():Number
		{
			
			if (textField && textField.text)
			{
				return textField.height;
			}
			
			return super.height;
		}
		
	}
}
