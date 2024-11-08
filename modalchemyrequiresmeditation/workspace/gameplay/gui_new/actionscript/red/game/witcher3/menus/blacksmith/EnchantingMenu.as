package red.game.witcher3.menus.blacksmith 
{
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.menus.common.DropdownEnchantmentsFilterMode;
	import red.game.witcher3.menus.common.EnchantmentListItemRenderer;
	import red.game.witcher3.menus.common.InventoryListItemRenderer;
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.menus.common.ModuleMerchantInfo;
	import red.game.witcher3.menus.common.PaidAction;
	import red.game.witcher3.menus.common.PlainListModule;
	import red.game.witcher3.menus.common.RecipeIconItemRenderer;
	import red.game.witcher3.tooltips.TooltipInventory;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	
	/**
	 * EnchantingMenu - EP1 -
	 * red.game.witcher3.menus.blacksmith.EnchantingMenu
	 * r4enchanting.menu
	 * @author Getsevich Yaroslav
	 */
	public class EnchantingMenu extends CoreMenu
	{
		public var mcItemsList:EnchantingItemsListModule;
		public var mcEnchantmentsList:EnchantingItemsListModule;
		public var mcIngredientsList:RequiredIngredientsListModule;
		
		public var mcTooltipAnchor:MovieClip;
		public var mcFiltersMode:DropdownEnchantmentsFilterMode;
		public var moduleMerchantInfo:ModuleMerchantInfo;
		
		public var mcActionEnchant:PaidAction;
		public var mcActionRemoveEnchantment:PaidAction;
		
		public var txtActiveFiltersTitle:TextField;
		public var txtActiveFiltersList:TextField;
		
		public var mcFilterAnchor: MovieClip;
		
		//public var mcActionDelimiter:MovieClip;
		
		private var _enchantmentEnabled:Boolean = false;
		private var _removeEnchantmentEnabled:Boolean = false;
		
		private var _isInProgress:Boolean;
		private var _selectedItemRenderer:InventoryListItemRenderer;
		private var _selectedEnchantmentRenderer:EnchantmentListItemRenderer;
		private var _selectedItemData:Object;
		private var _selectedEnchantmentData:Object;
		
		private var _filterLocStr_hasIngredients:String;
		private var _filterLocStr_missingIngredients:String;
		private var _filterLocStr_level1:String;
		private var _filterLocStr_level2:String;
		private var _filterLocStr_level3:String;
		
		private var _filter_hasIngredients:Boolean = true;
		private var _filter_missingIngredients:Boolean = true;
		private var _filter_level1:Boolean = true;
		private var _filter_level2:Boolean = true;
		private var _filter_level3:Boolean = true;
		private var _lastFilteredList:Array;
		
		private var _addSocketMode:Boolean = false;
		private var _notEnoughMoneyToApply:Boolean = false;
		private var _notEnoughMoneyToRemove:Boolean = false;
		private var _cachedEnchantmentIdx:int = -1;
		
		private var _pinnedTag : uint = 0;
		private var _inputSymbolIDA	: int = -1;
		private var _inputSymbolIDX	: int = -1;
		
		const listDefaultPos = 740;
		const listAnimPos = 745;
		const ingredientsDefaultPos = 1340;
		const ingredientsAnimPos = 1343;
		
		public function EnchantingMenu() 
		{
			if (mcFiltersMode)
			{
				mcFiltersMode.closeCB = filterModeClosed;
				mcFiltersMode.disallowCloseOnNoCheck = true;
			}
			
			TooltipInventory.ingnoreSafeRect = true;
			
			mcEnchantmentsList.filterFunction = applyFilters;
			txtActiveFiltersTitle.text = "[[gui_active_filters_title]]";
			
			mcItemsList.addEventListener(ListEvent.INDEX_CHANGE, handleItemSelected, false, 0, true);
			mcEnchantmentsList.addEventListener(FocusEvent.FOCUS_OUT, handleEnchantmentsUnfocus, false, 0, true);
			mcIngredientsList.active = false;
			
			mcActionEnchant.visible = false;
			mcActionEnchant.btnAction.label = "[[input_enchant_item]]";
			mcActionEnchant.btnAction.setDataFromStage(NavigationCode.GAMEPAD_A, KeyCode.E);
			mcActionEnchant.btnAction.addEventListener(ButtonEvent.CLICK, handleEnchantClick, false, 0, true);
			
			mcActionRemoveEnchantment.visible = false;
			mcActionRemoveEnchantment.btnAction.label = "[[input_remove_enchant]]";
			mcActionRemoveEnchantment.btnAction.setDataFromStage(NavigationCode.GAMEPAD_Y, KeyCode.DELETE);
			mcActionRemoveEnchantment.btnAction.addEventListener(ButtonEvent.CLICK, handleRemoveEnchantmentClick, false, 0, true);
			
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
			
			//InputFeedbackManager.eventDispatcher = this;
			//InputFeedbackManager.useOverlayPopup = false;
			
			//mcActionDelimiter.visible = false;
		}
		
		public function setPinnedRecipe(tag:uint):void
		{
			_pinnedTag  = tag;
			EnchantmentListItemRenderer.setCurrentPinnedTag(stage, tag);
		}
		
		public function /*WS*/ selectFirstEnchantment():void
		{
			mcIngredientsList.focused = 1;
			
			removeEventListener(Event.ENTER_FRAME, pendedSelectFirstEnchantment, false);
			addEventListener(Event.ENTER_FRAME, pendedSelectFirstEnchantment, false, 0, true);
		}
		
		protected function pendedSelectFirstEnchantment(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, pendedSelectFirstEnchantment, false);
			
			currentModuleIdx = 1;
		}
		
		public function /*WS*/ enableEnchantment(enchEnabled:Boolean, enchPrice:Number, notEnoughMoney:Boolean):void
		{
			_notEnoughMoneyToApply = notEnoughMoney;
			_enchantmentEnabled = enchEnabled;
			
			mcActionEnchant.visible = enchEnabled;
			mcActionEnchant.price = enchPrice;
			
			mcActionEnchant.tfPriceValue.textColor = _notEnoughMoneyToApply ? 0xFF0000 : 0xB68E49;
			updateActionsView();
		}
		
		public function /*WS*/ enableRemovingEnchantment(removingEnabled:Boolean, removingPrice:Number, notEnoughMoney:Boolean):void
		{
			_removeEnchantmentEnabled = removingEnabled;
			_notEnoughMoneyToRemove = notEnoughMoney;
			
			mcActionRemoveEnchantment.visible = removingEnabled;
			mcActionRemoveEnchantment.price = removingPrice;
			
			mcActionRemoveEnchantment.tfPriceValue.textColor = _notEnoughMoneyToRemove ? 0xFF0000 : 0xB68E49;
			updateActionsView();
		}
		
		private function updateActionsView():void
		{
			const POS_ACTION_ENCHANT:Number = 910;
			const POS_ACTION_REMOVE_ENCHANTMENT:Number = 961;
			
			if (mcActionEnchant.visible || mcActionRemoveEnchantment.visible)
			{
				mcActionRemoveEnchantment.y = mcActionEnchant.visible ? POS_ACTION_REMOVE_ENCHANTMENT : POS_ACTION_ENCHANT;
				//mcActionDelimiter.visible = true;
			}
			else
			{
				//mcActionDelimiter.visible = false;
			}
		}
		
		public function handleEnchantmentsUnfocus(event:Event = null):void
		{
			resetSelection();
		}
		
		override public function set currentModuleIdx(value:int):void
		{
			super.currentModuleIdx = value;
			
			if (mcEnchantmentsList.focused < 1)
			{
				resetSelection();
			}
			else 
			{
				handleEnchantmentSelected();
			}
			
			if (mcItemsList.focused > 0)
			{
				handleItemSelected();
			}
		}
		
		override protected function get menuName():String { return "EnchantingMenu"	}
		override protected function configUI():void 
		{
			super.configUI();
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "populate.items", [populateItemsList] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "populate.enchantments", [populateEnchantmentsList] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "populate.ingredients", [populateIngredientsList] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "blacksmith.merchant.info", [setMerchantInfo] ) );
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			
			_contextMgr.addGridEventsTooltipHolder(stage, false);
			_contextMgr.defaultAnchor = mcTooltipAnchor;
			
			selectTargetModule(mcItemsList);
			
			InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_LSTICK_HOLD, KeyCode.F , "panel_common_filters");
			InputFeedbackManager.updateButtons(this);
		}
		
		private function resetSelection():void
		{
			GTweener.removeTweens(mcIngredientsList);
			GTweener.to(mcIngredientsList, .5, { x : ingredientsDefaultPos, alpha : 0 }, { ease:Sine.easeOut } );
			
			_selectedItemRenderer = mcItemsList.mcScrollingList.getSelectedRenderer() as InventoryListItemRenderer;
			
			if (_selectedItemRenderer && _isInProgress)
			{
				_selectedItemRenderer.resetProgress();
				_isInProgress = false;
			}			
			
			enableEnchantment(false, 0, false);
			mcIngredientsList.active = false;
			
			updatePinInputFeedback();
		}
		
		private function handleItemSelected(event:ListEvent = null):void
		{
			var selectedItemRenderer:InventoryListItemRenderer = mcItemsList.mcScrollingList.getSelectedRenderer() as InventoryListItemRenderer;
			var applEnchantment:uint = 0;
			
			_addSocketMode = false;
			
			if (selectedItemRenderer)
			{
				var selectedItemData:Object = selectedItemRenderer.data;
				
				resetSelection();
				
				if (selectedItemData && selectedItemData.id)
				{
					_selectedItemData = selectedItemData;
					_selectedItemRenderer = selectedItemRenderer;
					
					removeEventListener(Event.ENTER_FRAME, pendedItemSelection, false);
					addEventListener(Event.ENTER_FRAME, pendedItemSelection, false, 0, true);
					
					applEnchantment = _selectedItemData.enchantmentId;
					
					if (_selectedItemData.isNotEnoughSockets)
					{
						_addSocketMode = true;
						
						// TODO:
						//mcActionEnchant.btnAction.label = "[[panel_blacksmith_add_socket]]";
						//mcActionEnchant.price = _selectedItemData.addSocketPrice;
					}
				}
			}
			if (!_addSocketMode)
			{
				
				// TODO:
				// reset
				//mcActionEnchant.btnAction.label = "[[panel_blacksmith_add_socket]]";
				//mcActionEnchant.price = _selectedItemData.addSocketPrice;
			}
			
			// #Y temp
			EnchantmentListItemRenderer.DISABLE_ACTION = _addSocketMode;
			EnchantmentListItemRenderer.APPLIED_ENCHANTMENT = applEnchantment;
		}
		
		private function pendedItemSelection(event:Event = null):void
		{
			removeEventListener(Event.ENTER_FRAME, pendedItemSelection, false);
			
			if (_selectedItemData)
			{
				if (_selectedItemData.userData as String == "ShowAll")
				{
					dispatchEvent(new GameEvent(GameEvent.CALL, "OnShowAllEnchantments", []));
				}
				else
				{
					dispatchEvent(new GameEvent(GameEvent.CALL, "OnSelectItem", [_selectedItemData.id]));
				}
			}
		}
		
		private function handleEnchantmentSelected(event:ListEvent = null):void
		{
			var selectedItemRenderer:EnchantmentListItemRenderer = mcEnchantmentsList.mcScrollingList.getSelectedRenderer() as EnchantmentListItemRenderer;
			
			if (selectedItemRenderer)
			{
				var selectedEnchantmentData:Object = selectedItemRenderer.data;
				
				if (mcEnchantmentsList.focused < 1)
				{
					updatePinInputFeedback();
					return;
				}
				
				if (_selectedItemRenderer && _isInProgress)
				{
					_selectedItemRenderer.resetProgress();
					_isInProgress = false;
				}
				
				if (selectedEnchantmentData && selectedEnchantmentData.name)
				{
					_selectedEnchantmentData = selectedEnchantmentData;
					_selectedEnchantmentRenderer = 	selectedItemRenderer;
					
					// to avoid event spamming
					removeEventListener(Event.ENTER_FRAME, pendedEnchantmentSelection, false);
					addEventListener(Event.ENTER_FRAME, pendedEnchantmentSelection, false, 0, true);
					
					mcIngredientsList.active = true;
				}
				else
				{
					_selectedEnchantmentData = null;
				}
				
				updatePinInputFeedback();
			}
		}
		
		private function pendedEnchantmentSelection(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, pendedEnchantmentSelection, false);
			if (_selectedEnchantmentData)
			{
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnSelectEnchantment", [uint(_selectedEnchantmentData.name)]))
			}
		}
		
		private function populateItemsList(data:Object):void
		{
			var cachedSelectedIndex:int = mcItemsList.mcScrollingList.selectedIndex;
			var itemsListArray:Array = data as Array;			
			
			cachedSelectedIndex = cachedSelectedIndex > -1 ? cachedSelectedIndex : 0;
			
			itemsListArray.sortOn( [ 'isNotEnoughSockets', 'isEquipped' ], [0, Array.DESCENDING] );
			
			var showAllRenderer:ItemDataStub = new ItemDataStub();
			showAllRenderer.itemName = "[[panel_enchanting_show_all]]";
			showAllRenderer.userData = "ShowAll";
			showAllRenderer.id = 1;
			itemsListArray.unshift(showAllRenderer);
			
			mcItemsList.data = itemsListArray;
			mcItemsList.mcScrollingList.validateNow();
			mcItemsList.validateNow();
			
			mcItemsList.mcScrollingList.selectedIndex = cachedSelectedIndex;
			mcItemsList.mcScrollingList.validateNow();
			
			handleItemSelected();
		}
		
		private function populateEnchantmentsList(data:Object):void
		{
			var enchantmentsListArray:Array = data as Array;
			var cachedSelectedIndex:Number = _cachedEnchantmentIdx;
			_cachedEnchantmentIdx = -1;
			
			mcEnchantmentsList.removeEventListener(ListEvent.INDEX_CHANGE, handleEnchantmentSelected);
			
			enchantmentsListArray.sortOn(["type", "level"], Array.DESCENDING);
			
			mcEnchantmentsList.data = enchantmentsListArray;
			mcEnchantmentsList.alpha = 0;
			mcEnchantmentsList.x = listAnimPos;
			mcEnchantmentsList.validateNow();
			
			GTweener.removeTweens(mcEnchantmentsList);
			GTweener.to(mcEnchantmentsList, .5, { x:listDefaultPos, alpha:1 }, {ease:Sine.easeIn }  );
			
			if (!enchantmentsListArray || enchantmentsListArray.length < 1)
			{
				mcEnchantmentsList.enabled = false;
				mcIngredientsList.active = false;
			}
			else
			{
				mcEnchantmentsList.enabled = true;
				//mcIngredientsList.active = true;
				
				mcEnchantmentsList.addEventListener(ListEvent.INDEX_CHANGE, handleEnchantmentSelected, false, 0, true);
			}
			
			if (mcEnchantmentsList.focused)
			{
				cachedSelectedIndex = cachedSelectedIndex > -1 ? cachedSelectedIndex : 0;
				
				mcEnchantmentsList.mcScrollingList.selectedIndex = cachedSelectedIndex;
				mcEnchantmentsList.mcScrollingList.validateNow();
			}
		}
		
		private function populateIngredientsList(data:Object):void
		{
			var ingredientsList:Object = data;
			
			mcIngredientsList.data = ingredientsList;
			
			GTweener.removeTweens(mcIngredientsList);
			if (ingredientsList)
			{
				GTweener.to(mcIngredientsList, .5, { x : ingredientsDefaultPos, alpha : 1 }, {ease:Sine.easeIn }  );
			}
			else
			{
				GTweener.to(mcIngredientsList, .5, { x : ingredientsAnimPos, alpha : 0 }, {ease:Sine.easeOut }  );
			}
		}
		
		private function enchantItem():void
		{
			if (_addSocketMode)
			{
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnNotEnoughSockets", [ ]));
				return;				
			}
			
			if (!_enchantmentEnabled)
			{
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnUnexpectedError", [ ]));
				return;
			}
			
			if (_notEnoughMoneyToApply)
			{
				mcActionEnchant.mcCoinIcon.gotoAndPlay("error");
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnNotEnoughMoney", [ ]));
				return;
			}
			
			if (!_isInProgress && _selectedItemRenderer && _selectedItemData)
			{
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnConfrimAction", [ uint(_selectedItemData.id), mcActionEnchant.price, false ]));
			}
		}
		
		public function startEnchanting():void // WS
		{
			if (!_isInProgress && _selectedItemRenderer)
			{
				_isInProgress = true;
				
				_selectedItemRenderer = mcItemsList.mcScrollingList.getSelectedRenderer() as InventoryListItemRenderer;	
				_selectedItemRenderer.showProgress(false, callEnchantItem , callSoundTrigger );
				
			}
		}
		
		private function callSoundTrigger( removeSound : Boolean ):void
		{
			if(removeSound){ dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlayEnchantSound", [ true ]));}
			else{dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlayEnchantSound", [ false ]));}
		}
		
		
		private function removeEnchantmentItem():void
		{
			if (!_removeEnchantmentEnabled)
			{
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnUnexpectedError", [ ]));
				return;
			}
			
			if (_notEnoughMoneyToRemove)
			{
				mcActionRemoveEnchantment.mcCoinIcon.gotoAndPlay("error");
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnNotEnoughMoney", [ ]));
				return;
			}
			
			if (!_isInProgress && _selectedItemRenderer && _selectedItemData)
			{
				//dispatchEvent(new GameEvent(GameEvent.CALL, "OnConfrimRemoving", [ uint(_selectedItemData.id) ]));
				//startRemovingEnchantments();
				
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnConfrimAction", [ uint(_selectedItemData.id), mcActionRemoveEnchantment.price, true ]));
			}
		}
		
		public function startRemovingEnchantments():void // WS
		{
			_isInProgress = true;
			_selectedItemRenderer = mcItemsList.mcScrollingList.getSelectedRenderer() as InventoryListItemRenderer;	
			_selectedItemRenderer.showProgress(true, callRemoveEnchantmentItem , callSoundTrigger );
		}
		
		private function callEnchantItem():void
		{
			if ( _selectedEnchantmentData && _selectedItemData)
			{
				_cachedEnchantmentIdx = mcEnchantmentsList.mcScrollingList.selectedIndex;
				
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnEnchantItem", [ uint(_selectedItemData.id), uint(_selectedEnchantmentData.name) ]));				
				_isInProgress = false;
			}
		}
		
		private function callRemoveEnchantmentItem():void
		{
			if (_selectedItemData)
			{
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnRemoveEnchantment", [ uint(_selectedItemData.id) ] ));
				_isInProgress = false;
			}
		}
		
		private function handleEnchantClick(event:ButtonEvent):void
		{
			enchantItem();
		}
		
		private function handleRemoveEnchantmentClick(event:ButtonEvent):void
		{
			removeEnchantmentItem();
		}
		
		public function updatePinInputFeedback():void
		{
			if (_inputSymbolIDX != -1) 
			{ 
				InputFeedbackManager.removeButton(this, _inputSymbolIDX); 
				_inputSymbolIDX = -1;
			}
			
			if ( _selectedEnchantmentData != null && mcEnchantmentsList.focused > 0 )
			{
				if (_selectedEnchantmentData.name == _pinnedTag)
				{
					_inputSymbolIDX = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_X, KeyCode.Q, "inputfeedback_unpin_recipe");
				}
				else
				{
					_inputSymbolIDX = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_X, KeyCode.Q, "inputfeedback_pin_recipe");
				}
			}
			
			InputFeedbackManager.updateButtons(this);
		}
		
		private function togglePinOnSelectedRecipe():void
		{
			if ( _selectedEnchantmentData != null && mcEnchantmentsList.focused > 0 )
			{
				var targetTag:uint;
				
				if (_inputSymbolIDX != -1) 
				{ 
					InputFeedbackManager.removeButton(this, _inputSymbolIDX); 
					_inputSymbolIDX = -1;
				}
				
				if (_pinnedTag == _selectedEnchantmentData.name)
				{
					targetTag = 0;
					_inputSymbolIDX = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_X, KeyCode.Q, "inputfeedback_pin_recipe");
				}
				else
				{
					targetTag = _selectedEnchantmentData.name;
					_inputSymbolIDX = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_X, KeyCode.Q, "inputfeedback_unpin_recipe");
				}
				
				InputFeedbackManager.updateButtons(this);
				
				_pinnedTag = targetTag;
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnChangePinnedRecipe', [targetTag] ) );
				EnchantmentListItemRenderer.setCurrentPinnedTag(stage, _pinnedTag);
			}
		}
		
		override public function handleInput(event:InputEvent):void 
		{
			super.handleInput(event);
			
			var details:InputDetails = event.details;
			
			if (details.value != InputValue.KEY_UP || mcFiltersMode.visible || event.handled)
			{
				return;
			}
			
			switch (details.navEquivalent)
			{
				case NavigationCode.GAMEPAD_Y:
					removeEnchantmentItem();
					return;
					break;
					
				case NavigationCode.GAMEPAD_A:
				case NavigationCode.ENTER:
					enchantItem();
					return;
					break;
				case NavigationCode.GAMEPAD_X:
					togglePinOnSelectedRecipe();
					return;
					break;					
			}
			
			switch (details.code)
			{
				case KeyCode.DELETE:
					removeEnchantmentItem();
					return;
					break;
				case KeyCode.E:
					enchantItem();
					return;
					break;
				case KeyCode.Q:
					togglePinOnSelectedRecipe();
					return;
					break;					
			}
		}
		
		override protected function handleInputNavigate(event:InputEvent):void
		{
			if (mcFiltersMode.visible)
			{
				return;
			}
			
			super.handleInputNavigate(event);
			
			var details:InputDetails = event.details;
			var inputEnabled:Boolean = details.value == InputValue.KEY_UP && !event.handled;
			
			if (inputEnabled)
			{
				if (!mcFiltersMode.visible && 
						(details.code == KeyCode.F || details.navEquivalent == NavigationCode.GAMEPAD_L3))
				{
					showFilterMode();
				}
			}
		}
		
		/*
		 * Filters
		 */
		
		override protected function onLastMoveStatusChanged()
		{
			if (mcFiltersMode)
			{
				mcFiltersMode.lastMoveWasMouse = _lastMoveWasMouse;
			}
		}
		
		public function setLocalization(strHasIngredients:String, strMissingIngredients:String, strLevel1:String, strLevel2:String, strLevel3:String):void
		{
			trace("GFX setLocalization ", strHasIngredients, strMissingIngredients, strLevel1);
			
			_filterLocStr_hasIngredients = strHasIngredients;
			_filterLocStr_missingIngredients = strMissingIngredients;
			_filterLocStr_level1 = strLevel1;
			_filterLocStr_level2 = strLevel2;
			_filterLocStr_level3 = strLevel3;
		}
		
		public function setFiltersData(hasIngredients:Boolean, missingIngredients:Boolean, level1:Boolean, level2:Boolean, level3:Boolean ):void
		{
			var defaultData:Array;
			
			defaultData = [{ key:"HasIngredients", label:_filterLocStr_hasIngredients, isChecked:hasIngredients },
						   { key:"MissingIngredients", label:_filterLocStr_missingIngredients, isChecked:missingIngredients },
						   { key:"Level1", label:_filterLocStr_level1, isChecked:level1 },
						   { key:"Level2", label:_filterLocStr_level2, isChecked:level2 },
						   { key:"Level3", label:_filterLocStr_level3, isChecked:level3 } ];
			
			mcFiltersMode.setData(defaultData);
			mcFiltersMode.validateNow();
			
			if (_lastFilteredList != null)
			{
				mcEnchantmentsList.data = _lastFilteredList;
			}
			
			updateFiltersText();
		}
		
		private function showFilterMode():void
		{
			mcFiltersMode.show();
		}
		
		private function updateFiltersText():void
		{
			var showHasIngredients:Boolean = mcFiltersMode.isBoxChecked("HasIngredients");
			var showMissingIngredients:Boolean = mcFiltersMode.isBoxChecked("MissingIngredients");
			var showLevel1:Boolean = mcFiltersMode.isBoxChecked("Level1");
			var showLevel2:Boolean = mcFiltersMode.isBoxChecked("Level2");
			var showLevel3:Boolean = mcFiltersMode.isBoxChecked("Level3");
			var finalString:String;
			
			finalString = "";
			
			if (showHasIngredients && showMissingIngredients && showLevel1 && showLevel2 && showLevel3)
			{
				// don't show description for default state
				txtActiveFiltersList.text = "";
				txtActiveFiltersTitle.visible = false;
				return;
			}
			txtActiveFiltersTitle.visible = false;
			
			if (!showHasIngredients)
			{
				finalString = _filterLocStr_hasIngredients;
			}
			
			if (!showMissingIngredients)
			{
				if (finalString != "") finalString += ", ";
				finalString += _filterLocStr_missingIngredients;
			}
			
			if (!showLevel1)
			{
				if (finalString != "") finalString += ", ";
				finalString += _filterLocStr_level1;
			}
			
			if (!showLevel2)
			{
				if (finalString != "") finalString += ", ";
				finalString += _filterLocStr_level2;
			}
			
			if (!showLevel3)
			{
				if (finalString != "") finalString += ", ";
				finalString += _filterLocStr_level3;
			}
			
			txtActiveFiltersList.text = finalString;
			
			txtActiveFiltersList.height = txtActiveFiltersList.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			txtActiveFiltersList.y = mcFilterAnchor.y + mcFilterAnchor.height - txtActiveFiltersList.height;
		}
		
		private function applyFilters(dataArray:Array):Array
		{
			_lastFilteredList = dataArray;
			
			var filteredList:Array = new Array();
			var showHasIngredients:Boolean = mcFiltersMode.isBoxChecked("HasIngredients");
			var showMissingIngredients:Boolean = mcFiltersMode.isBoxChecked("MissingIngredients");
			var showLevel1:Boolean = mcFiltersMode.isBoxChecked("Level1");
			var showLevel2:Boolean = mcFiltersMode.isBoxChecked("Level2");
			var showLevel3:Boolean = mcFiltersMode.isBoxChecked("Level3");
			
			var i:int;
			var curObj:Object;
			
			for (i = 0; i < dataArray.length; ++i)
			{
				curObj = dataArray[i];
				
				var checkMissingIngredients:Boolean = curObj.canApply || showMissingIngredients;
				var checkHasIngredients:Boolean = !curObj.canApply || showHasIngredients;
				var checkLevel1:Boolean = curObj.level != 1 || showLevel1;
				var checkLevel2:Boolean = curObj.level != 2 || showLevel2;
				var checkLevel3:Boolean = curObj.level != 3 || showLevel3;
				
				if (checkMissingIngredients && checkHasIngredients && checkLevel1 && checkLevel2 && checkLevel3)
				{
					filteredList.push(curObj);
				}
				
			}
			
			return filteredList;
		}
		
		private function filterModeClosed(valuesChanged:Boolean):void
		{
			if (valuesChanged)
			{
				if (_lastFilteredList != null)
				{
					mcEnchantmentsList.data = _lastFilteredList;
					mcEnchantmentsList.validateNow();
				}
				
				var showHasIngredients:Boolean = mcFiltersMode.isBoxChecked("HasIngredients");
				var showMissingIngredients:Boolean = mcFiltersMode.isBoxChecked("MissingIngredients");
				var showLevel1:Boolean = mcFiltersMode.isBoxChecked("Level1");
				var showLevel2:Boolean = mcFiltersMode.isBoxChecked("Level2");
				var showLevel3:Boolean = mcFiltersMode.isBoxChecked("Level3");
				
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnFiltersChanged', [showHasIngredients, showMissingIngredients, showLevel1, showLevel2, showLevel3] ) );
				
				updateFiltersText();
			}
		}
		
		private function setMerchantInfo(value:Object):void
		{
			moduleMerchantInfo.data = value;
		}
		
	}

}
