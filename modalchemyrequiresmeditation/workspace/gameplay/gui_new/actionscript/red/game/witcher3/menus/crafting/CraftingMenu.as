/***********************************************************************
/** PANEL Crafting  main class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/
package red.game.witcher3.menus.crafting
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.managers.ContextInfoManager;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.managers.PanelModuleManager;
	import red.game.witcher3.menus.common.CheckboxListMode;
	import red.game.witcher3.menus.common.DropdownListModuleBase;
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.menus.common.ModuleMerchantInfo;
	import red.game.witcher3.menus.common.RecipeIconItemRenderer;
	import red.game.witcher3.modules.ItemTooltipModule;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;

	public class CraftingMenu extends CoreMenu
	{
		protected static const FIRST_RIGHT_MODULE_Y:Number = 180;
		protected static const SECOND_RIGHT_MODULE_Y:Number = 265;
		
		/********************************************************************************************************************
				ART CLIPS
		/ ******************************************************************************************************************/
		public var mcPanelModuleManager : PanelModuleManager;

		public var 		mcMainListModule					: DropdownListModuleBase;
		public var      mcCraftingModule					: ItemCraftingModule;
		public var      mcCraftingGlossaryModule			: ItemCraftingModule;
		public var 		mcCraftedItemTooltipModule			: ItemTooltipModule;
		//public var 		moduleMerchantInfo					: ModuleMerchantInfo;
		public var 		merchantInfo						: MovieClip;
		public var 		mcFiltersMode						: CheckboxListMode;
		
		public var 		txtActiveFiltersTitle				: TextField;
		public var 		txtActiveFiltersList				: TextField;
		protected var 	activeFiltersMaxWidth				: Number = -1;
		protected var 	hasIngreLocString					: String;
		protected var 	missingCompLocString				: String;
		protected var 	alreadyCraftedLocString				: String;
		
		public var 		mcAnchor_MODULE_Tooltip				: MovieClip;
		
		private var 	_inputSymbolIDA						: int = -1;
		private var 	_inputSymbolIDX						: int = -1;
		
		protected var   craftingEnabled 					: Boolean = false;
		protected var   lastSelectedItem					: RecipeIconItemRenderer;
		
		protected var   pinnedTag							: uint = 0;

		/********************************************************************************************************************
				INTERNAL PROPERTIES
		/ ******************************************************************************************************************/

		public function CraftingMenu()
		{
			super();
			mcMainListModule.menuName = menuName;
			mcMainListModule.selectModuleOnClick = true;
			mcCraftingGlossaryModule.autoAlignSlots = true;
			merchantInfo = mcCraftedItemTooltipModule.moduleMerchantInfo;
			
			ContextInfoManager.TOOLTIPS_DELAY = 0;
			ContextInfoManager.TOOLTIPS_DELAY_MOUSE = 0;
			ContextInfoManager.getInstanse()._DBG_LOCK_MOUSE_TOOLTIP = true;
		}

		override protected function get menuName():String
		{
			return "CraftingMenu";
		}

		override protected function configUI():void
		{
			super.configUI();
			//trace("DROPDOWN QuestJournalMenu# configUI start");
			addEventListener( GridEvent.ITEM_CHANGE, onGridItemChange, false, 0, true );
			
			_contextMgr.defaultAnchor = mcAnchor_MODULE_Tooltip;
			_contextMgr.addGridEventsTooltipHolder(stage);
			_contextMgr.enableInputFeedbackShowing(true);
			
			if (mcCraftingGlossaryModule)
			{
				mcCraftingGlossaryModule.hideEmptyDataHolders = true;
			}
			
			if (mcFiltersMode)
			{
				mcFiltersMode.closeCB = filterModeClosed;
				mcFiltersMode.disallowCloseOnNoCheck = true;
			}
			
			mcMainListModule.mcDropDownList.addEventListener(ListEvent.INDEX_CHANGE, handleSelectChange, false, 0 , true );
			mcMainListModule.mcDropDownList.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, handleItemDoubleClick, false, 0, true );
			mcMainListModule.filterFunc = filterList;
			
			InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_RSTICK_HOLD, KeyCode.F , "panel_common_filters");
			InputFeedbackManager.updateButtons(this);
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'crafting.sublist.items', [updateIngredientsList] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "crafting.merchant.info", [setMerchantInfo] ) );
			
			stage.invalidate();
			validateNow();
			
			upToCloseEnabled = false;
			
			focused = 1;
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
		}
		
		public function updatePinInputFeedback():void
		{
			if (_inputSymbolIDX != -1)
			{
				InputFeedbackManager.removeButton(this, _inputSymbolIDX);
				_inputSymbolIDX = -1;
			}
			
			if (mcMainListModule.mcDropDownList.dataProvider.length > 0)
			{
				lastSelectedItem = null;
			}
			
			if (lastSelectedItem != null)
			{
				if (lastSelectedItem.data && lastSelectedItem.data.tag == pinnedTag)
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
		
		public function setPinnedRecipe(tag:uint):void
		{
			pinnedTag = tag;
			RecipeIconItemRenderer.setCurrentPinnedTag(stage, tag);
		}

		override public function ShowSecondaryModules( value : Boolean )
		{
			super.ShowSecondaryModules( value );
			
			if (value)
			{
				if (mcCraftedItemTooltipModule)
				{
					mcCraftedItemTooltipModule.active = true;
				}
				
				if (craftingEnabled)
				{
					if (mcCraftingModule)
					{
						mcCraftingModule.active = true;
					}
				}
				else
				{
					if (mcCraftingGlossaryModule)
					{
						mcCraftingGlossaryModule.active = true;
					}
				}
			}
			else
			{
				if (mcCraftingModule)
				{
					mcCraftingModule.active = false;
				}
				
				if (mcCraftingGlossaryModule)
				{
					mcCraftingGlossaryModule.active = false;
				}
				
				if (mcCraftedItemTooltipModule)
				{
					mcCraftedItemTooltipModule.active = false;
				}
				
				if (merchantInfo)
				{
					merchantInfo.setMerchantTypeCheck(false, false);
				}
			}
		}
		
		protected var setFilters:Boolean = false;
		public function SetFiltersValue(hasIngreStr:String, hasIngre:Boolean, missingCompStr:String, missingComp:Boolean, alreadyCraftedStr:String, alreadyCrafted:Boolean):void
		{
			if (mcFiltersMode)
			{
				setFilters = true;
				var defaultData : Array;
				defaultData = [{ key:"HasIngredients", label:hasIngreStr, isChecked:hasIngre },
							   { key:"MissingIngredients", label:missingCompStr, isChecked:missingComp } ];
							
				if (craftingEnabled)
				{
					defaultData.push( { key:"AlreadyCrafted", label:alreadyCraftedStr, isChecked:alreadyCrafted } );
				}
				
				hasIngreLocString = hasIngreStr;
				missingCompLocString = missingCompStr;
				alreadyCraftedLocString = alreadyCraftedStr;
				
				mcFiltersMode.setData(defaultData);
				mcFiltersMode.validateNow();
				
				if (_lastFilteredList != null)
				{
					selectTargetModule(mcMainListModule);
					mcMainListModule.handleListData(_lastFilteredList, -1);
					mcMainListModule.validateNow();
					
					removeEventListener(Event.ENTER_FRAME, validateScrollPosition, false);
					addEventListener(Event.ENTER_FRAME, validateScrollPosition, false, 0, true);
				}
				
				updateFiltersText();
				
				updatePinInputFeedback();
			}
		}
		
		protected var _lastFilteredList:Array;
		protected function filterList(dataArray:Array) : Array
		{
			if (mcFiltersMode)
			{
				_lastFilteredList = dataArray;
				
				if (!setFilters)
				{
					return null;
				}
				
				var filteredList:Array = new Array();
				var showHasIngredients:Boolean = mcFiltersMode.isBoxChecked("HasIngredients");
				var showMissingIngredients:Boolean = mcFiltersMode.isBoxChecked("MissingIngredients");
				var showAlreadyCrafted:Boolean = mcFiltersMode.isBoxChecked("AlreadyCrafted");
				var i:int;
				var curObj:Object;
				
				/*
				public static const ECE_TooLowCraftsmanLevel:int = 1;
				public static const ECE_MissingIngredient:int = 2;
				public static const ECE_TooFewIngredients:int = 3;
				public static const ECE_WrongCraftsmanType:int = 4;
				public static const ECE_NotEnoughMoney:int = 5;
				public static const ECE_UnknownSchematic:int = 6;
				public static const ECE_CookNotAllowed:int = 7;
				*/
				
				for (i = 0; i < dataArray.length; ++i)
				{
					curObj = dataArray[i];
					
					if (curObj.canCookStatus == RecipeIconItemRenderer.ECE_MissingIngredient || curObj.canCookStatus == RecipeIconItemRenderer.ECE_TooFewIngredients)
					{
						if (showMissingIngredients)
						{
							filteredList.push(curObj);
						}
					}
					else if (curObj.canCookStatus == RecipeIconItemRenderer.ECE_CookNotAllowed || curObj.canCookStatus == RecipeIconItemRenderer.ECE_WrongCraftsmanType || curObj.canCookStatus == RecipeIconItemRenderer.ECE_TooLowCraftsmanLevel)
					{
						if (showAlreadyCrafted)
						{
							filteredList.push(curObj);
						}
					}
					else if (showHasIngredients)
					{
						filteredList.push(curObj);
					}
				}
				
				if (filteredList.length == 0)
				{
					ShowSecondaryModules(false);
				}
				else
				{
					ShowSecondaryModules(true);
				}
				
				if (filteredList.length == 0 && _inputSymbolIDX != -1)
				{
					InputFeedbackManager.removeButton(this, _inputSymbolIDX);
					_inputSymbolIDX = -1;
			
					InputFeedbackManager.updateButtons(this);
				}
				
				return filteredList;
			}
			
			return null;
		}
		
		/********************************************************************************************************************
			UPDATES
		/ ******************************************************************************************************************/
		protected function Update() : void
		{

		}

		/********************************************************************************************************************
			PUBLIC FUNCTIONS
		/ ******************************************************************************************************************/
		
		public function hideContent(value:Boolean):void
		{
			if (craftingEnabled)
			{
				mcCraftingModule.active = value;
			}
			else
			{
				mcCraftingGlossaryModule.active = value;
			}
			mcCraftedItemTooltipModule.active = value;
			
			if (merchantInfo && !value)
			{
				merchantInfo.setMerchantTypeCheck(false, false);
			}
		}
		
		public function setCraftingEnabled(value:Boolean):void
		{
			craftingEnabled = value;
			
			if (!craftingEnabled)
			{
				setCraftingEnabledFeedback(false);
				
				if (mcCraftingModule)
				{
					mcCraftingModule.active = false;
				}
				
				if (mcCraftingGlossaryModule)
				{
					mcCraftingGlossaryModule.active = true;
				}
			}
			else
			{
				if (mcCraftingModule)
				{
					mcCraftingModule.active = true;
				}
				
				if (mcCraftingGlossaryModule)
				{
					mcCraftingGlossaryModule.active = false;
				}
				
				if (lastSelectedItem && lastSelectedItem.data.canCookStatus == RecipeIconItemRenderer.NoException)
				{
					setCraftingEnabledFeedback(true);
				}
				else
				{
					setCraftingEnabledFeedback(false);
				}
			}
		}
		
		protected function updateIngredientsList(array:Array):void
		{
			if (mcCraftingModule && mcCraftingModule.enabled)
			{
				mcCraftingModule.setIngredientItemData(array);
			}
			
			if (mcCraftingGlossaryModule && mcCraftingGlossaryModule.enabled)
			{
				mcCraftingGlossaryModule.setIngredientItemData(array);
			}
		}
		
		protected function setMerchantInfo(value:Object):void
		{
			merchantInfo.data = value;
			//merchantInfo.y = FIRST_RIGHT_MODULE_Y;
			//mcCraftedItemTooltipModule.y = SECOND_RIGHT_MODULE_Y;
		}
		
		public function setMerchantTypeCheck(wrongLevel:Boolean, wrongType:Boolean):void
		{
			merchantInfo.setMerchantTypeCheck(wrongLevel, wrongType);
		}
		
		public function setCraftedItem(schematicTag:uint, itemName:String, iconPath:String, canCraft:Boolean, gridSize:int, price:String, rarity:int = 0, sockets:int = 0):void
		{
			if (mcCraftingModule && mcCraftingModule.enabled )
			{
				mcCraftingModule.setCraftedItemInfo(schematicTag, itemName, iconPath, canCraft, gridSize, price, rarity, sockets);
			}
			
			if (mcCraftingGlossaryModule && mcCraftingGlossaryModule.enabled)
			{
				mcCraftingGlossaryModule.setCraftedItemInfo(schematicTag, itemName, iconPath, canCraft, gridSize, price, rarity, sockets);
			}
		}
		
		public function handleSelectChange(event:ListEvent):void
		{
			if (_inputSymbolIDX != -1)
			{
				InputFeedbackManager.removeButton(this, _inputSymbolIDX);
				_inputSymbolIDX = -1;
			}
			
			if (event.itemRenderer is RecipeIconItemRenderer)
			{
				lastSelectedItem = event.itemRenderer as RecipeIconItemRenderer;
				mcCraftingModule.setItemColorQuality( lastSelectedItem.data.rarity );
				mcCraftedItemTooltipModule.setItemColorQuality( lastSelectedItem.data.rarity  );
				
				mcCraftingGlossaryModule.setItemColorQuality( lastSelectedItem.data.rarity );
				mcCraftedItemTooltipModule.setItemColorQuality( lastSelectedItem.data.rarity  );
				
				
				if (lastSelectedItem.data && lastSelectedItem.data.tag == pinnedTag)
				{
					_inputSymbolIDX = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_X, KeyCode.Q, "inputfeedback_unpin_recipe");
				}
				else
				{
					_inputSymbolIDX = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_X, KeyCode.Q, "inputfeedback_pin_recipe");
				}
				
				if (craftingEnabled && event.itemData)
				{
					if (event.itemData.canCookStatus == RecipeIconItemRenderer.NoException)
					{
						setCraftingEnabledFeedback(true);
					}
					else
					{
						setCraftingEnabledFeedback(false);
					}
				}
			}
			else
			{
				lastSelectedItem = null;
			}
			
			InputFeedbackManager.updateButtons(this);
		}
		
		private function handleItemDoubleClick(event:ListEvent):void
		{
			if (event.itemRenderer is RecipeIconItemRenderer)
			{
				mcCraftingModule.startCrafting();
			}
		}
		
		public function setCraftingEnabledFeedback(value:Boolean):void
		{
			if (value)
			{
				if (_inputSymbolIDA == -1)
				{
					_inputSymbolIDA = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, -1 , "panel_alchemy_craft_item");
				}
			}
			else
			{
				if (_inputSymbolIDA != -1)
				{
					InputFeedbackManager.removeButton(this, _inputSymbolIDA);
					_inputSymbolIDA = -1;
				}
			}
			
			InputFeedbackManager.updateButtons(this);
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
						(details.code == KeyCode.F || details.navEquivalent == NavigationCode.GAMEPAD_R3))
				{
					showFilterMode();
				}
				
				if (details.code == KeyCode.Q || details.navEquivalent == NavigationCode.GAMEPAD_X)
				{
					togglePinOnSelectedRecipe();
				}
			}
		}
		
		private function togglePinOnSelectedRecipe():void
		{
			if (lastSelectedItem != null && lastSelectedItem.data)
			{
				var targetTag:uint;
				
				if (_inputSymbolIDX != -1)
				{
					InputFeedbackManager.removeButton(this, _inputSymbolIDX);
					_inputSymbolIDX = -1;
				}
				
				if (pinnedTag == lastSelectedItem.data.tag)
				{
					targetTag = 0;
					_inputSymbolIDX = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_X, KeyCode.Q, "inputfeedback_pin_recipe");
				}
				else
				{
					targetTag = lastSelectedItem.data.tag;
					_inputSymbolIDX = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_X, KeyCode.Q, "inputfeedback_unpin_recipe");
				}
				
				InputFeedbackManager.updateButtons(this);
				
				pinnedTag = targetTag;
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnChangePinnedRecipe', [targetTag] ) );
				RecipeIconItemRenderer.setCurrentPinnedTag(stage, targetTag);
			}
		}
		
		private function showFilterMode():void
		{
			mcFiltersMode.show();
			mcMainListModule.inputEnabled = false;
		}
		
		private function filterModeClosed(valuesChanged:Boolean):void
		{
			mcMainListModule.inputEnabled = true;
			
			if (valuesChanged)
			{
				if (_lastFilteredList != null)
				{
					lastSelectedItem = null;
					selectTargetModule(mcMainListModule);
					mcMainListModule.handleListData(_lastFilteredList, -1);
					mcMainListModule.validateNow();
					
					removeEventListener(Event.ENTER_FRAME, validateScrollPosition, false);
					addEventListener(Event.ENTER_FRAME, validateScrollPosition, false, 0, true);
				}
				
				updatePinInputFeedback();
				
				var showHasIngredients:Boolean = mcFiltersMode.isBoxChecked("HasIngredients");
				var showMissingIngredients:Boolean = mcFiltersMode.isBoxChecked("MissingIngredients");
				var showAlreadyCrafted:Boolean = mcFiltersMode.isBoxChecked("AlreadyCrafted");
				
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCraftingFiltersChanged', [showHasIngredients, showMissingIngredients, showAlreadyCrafted] ) );
				
				updateFiltersText();
			}
		}
		
		private function validateScrollPosition(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, validateScrollPosition, false);
			
			mcMainListModule.mcDropDownList.SetInitialSelection();
			mcMainListModule.mcDropDownList.scrollPosition = 0;
			mcMainListModule.mcDropDownList.validateNow();
		}
		
		private function updateFiltersText():void
		{
			if (activeFiltersMaxWidth == -1)
			{
				activeFiltersMaxWidth = txtActiveFiltersList.width;
				txtActiveFiltersTitle.text = "[[gui_active_filters_title]]";
				txtActiveFiltersList.x = txtActiveFiltersList.x + txtActiveFiltersTitle.textWidth + 10;
				txtActiveFiltersList.width = activeFiltersMaxWidth - txtActiveFiltersTitle.textWidth - 10;
			}
			
			var showHasIngredients:Boolean = mcFiltersMode.isBoxChecked("HasIngredients");
			var showMissingIngredients:Boolean = mcFiltersMode.isBoxChecked("MissingIngredients");
			var showAlreadyCrafted:Boolean = mcFiltersMode.isBoxChecked("AlreadyCrafted");
			var finalString:String;
				
			finalString = "";
			if (showHasIngredients)
			{
				finalString = hasIngreLocString;
			}
			
			if (showMissingIngredients)
			{
				if (finalString != "")
				{
					finalString += ", ";
				}
				
				finalString += missingCompLocString;
			}
			
			if (showAlreadyCrafted && craftingEnabled)
			{
				if (finalString != "")
				{
					finalString += ", ";
				}
				
				finalString += alreadyCraftedLocString;
			}
			
			txtActiveFiltersList.text = finalString;
			txtActiveFiltersList.height = txtActiveFiltersList.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			txtActiveFiltersList.y = txtActiveFiltersTitle.y + txtActiveFiltersTitle.height - txtActiveFiltersList.height;
			if (finalString == "")
			{
				txtActiveFiltersTitle.text = "";
			}
			else
			{
				txtActiveFiltersTitle.text = "[[gui_active_filters_title]]";
			}
		}
		
		override protected function onLastMoveStatusChanged()
		{
			if (mcFiltersMode)
			{
				mcFiltersMode.lastMoveWasMouse = _lastMoveWasMouse;
			}
		}

		/********************************************************************************************************************
			PRIVATE FUNCTIONS
		/ ******************************************************************************************************************/
		
		private function cleanup():void
		{
			updateIngredientsList([]);
		}
		
		protected function onGridItemChange( event:GridEvent ) : void
		{
			var itemDataStub:ItemDataStub = event.itemData as ItemDataStub;
			var displayEvent:GridEvent;
			if (itemDataStub)
			{
				if (itemDataStub.id)
				{
					displayEvent = new GridEvent( GridEvent.DISPLAY_TOOLTIP, true, false, 0, -1, -1, null, itemDataStub );
				}
				else
				{
					displayEvent = new GridEvent( GridEvent.HIDE_TOOLTIP, true, false, 0, -1, -1, null, itemDataStub );
				}
			}
			else
			{
				displayEvent = new GridEvent( GridEvent.HIDE_TOOLTIP, true, false, 0, -1, -1, null, itemDataStub );
			}
			dispatchEvent(displayEvent);
		}
	}
}
