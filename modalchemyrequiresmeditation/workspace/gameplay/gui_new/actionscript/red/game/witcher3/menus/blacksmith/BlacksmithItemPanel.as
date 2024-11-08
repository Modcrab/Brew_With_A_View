package red.game.witcher3.menus.blacksmith
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3UILoaderSlot;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ButtonEvent;
	
	/**
	 * Base panel for items info in the blacksmith menu
	 * @author Getsevich Yaroslav
	 */
	public class BlacksmithItemPanel extends UIComponent
	{
		private static const ICON_PADDING:Number = 0;
		private static const PRICE_COLOR_ENOUGH:Number = 0xFFFFFF;
		private static const PRICE_COLOR_NOT_ENOUGH:Number = 0xE70000;
		
		public var txtEquipped:TextField;
		public var txtPriceLabel:TextField;
		public var txtPriceValue:TextField;
		public var imageHolder:MovieClip;
		public var mcItemQuality:MovieClip;
		public var mcProgressBar:MovieClip;
		public var mcCoinIcon:Sprite;
		public var price_frame:MovieClip;
		
		protected var _imageLoader:W3UILoaderSlot;
		protected var _inProgress:Boolean;
		protected var _data:Object;
		protected var _playerMoney:int;
		protected var _itemCost:int;
		
		public var btnExecute:InputFeedbackButton;
		public var buttonCallback:Function;
		
		public function BlacksmithItemPanel()
		{
			if (txtEquipped)
			{
				//txtEquipped.text  = "[[panel_blacksmith_equipped]]";
				txtEquipped.visible = false;
			}
			
			txtPriceLabel.text = "[[panel_inventory_item_price]]";
			txtPriceLabel.text = CommonUtils.toUpperCaseSafe(txtPriceLabel.text);
			
			_playerMoney = int.MAX_VALUE;
			_itemCost = 0;
			
			if (btnExecute)
			{
				btnExecute.visible = false; // default
				btnExecute.addEventListener(ButtonEvent.CLICK, handleButtonClick, false, 0, true);
			}
			
			// fired from timeline
			mcProgressBar.addEventListener(Event.COMPLETE, handleProgressComplete, false, 0, true);
		}
		
		public function playErrorAnimation():void
		{
			// virtual
		}
		
		public function setButtonData(btnLabel:String, gpadCode:String, kbCode:int):void
		{
			if (btnExecute)
			{
				btnExecute.label = btnLabel;
				btnExecute.setDataFromStage(gpadCode, kbCode);
				btnExecute.visible = true;
				btnExecute.validateNow();
				
				invalidateSize();
			}
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if (isInvalid(InvalidationType.SIZE))
			{
				if (imageHolder && btnExecute)
				{
					//btnExecute.x = imageHolder.x - btnExecute.getViewWidth() / 2;
				}
			}
		}
		
		public function get playerMoney():int { return _playerMoney }
		public function set playerMoney(value:int):void
		{
			_playerMoney = value;
			txtPriceValue.textColor = _playerMoney < _itemCost ? PRICE_COLOR_NOT_ENOUGH : PRICE_COLOR_ENOUGH;
		}
		
		public function get data():Object { return _data }
		public function set data(value:Object):void
		{
			_data = value;
			updateData();
		}
		
		public function cleanup():void
		{
			cleanupView();
		}
		
		public function isInProgress():Boolean
		{
			return _inProgress;
		}
		
		public function showProcessAnimation():void
		{
			_inProgress	= true;
			mcProgressBar.gotoAndPlay(2);
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnStartCrafting" ));
		}
		
		public function stopProcess():void
		{
			_inProgress	= false;
			mcProgressBar.gotoAndStop(1);
		}
		
		protected function updateData():void
		{
			trace("GFX SUPER updateData ");
			
			cleanupView();
			
			if (mcItemQuality && _data.quality)
			{
				mcItemQuality.gotoAndStop( data.quality );
			}
			
			if (_data.iconPath && imageHolder)
			{
				_imageLoader = new W3UILoaderSlot();
				_imageLoader.source = _data.iconPath;
				_imageLoader.addEventListener(Event.COMPLETE, handleImageLoaded, false, 0, true);
				imageHolder.addChild(_imageLoader);
			}
			
			if (_data.actionPriceTotal)
			{
				_itemCost = _data.actionPriceTotal;
			}
			else
			{
				_itemCost = _data.actionPrice;
			}
			
			if (_itemCost)
			{
				txtPriceLabel.visible = true;
				txtPriceValue.text = _itemCost.toString();
				
				if (price_frame)
				{
					price_frame.visible = true;
				}
				
				//txtPriceValue.width = txtPriceValue.textWidth + CommonConstants.SAFE_TEXT_PADDING;
				txtPriceValue.textColor = _playerMoney < _itemCost ? PRICE_COLOR_NOT_ENOUGH : PRICE_COLOR_ENOUGH;
				mcCoinIcon.visible = true;
				//mcCoinIcon.x = txtPriceValue.x + txtPriceValue.width + ICON_PADDING;
			}
			
			if (txtEquipped)
			{
				//txtEquipped.visible = _data.isEquipped;
			}
			
			visible = true;
			
			trace("GFX SUPER updateData END");
		}
		
		protected function handleButtonClick(event:ButtonEvent):void
		{
			if (buttonCallback != null)
			{
				buttonCallback();
			}
		}
		
		protected function cleanupView():void
		{
			if (_imageLoader)
			{
				_imageLoader.removeEventListener(Event.COMPLETE, handleImageLoaded);
				_imageLoader.unload();
				imageHolder.removeChild(_imageLoader);
			}
			if (txtEquipped)
			{
				//txtEquipped.visible = false;
			}
			
			if (price_frame)
			{
				price_frame.visible = false;
			}
			mcCoinIcon.visible = false;
			txtPriceValue.text = "";
			txtPriceLabel.visible = false;
			if (imageHolder)
			{
				updateSlots(0, imageHolder);
			}
		}
		
		private function handleProgressComplete(event:Event):void
		{
			dispatchEvent(event);
			_inProgress = false;
		}
		
		private function handleImageLoaded(event:Event):void
		{
			if (_imageLoader)
			{
				_imageLoader.x = - Math.round(_imageLoader.actualWidth / 2);
				_imageLoader.y = - Math.round(_imageLoader.actualHeight / 2);
			}
		}
		
		/*
		 * 	Slots
		 * WARNING: COPY-PASTE from SlotBase
		 */
		
		private static const SOCKET_PADDING:Number = 2;
		private static const SOCKET_OFFSET:Number = -35;
		private static const SOCKET_REF:String = "SlotSocketRef";
		private var _slotsItems:Vector.<MovieClip> = new Vector.<MovieClip>;
		public function updateSlots(slotsCount:int, container:MovieClip):void
		{
			if (isNaN(slotsCount)) slotsCount = 0;
			
			var i:int;
			var socketContentRef:Class = getDefinitionByName(SOCKET_REF) as Class;
			while (_slotsItems.length > slotsCount)	container.removeChild(_slotsItems.pop());
			while (_slotsItems.length < slotsCount)
			{
				var newIcon:MovieClip = new socketContentRef() as MovieClip;
				container.addChild(newIcon);
				_slotsItems.push(newIcon);
			}
			
			var maxHeight:Number = parent.height;
			for (i = 0; i < slotsCount; i++ )
			{
				_slotsItems[i].x = SOCKET_OFFSET;
				_slotsItems[i].y = (SOCKET_PADDING + _slotsItems[i].height) * i + SOCKET_OFFSET;
			}
		}
		
	}
}
