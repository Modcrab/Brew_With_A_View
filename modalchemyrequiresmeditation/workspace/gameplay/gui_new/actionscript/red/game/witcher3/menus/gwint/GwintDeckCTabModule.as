/***********************************************************************
/** PANEL glossary characters main class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.gwint
{
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTweener;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.GwintInputFeedback;
	import red.game.witcher3.controls.AdvancedTabListItem;
	import red.game.witcher3.controls.TabListItem;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.modules.CollapsableTabbedListModule;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	
	public class GwintDeckCTabModule extends CollapsableTabbedListModule
	{
		public static const TabIndex_All 		: int = 0;
		public static const TabIndex_Melee 		: int = 1;
		public static const TabIndex_Ranged 	: int = 2;
		public static const TabIndex_Siege 		: int = 3;
		public static const TabIndex_Heroes		: int = 4;
		public static const TabIndex_Weather	: int = 5;
		public static const TabIndex_Special 	: int = 6;
		
		public var mcCardSlotList:GwintCardGridList;
		
		protected var targetDeck:GwintDeck;
		
		protected var forceRefreshSelectionCardID:int = -1;
		
		public var tutorialCardSorting:Boolean = false;
		private var cardsSentOnce:Boolean = false;
		
		protected override function configUI():void
		{
			super.configUI();
			
			bToCloseEnabled = false;
			
			setTabData(new DataProvider( [ { icon:"All", locKey:"[[gwint_card_category_title_all]]" }, 
										   { icon:"Melee", locKey:"[[gwint_card_category_title_melee]]" },
										   { icon:"Ranged", locKey:"[[gwint_card_category_title_ranged]]" }, 
										   { icon:"Siege", locKey:"[[gwint_card_category_title_siege]]" },
										   { icon:"Heroes", locKey:"[[gwint_card_category_title_Heroes]]" },
										   { icon:"Weather", locKey:"[[gwint_card_category_title_weather]]" },
										   { icon:"Special", locKey:"[[gwint_card_category_title_special]]" } ] ));
			
			if (mcTabList.selectedIndex == -1)
			{
				mcTabList.selectedIndex = 0;
			}
			
			if (mcCardSlotList)
			{
				mcCardSlotList.focusable = false;
				_inputHandlers.push(mcCardSlotList);
				//addToListContainer(mcCardSlotList);
				mcCardSlotList.addEventListener(CardSlot.CardMouseOver, OnCardMouseOver, false, 0, true);
				mcCardSlotList.addEventListener(CardSlot.CardMouseOut, OnCardMouseOut, false, 0, true);
			}
		}
		
		override public function open():void
		{
			// Can't open empty tabs ><
			if (canOpen() || _lastMoveWasMouse)
			{
				stateMachine.ChangeState(CollapsableTabbedListModule.State_Open);
			}
		}
		
		public function canOpen():Boolean
		{
			return stateMachine.currentState != CollapsableTabbedListModule.State_Open && (mcCardSlotList.data != null && mcCardSlotList.data.length > 0);
		}
		
		override protected function onTabListItemSelected( event:ListEvent ):void
		{
			super.onTabListItemSelected(event);
			
			if (focused)
			{
				InputFeedbackManager.removeButtonById(GwintInputFeedback.openTab);
				
				if (canOpen())
				{
					InputFeedbackManager.appendButtonById(GwintInputFeedback.openTab, NavigationCode.GAMEPAD_A, -1, "inputfeedback_common_open_grid");
				}
			}
		}
		
		override public function hasSelectableItems():Boolean
		{
			return true;
		}
		
		public function setTargetDeck(deck:GwintDeck):void
		{
			if (targetDeck != deck)
			{
				if (targetDeck != null)
				{
					targetDeck.refreshCallback = null;
					targetDeck.onCardChangedCallback = null;
				}
				
				targetDeck = deck;
				
				if (targetDeck)
				{
					targetDeck.refreshCallback = onDeckRefreshTriggered;
					targetDeck.onCardChangedCallback = onCardChangedCallback;
					onDeckRefreshTriggered();
				}
			}
			else
			{
				onDeckRefreshTriggered();
			}
		}
		
		protected function onDeckRefreshTriggered():void
		{
			updateSubData(mcTabList.selectedIndex);
		}
		
		override protected function state_colapsed_begin():void
		{
			super.state_colapsed_begin();
			
			if (focused)
			{
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"]));
			}
		}
		
		protected function onCardChangedCallback(cardID:int, numCopies:int):void
		{
			var i:int;
			var curRenderer:CardSlot;
			var matchingRenderer:CardSlot = null;
			
			// get existing renderer if it exists
			
			for (i = 0; i < mcCardSlotList.getRenderersLength(); ++i)
			{
				curRenderer = mcCardSlotList.getRendererAt(i) as CardSlot;
				
				if (curRenderer.cardIndex == cardID)
				{
					matchingRenderer = curRenderer;
					break;
				}
			}
			
			var autoselectNewSlot:Boolean = false;
			
			var rendererData:Object = { cardID:cardID, numCopies:numCopies };
			
			if (matchingRenderer == null)
			{
				if (numCopies > 0)
				{
					trace("GFX ----- Adding renderer with data: " + rendererData);
					mcCardSlotList.addRenderer(rendererData);
					autoselectNewSlot = true;
				}
			}
			else
			{
				if (numCopies == 0)
				{
					trace("GFX ----- Removing Renderer with data: " + rendererData);
					mcCardSlotList.removeRenderer(matchingRenderer);
					if (mcCardSlotList.getRenderersLength() == 0)
					{
						close();
					}
				}
				else
				{
					trace("GFX ----- Updating Renderer with data: " + rendererData);
					matchingRenderer.setData(rendererData);
					autoselectNewSlot = true;
				}
			}
			
			if (!IsCardInCurrentTab(cardID) && mcTabList.selectedIndex != -1)
			{
				var currentTab:AdvancedTabListItem = mcTabList.getSelectedRenderer() as AdvancedTabListItem;
				
				// #J kinda lame but changing the index in the way right after is not doing this properly for the current item
				if (currentTab)
				{
					currentTab.selected = false;
					currentTab.setIsOpen(false);
				}
				
				forceRefreshSelectionCardID = cardID;
				mcTabList.selectedIndex = 0;
			}
			else if (!_lastMoveWasMouse)
			{
				mcCardSlotList.validateNow();
				
				for (i = 0; i < mcCardSlotList.getRenderersLength(); ++i)
				{
					curRenderer = mcCardSlotList.getRendererAt(i) as CardSlot;
					
					if (curRenderer.cardIndex == cardID)
					{
						mcCardSlotList.selectedIndex = i;
						break;
					}
				}
			}
		}
		
		protected function IsCardInCurrentTab(cardID:int) : Boolean
		{
			var cardManagerRef:CardManager = CardManager.getInstance();
			var currentTemplate:CardTemplate;
			currentTemplate = cardManagerRef.getCardTemplate(cardID);
			
			if (currentTemplate)
			{
				switch (mcTabList.selectedIndex)
				{
				default:
				case TabIndex_All:
					return true;
				case TabIndex_Melee:
					return isMelee(currentTemplate);
				case TabIndex_Ranged:
					return isRanged(currentTemplate);
				case TabIndex_Siege:
					return isSiege(currentTemplate);
				case TabIndex_Heroes:
					return isHero(currentTemplate);
				case TabIndex_Weather:
					return isWeather(currentTemplate);
				case TabIndex_Special:
					return isSpecial(currentTemplate);
				}
			}
			
			return false;
		}
		
		override protected function updateSubData(index:int):void
		{
			var cardInfoArray:Array = new Array();
			
			cardsSentOnce = true;
			
			trace("GFX - " + this + " is updating with deckInfo: " + targetDeck);
			
			switch (index)
			{
			default:
			case TabIndex_All:
				cardInfoArray = fillDataWithCallback(null);
				break;
			case TabIndex_Melee:
				cardInfoArray = fillDataWithCallback(isMelee);
				break;
			case TabIndex_Ranged:
				cardInfoArray = fillDataWithCallback(isRanged);
				break;
			case TabIndex_Siege:
				cardInfoArray = fillDataWithCallback(isSiege);
				break;
			case TabIndex_Heroes:
				cardInfoArray = fillDataWithCallback(isHero);
				break;
			case TabIndex_Weather:
				cardInfoArray = fillDataWithCallback(isWeather);
				break;
			case TabIndex_Special:
				cardInfoArray = fillDataWithCallback(isSpecial);
				break;
			}
			
			if (tutorialCardSorting)
			{
				cardInfoArray.sort(deckbuilderCardSorter_tutorial);
			}
			else
			{
				cardInfoArray.sort(deckbuilderCardSorter);
			}
			
			mcCardSlotList.data = cardInfoArray;
			mcCardSlotList.validateNow();
			
			//if (!_lastMoveWasMouse || mcCardSlotList.selectedIndex >= cardInfoArray.length)
			//{
				mcCardSlotList.findSelection();
				mcCardSlotList.validateNow();
			//}
			
			if (hideTabBackgroundWhenData && mcTabBackground)
			{
				mcTabBackground.visible = mcCardSlotList.data.length == 0;
			}
			
			var targetUIComponent:UIComponent = mcCardSlotList as UIComponent;
			
			if (targetUIComponent)
			{
				targetUIComponent.visible = true;
				targetUIComponent.validateNow();
				
				if (subDataTweener)
				{
					subDataTweener.paused = true;
					GTweener.removeTweens(targetUIComponent);
				}
				
				targetUIComponent.alpha = 0;
				
				var duration:Number = 0.5;
				
				subDataTweener = GTweener.to(targetUIComponent, duration, { alpha: 1 }, {onComplete:handleTweenComplete, ease:Sine.easeOut} );
			}
			
			var currentDataComponent:UIComponent = getDataShowerForCurrentTab();
				
			if (currentDataComponent)
			{				
				if (stateMachine.currentState != State_Open)
				{
					if (!focused)
					{
						currentDataComponent.visible = false;
					}
				}
			}
			
			setAllowSelectionHighlight(isOpen && focused);
			
			if (forceRefreshSelectionCardID != -1 && !_lastMoveWasMouse)
			{
				var i:int;
				var curRenderer:CardSlot;
				
				mcCardSlotList.validateNow();
				
				for (i = 0; i < mcCardSlotList.getRenderersLength(); ++i)
				{
					curRenderer = mcCardSlotList.getRendererAt(i) as CardSlot;
					
					if (curRenderer.cardIndex == forceRefreshSelectionCardID)
					{
						mcCardSlotList.selectedIndex = i;
						break;
					}
				}
				forceRefreshSelectionCardID = -1;
			}
			
			closeIfEmpty();
			
			updateInputFeedback();
		}
		
		override protected function closeIfEmpty():void
		{
			if (isOpen)
			{
				if (mcCardSlotList == null || mcCardSlotList.data == null || mcCardSlotList.data.length == 0)
				{
					close();
				}
			}
		}
		
		public function sortTutorialCards():void
		{
			tutorialCardSorting = true;
			
			if (cardsSentOnce)
			{
				updateSubData(TabIndex_All);
			}
		}
		
		protected function isMelee(cardTemplate:CardTemplate):Boolean
		{
			return cardTemplate.isType(CardTemplate.CardType_Melee) && cardTemplate.isType(CardTemplate.CardType_Creature);
		}
		
		protected function isRanged(cardTemplate:CardTemplate):Boolean
		{
			return cardTemplate.isType(CardTemplate.CardType_Ranged) && cardTemplate.isType(CardTemplate.CardType_Creature);
		}
		
		protected function isSiege(cardTemplate:CardTemplate):Boolean
		{
			return cardTemplate.isType(CardTemplate.CardType_Siege) && cardTemplate.isType(CardTemplate.CardType_Creature);
		}
		
		protected function isHero(cardTemplate:CardTemplate):Boolean
		{
			return cardTemplate.isType(CardTemplate.CardType_Hero);
		}
		
		protected function isWeather(cardTemplate:CardTemplate):Boolean
		{
			return cardTemplate.isType(CardTemplate.CardType_Weather);
		}
		
		protected function isSpecial(cardTemplate:CardTemplate):Boolean
		{
			return !cardTemplate.isType(CardTemplate.CardType_Creature);
		}
		
		protected var _lastMousedOverCardIndex:int = -1;
		protected function OnCardMouseOver(event:Event):void
		{
			if (!_lastMoveWasMouse)
			{
				return;
			}
			
			var currentCard:CardSlot = event.target as CardSlot;
			
			trace("GFX -------- OnCardMouseOver ---- target: " + event.target + ", currentTarget: " + event.currentTarget);
			
			if (currentCard)
			{
				_lastMousedOverCardIndex = mcCardSlotList.getRendererIndex(currentCard);
				mcCardSlotList.selectedIndex = _lastMousedOverCardIndex
			}
		}
		
		protected function OnCardMouseOut(event:Event):void
		{
			if (!_lastMoveWasMouse)
			{
				return;
			}
			
			mcCardSlotList.selectedIndex = -1;
			_lastMousedOverCardIndex = -1;
		}
		
		override protected function handleControllerChange(event:ControllerChangeEvent):void
		{
			super.handleControllerChange(event);
			
			if (event.isGamepad)
			{
				_lastMoveWasMouse = false;
			}
			
			if (!_lastMoveWasMouse)
			{
				if (mcCardSlotList.selectedIndex == -1)
				{
					mcCardSlotList.findSelection();
				}
			}
			else
			{
				mcCardSlotList.selectedIndex = _lastMousedOverCardIndex;
			}
		}
		
		protected function fillDataWithCallback(checkFunction:Function):Array
		{
			var listArray:Array = new Array();
			var currentObject:Object;
			var currentTemplateID:int;
			var currentTemplate:CardTemplate;
			var cardManagerRef:CardManager = CardManager.getInstance();
			var i:int;
			var x:int;
			
			if (targetDeck)
			{
				for (i = 0; i < targetDeck.cardIndices.length; ++i)
				{
					currentTemplateID = targetDeck.cardIndices[i];
					
					currentObject = null;
					
					for (x = 0; x < listArray.length; ++x)
					{
						if (listArray[x].cardID == currentTemplateID)
						{
							currentObject = listArray[x];
						}
					}
					
					if (currentObject != null)
					{
						currentObject.numCopies += 1;
						trace("GFX - increasing num copies for card element with ID: " + currentTemplateID + ", with resulting quantity: " + currentObject.numCopies);
					}
					else
					{
						currentTemplate = cardManagerRef.getCardTemplate(currentTemplateID);
						
						if (checkFunction == null || checkFunction(currentTemplate))
						{
							currentObject = { cardID:currentTemplateID, numCopies:1 };
							trace("GFX - created new card item with id: " + currentTemplateID);
							listArray.push(currentObject);
						}
					}
				}
			}
			
			return listArray;
		}
		
		protected function deckbuilderCardSorter(element1:Object, element2:Object):Number
		{
			var cardTemplateA:CardTemplate = CardManager.getInstance().getCardTemplate(element1.cardID);
			var cardTemplateB:CardTemplate = CardManager.getInstance().getCardTemplate(element2.cardID);
			
			if (cardTemplateA.isType(CardTemplate.CardType_Creature) && !cardTemplateB.isType(CardTemplate.CardType_Creature))
			{
				return 1;
			}
			else if (!cardTemplateA.isType(CardTemplate.CardType_Creature) && cardTemplateB.isType(CardTemplate.CardType_Creature))
			{
				return -1;
			}
			
			if (cardTemplateA.factionIdx != cardTemplateB.factionIdx)
			{
				if (cardTemplateA.factionIdx < cardTemplateB.factionIdx)
				{
					return -1;
				}
				else if (cardTemplateA.factionIdx > cardTemplateB.factionIdx)
				{
					return 1;
				}
			}
			
			if (cardTemplateA.power != cardTemplateB.power)
			{
				// MOAR POWER AT TOP
				return cardTemplateB.power - cardTemplateA.power;
			}
			
			return cardTemplateA.index - cardTemplateB.index;
		}
		
		protected function deckbuilderCardSorter_tutorial(element1:Object, element2:Object):Number
		{
			var cardTemplateA:CardTemplate = CardManager.getInstance().getCardTemplate(element1.cardID);
			var cardTemplateB:CardTemplate = CardManager.getInstance().getCardTemplate(element2.cardID);
			
			if (cardTemplateA.isType(CardTemplate.CardType_Creature) && !cardTemplateB.isType(CardTemplate.CardType_Creature))
			{
				return -1;
			}
			else if (!cardTemplateA.isType(CardTemplate.CardType_Creature) && cardTemplateB.isType(CardTemplate.CardType_Creature))
			{
				return 1;
			}
			
			if (cardTemplateA.factionIdx != cardTemplateB.factionIdx)
			{
				if (cardTemplateA.factionIdx < cardTemplateB.factionIdx)
				{
					return -1;
				}
				else if (cardTemplateA.factionIdx > cardTemplateB.factionIdx)
				{
					return 1;
				}
			}
			
			if (cardTemplateA.power != cardTemplateB.power)
			{
				// MOAR POWER AT TOP
				return cardTemplateB.power - cardTemplateA.power;
			}
			
			return cardTemplateA.index - cardTemplateB.index;
		}
		
		override protected function updateInputFeedbackButtons():void
		{
			if (_inputSymbolIDB != -1)
			{
				InputFeedbackManager.removeButton(this, _inputSymbolIDB);
				_inputSymbolIDB = -1;
			}

			if (_inputSymbolIDA != -1)
			{
				InputFeedbackManager.removeButton(this, _inputSymbolIDA);
				_inputSymbolIDA = -1;
			}

			if (stateMachine.currentState == State_Colapsed)
			{
				if (_focused && mcTabList.selectedIndex != -1 && subDataDictionary[mcTabList.selectedIndex] != null && subDataDictionary[mcTabList.selectedIndex].length > 0)
				{
					_inputSymbolIDA = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, -1, "inputfeedback_common_open_grid");
				}
			}
			//else if (stateMachine.currentState == State_Open)
			//{
			//	_inputSymbolIDB = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_B, -1, "inputfeedback_common_close_grid");
			//}
		}
		
		override protected function setAllowSelectionHighlight(allowed:Boolean):void
		{
			super.setAllowSelectionHighlight(allowed);
			
			var currentSlotItem:SlotBase;
			var i:int;
			
			if (mcCardSlotList)
			{
				mcCardSlotList.validateNow();
				
				mcCardSlotList.activeSelectionVisible = allowed  || _lastMoveWasMouse;
			}
		}
	}
}    
     
     
     