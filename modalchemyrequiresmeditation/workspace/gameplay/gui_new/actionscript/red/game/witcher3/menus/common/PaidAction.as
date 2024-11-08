package red.game.witcher3.menus.common 
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.InputFeedbackButton;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * red.game.witcher3.menus.common.PaidAction
	 * @author Getsevich Yaroslav
	 */
	public class PaidAction extends UIComponent
	{
		protected const TEXT_PADDING:Number = 10;
		
		public var tfPriceLabel:TextField;
		public var tfPriceValue:TextField;
		public var mcCoinIcon:MovieClip;
		public var btnAction:InputFeedbackButton;
		
		public function PaidAction()
		{
			if (tfPriceLabel)
			{
				tfPriceLabel.text = "[[panel_inventory_item_price]]";
				tfPriceLabel.width = tfPriceLabel.textWidth + CommonConstants.SAFE_TEXT_PADDING;
				tfPriceLabel.visible = false;
			}
			
			tfPriceValue.visible = false;
			mcCoinIcon.visible = false;
		}
		
		protected var _price:Number;
		public function get price():Number { return _price }
		public function set price(value:Number):void
		{
			_price = value;
			
			var showPrice:Boolean = _price > 0;
			
			if (!showPrice)
			{
				tfPriceValue.visible = false;
				mcCoinIcon.visible = false;
			}
			else
			{
				tfPriceValue.visible = true;
				mcCoinIcon.visible = true;
				
				tfPriceValue.text = String(_price);
				mcCoinIcon.x = tfPriceValue.x + tfPriceValue.textWidth + TEXT_PADDING;
			}
			
			if (tfPriceLabel)
			{
				tfPriceLabel.visible = showPrice;
			}
			
		}
		
		override public function set visible(value:Boolean):void 
		{
			super.visible = value;
			btnAction.enabled = value;
		}
		
		
		
		
	}

}
