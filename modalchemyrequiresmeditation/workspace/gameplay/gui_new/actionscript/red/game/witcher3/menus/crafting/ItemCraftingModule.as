/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.crafting
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import red.core.constants.KeyCode;
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3TextArea;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.ColorSprite;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotCrafting;
	import red.game.witcher3.slots.SlotsListPreset;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import red.game.witcher3.utils.CommonUtils;
	
	public class ItemCraftingModule extends CoreMenuModule
	{
		public var mcCanCraftFeedback:MovieClip;
		public var mcCraftingProgress:MovieClip;
		
		public var mcItemSlotsListPreset:SlotsListPreset;
		
		public var txtIngredients:TextField;
		public var txtCraftedItem:TextField;
		
		public var txtPrice:TextField;
		public var txtPricePrefix:TextField;

		public var mcPriceIcon:MovieClip;
		
		public var mcRecipeSlotItem1:SlotCrafting;
		public var mcRecipeSlotItem2:SlotCrafting;
		public var mcRecipeSlotItem3:SlotCrafting;
		public var mcRecipeSlotItem4:SlotCrafting;
		public var mcRecipeSlotItem5:SlotCrafting;
		public var mcRecipeSlotItem6:SlotCrafting;
		public var mcRecipeSlotItem7:SlotCrafting;
		
		public var mcCraftedItem:MovieClip;
		
		protected var recipeLinkList:Vector.<MovieClip>;
		protected var slotsList:Vector.<MovieClip>;
		
		private var _selectedItemTag:uint;
		public var hideEmptyDataHolders:Boolean = true;
		
		private var iconLoaderStartY:Number = Number.POSITIVE_INFINITY;
		
		public var txtWarning:TextField;
		public var mcWarningBackgound:MovieClip;
		public var mcItemQuality : MovieClip;
		
		private var _autoAlignSlots:Boolean;
		public function get autoAlignSlots():Boolean { return _autoAlignSlots }
		public function set autoAlignSlots(value:Boolean):void
		{
			_autoAlignSlots = value;
		}
		
		public function get selectedItemTag() : uint { return _selectedItemTag; }
		public function set selectedItemTag(value:uint):void
		{
			if (_selectedItemTag != value)
			{
				if (mcCraftingProgress)
				{
					mcCraftingProgress.gotoAndStop(1);
				}
				_selectedItemTag = value;
			}
		}
		
		public function ItemCraftingModule()
		{
			super();
			
			if (mcItemSlotsListPreset)
			{
				mcItemSlotsListPreset.sortData = true;
			}
			
			if (txtWarning && mcWarningBackgound)
			{
				const padding:Number = 30;
				txtWarning.text = "[[panel_crafting_description]]";
				mcWarningBackgound.height = txtWarning.textHeight + padding;
			}
			
			slotsList = new Vector.<MovieClip>;
			
			addChild(mcRecipeSlotItem7);
			addChild(mcRecipeSlotItem6);
			addChild(mcRecipeSlotItem5);
			addChild(mcRecipeSlotItem4);
			addChild(mcRecipeSlotItem3);
			addChild(mcRecipeSlotItem2);
			addChild(mcRecipeSlotItem1);
			
			slotsList.push(mcRecipeSlotItem1);
			slotsList.push(mcRecipeSlotItem2);
			slotsList.push(mcRecipeSlotItem3);
			slotsList.push(mcRecipeSlotItem4);
			slotsList.push(mcRecipeSlotItem5);
			slotsList.push(mcRecipeSlotItem6);
			slotsList.push(mcRecipeSlotItem7);
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			setupRecipeLinks();
			setupCraftingButton();
			
			stage.addEventListener(InputEvent.INPUT, handleInput, false, -1, true);
			
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, updateCraftingButton, false, 0, true);
			
			if (mcCraftingProgress) { mcCraftingProgress.addEventListener(Event.COMPLETE, handleProgressComplete, false, 0, true); }
			
			if (mcItemSlotsListPreset)
			{
				mcItemSlotsListPreset.focusable = false;
			}
		}
		
		protected function setupRecipeLinks():void
		{
			recipeLinkList = new Vector.<MovieClip>();
		}
		
		protected function setupCraftingButton():void
		{
			if (txtIngredients)
			{
				txtIngredients.htmlText = "[[panel_alchemy_required_ingridients]]";
				txtIngredients.htmlText = CommonUtils.toUpperCaseSafe(txtIngredients.htmlText);
			}
			
			if (mcCanCraftFeedback)
			{
				var craftText:W3TextArea = mcCanCraftFeedback.getChildByName("txtCraft") as W3TextArea;
				
				if (craftText)
				{
					craftText.uppercase = true;
					craftText.htmlText = "[[panel_crafting_craft_item]]";
				}
				
				var feedbackButton:InputFeedbackButton = mcCanCraftFeedback.getChildByName("mcButton") as InputFeedbackButton;
				if (feedbackButton)
				{
					feedbackButton.setDataFromStage(NavigationCode.GAMEPAD_A, KeyCode.E);
					feedbackButton.addEventListener(ButtonEvent.CLICK, handleCraftClick, false, 0, true);
				}
				
				updateCraftingButton();
			}
		}
		
		protected function updateCraftingButton(event:ControllerChangeEvent = null):void
		{
			const BTN_GAMEPAD_X:Number = -20;
			const BTN_GAMEPAD_Y:Number = 25;
			const BTN_MOUSE_Y:Number = -25;
			
			if (mcCanCraftFeedback)
			{
				var isGamepad:Boolean = InputManager.getInstance().isGamepad();
				var craftText:W3TextArea = mcCanCraftFeedback.getChildByName("txtCraft") as W3TextArea;
				
				if (craftText)
				{
					craftText.visible = isGamepad;
				}
				
				var feedbackButton:InputFeedbackButton = mcCanCraftFeedback.getChildByName("mcButton") as InputFeedbackButton;
				if (feedbackButton)
				{
					if (isGamepad)
					{
						feedbackButton.label = "";
						feedbackButton.y = BTN_GAMEPAD_Y;
						feedbackButton.x = BTN_GAMEPAD_X;
					}
					else
					{
						feedbackButton.label = "[[panel_crafting_craft_item]]";
						feedbackButton.validateNow();
						
						feedbackButton.y = BTN_MOUSE_Y;
						feedbackButton.x = - feedbackButton.getViewWidth() / 2;
					}
				}
			}
		}
		
		protected function handleCraftClick(event:Event):void
		{
			startCrafting();
		}
		
		protected var _canCraftItem:Boolean = false;
		public function setCraftedItemInfo(schematicTag:uint, itemName:String, fileLoc:String, canCraft:Boolean, gridSize:int, price:String, rarity:int = 0, slotsCount:int = 0):void
		{
			selectedItemTag = schematicTag;
			
			if (txtCraftedItem)
			{
				txtCraftedItem.htmlText = itemName;
				txtCraftedItem.htmlText = CommonUtils.toUpperCaseSafe(txtCraftedItem.htmlText);
				
			}
			
			if (mcCraftedItem)
			{
				if (canCraft)
				{
					
					mcCraftedItem.gotoAndStop("Enabled");
				}
				else
				{
					mcCraftedItem.gotoAndStop("Disabled");
				}
				
				var iconLoader:W3UILoader = mcCraftedItem.getChildByName("mcItem") as W3UILoader;
				
				if (iconLoader)
				{
					if (iconLoaderStartY == Number.POSITIVE_INFINITY)
					{
						iconLoaderStartY = iconLoader.y;
					}
					
					iconLoader.source = "img://" + fileLoc;
					iconLoader.GridSize = gridSize;
					
					if (gridSize == 1)
					{
						iconLoader.y = iconLoaderStartY;
					}
					else
					{
						iconLoader.y = iconLoaderStartY - 32;
					}
				}
				
				
				
				updateSlots(slotsCount, mcCraftedItem);
			}
			
			_canCraftItem = canCraft;
			
			if (mcCanCraftFeedback)
			{
				if (canCraft)
				{
					mcCanCraftFeedback.gotoAndStop("Enabled");
					mcCanCraftFeedback.alpha = 1;
				}
				else
				{
					mcCanCraftFeedback.gotoAndStop("Disabled");
					mcCanCraftFeedback.alpha = 0.4;
				}
			}
			
			updateCraftingCost(price);
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
		
		protected function updateCraftingCost(price:String):void
		{
			if (txtPrice && txtPricePrefix && mcPriceIcon)
			{
				txtPricePrefix.htmlText = "[[panel_inventory_item_price]]";
				
				if (price == "")
				{
					price = "0";
				}
				
				txtPrice.htmlText = price;
				//txtPrice.validateNow();
				//mcPriceIcon.x = txtPrice.x + txtPrice.width / 2 - txtPrice.textField.textWidth / 2;
			}
		}
		
		public function setIngredientItemData(itemData:Array):void
		{
			// reset selection
			if (_autoAlignSlots)
			{
				// #Y
				// mcItemSlotsListPreset.selectedIndex = -1;
				// mcItemSlotsListPreset.validateNow();
			}
			
			mcItemSlotsListPreset.data = itemData;
			mcItemSlotsListPreset.validateNow();
			
			
			centerRenderers();
			
			
			updateRendererVisibility();
			
			updateLinkStates();
			updateSelectionState();
			
			mcItemSlotsListPreset.findSelection();
		}
		public function setItemColorQuality(value : int)
		{
			if (mcItemQuality)
			{
				if (!isNaN(value) && value != 0)
				{
					mcItemQuality.gotoAndStop(value);
				}
				else
				{
					mcItemQuality.gotoAndStop(1);
				}
			}
			
		}
		
		protected function centerRenderers() : void
		{
			const CENTER_POINT:Number = 310;
			const CELL_SIZE:Number = 80;
			const CELL_PADDING:Number = 7;
			
			var nonEmptyCount:int = mcItemSlotsListPreset.NumNonEmptyRenderers();
			var count:int = slotsList.length;
			var listWidth:Number = CELL_SIZE * nonEmptyCount + CELL_PADDING * (nonEmptyCount - 1);
			var initX:Number = CENTER_POINT - listWidth / 2;
			
			for (var i:int = 0; i < count; i++ )
			{
				var curRenderer:MovieClip = slotsList[i];
				curRenderer.x = initX + i * (CELL_SIZE + CELL_PADDING);
			}
		}
		
		protected function updateRendererVisibility() : void
		{
			var i:int;
			var currentRenderer:SlotBase;
			
			for (i = 0; i < mcItemSlotsListPreset.getRenderersLength(); ++i)
			{
				currentRenderer = mcItemSlotsListPreset.getRendererAt(i) as SlotBase;
				
				if (currentRenderer)
				{
					if (currentRenderer.data == null && hideEmptyDataHolders)
					{
						currentRenderer.visible = false;
					}
					else
					{
						currentRenderer.visible = true;
					}
				}
			}
		}
		
		protected function updateLinkStates():void
		{
			var i:int = 0;
			var currentRenderer:SlotCrafting;
			
			for (i = 0; i < recipeLinkList.length; ++i)
			{
				if (recipeLinkList[i])
				{
					currentRenderer = mcItemSlotsListPreset.getRendererAt(i) as SlotCrafting;
					
					if (currentRenderer && currentRenderer.data && currentRenderer.data.reqQuantity <= currentRenderer.data.quantity)
					{
						recipeLinkList[i].gotoAndStop("Enabled");
					}
					else
					{
						recipeLinkList[i].gotoAndStop("Disabled");
					}
				}
			}
		}
		
		public function cleanup():void
		{
			// remove all
			visible = false;
			
			if (mcCraftingProgress)
			{
				mcCraftingProgress.gotoAndStop(1);
			}
		}
		
		override public function set focused(value:Number):void
		{
			super.focused = value;
			
			updateSelectionState();
		}
		
		override public function set active(value:Boolean):void
		{
			super.active = value;
			
			if (!active && mcCraftingProgress)
			{
				mcCraftingProgress.gotoAndStop(1);
			}
		}
		
		protected function updateSelectionState():void
		{
			var currentRenderer:SlotBase;
			var i:int;
			
			currentRenderer = mcItemSlotsListPreset.getSelectedRenderer() as SlotBase;
			if (mcItemSlotsListPreset.selectedIndex == -1 || currentRenderer == null)
			{
				mcItemSlotsListPreset.findSelection();
			}
			
			for (i = 0; i < mcItemSlotsListPreset.getRenderersLength(); ++i)
			{
				currentRenderer = mcItemSlotsListPreset.getRendererAt(i) as SlotBase;
				
				if (currentRenderer)
				{
					currentRenderer.activeSelectionEnabled = focused != 0;
				}
			}
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			var inputDetails:InputDetails = event.details as InputDetails;
			
			if( inputDetails.value == InputValue.KEY_DOWN )
			{
				if ((inputDetails.navEquivalent == NavigationCode.GAMEPAD_A || inputDetails.code == KeyCode.E))
				{
					startCrafting();
					event.handled = true;
				}
				else
				if (inputDetails.navEquivalent == NavigationCode.GAMEPAD_Y)
				{
					var ingrSlot:SlotCrafting = mcItemSlotsListPreset.getSelectedRenderer() as SlotCrafting;
					
					if (ingrSlot && ingrSlot.data && ingrSlot.data.vendorQuantity > 0 )
					{
						dispatchEvent( new GameEvent(GameEvent.CALL, "OnBuyIngredient", [ int( ingrSlot.data.id ), Boolean( (ingrSlot.data.reqQuantity - ingrSlot.data.quantity) == 1) ] ) );
						event.handled = true;
					}
					
				}
			}
			
			if (event.handled || !focused)
			{
				return;
			}
			
			if (mcItemSlotsListPreset)
			{
				mcItemSlotsListPreset.handleInputPreset(event);
			}
		}
		
		public function startCrafting():void
		{
			if (mcCraftingProgress)
			{
				if (_canCraftItem)
				{
					mcCraftingProgress.gotoAndPlay("start");
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnStartCrafting" ));
				}
				else
				{
					mcCraftingProgress.gotoAndPlay("CannotCraft");
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnCraftItem", [selectedItemTag] )); // #J This will trigger the appropriate error message from ws
				}
			}
		}
		
		private function handleProgressComplete(event:Event):void
		{
			dispatchCraftingDone();
		}
		
		protected function dispatchCraftingDone():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnCraftItem", [selectedItemTag] ));
		}
	}
}
