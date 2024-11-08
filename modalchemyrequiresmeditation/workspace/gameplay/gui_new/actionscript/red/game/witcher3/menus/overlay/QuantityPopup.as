package red.game.witcher3.menus.overlay
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3QuantitySlider;
	import red.game.witcher3.controls.W3Slider;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.overlay.BasePopup;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.SliderEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;

	/**
	 * Quantity Popup (sell/buy/transfer items)
	 * @author Getsevich Yaroslav
	 */
	public class QuantityPopup extends BasePopup
	{
		public var txtTitle:TextField;
		
		public var tfPriceValue:TextField;
		
		public var mcSlider:W3QuantitySlider;
		public var mcPriceIcon:MovieClip;
		public var mcBettingMoneyIcon:MovieClip;
		
		protected var _itemPrice:Number;
		protected var _currentQuantity:int;
		protected var _showPrice:Boolean;
		
		private const INVALID_VALUE : Number = 0xFF0000;
		private const VALID_VALUE : Number = 0xB18A5F
		private const MONEY_ICON_PADDING : Number = 25;
		
		public function QuantityPopup()
		{			
			mcInpuFeedback.buttonAlign = "center";
			tfPriceValue.text = "0";
			
			mcSlider.visible = false;			
			mcSlider.snapping = true;
			mcSlider.liveDragging = true;
		}
		
		protected override function configUI():void
		{
			super.configUI();
			
			mcSlider.addEventListener(SliderEvent.VALUE_CHANGE, handlSliderChanged, false, 0, true);
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
		}

		override protected function populateData():void
		{
			super.populateData();
			
			mcInpuFeedback.handleSetupButtons(_data.ButtonsList);
			
			_showPrice = _data.ShowPrice;
			if (_showPrice)
			{
				_itemPrice = _data.ItempPrice;
				mcPriceIcon.visible = true;
				tfPriceValue.visible = true;
			}
			else
			{
				mcPriceIcon.visible = false;
				tfPriceValue.visible = false;
			}
			
			alignControls();
			
			txtTitle.htmlText = _data.TextTitle;
			txtTitle.htmlText = CommonUtils.toUpperCaseSafe(txtTitle.htmlText);
			
			mcSlider.minimum = _data.minValue;
			mcSlider.maximum = _data.maxValue;
			mcSlider.value = _data.currentValue;
			mcSlider.visible = true;
			
			if (_showPrice)
			{
				tfPriceValue.text = String(mcSlider.value  * _itemPrice);
			}
			
			if (mcBettingMoneyIcon)
			{
				mcBettingMoneyIcon.visible = _data.displayMoneyIcon;
			}
			alignMoneyIcon();	
		}
		
		protected function alignControls():void
		{
			const money_slider_y = 140;
			const money_icon_y = 104;
			const quant_slider_y = 153;
			const quant_icon_y = 117;
			
			if (_showPrice)
			{
				mcSlider.y = money_slider_y;
				if (mcBettingMoneyIcon) mcBettingMoneyIcon.y = money_icon_y;
			}
			else
			{
				mcSlider.y = quant_slider_y;
				if (mcBettingMoneyIcon) mcBettingMoneyIcon.y = quant_icon_y;
			}
		}
		
		protected function handlSliderChanged(event:SliderEvent):void
		{
			if ( _currentQuantity != event.value )
			{
				_currentQuantity = event.value;
				tfPriceValue.text = String(_currentQuantity * _itemPrice);
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSetQuantity', [_currentQuantity] ) );
				
				removeEventListener(Event.ENTER_FRAME, handleValidatePosition);
				addEventListener(Event.ENTER_FRAME, handleValidatePosition, false, 0, true);
			}
		}
		
		private function handleValidatePosition():void
		{
			removeEventListener(Event.ENTER_FRAME, handleValidatePosition);
			
			checkValidBet();
			alignMoneyIcon();
		}
		
		private function alignMoneyIcon() : void
		{
			if (mcBettingMoneyIcon)
			{
				if ( mcBettingMoneyIcon.visible )
				{
					var txtValue : TextField = mcSlider.txtValue;

					//manual local to stage calculation since the icon is outside of the slider mc
					mcBettingMoneyIcon.x = txtValue.x + ((txtValue.width - txtValue.textWidth) / 2) + txtValue.textWidth + MONEY_ICON_PADDING + mcSlider.x;
				}
			}
		}
		
		override public function handleInput(event:InputEvent):void
		{
			super.handleInput(event);
			
			if (event.handled)
			{
				return;
			}
			
			var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			
			if (keyPress)
			{
				var needUpdate:Boolean = false;
				
				switch(details.navEquivalent)
				{
					case NavigationCode.LEFT:
					case NavigationCode.DOWN:
						mcSlider.value--;
						event.handled = true;
						needUpdate = true;
						return;
					case NavigationCode.RIGHT:
					case NavigationCode.UP:
						mcSlider.value++;
						event.handled  = true;
						needUpdate = true;
						return;
					case NavigationCode.HOME:
						mcSlider.value = mcSlider.minimum;
						event.handled  = true;
						needUpdate = true;
						return;
					case NavigationCode.END:
						mcSlider.value = mcSlider.maximum;
						event.handled  = true;
						needUpdate = true;
						return;
				}
				
				if (!event.handled)
				{
					switch(details.code)
					{
						case KeyCode.NUMPAD_ADD:
							mcSlider.value++;
							needUpdate = true;
							break;
						case KeyCode.NUMPAD_SUBTRACT:
							mcSlider.value--;
							needUpdate = true;
							break;
					}
				}
				
				if (needUpdate)
				{
					//checkValidBet();
					//alignMoneyIcon();
				}
			}
		}
		
		private function checkValidBet() : void
		{
			//this will only be called thru the betting popup, hence checking for the money icon.
			if (mcBettingMoneyIcon)
			{
				if ( mcBettingMoneyIcon.visible )
				{
					if ( mcSlider.value > _data.playerMoney )
						mcSlider.txtValue.textColor = INVALID_VALUE;
					else
						mcSlider.txtValue.textColor = VALID_VALUE;				
				}
			}
		}
	}
}
