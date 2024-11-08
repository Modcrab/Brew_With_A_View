package red.game.witcher3.menus.inventory_menu
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import red.core.constants.KeyCode;
	import red.core.CoreMenu;
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.managers.ContextInfoManager;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.menus.character_menu.CharacterModeBackground;
	import red.game.witcher3.menus.common.CheckboxListMode;
	import red.game.witcher3.menus.common.ModuleMerchantInfo;
	import red.game.witcher3.menus.common.PlayerStatsModule;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotInventoryGrid;
	import red.game.witcher3.slots.SlotPaperdoll;
	import red.game.witcher3.slots.SlotSkillGrid;
	import red.game.witcher3.slots.SlotsListGrid;
	import red.game.witcher3.slots.SlotsTransferManager;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import flash.utils.getDefinitionByName;
	
	/**
	 * This is the new inventory screen document class
	 * @author Yaroslav Getsevich
	 */
	public class MenuInventory extends CoreMenu
	{
		public static const STATE_CHARACTER:String = "CharacterInventory";
		public static const STATE_HORSE:String = "HorseInventory";
		
		public static const IMS_Player			:int = 0;
		public static const IMS_Shop			:int = 1;
		public static const IMS_Container		:int = 2;
		public static const IMS_HorseInventory	:int = 3;
		public static const IMS_Stash 			:int = 4;
		
		public static const INV_SORT_MODE_INVALID		: int = -1;
		public static const INV_SORT_MODE_TYPE  		: int = 0;
		public static const INV_SORT_MODE_PRICE			: int = 1;
		public static const INV_SORT_MODE_WEIGHT 		: int = 2;
		public static const INV_SORT_MODE_DURABILTIY	: int = 3;
		public static const INV_SORT_MODE_RARITY		: int = 4;
		
		protected static const HORSE_GRID_X			:Number = 1293;
		protected static const CONTAINER_GRID_X		:Number = 758;
		
		private var mcContainerGridModule	: ModuleContainer;
		public var mcPlayerInventory		: InventoryTabbedListModule;
		private var mcPaperDollModule		: ModulePaperdoll;
		public var mcHorsePaperdollModule	: ModuleHorsePaperdoll;
		public var mcPlayerStatistics		: PlayerStatsModule;
		public var mcSortingMode 			: CheckboxListMode;
		public var pinnedCraftingModule		: PinnedCraftingInfoModule;
		public var currentSortingMode		: int;
		
		public var mcSelectionMode			: CharacterModeBackground;
		public var moduleMerchantInfo		: ModuleMerchantInfo;
		
		public var containerGrid			: Sprite;
		public var mcOverburdened			: MovieClip;
		public var tooltipLeftAnchor		: DisplayObject;
		public var tooltipRightAnchor		: DisplayObject;
		public var mcShopPaperdollAnchor	: DisplayObject;
		
		public var mcHorseModelAnchor		: MovieClip;
		public var mcCharacterModelAnchor	: MovieClip;
		public var mcCharacterRenderer		: MovieClip;
		public var mcShopBackground			: MovieClip;
		public var mcStashBackground 		: MovieClip;
		
		public var mcContainerAnchor		: MovieClip;
		public var mcPaperdollAnchor		: MovieClip;
		
		public var btnSort					: InputFeedbackButton;
		public var btnSortChange			: InputFeedbackButton;
		public var dropSlot					: InventoryDropArea;
		
		public var mcSelectionModeBackground : MovieClip;
		
		public var tooltipPaperdollAnchor   : MovieClip;
		
		protected var _filteringMode		: Boolean;
		
		private var _btn_stats_id   	    : int = -1;
		private var _btn_sort_id     		: int = -1;
		private var _btn_switch_sections    : int = -1;
		
		private var _defaultTabIdx			: int   = -1;
		
		// ----  STATS PROTOTYPE
		
		public var mcVitalityStat 			: PlayerStatInfo;
		public var mcToxicityStat 			: PlayerStatInfo;
		
		public var mcPanelDetailedStats 	: PlayerDetailedStatsPanel;
		public var mcPanelGeneralStats 	    : PlayerGeneralStatsPanel;
		
		private var _rendererController     : CharacterRendererController;
		
		public var playerGridInitX			: Number;
		public var playerGridXOffset		: Number = 155;
		
		// -- TICK --
		private const TICK_DELAY:int = 100;
		private var _timer : Timer;
		
		public function MenuInventory()
		{
			SlotBase.AUTO_SHOW_COLLAPSED_ICON = true;
			SlotBase.OPT_MODE = false;
			
			super();
			
			playerGridInitX = mcPlayerInventory.x;
			
			_rendererController = new CharacterRendererController(mcCharacterRenderer, this);
			_rendererController.setCenterAnchor(450, 50);
			_rendererController.setDefaultAnchor(mcCharacterModelAnchor.x, 50);
			_rendererController.addFadeOutComponent(mcPlayerInventory);
			_rendererController.addFadeOutComponent(mcVitalityStat);
			_rendererController.addFadeOutComponent(mcToxicityStat);
			_rendererController.addFadeOutComponent(btnSort);
			_rendererController.addFadeOutComponent(btnSortChange);
			_rendererController.leftInfoPanel = mcPanelGeneralStats;
			_rendererController.rightInfoPanel = mcPanelDetailedStats;
			
			mcVitalityStat.label = "[[vitality]]";
			mcVitalityStat.isPositive = true;
			mcVitalityStat.type = PlayerStatInfo.TYPE_VITALITY;
			mcVitalityStat.visible = false;
			mcVitalityStat.dangerLimit = .3;
			
			mcToxicityStat.label = "[[attribute_name_toxicity]]";
			mcToxicityStat.isPositive = false;
			mcToxicityStat.type = PlayerStatInfo.TYPE_TOXICITY;
			mcToxicityStat.visible = false;
			mcToxicityStat.dangerLimit = .7;
			mcToxicityStat.isPercentage = true;
			
			mcCharacterRenderer.addEventListener(Event.ACTIVATE, handleCharStatsShown, false, 0, true);
			mcCharacterRenderer.addEventListener(Event.DEACTIVATE, handleCharStatHidden, false, 0, true);
			
			mcPlayerInventory.tabsAutoAlign = true;
			mcPlayerInventory.gridMaskOffset = 0;
			mcPlayerInventory.noDelay = false;
			
			dropSlot.disabled = true;
			
			mcCharacterRenderer.mouseChildren = mcCharacterRenderer.mouseEnabled = false;
			mcSelectionModeBackground.mouseChildren = mcSelectionModeBackground.mouseEnabled = false;
			
			mcSelectionMode.mcBackground = mcSelectionModeBackground;
			mcSelectionModeBackground.alpha = 0;
		}
		
		override public function setCurrentModule(value:int):void
		{
			super.setCurrentModule(value);
			
			if (value == 0)
			{
				// hack to reselect item
				mcPlayerInventory.focused = 1;
				mcPlayerInventory.mcPlayerGrid.scrollPosition = 0;
				mcPlayerInventory.mcPlayerGrid.selectedIndex = -1;
				mcPlayerInventory.mcPlayerGrid.validateNow();
			}
		}
		
		private function handleCharStatsShown(event:Event):void
		{
			if (_contextMgr)
			{
				_contextMgr.enableInputFeedbackShowing(false, true);
				_contextMgr.blockTooltips(true);
				_contextMgr.blockModeSwitching = true;
			}
			
			dropSlot.disabled = true;
			
			if (_btn_sort_id != -1)
			{
				InputFeedbackManager.removeButton(this, _btn_sort_id);
				_btn_sort_id = -1;
			}
			if (_btn_switch_sections != -1)
			{
				InputFeedbackManager.removeButton(this, _btn_switch_sections);
				_btn_switch_sections = -1;
			}
			
			mcPlayerInventory.enabled = false;
			mcPlayerInventory.refreshButtons();
		}
		
		private function handleCharStatHidden(event:Event):void
		{
			if (_contextMgr)
			{
				_contextMgr.enableInputFeedbackShowing(true, true);
				_contextMgr.blockTooltips(false);
				_contextMgr.blockModeSwitching = false;
			}
			
			dropSlot.disabled = false;
			
			if (_btn_sort_id == -1)
			{
				_btn_sort_id = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_RSTICK_HOLD, -1 , "panel_button_common_sort_items");
			}
			if (_btn_switch_sections == -1)
			{
				_btn_switch_sections = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_R3, -1 , "panel_button_common_jump_sections");
			}
			
			mcPlayerInventory.enabled = true;
			mcPlayerInventory.refreshButtons();
		}
		
		override protected function get menuName():String { return "InventoryMenu"	}
		override protected function configUI():void
		{
			super.configUI();
			
			// #Y GRID SECTIONS PROTO
			// Defining structure
			// Syntax: ItemSectionData(<index 0...N>, <start column 0..N>, <end column 0..N>, <localization key for title>, <inventory tab idx>)
			
			/*
				public static const TabIndex_Weapons 		: int = 0;
				public static const TabIndex_Potions 		: int = 1;
				public static const TabIndex_Ingredients	: int = 2;
				public static const TabIndex_QuestItems		: int = 3;
				public static const TabIndex_Default 		: int = 4;
				public static const TabIndex_Books			: int = 5;
			*/
			
			var gridSectionsList:Array = [];
			
			var sectionsData:GridTabSections = new GridTabSections();
			
			sectionsData.push(4, new ItemSectionData(0, 0, 3, "[[panel_inventory_tab_weapons]]"));
			sectionsData.push(4, new ItemSectionData(1, 4, 8, "[[panel_inventory_tab_armors]]"));
			
			sectionsData.push(3, new ItemSectionData(0, 0, 2, "[[panel_alchemy_tab_oils]]"));
			sectionsData.push(3, new ItemSectionData(1, 3, 5, "[[panel_alchemy_tab_potions]]"));
			sectionsData.push(3, new ItemSectionData(2, 6, 8, "[[panel_alchemy_tab_bombs]]"));

			sectionsData.push(2, new ItemSectionData(0, 0, 5, "[[item_category_edibles]]"));
			sectionsData.push(2, new ItemSectionData(1, 6, 8, "[[panel_inventory_tab_horse]]"));
			
			sectionsData.push(1, new ItemSectionData(0, 0, 3, "[[item_category_quest_items]]"));
			sectionsData.push(1, new ItemSectionData(1, 4, 8, "[[item_category_misc]]"));
			
			sectionsData.push(0, new ItemSectionData(0, 0, 4, "[[panel_inventory_tab_crafting]]"));
			sectionsData.push(0, new ItemSectionData(1, 5, 8, "[[panel_inventory_tab_alchemy]]"));
			
			mcPlayerInventory.setItemSections(sectionsData);
			
			//-----------
			
			initDataBindings();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			initTooltips();
			
			mcSelectionMode.visible = false;
			mcSelectionMode.addEventListener(CharacterModeBackground.ACCEPT, handleSelectionModeAcceptClick, false, 0, true);
			mcSelectionMode.addEventListener(CharacterModeBackground.CANCEL, handleSelectionModeCancelClick, false, 0, true);
			
			if (mcSortingMode)
			{
				mcSortingMode.hideCB = sortingModeClosed;
				mcSortingMode.closeCB = sortingModeApply;
				mcSortingMode.mcTitle.text = "[[gui_panel_sort_by]]";
				mcSortingMode.disallowCloseOnNoCheck = true;
				mcSortingMode.allowUnchecking = false;
				mcSortingMode.exclusiveCheckList = true;
				mcSortingMode.extraCloseMode = true;
			}
			
			btnSort.label = "[[panel_button_common_quick_sort_items]]";
			btnSort.setDataFromStage("", KeyCode.Q);
			btnSort.addEventListener(ButtonEvent.CLICK, handleSortClick, false, 0, true);
			btnSort.clickable = true;
			btnSort.validateNow();
			
			btnSortChange.label = "[[panel_button_common_sort_items]]";
			btnSortChange.setDataFromStage("", KeyCode.F);
			btnSortChange.addEventListener(ButtonEvent.CLICK, showSortingModeChange, false, 0, true);
			btnSortChange.clickable = true;
			btnSortChange.x = btnSort.x + btnSort.actualWidth;
			
			_btn_sort_id = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_RSTICK_HOLD, -1 , "panel_button_common_sort_items");
			_timer = new Timer( TICK_DELAY );
			_timer.addEventListener(TimerEvent.TIMER, handleTickEvent, false, 0, true);
			_timer.start();
			
			tickTimeDelta = getTimer();
			if (_btn_switch_sections == -1 )
			{
				_btn_switch_sections = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_R3, -1 , "panel_button_common_jump_sections");
			}
		}
		
		private var tickTimeDelta:int = 0;
		private function handleTickEvent( event : TimerEvent ):void
		{
			var res : int = getTimer();
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnTickEvent', [ int(res - tickTimeDelta)] ));
			tickTimeDelta = res;
		}
		
		public function setPaperdollPreviewIcon( slotType : int, show : Boolean) : void
		{
			if ( !mcPaperDollModule )
			{
				return;
			}
			
			var targetSlot : SlotPaperdoll = mcPaperDollModule.mcPaperdoll.getRendererForSlotType( slotType ) as SlotPaperdoll;
			
			if ( targetSlot && targetSlot.mcPreviewIcon )
			{
				targetSlot.mcPreviewIcon.visible = show;
			}
		}
		
		override public function setMenuState(value:String):void
		{
			super.setMenuState(value);
			//mcPlayerGridModule.currentState = value;
		}
		
		public function setSortingMode(value:int, firstSortString:String, secondSortString:String, thirdSortString:String, forthSortString:String, fifthSortString:String):void
		{
			var defaultData : Array;
			
			currentSortingMode = value;
			
			defaultData = [{ key:"TypeSort", label:firstSortString, isChecked:(value == INV_SORT_MODE_TYPE) },
						   { key:"PriceSort", label:secondSortString, isChecked:(value == INV_SORT_MODE_PRICE) },
						   { key:"WeightSort", label:thirdSortString, isChecked:(value == INV_SORT_MODE_WEIGHT) },
						   { key:"DurabilitySort", label:forthSortString, isChecked:(value == INV_SORT_MODE_DURABILTIY) },
						   { key:"RaritySort", label:fifthSortString, isChecked:(value == INV_SORT_MODE_RARITY) } ];
			
			mcPlayerInventory.mcPlayerGrid.setCurrentSort(currentSortingMode);
			
			mcSortingMode.setData(defaultData);
			mcSortingMode.validateNow();
		}
		
		protected function initTooltips():void
		{
			_contextMgr.addGridEventsTooltipHolder(stage, false);
			_contextMgr.defaultAnchor = tooltipLeftAnchor;
			_contextMgr.overridedMouseDataSource = "OnGetItemDataForMouse";
			_contextMgr.enableInputFeedbackShowing(true);
			_contextMgr.saveScaleValue = true;
			
			// gamepad only
			//_contextMgr.addTooltipTrigger("context.tooltip.data", "context.tooltip.hide", "ItemTooltipRef", tooltipLeftAnchor);
			//_contextMgr.addTooltipTrigger("statistic.tooltip.data", "statistic.tooltip.hide", "PlayerStatisticsTooltipRef", tooltipRightAnchor);
		}
		
		protected function initDataBindings():void
		{
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "inventory.item.active", [setActiveItem] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "inventory.capacity.overburdened.text", [setIsOverburdenedText] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "inventory.capacity.overburdened.value", [setIsOverburdened]) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "inventory.selection.mode.show", [showSelectionMode]) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "inventory.merchant.info", [setMerchantInfo] ) );
		}
		
		private function handleSortClick(event:ButtonEvent = null):void
		{
			mcPlayerInventory.mcPlayerGrid.ignoreNextGridPosition = true;
			mcPlayerInventory.mcPlayerGrid.scrollPosition = 0;
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSortingRequested' ) );
		}
		
		public function setNewFlagsForTabs(tab1 : Boolean, tab2 : Boolean, tab3 : Boolean, tab4 : Boolean, tab5 : Boolean, tab6 : Boolean):void
		{
			var flagArray:Array = new Array(tab1, tab2, tab3, tab4, tab5, tab6);
			
			
			mcPlayerInventory.setNewFlagsForTabs(flagArray);
		}
		
		override protected function onLastMoveStatusChanged()
		{
			if (mcSortingMode)
			{
				mcSortingMode.lastMoveWasMouse = _lastMoveWasMouse;
			}
		}

		/*
		 * Witcher Script's API
		 */
		
		public function setPreviewMode(value:Boolean):void
		{
			if ( mcPaperDollModule )
			{
				mcPaperDollModule.previewMode = value;
			}
		}
		
		public function setVitality(value:Number, minValue:Number, maxValue:Number):void
		{
			mcVitalityStat.setData(value, minValue, maxValue);
		}
		
		public function setToxicity(value:Number, minValue:Number, maxValue:Number):void
		{
			mcToxicityStat.setData(value, minValue, maxValue);
		}
		
		// Turn of filtering from inventory grid; hide paperdoll
	    public function setFilteringMode( value : Boolean ):void
	    {
			trace("GFX setFilteringMode ", value);
			_filteringMode = value;
			if (_filteringMode)
			{
				//mcPlayerGridModule.disableFilters(true);
				if ( mcPaperDollModule )
				{
					mcPaperDollModule.visible = false;
					mcPaperDollModule.enabled = false;
				}
			}
			else
			{
				if ( mcPaperDollModule && mcPaperDollModule.active)
				{
					//mcPlayerGridModule.disableFilters(false);
					mcPaperDollModule.visible = true;
					mcPaperDollModule.enabled = true;
				}
			}
   	    }
		
		public function paperdollRemoveItem( itemId : uint ):void
		{
			if ( mcPaperDollModule )
			{
				mcPaperDollModule.paperdollRemoveItem(itemId);
			}
		}

		public function handlePaperdollUpdateItem( itemData : Object ):void
		{
			if ( mcPaperDollModule )
			{
				mcPaperDollModule.handlePaperdollUpdateItem(itemData);
			}
		}

		public function forceSelectTab( tabIndex : int ):void
		{
			mcPlayerInventory.onSetTabCalled(tabIndex);
		}

		public function forceSelectItem( itemPosition : int ) :void
		{
			mcPlayerInventory.forceSelectItem(itemPosition);
		}

		public function forceSelectPaperdollSlot( slotType : int ):void
		{
			if ( mcPaperDollModule )
			{
				mcPaperDollModule.forceSelectPaperdollSlot(slotType);
			}
		}

		public function inventoryRemoveItem( itemId:int, keepSelectionIdx : Boolean = false):void
		{
			mcPlayerInventory.inventoryRemoveItem(itemId, keepSelectionIdx);
		}
		
		public function shopRemoveItem( itemID:int ):void
		{
			if ( mcContainerGridModule )
			{
				mcContainerGridModule.handleItemRemoved(itemID);
			}
		}

		public function CloseMenu() : void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseMenu' ) );
		}
		
		private function showSortingModeChange(event:ButtonEvent = null):void
		{
			mcSortingMode.show();
			
			mcPlayerInventory.enabled = false;
			mcPlayerInventory._inputEnabled = false;
			if ( mcPaperDollModule )
			{
				mcPaperDollModule.enabled = false;
			}
			
			_contextMgr.blockTooltips(true);
			_contextMgr.blockModeSwitching = true;
			
			currentModuleIdx = 0;
			
			mcPlayerInventory.refreshButtons();
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSortingIndexChoosingStart' ) );
		}
		
		private function sortingModeClosed():void
		{
			mcPlayerInventory.enabled = true;
			mcPlayerInventory._inputEnabled = true;
			if ( mcPaperDollModule )
			{
				mcPaperDollModule.enabled = true;
			}
			
			_contextMgr.blockTooltips(false);
			_contextMgr.blockModeSwitching = false;
			
			currentModuleIdx = 0;
			
			mcPlayerInventory.refreshButtons();
		}
		
		private function sortingModeApply(valuesChanged:Boolean):void
		{
			var newSortIndex:int = 0;
				
			if (mcSortingMode.isBoxChecked("TypeSort"))
			{
				newSortIndex = 0;
			}
			else if (mcSortingMode.isBoxChecked("PriceSort"))
			{
				newSortIndex = 1;
			}
			else if (mcSortingMode.isBoxChecked("WeightSort"))
			{
				newSortIndex = 2;
			}
			else if (mcSortingMode.isBoxChecked("DurabilitySort"))
			{
				newSortIndex = 3;
			}
			else if (mcSortingMode.isBoxChecked("RaritySort"))
			{
				newSortIndex = 4;
			}
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSortingIndexChosen', [newSortIndex] ) );
			
			mcPlayerInventory.mcPlayerGrid.ignoreNextGridPosition = true;
			mcPlayerInventory.mcPlayerGrid.scrollPosition = 0;
			mcPlayerInventory.mcPlayerGrid.setCurrentSort(newSortIndex);
			mcPlayerInventory.mcPlayerGrid.selectedIndex = -1;
			mcPlayerInventory.mcPlayerGrid.validateNow();
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSortingRequested' ) );
			
			//ContextInfoManager.getInstanse().setHiddenState( false );
			//ContextInfoManager.getInstanse().blockModeSwitching = false;
		}
		
		public function /*Witcher Script*/  setDefaultTab( value : int ) : void
		{
			trace("GFX [WitcherScript] setDefaultTab", value);
			_defaultTabIdx = value;
		}
		
		private function createPaperdollModule( active : Boolean ):Boolean
		{
			if ( !mcPaperDollModule )
			{
				var containerGridClass : Class = getDefinitionByName("PaperdollRef") as Class;
				
				mcPaperDollModule = new containerGridClass() as ModulePaperdoll;
				
				if ( !mcPaperDollModule )
				{
					return false;
				}
				
				addChild( mcPaperDollModule );
				swapChildren( mcPaperdollAnchor, mcPaperDollModule );
				mcPaperDollModule.validateNow();
			}
			
			mcPaperDollModule.active = active;
			
			_rendererController.addFadeOutComponent( mcPaperDollModule );
			mcPaperDollModule.addEventListener(CharacterModeBackground.ACCEPT, handleSelectionModeAcceptClick, false, 0, true);

			mcPaperDollModule.x = 856;
			mcPaperDollModule.y = 107;

			initModuleDynamically( mcPaperDollModule );

			return true;
		}

		private function createContainerGridModule( value : int ):Boolean
		{
			if ( !mcContainerGridModule )
			{
				var containerGridClass : Class = getDefinitionByName("ContainerGrid") as Class;
				
				mcContainerGridModule = new containerGridClass() as ModuleContainer;
				mcContainerGridModule.mcPlayerGrid.ignoreValidationOpt = true;
				addChild( mcContainerGridModule );
				mcContainerGridModule.validateNow();
				swapChildren(mcContainerAnchor, mcContainerGridModule);
			}
			
			mcContainerGridModule.active = true;
			
			mcContainerGridModule.x = 1046;
			mcContainerGridModule.y = 217;
			mcContainerGridModule.dropMode = value;
			mcContainerGridModule.dropEnabled = true;

			initModuleDynamically( mcContainerGridModule );

			return true;
		}
		
		public function /*Witcher Script*/  setInventoryMode( value : int ) : void
		{
			trace("GFX --------------------------------------");
			trace("GFX [WitcherScript] setInventoryMode", value);
			
			mcPlayerInventory.mcPlayerGrid.dropMode = value;

			///////////////
			//
			//mcContainerGridModule.dropMode = value;
			//mcContainerGridModule.dropEnabled = true;
			//
			///////////////
			
			if (_btn_stats_id != -1)
			{
				InputFeedbackManager.removeButton(this, _btn_stats_id);
				_btn_stats_id = -1;
			}
			
			
			switch(value)
			{
				case IMS_Player:
					
					if (_btn_stats_id == -1)
					{
						_btn_stats_id = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_R2, KeyCode.C, "panel_common_show_advanced_statistics");
					}
					
					mcSortingMode.x = 0;
					btnSort.x = 314.75;
					btnSortChange.x = 500.65;
					mcPlayerInventory.x = playerGridInitX;
					mcShopBackground.visible = false;
					mcStashBackground.visible = false;
					//mcContainerGridModule.active = false;
					//mcPlayerStatistics.active = true;
					//mcPlayerStatistics.visible = true;
					
					createPaperdollModule( !_filteringMode );
					//mcPaperDollModule.active = true && !_filteringMode;
					//mcHorsePaperdollModule.active = false;
					mcCharacterRenderer.x = mcCharacterModelAnchor.x;
					mcCharacterRenderer.y = mcCharacterModelAnchor.y;
					_rendererController.enabled = true;
					registerRenderTarget( "test_nopack", 1024, 1024 );
					dropSlot.disabled = false;
					mcVitalityStat.visible = true;
					mcToxicityStat.visible = true;
					
					
					mcPlayerInventory.setTabData(new DataProvider( [
																	{ icon:"INGREDIENTS", locKey:"[[panel_inventory_filter_type_ingredients]]" },
																	{ icon:"QUEST_ITEMS", locKey:"[[panel_inventory_filter_type_quest_items]]" },
																	{ icon:"DEFAULT", locKey:"[[panel_inventory_filter_type_default]]" },
																	{ icon:"POTIONS", locKey:"[[panel_inventory_filter_type_alchemy_items]]" },
																	{ icon:"WEAPONS", locKey:"[[item_category_equipement]]" }
																	] ));
																	
																	 //{ icon:"BOOKS", locKey:"[[panel_inventory_grid_tab_books]]" } * / ] ));
																	
					mcPlayerInventory.onSetTabCalled(4);
					
					break;
				
				case IMS_Stash:
					
					mcSortingMode.x = 170;
					mcPlayerInventory.x = playerGridInitX + playerGridXOffset;
					
					if ((mcPlayerInventory.mcSlotList as SlotsListGrid))
					{
						(mcPlayerInventory.mcSlotList as SlotsListGrid).updateRendererBounds();
					}
					
					
					btnSort.x = 422;
					btnSortChange.x = 608;
					
					mcShopBackground.visible = false;
					mcStashBackground.visible = true;
					
					createContainerGridModule( value );
					mcContainerGridModule.mcPlayerGrid.ignoreGridPosition = true;
					//mcContainerGridModule.mcPlayerGrid.slotRendererName = "StashSlotRef";
					//mcContainerGridModule.mcPlayerGrid.invalidateData();
					
					//mcContainerGridModule.x = CONTAINER_GRID_X;
					
					//mcPaperDollModule.active = false;
					mcCharacterRenderer.visible = false;
					_rendererController.enabled = false;
					dropSlot.disabled = true;
					mcVitalityStat.visible = false;
					mcToxicityStat.visible = false;
					
					mcPlayerInventory.setTabData(new DataProvider( [
												{ icon:"INGREDIENTS", locKey:"[[panel_inventory_filter_type_ingredients]]" },
												{ icon:"QUEST_ITEMS", locKey:"[[panel_inventory_filter_type_quest_items]]" },
												{ icon:"DEFAULT", locKey:"[[panel_inventory_filter_type_default]]" },
												{ icon:"POTIONS", locKey:"[[panel_inventory_filter_type_alchemy_items]]" },
												{ icon:"WEAPONS", locKey:"[[item_category_equipement]]" }
												] ));
					/*
					mcPlayerInventory.setTabData(new DataProvider( [ { icon:"WEAPONS", locKey:"[[item_category_equipement]]" },
																	 { icon:"DEFAULT", locKey:"[[panel_inventory_filter_type_default]]" } ] ));
					*/
																	
					if ( _defaultTabIdx != -1 )
					{
						mcPlayerInventory.onSetTabCalled( _defaultTabIdx );
					}
					
					break;
					
				case IMS_Shop:
				case IMS_Container:
					
					mcSortingMode.x = 170;
					mcPlayerInventory.x = playerGridInitX + playerGridXOffset;
					
					if ((mcPlayerInventory.mcSlotList as SlotsListGrid))
					{
						(mcPlayerInventory.mcSlotList as SlotsListGrid).updateRendererBounds();
					}
					
					btnSort.x = 422;
					btnSortChange.x = 608;
					mcShopBackground.visible = true;
					mcStashBackground.visible = false;
					
					createContainerGridModule( value );
					mcContainerGridModule.mcPlayerGrid.ignoreGridPosition = true;
					
					//mcContainerGridModule.x = CONTAINER_GRID_X;
					//mcPlayerStatistics.visible = false;
					//mcHorsePaperdollModule.active = false;
					
					//mcPaperDollModule.active = false;
					mcCharacterRenderer.visible = false;
					_rendererController.enabled = false;
					dropSlot.disabled = true;
					mcVitalityStat.visible = false;
					mcToxicityStat.visible = false;

					mcPlayerInventory.setTabData(new DataProvider( [
												{ icon:"INGREDIENTS", locKey:"[[panel_inventory_filter_type_ingredients]]" },
												{ icon:"QUEST_ITEMS", locKey:"[[panel_inventory_filter_type_quest_items]]" },
												{ icon:"DEFAULT", locKey:"[[panel_inventory_filter_type_default]]" },
												{ icon:"POTIONS", locKey:"[[panel_inventory_filter_type_alchemy_items]]" },
												{ icon:"WEAPONS", locKey:"[[item_category_equipement]]" }
												] ));
					
					
					if ( _defaultTabIdx != -1 )
					{
						mcPlayerInventory.onSetTabCalled( _defaultTabIdx );
					}
					
					/*
					mcPaperDollModule.active = true && !_filteringMode;
					mcPaperDollModule.x = mcShopPaperdollAnchor.x;
					mcPaperDollModule.y = mcShopPaperdollAnchor.y;
					
					mcCharacterRenderer.x = mcHorseModelAnchor.x;
					mcCharacterRenderer.y = mcHorseModelAnchor.y;
					*/
					
					break;
					
				case IMS_HorseInventory:
					
					mcSortingMode.x = 170;
					mcShopBackground.visible = false;
					mcStashBackground.visible = false;
					
					createContainerGridModule( value );
					//mcPaperDollModule.active = false;
					//cHorsePaperdollModule.active = true;
					mcCharacterRenderer.x = mcHorseModelAnchor.x;
					mcCharacterRenderer.y = mcHorseModelAnchor.y;
					_rendererController.enabled = false;
					dropSlot.disabled = true;
					mcVitalityStat.visible = false;
					mcToxicityStat.visible = false;
					
					break;
			}
			
			stage.dispatchEvent(new Event(CoreMenu.CURRENT_MODULE_INVALIDATE));
		}
		
		protected function /*Witcher Script*/ setIsOverburdenedText( value : String ) : void
		{
			var textField:TextField;

			if (mcOverburdened)
			{
				textField = (mcOverburdened.getChildByName("txtOverburdened") as MovieClip).getChildByName("txtOverburdened") as TextField;
				
				if (textField)
				{
					textField.text = value;
				}
			}
		}

		protected function /*Witcher Script*/ setIsOverburdened( value : Boolean ) : void
		{
			mcOverburdened.visible = value;
			mcPlayerInventory.SetOverburdened(value);
		}
		
		protected function /*Witcher Script*/ setMerchantInfo( value:Object ):void
		{
			moduleMerchantInfo.data = value;
		}
		
		/**
		 * @deprecated
		 */
		public function /*Witcher Script*/ setActiveItem(  value : String ) : void
		{
			trace("GFX [Witcher Script] setActiveItem", value);
		}
		
		override protected function handleInputNavigate(event:InputEvent):void
		{
			var details:InputDetails = event.details;
			var inputEnabled:Boolean = details.value == InputValue.KEY_UP && !event.handled;
			
			//trace("GFX --- handleInputNavigate --- ", details.navEquivalent, "; _rendererController ", _rendererController);
			
			/*
			if (!_rendererController.isCentered())
			{
				//_rendererController.handleInput(event);
			}
			*/
			
			if (inputEnabled)
			{
				switch (details.navEquivalent)
				{
					case NavigationCode.GAMEPAD_R2:
						//showFullStats();
						event.handled = true;
						break;
						
					case NavigationCode.GAMEPAD_B:
						if (mcSelectionMode.isActive())
						{
							event.handled = true;
							event.stopImmediatePropagation();
							CancelSelectionMode();
						}
						break;
						
					case NavigationCode.GAMEPAD_A:
						if (mcSelectionMode.isActive())
						{
							if (FinishSelectionMode())
							{
								event.handled = true;
								event.stopImmediatePropagation();
							}
						}
						break;
				}
				
				if (details.code == KeyCode.C)
				{
					event.handled = true;
					
					//showFullStats();
					//dispatchEvent( new GameEvent( GameEvent.CALL, 'OnShowFullStats' ));
				}
				else
				if (details.code == KeyCode.Q)
				{
					if ( !mcSelectionMode.isActive() && !_rendererController.isActive() )
					{
						event.handled = true;
						handleSortClick();
					}
				}
				else if (details.code == KeyCode.F || details.navEquivalent == NavigationCode.GAMEPAD_R3)
				{
					if ( !mcSelectionMode.isActive() && !_rendererController.isActive() )
					{
						if (!mcSortingMode.visible)
						{
							showSortingModeChange();
						}
						else
						{
							mcSortingMode.close();
						}
					}
				}
				if (details.code == KeyCode.E)
				{
					if (mcSelectionMode.isActive())
					{
						if (FinishSelectionMode())
						{
							event.handled = true;
							event.stopImmediatePropagation();
						}
					}
				}
			}
			
			super.handleInputNavigate(event);
		}
		
		private function handleSelectionModeAcceptClick(event:Event):void
		{
			trace("GFX handleSelectionModeAcceptClick");
			FinishSelectionMode();
		}
		
		private function handleSelectionModeCancelClick(event:Event):void
		{
			trace("GFX handleSelectionModeCancelClick");
			CancelSelectionMode();
		}
		
		private function FinishSelectionMode():Boolean
		{
			if ( !mcPaperDollModule )
			{
				return false;
			}
			var currentPaperdollSlot:SlotPaperdoll = mcPaperDollModule.mcPaperdoll.getSelectedRenderer() as SlotPaperdoll;
			
			trace("GFX FinishSelectionMode ", currentPaperdollSlot);
			
			if (currentPaperdollSlot)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSelectionModeTargetChosen', [currentPaperdollSlot.equipID] ) );
				return true;
			}
			else
			{
				throw new Error("GFX - failed to activate selected slot, selected index: " + mcPaperDollModule.mcPaperdoll.selectedIndex);
			}
			return false;
		}
		
		private function CancelSelectionMode():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSelectionModeCancelRequested' ) );
		}
		
		protected var _isTooltipHidden:Boolean = false;
		protected function showSelectionMode(infoObject:Object):void
		{
			if ( !mcPaperDollModule )
			{
				return;
			}
			var id:int = infoObject.sourceItem;
			var slotList:Array = infoObject.validSlots;
			var targetSlot:SlotInventoryGrid = mcPlayerInventory.getSlotByID(id);
			
			trace("GFX - starting selection mode by id: " + id + ", with valid slot list: " + slotList);
			
			if (!targetSlot)
			{
				mcPlayerInventory.mcPlayerGrid.traceGrid();
				throw new Error("GFX - was unable to find inventory slot with id: " + id);
			}
			else
			{
				trace("GFX - successfully found target slot: " + targetSlot);
			}
			
			mcSelectionMode.activate(targetSlot);
			mcPaperDollModule.startSelectModeWithValidSlots(slotList);
			
			mcPlayerInventory.enabled = false;
			mcPlayerInventory._inputEnabled = false;
			currentModuleIdx = 0;
			_rendererController.inputDisabled = true;
			
			SlotsTransferManager.getInstance().disabled = true;
			
			_isTooltipHidden = ContextInfoManager.getInstanse().isHidden();
			
			if (!_isTooltipHidden && infoObject.isDyeApplyingMode)
			{
				ContextInfoManager.getInstanse().setHiddenState(true);
			}
		}
		
		public function hideSelectionMode():void
		{
			if ( !mcPaperDollModule )
			{
				return;
			}
			mcSelectionMode.deactivate();
			
			mcPaperDollModule.endSelectionMode();
			
			mcPlayerInventory.enabled = true;
			mcPlayerInventory._inputEnabled = true;
			currentModuleIdx = 0;
			_rendererController.inputDisabled = false;
			
			SlotsTransferManager.getInstance().disabled = false;
			
			if (!_isTooltipHidden)
			{
				ContextInfoManager.getInstanse().setHiddenState(false);
			}
		}
	}
}
