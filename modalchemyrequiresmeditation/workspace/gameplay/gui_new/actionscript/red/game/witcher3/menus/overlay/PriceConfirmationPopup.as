package red.game.witcher3.menus.overlay
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.gfx.Extensions;

	public class PriceConfirmationPopup extends BasePopup
	{
		private static const ICON_PADDING:Number = 2;
		private static const PRICETEXT_PADDING:Number = 14;
		private static const TITLE_PADDING:Number = 10;
		private static const BUTTONS_PADDING:Number = 30;
		private static const BOTTOM_PADDING:Number = 10;
		
		public var tfMessage:TextField;
		public var tfTitle:TextField;		
		public var tfPriceValue:TextField;
		
		public var mcPriceIcon:Sprite;
		
		public var mcBackground:Sprite;
		public var textBorder:MovieClip;
		
		public function PriceConfirmationPopup()
		{
			cleanup();
			if (!Extensions.isScaleform)
			{
				startDebugMode();
			}
		}
		
		override protected function populateData():void
		{
			super.populateData();			
			cleanup();
			
			tfTitle.htmlText = CommonUtils.toUpperCaseSafe(_data.TextTitle);
			//tfTitle.width = tfTitle.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			
			var itemPrice:Number = _data.ItempPrice;
			if (!isNaN(itemPrice) && itemPrice > 0)
			{
				//tfPriceValue.x = tfTitle.x + tfTitle.width + TITLE_PADDING;
				tfPriceValue.text = itemPrice.toString();
				
				//tfPriceValue.width = tfPriceValue.textWidth + CommonConstants.SAFE_TEXT_PADDING;
				//tfPriceValue.y = tfMessage.y + tfMessage.height + PRICETEXT_PADDING;
				//mcPriceIcon.x = tfPriceValue.x + tfPriceValue.width + mcPriceIcon.width / 2 + ICON_PADDING;
				//mcPriceIcon.y = tfPriceValue.y + tfPriceValue.height / 2;
				mcPriceIcon.visible = true;
			}
			
			tfMessage.htmlText = _data.TextContent;
			tfMessage.height = tfMessage.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			tfMessage.y = textBorder.y + textBorder.height / 2 - tfMessage.textHeight / 2;
			
			if (_data.ButtonsList)
			{		
				mcInpuFeedback.handleSetupButtons(_data.ButtonsList);
			}
			
			//mcInpuFeedback.y = tfMessage.y + tfMessage.height + BUTTONS_PADDING;			
			//mcInpuFeedback.y = tfPriceValue.y + tfPriceValue.height + BUTTONS_PADDING;
			//mcBackground.height = mcInpuFeedback.y + mcInpuFeedback.height / 2 +  BOTTOM_PADDING;
		}
		
		private function cleanup():void
		{
			tfMessage.text = "";
			tfTitle.text = "";
			tfPriceValue.text = "";
			mcPriceIcon.visible = false;
		}
		
		private function startDebugMode():void
		{
			var testData:Object = { };
			testData.ItempPrice = 468;
			testData.TextTitle = "Test title";
			testData.TextContent = "Test message";
			data = testData;
		}
		
	}

}
