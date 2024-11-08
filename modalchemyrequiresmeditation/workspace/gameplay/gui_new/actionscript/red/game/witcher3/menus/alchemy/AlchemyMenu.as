/***********************************************************************
/** PANEL Alchemy  main class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/
package red.game.witcher3.menus.alchemy
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.managers.ContextInfoManager;
	import red.game.witcher3.menus.common.CheckboxListMode;
	import red.game.witcher3.controls.W3DropDownItemRenderer;
	import red.game.witcher3.controls.W3DropdownMenuListItem;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.menus.common.RecipeIconItemRenderer;
	import red.game.witcher3.menus.crafting.ItemCraftingModule;
	import scaleform.clik.constants.InputValue;
	import red.game.witcher3.modules.ItemTooltipModule;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.events.ListEvent;

	import red.core.CoreMenu;
	import scaleform.gfx.Extensions;

	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	
	import red.game.witcher3.menus.common.IconItemRenderer;

	import red.game.witcher3.events.GridEvent;

	import red.game.witcher3.managers.PanelModuleManager;
	import red.game.witcher3.menus.common.PlayerDetails;
	import red.game.witcher3.menus.common.PlayerStatsModule;
	import red.game.witcher3.menus.common.TextAreaModule;

	import red.game.witcher3.menus.common.ItemDataStub;
	import flash.external.ExternalInterface;

	import red.game.witcher3.menus.common.DropdownListModuleBase;

	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.easing.Quadratic;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;

	import red.game.witcher3.controls.W3Label;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;

	public class AlchemyMenu extends CoreMenu
	{
		
		/********************************************************************************************************************
				ART CLIPS
		/ ******************************************************************************************************************/
		public var mcPanelModuleManager : PanelModuleManager;

		public var 		mcMainListModule					: DropdownListModuleBase;
		public var 		mcCraftingModule					: ItemCraftingModule;
		public var 		mcCraftingGlossaryModule			: ItemCraftingModule;
		public var 		mcCraftedItemTooltipModule			: ItemTooltipModule;
		public var 		mcFiltersMode						: CheckboxListMode;
		
		public var 		txtActiveFiltersTitle				: TextField;
		public var 		txtActiveFiltersList				: TextField;
		protected var 	activeFiltersMaxWidth				: Number = -1;
		protected var 	hasIngreLocString					: String;
		protected var 	missingCompLocString				: String;
		protected var 	alreadyCraftedLocString				: String;

		public var 		mcAnchor_MODULE_Tooltip				: MovieClip;
		public var 		mcAnchor_SelectedRecipe_Tooltip		: MovieClip;
		
		private var 	_inputSymbolIDA						: int = -1;
		private var 	_inputSymbolIDX						: int = -1;
		
		protected var   craftingEnabled 					: Boolean = false;
		protected var   lastSelectedItem					: RecipeIconItemRenderer;
		
		protected var   pinnedTag							: uint = 0;

		/********************************************************************************************************************
				INTERNAL PROPERTIES
		/ ******************************************************************************************************************/

		private	var	m_bUsingGamepad	: Boolean = true;

		public function AlchemyMenu()
		{
			super();
			mcMainListModule.menuName = menuName;
			mcMainListModule.selectModuleOnClick = true;
			ContextInfoManager.TOOLTIPS_DELAY = 0;
			ContextInfoManager.TOOLTIPS_DELAY_MOUSE = 0;
		}

		override protected function get menuName():String
		{
			return "AlchemyMenu";
		}

		override protected function configUI():void
		{
			super.configUI();
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
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'crafting.sublist.items', [updateIngredientsList] ) );
			
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
		}

		override public function ShowSecondaryModules( value : Boolean )
		{
			super.ShowSecondaryModules( value );
			
			if (value)
			{
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
							   { key:"MissingIngredients", label:missingCompStr, isChecked:missingComp },
							   { key:"AlreadyCrafted", label:alreadyCraftedStr, isChecked:alreadyCrafted } ];
				
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
				public static const MissingIngredient:int = 1;
				public static const NotEnoughIngredients:int = 2;
				public static const NoRecipe:int = 3;
				public static const CannotCookMore:int = 4;
				public static const CookNotAllowed:int = 5;
				*/
				
				for (i = 0; i < dataArray.length; ++i)
				{
					curObj = dataArray[i];
					
					if (curObj.canCookStatusForFilter == RecipeIconItemRenderer.ECE_MissingIngredient || curObj.canCookStatusForFilter == RecipeIconItemRenderer.ECE_TooFewIngredients)
					{
						if (showMissingIngredients)
						{
							filteredList.push(curObj);
						}
					}
					else if (/*curObj.canCookStatus == RecipeIconItemRenderer.ECE_CookNotAllowed ||*/ curObj.canCookStatusForFilter == RecipeIconItemRenderer.CannotCookMore)
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
		
		public function setCraftedItem(schematicTag:uint, itemName:String, iconPath:String, canCraft:Boolean, gridSize:int, price:String):void
		{
			if (mcCraftingModule && mcCraftingModule.enabled )
			{
				mcCraftingModule.setCraftedItemInfo(schematicTag, itemName, iconPath, canCraft, gridSize, price);
				
			}
			
			if (mcCraftingGlossaryModule && mcCraftingGlossaryModule.enabled)
			{
				mcCraftingGlossaryModule.setCraftedItemInfo(schematicTag, itemName, iconPath, canCraft, gridSize, price);
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
			
			if (showAlreadyCrafted)
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

		/********************************************************************************************************************
			Move to common
		/ ******************************************************************************************************************/
		public function IsUsingGamepad() : Boolean
		{
			m_bUsingGamepad =  ExternalInterface.call( "isUsingPad" );
			return m_bUsingGamepad;
		}
	}
}
