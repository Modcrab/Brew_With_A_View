package red.game.witcher3.tooltips
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import scaleform.clik.core.UIComponent;
	import red.game.witcher3.utils.CommonUtils;
	
	/**
	 * @author Getsevich Yaroslav
	 */
	public class TooltipPrimaryStat extends UIComponent
	{
		protected static const SMALL_PADDING:Number = 8;
		protected static const SMALL_PADDING_TEXT:Number = 20;
		protected static const STAT_NAME_PADDING:Number = 3;
		protected static const BIG_PADDING:Number = 25;
		protected static const ICON_PADDING:Number = 10;
		protected static const DIFF_PADDING:Number = 10;
		
		public var tfValue:TextField;
		public var tfLabel:TextField;
		public var tfDiffValue:TextField;
		public var txtDurabilityPrefix:TextField;
		
		public var mcComparisonIcon:MovieClip;
		public var mcDurabilityIcon:Sprite;
		public var thisWidth:Number;
		
		private var diffPosition:Number;
		
		public function setValue(value:Number, label:String, diff:String = "none", delta:Number = 0, diffValue:String = "", durabilityPenalty:Number = 0 ):void
		{
			var currentPosition:Number = 0;
			thisWidth = 0;
			// ----- value
			
			if (delta > 0)
			{
				var deltaValue:Number = value * delta;
				var minValue:Number = Math.round(value - deltaValue);
				var maxValue:Number = Math.round(value + deltaValue);
				if (minValue != maxValue)
					tfValue.htmlText = minValue + "-" + maxValue;
				else
					tfValue.htmlText = String(maxValue);
			}
			else
			{
				tfValue.htmlText = String(Math.round(value));
			}
			
			tfValue.width = tfValue.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			thisWidth = tfValue.width;
			currentPosition = tfValue.x + tfValue.textWidth + SMALL_PADDING;
			
			// ----- label
			
			if (label)
			{
				tfLabel.htmlText = label;
				tfLabel.htmlText = CommonUtils.toUpperCaseSafe(tfLabel.htmlText);
			}
			
			tfLabel.width = tfLabel.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			thisWidth += tfLabel.width;
			tfLabel.x = currentPosition;
			
			currentPosition = tfLabel.x + tfLabel.width + STAT_NAME_PADDING;
			
			// ----- durability
			
			if (txtDurabilityPrefix  && mcDurabilityIcon)
			{
				if (durabilityPenalty > 0)
				{
					txtDurabilityPrefix.visible = true;
					txtDurabilityPrefix.text = "-" + durabilityPenalty;
					txtDurabilityPrefix.width = txtDurabilityPrefix.textWidth + CommonConstants.SAFE_TEXT_PADDING;
					txtDurabilityPrefix.x = currentPosition;
					currentPosition += (txtDurabilityPrefix.textWidth + SMALL_PADDING);
					
					mcDurabilityIcon.visible = true;
					mcDurabilityIcon.x = currentPosition;
					
					currentPosition += mcDurabilityIcon.width + BIG_PADDING;
					
					thisWidth += txtDurabilityPrefix.width+ SMALL_PADDING_TEXT;
					thisWidth += mcDurabilityIcon.width;
				}
				else
				{
					txtDurabilityPrefix.visible = false;
					
					mcDurabilityIcon.visible = false;
					currentPosition += STAT_NAME_PADDING;
				}
			}
			else
			{
				currentPosition += STAT_NAME_PADDING;
			}
			
			// ----- compare
			
			if (mcComparisonIcon)
			{
				 if (diff && diff != "none")
				 {
					mcComparisonIcon.visible = true;
					mcComparisonIcon.gotoAndStop(diff);
					mcComparisonIcon.x = currentPosition;
					currentPosition += ICON_PADDING;
					thisWidth += mcComparisonIcon.width;
				 }
				 else
				 {
					mcComparisonIcon.visible = false;
					mcComparisonIcon.x = mcComparisonIcon.width / 2;
				 }
			}
			
			// diff
			
			if (tfDiffValue)
			{
				if (diffValue)
				{
					tfDiffValue.htmlText = diffValue;
					tfDiffValue.width = tfDiffValue.textWidth + CommonConstants.SAFE_TEXT_PADDING;
					tfDiffValue.x = currentPosition;
					tfDiffValue.visible = true;
					currentPosition += tfDiffValue.textWidth + DIFF_PADDING;
					thisWidth += tfDiffValue.width;
				}
				else
				{
					tfDiffValue.x = 0;
					tfDiffValue.width = 0;
					tfDiffValue.visible = false;
				}
			}

			
			
			
		}
	}
}
