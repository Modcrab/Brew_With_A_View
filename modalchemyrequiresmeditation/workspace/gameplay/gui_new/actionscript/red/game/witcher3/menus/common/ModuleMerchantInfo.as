package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.core.CoreComponent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * Merchant info for inventory / crafting / blacksmithing
	 * @author Getsevich Yaroslav
	 */
	public class ModuleMerchantInfo extends UIComponent
	{
		private static const ICON_PADDING:Number = 2;
		private static const TITLE_PADDING:Number = 10;
		
		public var txtType:TextField;
		public var txtLevelValue:TextField;
		public var txtMoney:TextField;
		public var mcCoinIcon:MovieClip;
		public var bkImage:MovieClip;
		public var txtTypeInitY:Number;
		
		protected var _data:Object;
		
		public function ModuleMerchantInfo()
		{
			cleanup();
			txtTypeInitY = txtType.y;
		}
		
		public function get data():Object { return _data }
		public function set data(value:Object):void
		{
			_data = value;
			populateData();
		}
		
		public function setMerchantTypeCheck(wrongLevel:Boolean, wrongType:Boolean):void
		{
			//txtType.textColor = (wrongLevel || wrongType) ? 0xE00000 : 0xB58D48;
			//txtLevelValue.textColor = wrongLevel ? 0xE00000 : 0xB58D48;
		}
		
		private function populateData():void
		{
			cleanup();
			this.visible = true;
			var textValue:String;
			if (_data.type)
			{
				textValue = _data.typeName;
				
				if (CoreComponent.isArabicAligmentMode)
				{
					txtType.htmlText = "<p align=\"right\">" + textValue + "</p>";
				}
				else
				{
					txtType.htmlText = textValue;
					CommonUtils.toSmallCaps(txtType);
				}
				//
				//txtType.width = txtType.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			}
			if (_data.level)
			{
				textValue = _data.level;
				txtLevelValue.htmlText = textValue;
				txtLevelValue.htmlText = CommonUtils.toUpperCaseSafe(textValue);
				if (CoreComponent.isArabicAligmentMode)
				{
					txtLevelValue.htmlText = "<p align=\"right\">" + textValue + "</p>";
				}
				
			}
			if (txtLevelValue.text == "")
			{
				txtType.y = -5.6;
			}
			else
			{
				txtType.y = txtTypeInitY;
			}
			
			var money:Number = _data.money;
			if (!isNaN(money) && money >= 0)
			{
				//txtMoney.x = txtType.x + txtType.width + TITLE_PADDING;
				txtMoney.text = money.toString();
				//txtMoney.width = txtMoney.textWidth + CommonConstants.SAFE_TEXT_PADDING;
				//mcCoinIcon.x = txtMoney.x + txtMoney.width + ICON_PADDING;
				mcCoinIcon.visible = true;
			}
			if (bkImage && _data.type)
			{
				bkImage.gotoAndStop(_data.type);
			}
		}
		
		private function cleanup():void
		{
			this.visible = false;
			txtType.text = "";
			txtLevelValue.text = "";
			txtMoney.text = "";
			mcCoinIcon.visible = false;
			
		}
		
		
	}

}
