package red.game.witcher3.menus.gwint
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.constants.GwintInputFeedback;
	import red.game.witcher3.controls.ConditionalButton;
	import red.game.witcher3.controls.ConditionalCloseButton;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3ChoiceDialog;
	import red.game.witcher3.controls.W3ListSelectionTracker;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.events.InputFeedbackEvent;
	import red.game.witcher3.events.SlotActionEvent;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	import red.game.witcher3.constants.InventoryActionType;
	import red.game.witcher3.utils.CommonUtils;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jason Slama sept 2014
	 */
	public class DeckBuilderMenu extends GwintBaseMenu
	{
		public var txtCurrentDeck:TextField;
		public var txtCurrentDeckPassive:TextField;
		public var txtPrevDeck:TextField;
		public var txtNextDeck:TextField;
		public var mcLeftPCButton : ConditionalButton;
		public var mcRightPCButton : ConditionalButton;
		public var mcLeftFeedbackButton:InputFeedbackButton;
		public var mcRightFeedbackButton:InputFeedbackButton;
		public var mcDeckSelectionTracker:W3ListSelectionTracker;
		public var mcFactionIcon:MovieClip;
		
		public var mcStartGameButton:InputFeedbackButton;
		public var mcStartGameButtonPC:ConditionalButton;
		public var txtStartGameText:TextField;
		public var mcChangeHeroButton:InputFeedbackButton;
		
		public var mcChoiceDialog:W3ChoiceDialog;
		public var mcLeaderCard:CardSlot;
		public var mcCloseBtn : ConditionalCloseButton;
		
		public var mcTutorial:GwintTutorial;
		
		public var mcDeckStats			:GwintDeckStatsPanel;
		public var mcDeckHolder			:GwintDeckCTabModule;
		public var mcCollectionHolder	:GwintDeckCTabModule;
		
		protected var deckFactionList:Array;
		protected var deckToFactionIndexes:Array = new Array();
		protected var factionDecks:Vector.<GwintDeck> = new Vector.<GwintDeck>();
		protected var collectionDeck:GwintDeck;
		
		protected var hasDeckInfo:Boolean = false;
		protected var hasCollectionInfo:Boolean = false;
		protected var hasLeaderInfo:Boolean = false;
		protected var _selectedDeckIndex:int = -1;
		
		protected var collectionInfo:Array = null;
		protected var leaderCollectionInfo:Array = null;
		
		protected var gwintGamePending:Boolean = false;
		
		protected var isInZoomMode:Boolean = false;
		
		public var passiveAbilityString:String;
		
		public function get selectedDeckIndex():int { return _selectedDeckIndex; }
		public function set selectedDeckIndex(value:int):void
		{
			if (_selectedDeckIndex != value)
			{
				_selectedDeckIndex = value;
				
				if (hasDeckInfo)
				{
					var selectedDeck:GwintDeck = factionDecks[_selectedDeckIndex];
					
					trace("GFX - Setting up Deck with selectedIndex: " + _selectedDeckIndex);
					mcDeckHolder.setTargetDeck(selectedDeck);
					mcDeckStats.targetDeck = selectedDeck;
					
					resetToDefaultButtons();
					
					updateTopSelectedDeck();
					
					if (hasCollectionInfo)
					{
						updateCollectionDeck();
					}
				}
				
				CardSlot.updateDefaultFaction(value);
				
				updateStartGameButton();
			}
		}
		
		public function DeckBuilderMenu()
		{
			super();
			_enableMouse = false;
		}
		
		override protected function configUI():void
		{
			mcTutorial.currentTutorialFrame = 3; // #Y #HACK
			
			super.configUI();
			
			if (mcTutorial)
			{
				mcTutorial.showCarouselCB = showTutCarousel;
				mcTutorial.hideCarouselCB = hideTutCarousel;
			}
			
			clearMouseEnabledOnTextFieldsInDeckStats();
			
			InputFeedbackManager.useOverlayPopup = true;
			InputFeedbackManager.eventDispatcher = this;
			
			setupFactions();
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'gwint.deckbuilder.decks', [ updateGwintDecks ] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'gwint.deckbuilder.collection', [updateGwintCollection ] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'gwint.deckbuilder.leaderList', [updateLeaderList] ) );
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			
			setupLeaderCard();
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange, false, 0, true);
			
			mcCollectionHolder.addEventListener(SlotActionEvent.EVENT_ACTIVATE, handleCollectionSlotActivated, false, 0, true);
			mcCollectionHolder.addEventListener(CardSlot.CardMouseRightClick, onCollectionRightClickCard, false, 0, true);
			mcCollectionHolder.mcCardSlotList.addEventListener(ListEvent.INDEX_CHANGE, onSelectedCardChanged, false, 0, true);
			mcCollectionHolder.closedCallback = resetToDefaultButtons;
			mcCollectionHolder.openedCallback = resetToDefaultButtons;
			
			mcDeckHolder.addEventListener(SlotActionEvent.EVENT_ACTIVATE, handleDeckSlotActivated, false, 0, true);
			mcDeckHolder.addEventListener(CardSlot.CardMouseRightClick, onDeckRightClickCard, false, 0, true);
			mcDeckHolder.mcCardSlotList.addEventListener(ListEvent.INDEX_CHANGE, onSelectedCardChanged, false, 0, true);
			mcDeckHolder.closedCallback = resetToDefaultButtons;
			mcDeckHolder.openedCallback = resetToDefaultButtons;
			
			if (mcCloseBtn)
			{
				mcCloseBtn.addEventListener(ButtonEvent.PRESS, handleClosePressed, false, 0, true);
			}
			
			mcChoiceDialog.cardsCarousel.addEventListener(ListEvent.INDEX_CHANGE, onCarouselSelectionChanged, false, 0, true);
			
			upToCloseEnabled = false;
			
			if (mcLeftPCButton)
			{
				mcLeftPCButton.addEventListener(ButtonEvent.PRESS, handlePrevButtonPress, false, 0, true);
			}
			
			if (mcRightPCButton)
			{
				mcRightPCButton.addEventListener(ButtonEvent.PRESS, handleNextButtonPress, false, 0, true);
			}
			
			if (mcLeftFeedbackButton)
			{
				mcLeftFeedbackButton.setDataFromStage(NavigationCode.GAMEPAD_L1, -1);
			}
			
			if (mcRightFeedbackButton)
			{
				mcRightFeedbackButton.setDataFromStage(NavigationCode.GAMEPAD_R1, -1);
			}
			
			if (mcStartGameButton)
			{
				mcStartGameButton.setDataFromStage(NavigationCode.GAMEPAD_Y, -1);
				//mcStartGameButton.visible = false;
			}
			
			if (txtStartGameText)
			{
				txtStartGameText.mouseEnabled = false;
			}
			
			if (mcStartGameButtonPC)
			{
				if (txtStartGameText)
				{
					mcStartGameButtonPC.visibleWidth = txtStartGameText.textWidth + 12;
				}
				
				mcStartGameButtonPC.filters = [];
				mcStartGameButtonPC.alpha = 1;
				mcStartGameButtonPC.addEventListener(ButtonEvent.PRESS, handleStartPressed, false, 0, true);
			}
			
			if (mcChangeHeroButton)
			{
				mcChangeHeroButton.setDataFromStage(NavigationCode.GAMEPAD_X, -1);
			}
			
			if (mcChoiceDialog)
			{
				mcChoiceDialog.visible = false;
			}
			
			currentModuleIdx = 0;
		}
		
		override protected function get menuName():String
		{ 
			return "DeckBuilder";
		}
		
		public function sorryJason_temp():void
		{
			mcDeckHolder._inputEnabled = false;
			mcCollectionHolder._inputEnabled = false;
			mcDeckHolder.enabled = false;
			mcCollectionHolder.enabled = false;
		}
		
		public function showTutorial():void
		{
			mcTutorial.show();
			
			mcCollectionHolder.sortTutorialCards();
			
			resetInputFeedbackButtons();
			
			mcTutorial.onHideCallback = onTutorialHide;
			mcDeckHolder._inputEnabled = false;
			mcCollectionHolder._inputEnabled = false;
			mcDeckHolder.enabled = false;
			mcCollectionHolder.enabled = false;
		}
		
		public function onTutorialHide():void
		{
			mcDeckHolder._inputEnabled = true;
			mcCollectionHolder._inputEnabled = true;
			resetToDefaultButtons();
			mcCollectionHolder.enabled = true;
			mcDeckHolder.enabled = true;
			currentModuleIdx = 0;
		}
		
		public function setPassiveAbilityString(string:String):void
		{
			passiveAbilityString = string;
		}
		
		protected function setupFactions():void
		{
			deckToFactionIndexes.push(CardTemplate.FactionId_Neutral);
			deckToFactionIndexes.push(CardTemplate.FactionId_Northern_Kingdom);
			deckToFactionIndexes.push(CardTemplate.FactionId_Nilfgaard);
			deckToFactionIndexes.push(CardTemplate.FactionId_Scoiatael);
			deckToFactionIndexes.push(CardTemplate.FactionId_No_Mans_Land);
			deckToFactionIndexes.push(CardTemplate.FactionId_Skellige);
			
			factionDecks.push(null);
			factionDecks.push(null);
			factionDecks.push(null);
			factionDecks.push(null);
			factionDecks.push(null);
		}
		
		protected function updateGwintDecks(decks:Array):void
		{
			var i:int;
			var numDecks:int = 0;
			
			for (i = 0; i < decks.length; ++i)
			{
				var deck:GwintDeck = decks[i] as GwintDeck;
				
				if (deck)
				{
					trace("GFX - Received deck information for faction: " + deck.getDeckFaction());
					trace("GFX - deck info: " + deck);
					
					factionDecks[deck.getDeckFaction()] = deck;
					++numDecks;
					trace("GFX - and set is successfully"); // #J added a second trace here because I have a feeling this could easily break
				}
			}
			
			setupDecksTopBar(numDecks);
			
			hasDeckInfo = true;
			
			if (selectedDeckIndex != -1)
			{
				trace("GFX - selectedDeckIndex was already set to: " + selectedDeckIndex + ", setting target deck to: " + factionDecks[selectedDeckIndex]);
				mcDeckHolder.setTargetDeck(factionDecks[selectedDeckIndex]);
				mcDeckStats.targetDeck = factionDecks[selectedDeckIndex];
				
				updateTopSelectedDeck();
			
				if (hasCollectionInfo)
				{
					updateCollectionDeck();
				}
				
				resetToDefaultButtons();
			}
		}
		
		protected function setupDecksTopBar(numDecks:int):void
		{
			if (numDecks <= 1)
			{
				if (txtPrevDeck)
				{
					txtPrevDeck.visible = false;
				}
				
				if (txtNextDeck)
				{
					txtNextDeck.visible = false;
				}
				
				if (mcLeftFeedbackButton)
				{
					mcLeftFeedbackButton.visible = false;
				}
				
				if (mcRightFeedbackButton)
				{
					mcRightFeedbackButton.visible = false;
				}
				
				if (mcDeckSelectionTracker)
				{
					mcDeckSelectionTracker.visible = false;
				}
			}
			else
			{
				if (mcDeckSelectionTracker)
				{
					mcDeckSelectionTracker.numElements = numDecks;
				}
				
				deckFactionList = new Array();
				
				for (var i:int = 0; i < factionDecks.length; ++i)
				{
					if (factionDecks[i] != null)
					{
						deckFactionList.push(factionDecks[i]);
					}
				}
			}
		}
		
		protected function updateTopSelectedDeck():void
		{
			var selectedDeck:GwintDeck = getSelectedDeck();
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnSelectedDeckChanged", [ selectedDeckIndex ] ) );
			
			if (txtCurrentDeck)
			{
				txtCurrentDeck.text = selectedDeck.getFactionNameString();
				txtCurrentDeckPassive.htmlText = selectedDeck.getFactionPerkString();
				txtCurrentDeckPassive.htmlText = txtCurrentDeckPassive.htmlText;
				
				//txtCurrentDeck.width = txtCurrentDeck.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			}
			
			if (mcFactionIcon)
			{
				mcFactionIcon.gotoAndStop(selectedDeck.getDeckKingTemplate().getFactionString());
			}
			
			if (txtCurrentDeck && mcFactionIcon)
			{
				var screenRect:Rectangle = CommonUtils.getScreenRect();
				var centerPoint:Number = Math.round((screenRect.x + screenRect.width - (txtCurrentDeck.width + mcFactionIcon.width))/ 2);
				mcFactionIcon.x = txtCurrentDeck.x + txtCurrentDeck.width/2 - txtCurrentDeck.textWidth/2 - mcFactionIcon.width;
				//txtCurrentDeck.x = mcFactionIcon.x + mcFactionIcon.width;
			}
			
			if (mcLeaderCard)
			{
				mcLeaderCard.cardIndex = selectedDeck.selectedKingIndex;
			}
			
			if (deckFactionList != null)
			{
				var currentIndex:int = deckFactionList.indexOf(selectedDeck);
				var nextIndex:int;
				var prevIndex:int;
				
				if (currentIndex == (deckFactionList.length - 1))
				{
					nextIndex = 0;
				}
				else
				{
					nextIndex = currentIndex + 1;
				}
				
				if (currentIndex == 0)
				{
					prevIndex = deckFactionList.length - 1;
				}
				else
				{
					prevIndex = currentIndex - 1;
				}
				
				if (txtNextDeck)
				{
					txtNextDeck.text = deckFactionList[nextIndex].getFactionNameString();
				}
				
				if (txtPrevDeck)
				{
					txtPrevDeck.text = deckFactionList[prevIndex].getFactionNameString();
				}
				
				if (mcDeckSelectionTracker)
				{
					mcDeckSelectionTracker.selectedIndex = currentIndex;
				}
			}
		}
		
		protected function changeDeckIndex(next:Boolean):void
		{
			var currentIndex:int = deckFactionList.indexOf(getSelectedDeck());
			
			var newIndex:int;
			
			if (next)
			{
				if (currentIndex == (deckFactionList.length - 1))
				{
					newIndex = 0;
				}
				else
				{
					newIndex = currentIndex + 1;
				}
			}
			else
			{
				if (currentIndex == 0)
				{
					newIndex = deckFactionList.length - 1;
				}
				else
				{
					newIndex = currentIndex - 1;
				}
			}
			
			selectedDeckIndex = deckFactionList[newIndex].getDeckFaction();
		}
		
		public function setSelectedDeck(deckIndex:int):void
		{
			selectedDeckIndex = deckIndex;
		}
		
		public function setGwintGamePending(value:Boolean):void
		{
			gwintGamePending = value;
			
			if (mcStartGameButton)
			{
				mcStartGameButton.visible = value;
			}
			
			if (txtStartGameText)
			{
				txtStartGameText.visible = value;
			}
			
			if (mcStartGameButtonPC)
			{
				mcStartGameButtonPC.visible = value;
			}
			
			if (mcCloseBtn)
			{
				mcCloseBtn.label = value ? "[[gwint_pass_game]]" : "[[panel_button_common_close]]";
			}
			
			resetToDefaultButtons();
		}
		
		public function getSelectedDeck():GwintDeck
		{
			return factionDecks[selectedDeckIndex];
		}
		
		protected function updateStartGameButton():void
		{
			if (!mcStartGameButton)
			{
				return;
			}
			
			var isDeckValid:Boolean = false;
			
			if (selectedDeckIndex != -1)
			{
				var selectedDeck:GwintDeck = getSelectedDeck();
				
				if (selectedDeck && selectedDeck.dbIsValidDeck())
				{
					isDeckValid = true;
				}
			}
			
			if (isDeckValid)
			{
				mcStartGameButton.filters = [];
				mcStartGameButton.alpha = 1;
				mcStartGameButtonPC.filters = [];
				mcStartGameButtonPC.alpha = 1;
			}
			else
			{
				//mcStartGameButton.filters = [CommonUtils.generateDesaturationFilter(0.2)];
				mcStartGameButton.filters = [CommonUtils.generateDarkenFilter(0.5)];
				mcStartGameButton.alpha = 0.5;
				mcStartGameButtonPC.filters = [CommonUtils.generateDarkenFilter(0.5)];
				mcStartGameButtonPC.alpha = 0.5;
			}
		}
		
		protected function updateGwintCollection(cards:Array):void
		{
			collectionInfo = cards;
			
			if (collectionInfo != null)
			{
				hasCollectionInfo = true;
				
				if (hasDeckInfo && selectedDeckIndex != -1)
				{
					updateCollectionDeck();
				}
			}
		}
		
		protected function updateLeaderList(cards:Array):void
		{
			leaderCollectionInfo = cards;
			
			if (leaderCollectionInfo != null)
			{
				hasLeaderInfo = true;
			}
		}
		
		protected var hasUpdatedOnce:Boolean = false;
		protected function updateCollectionDeck():void
		{
			var selectedDeck:GwintDeck = getSelectedDeck();
			var cardManagerRef:CardManager = CardManager.getInstance();
			var curCollectionInfo:Object;
			var curCardFaction:int;
			var deckFaction:int = selectedDeck.getDeckFaction();
			
			trace("GFX - updatingCollectionDeck with deckID: " + selectedDeckIndex + ", and result: " + selectedDeck);
			
			if (collectionDeck == null)
			{
				collectionDeck = new GwintDeck();
				collectionDeck.cardIndices = new Array();
			}
			
			collectionDeck.cardIndices.length = 0;
			
			var i:int;
			var numCopiesToPut:int;
			var x:int;
			
			for (i = 0; i < collectionInfo.length; ++i)
			{
				curCollectionInfo = collectionInfo[i];
				
				if (!cardManagerRef.getCardTemplate(curCollectionInfo.cardID))
				{
					throw new Error("GFX [ERROR] - Trying to parse with an invalid card ID: " + curCollectionInfo.cardID);
				}
				curCardFaction = cardManagerRef.getCardTemplate(curCollectionInfo.cardID).factionIdx
				
				// Don't show cards that aren't either neutral or current decks faction
				if (curCardFaction == CardTemplate.FactionId_Neutral || curCardFaction == deckFaction)
				{
					numCopiesToPut = curCollectionInfo.numCopies - selectedDeck.dbGetNumCopiesOfCard(curCollectionInfo.cardID);
					for (x = 0; x < numCopiesToPut; ++x)
					{
						collectionDeck.cardIndices.push(curCollectionInfo.cardID);
					}
				}
			}
			
			if (mcCollectionHolder)
			{
				trace("GFX - finished setting up collection deck: " + collectionDeck);
				mcCollectionHolder.setTargetDeck(collectionDeck);
			}
			
			if (!hasUpdatedOnce)
			{
				hasUpdatedOnce = true;
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_gwint_gwint_start"]));
			}
		}
		
		override protected function closeMenu():void
		{
			dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_gwint_lock_in"]));
			super.closeMenu();
		}
		
		protected function handleStartPressed( event : ButtonEvent ) : void
		{
			var currentDeck:GwintDeck = getSelectedDeck();
			if (!mcChoiceDialog.visible && !isInZoomMode)
			{
				if (currentDeck == null || !currentDeck.dbIsValidDeck())
				{
					mcDeckStats.highlightUnitCount();
					dispatchEvent(new GameEvent(GameEvent.CALL, "OnLackOfUnitsError", [currentDeck.dbCountCards(CardTemplate.CardType_Creature, CardTemplate.CardEffect_None)]));
				}
				else if (gwintGamePending)
				{
					closeMenu();
				}
			}
		}
		
		override protected function handleInputNavigate(event:InputEvent):void
		{
			if (mcTutorial && mcTutorial.visible && !mcTutorial.isPaused)
			{
				mcTutorial.handleInput(event);
				return;
			}
			
			var currentDeck:GwintDeck = getSelectedDeck();
			
			var details:InputDetails = event.details;
			
			var keyDown:Boolean = details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD; 
			var keyUp:Boolean = details.value == InputValue.KEY_UP;

			if (!event.handled)
			{
				if (mcChoiceDialog && mcChoiceDialog.visible)
				{
					switch (details.navEquivalent)
					{
						case NavigationCode.GAMEPAD_R2:
						if (keyUp)
						{
							if (isInZoomMode && !choosingLeader)
							{
								closeZoomCB();
							}
						}
						break;
					}
				}
				else
				{
					if (details.code == KeyCode.X && keyUp && !isInZoomMode)
					{
						startChooseModeLeader();
					}
					else if (details.code == KeyCode.H && keyUp && !gwintGamePending && !isInZoomMode)
					{
						tryClose();
					}
					else if (details.code == KeyCode.ENTER || details.navEquivalent == NavigationCode.GAMEPAD_Y)
					{
						if (keyUp && !mcChoiceDialog.visible && !isInZoomMode)
						{
							if (currentDeck == null || !currentDeck.dbIsValidDeck())
							{
								mcDeckStats.highlightUnitCount();
								dispatchEvent(new GameEvent(GameEvent.CALL, "OnLackOfUnitsError", [currentDeck.dbCountCards(CardTemplate.CardType_Creature, CardTemplate.CardEffect_None)]));
							}
							else if (gwintGamePending)
							{
								closeMenu();
							}
						}
					}
					else if ((details.code == KeyCode.NUMBER_1 || details.code == KeyCode.NUMPAD_1 || details.code == KeyCode.PAGE_DOWN) && keyUp && !isInZoomMode)
					{
						changeDeckIndex(false);
					}
					else if ((details.code == KeyCode.NUMBER_3 || details.code == KeyCode.NUMPAD_3 || details.code == KeyCode.PAGE_UP) && keyUp && !isInZoomMode)
					{
						changeDeckIndex(true);
					}
					else
					{
						switch (details.navEquivalent)
						{
							case NavigationCode.GAMEPAD_B:
								if (keyUp && !mcChoiceDialog.visible && !isInZoomMode)
								{
									tryClose();
								}
								break;
							case NavigationCode.GAMEPAD_X:
								if (keyUp && !isInZoomMode)
								{
									startChooseModeLeader();
								}
								break;
							case NavigationCode.LEFT:
								if (keyDown && !isInZoomMode)
								{
									currentModuleIdx--;
									resetToDefaultButtons();
								}
								break;
							case NavigationCode.RIGHT:
								if (keyDown && !isInZoomMode)
								{
									currentModuleIdx++;
									resetToDefaultButtons();
								}
								break;
							case NavigationCode.GAMEPAD_L1:
								if (keyUp && !isInZoomMode)
								{
									changeDeckIndex(false);
								}
								break;
							case NavigationCode.GAMEPAD_R1:
								if (keyUp && !isInZoomMode)
								{
									changeDeckIndex(true);
								}
								break;
							case NavigationCode.GAMEPAD_R2:
								if (keyUp)
								{
									if (!isInZoomMode)
									{
										tryZoomCard();
									}
								}
								break;
						}
					}
					
					if (details.value == InputValue.KEY_DOWN && !isInZoomMode)
					{
						switch (details.navEquivalent)
						{
							case NavigationCode.RIGHT_STICK_LEFT:
								currentModuleIdx--;
								resetToDefaultButtons();
								break;
							case NavigationCode.RIGHT_STICK_RIGHT:
								currentModuleIdx++;
								resetToDefaultButtons();
								break;
						}
					}
				}
			}
		}
		
		protected function tryClose():void
		{
			if (!gwintGamePending)
			{
				closeMenu();
			}
			else
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfirmSurrender" ) );
			}
		}
		
		protected function handleClosePressed( event : ButtonEvent ) : void
		{
			tryClose();
		}
		
		protected function handlePrevButtonPress( event : ButtonEvent ) : void
		{
			if (!isInZoomMode)
			{
				changeDeckIndex(false);
			}
		}
		
		protected function handleNextButtonPress( event : ButtonEvent ) : void
		{
			if (!isInZoomMode)
			{
				changeDeckIndex(true);
			}
		}
		
		protected function handleDeckSlotActivated(event:SlotActionEvent):void
		{	
			if (event.actionType == InventoryActionType.DROP || isInZoomMode)
			{
				return;
			}
			
			var targetSlot:CardSlot = event.targetSlot as CardSlot;
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnCardRemovedFromDeck", [ selectedDeckIndex, targetSlot.cardIndex ] ) );
			
			collectionDeck.dbAddCard(targetSlot.cardIndex);
			getSelectedDeck().dbRemoveCard(targetSlot.cardIndex);
			
			dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_gwint_discard_card"]));
			
			mcDeckStats.updateStats();
			updateStartGameButton();
		}
		
		protected function handleCollectionSlotActivated(event:SlotActionEvent):void
		{	
			if (event.actionType == InventoryActionType.DROP || isInZoomMode)
			{
				return;
			}
			
			var targetSlot:CardSlot = event.targetSlot as CardSlot;
			var selectedDeck:GwintDeck = getSelectedDeck();
			
			if (!selectedDeck || !selectedDeck.dbCanAddCard(targetSlot.cardIndex))
			{
				mcDeckStats.highlightSpecialCards();
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnTooManySpecialCards" ) );
				return;
			}
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnCardAddedToDeck", [ selectedDeckIndex, targetSlot.cardIndex ] ) );
			
			collectionDeck.dbRemoveCard(targetSlot.cardIndex);
			getSelectedDeck().dbAddCard(targetSlot.cardIndex);
			
			dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_gwint_draw_2"]));
			
			mcDeckStats.updateStats();
			updateStartGameButton();
			
			// #Y Hack
			if (mcTutorial.visible && getSelectedDeck().dbIsValidDeck())
			{
				mcTutorial.continueTutorial();
			}
		}
		
		protected var choosingLeader:Boolean = false;
		protected function startChooseModeLeader():void
		{
			if (choosingLeader)
			{
				return;
			}
			
			choosingLeader = true;
			
			if (mcChoiceDialog)
			{
				var selectedDeck:GwintDeck = getSelectedDeck();
				var choiceList:Vector.<int> = new Vector.<int>();
				var validLeaders:Vector.<int> = new Vector.<int>();
				var i:int;
				var x:int;
				var currentCardID:int;
				var cardManagerRef:CardManager = CardManager.getInstance();
				var currentCardTemplate:CardTemplate;
				var alreadyInList:Boolean;
				var currentLeaderIndex:int = -1;
				
				for (i = 0; i < leaderCollectionInfo.length; ++i)
				{
					validLeaders.push(leaderCollectionInfo[i].cardID);
				}
				
				switch (selectedDeck.getDeckFaction())
				{
				case CardTemplate.FactionId_Nilfgaard:
					choiceList.push(2001);
					choiceList.push(2002);
					choiceList.push(2003);
					choiceList.push(2004);
					choiceList.push(2005);
					break;
				case CardTemplate.FactionId_No_Mans_Land:
					choiceList.push(4001);
					choiceList.push(4002);
					choiceList.push(4003);
					choiceList.push(4004);
					choiceList.push(4005);
					break;
				case CardTemplate.FactionId_Northern_Kingdom:
					choiceList.push(1001);
					choiceList.push(1002);
					choiceList.push(1003);
					choiceList.push(1004);
					choiceList.push(1005);
					break;
				case CardTemplate.FactionId_Scoiatael:
					choiceList.push(3001);
					choiceList.push(3002);
					choiceList.push(3003);
					choiceList.push(3004);
					choiceList.push(3005);
					break;
				case CardTemplate.FactionId_Skellige:
					choiceList.push(5001);
					choiceList.push(5002);
					break;
				}
				
				if (choiceList.length > 0)
				{
					resetInputFeedbackButtons();
					
					mcChoiceDialog.showDialogCardTemplates(choiceList, leaderChosenCb, cancelChoiceCb, "[[gwint_deckbuilder_choose_leader]]");
					mcDeckHolder._inputEnabled = false;
					mcCollectionHolder._inputEnabled = false;
					
					isInZoomMode = true;
					
					var cardSlot:CardSlot;
					for (i = 0; i < mcChoiceDialog.cardsCarousel.getRenderersLength(); ++i)
					{
						cardSlot = mcChoiceDialog.cardsCarousel.getRendererAt(i) as CardSlot;
						
						if (cardSlot)
						{
							if (cardSlot.cardIndex == getSelectedDeck().selectedKingIndex)
							{
								currentLeaderIndex = i;
							}
							
							if (validLeaders.indexOf(cardSlot.cardIndex) == -1)
							{
								cardSlot.activateEnabled = false;
							}
						}
					}
					
					if (currentLeaderIndex != -1)
					{
						mcChoiceDialog.cardsCarousel.selectedIndex = currentLeaderIndex;
					}
				}
				else
				{
					throw new Error("GFX [ERROR] - tried to show leader card choice but couldn't find any which is WIERD");
				}
			}
		}
		
		protected function leaderChosenCb(templateID:int = -1):void
		{
			choosingLeader = false;
			mcChoiceDialog.hideDialog();
			mcDeckHolder._inputEnabled = true;
			mcCollectionHolder._inputEnabled = true;
			isInZoomMode = false;
			
			getSelectedDeck().selectedKingIndex = templateID;
			
			if (mcLeaderCard)
			{
				mcLeaderCard.cardIndex = templateID;
			}
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnLeaderChanged", [ selectedDeckIndex, templateID ] ) );
			
			resetToDefaultButtons();
		}
		
		protected function cancelChoiceCb():void
		{
			choosingLeader = false;
			mcChoiceDialog.hideDialog();
			mcDeckHolder._inputEnabled = true;
			mcCollectionHolder._inputEnabled = true;
			isInZoomMode = false;
			
			resetToDefaultButtons();
		}
		
		protected function resetToDefaultButtons():void
		{
			if (isInZoomMode || (mcTutorial && mcTutorial.visible && !mcTutorial.isPaused))
			{
				return;
			}
			
			resetInputFeedbackButtons();
			
			if (gwintGamePending)
			{
				InputFeedbackManager.appendButtonById(GwintInputFeedback.startGame, NavigationCode.GAMEPAD_Y, KeyCode.ENTER, "gwint_deckbuilder_start_game");
				InputFeedbackManager.appendButtonById(GwintInputFeedback.quitGame, NavigationCode.GAMEPAD_B, -1, "gwint_pass_game");
			}
			else
			{
				InputFeedbackManager.appendButtonById(GwintInputFeedback.closeDeckbuilder, NavigationCode.GAMEPAD_B, -1, "panel_button_common_close");
			}
			
			InputFeedbackManager.appendButtonById(GwintInputFeedback.choseLeader, NavigationCode.GAMEPAD_X, KeyCode.X, "gwint_deckbuilder_inputfeedback_changeleader");
			
			if (deckFactionList != null && deckFactionList.length > 1)
			{
				InputFeedbackManager.appendButtonById(GwintInputFeedback.changeDeck, NavigationCode.GAMEPAD_RBLB, -1, "gwint_deckbuilder_inputfeedback_changedeck");
			}
			
			if (mcDeckHolder.focused)
			{
				if (mcDeckHolder.isOpen && mcDeckHolder.mcCardSlotList.getSelectedRenderer() != null)
				{
					InputFeedbackManager.appendButtonById(GwintInputFeedback.openTab, NavigationCode.GAMEPAD_A, KeyCode.E, "gwint_deckbuilder_inputfeedback_removecard");
					InputFeedbackManager.appendButtonById(GwintInputFeedback.zoomCard, NavigationCode.GAMEPAD_R2, KeyCode.RIGHT_MOUSE, "panel_button_common_zoom");
				}
				else if (mcDeckHolder.canOpen())
				{
					InputFeedbackManager.appendButtonById(GwintInputFeedback.openTab, NavigationCode.GAMEPAD_A, -1, "inputfeedback_common_open_grid");
				}
			}
			else if (mcCollectionHolder.focused)
			{
				if (mcCollectionHolder.isOpen && mcCollectionHolder.mcCardSlotList.getSelectedRenderer() != null)
				{
					InputFeedbackManager.appendButtonById(GwintInputFeedback.openTab, NavigationCode.GAMEPAD_A, KeyCode.E, "gwint_deckbuilder_inputfeedback_addcard");
					InputFeedbackManager.appendButtonById(GwintInputFeedback.zoomCard, NavigationCode.GAMEPAD_R2, KeyCode.RIGHT_MOUSE, "panel_button_common_zoom");
				}
				else if (mcCollectionHolder.canOpen())
				{
					InputFeedbackManager.appendButtonById(GwintInputFeedback.openTab, NavigationCode.GAMEPAD_A, -1, "inputfeedback_common_open_grid");
				}
			}
		}
		
		protected function onSelectedCardChanged( event:ListEvent ):void
		{
			resetToDefaultButtons();
		}
		
		protected function tryZoomCard(targetCard:CardSlot = null, targetHolder:GwintDeckCTabModule = null):void
		{
			var cardHolder:GwintDeckCTabModule = null;
			var choiceList:Vector.<int> = new Vector.<int>();
			var i:int;
			var currentRenderer:CardSlot;
			var selectedIndex:int;
			
			if (isInZoomMode)
			{
				return;
			}
			
			if (targetCard != null)
			{
				choiceList.push(targetCard.cardIndex);
			}
			else
			{
				if (targetHolder != null)
				{
					cardHolder = targetHolder;
				}
				else if (mcDeckHolder.focused && mcDeckHolder.isOpen && mcDeckHolder.mcCardSlotList.getSelectedRenderer() != null)
				{
					cardHolder = mcDeckHolder;
				}
				else if (mcCollectionHolder.focused && mcCollectionHolder.isOpen && mcCollectionHolder.mcCardSlotList.getSelectedRenderer() != null)
				{
					cardHolder = mcCollectionHolder;
				}
				
				if (cardHolder != null)
				{
					for (i = 0; i < cardHolder.mcCardSlotList.getRenderersLength(); ++i)
					{
						currentRenderer = cardHolder.mcCardSlotList.getRendererAt(i) as CardSlot;
						
						if (currentRenderer)
						{
							choiceList.push(currentRenderer.cardIndex);
						}
					}
					
					selectedIndex = cardHolder.mcCardSlotList.selectedIndex;
				}
			}
			
			if (choiceList.length != 0)
			{
				resetInputFeedbackButtons();
				
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_gwint_preview_card"]));
				
				InputFeedbackManager.appendButtonById(GwintInputFeedback.zoomCard, NavigationCode.GAMEPAD_R2, KeyCode.RIGHT_MOUSE, "panel_button_common_close");
				
				isInZoomMode = true;
				
				trace("GFX -------------------------- Choice dialog called ---------------- ");
				mcChoiceDialog.showDialogCardTemplates(choiceList, null, closeZoomCB, "");
				mcChoiceDialog.cardsCarousel.validateNow();
				mcDeckHolder._inputEnabled = false;
				mcCollectionHolder._inputEnabled = false;
				
				if (selectedIndex != -1)
				{
					mcChoiceDialog.cardsCarousel.selectedIndex = selectedIndex;
				}
			}
		}
		
		protected function closeZoomCB(templateID:int = -1):void
		{
			var cardHolder:GwintDeckCTabModule = null;
			trace("GFX -------------------------- close zoom cb called ---------------- ");
			
			if (mcDeckHolder.focused && mcDeckHolder.isOpen && mcDeckHolder.mcCardSlotList.getSelectedRenderer() != null)
			{
				cardHolder = mcDeckHolder;
			}
			else if (mcCollectionHolder.focused && mcCollectionHolder.isOpen && mcCollectionHolder.mcCardSlotList.getSelectedRenderer() != null)
			{
				cardHolder = mcCollectionHolder;
			}
			
			if (cardHolder != null)
			{
				cardHolder.mcCardSlotList.selectedIndex = mcChoiceDialog.cardsCarousel.selectedIndex;
			}
			
			dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_gwint_preview_card"]));
			
			isInZoomMode = false;
			
			mcChoiceDialog.hideDialog();
			mcDeckHolder._inputEnabled = true;
			mcCollectionHolder._inputEnabled = true;
			
			resetToDefaultButtons();
		}
		
		protected function onCarouselSelectionChanged( event:ListEvent ):void
		{
			if (isInZoomMode && !choosingLeader)
			{
				var cardHolder:GwintDeckCTabModule = null;
				
				if (mcDeckHolder.focused && mcDeckHolder.isOpen && mcDeckHolder.mcCardSlotList.getSelectedRenderer() != null)
				{
					cardHolder = mcDeckHolder;
				}
				else if (mcCollectionHolder.focused && mcCollectionHolder.isOpen && mcCollectionHolder.mcCardSlotList.getSelectedRenderer() != null)
				{
					cardHolder = mcCollectionHolder;
				}
				
				if (cardHolder != null)
				{
					cardHolder.mcCardSlotList.selectedIndex = event.index;
				}
			}
		}
		
		protected function showTutCarousel():void
		{
			startChooseModeLeader();
			mcChoiceDialog.inputEnabled = false;
			resetInputFeedbackButtons();
		}
		
		protected function hideTutCarousel():void
		{
			choosingLeader = false;
			mcChoiceDialog.hideDialog();
			isInZoomMode = false;
		}
		
		protected function clearMouseEnabledOnTextFieldsInDeckStats():void
		{
			if (mcDeckStats)
			{
				var currentTextfield:TextField;
				for (var i:int = i; i < mcDeckStats.numChildren; ++i)
				{
					currentTextfield = mcDeckStats.getChildAt(i) as TextField;
					
					if (currentTextfield)
					{
						currentTextfield.mouseEnabled = false;
					}
				}
			}
		}
		
		protected function resetInputFeedbackButtons():void
		{
			InputFeedbackManager.cleanupButtons();
			InputFeedbackManager.appendButtonById(GwintInputFeedback.navigate, NavigationCode.GAMEPAD_L3, -1, "panel_button_common_navigation");
		}
		
		// --------------------------------------------------------------------------------------------
		// Mouse stuff
		// --------------------------------------------------------------------------------------------
		
		protected var _leaderCardHovered:Boolean = false;
		protected function setupLeaderCard():void
		{
			if (mcLeaderCard)
			{
				mcLeaderCard.addEventListener(CardSlot.CardMouseOver, onLeaderMouseOver, false, 0, true);
				mcLeaderCard.addEventListener(CardSlot.CardMouseOut, onLeaderMouseOut, false, 0, true);
				//mcLeaderCard.addEventListener(CardSlot.CardMouseLeftClick, onLeaderMouseLeftClick, false, 0, true);
				mcLeaderCard.addEventListener(CardSlot.CardMouseRightClick, onLeaderMouseRightClick, false, 0, true);
				mcLeaderCard.addEventListener(CardSlot.CardMouseDoubleClick, onLeaderMouseDoubleClick, false, 0, true);
			}
		}
		
		protected function onLeaderMouseOver(e:Event):void
		{
			_leaderCardHovered = true;
			if (!InputManager.getInstance().isGamepad())
			{
				mcLeaderCard.selected = true;
			}
		}
		
		protected function onLeaderMouseOut(e:Event):void
		{
			_leaderCardHovered = false;
			if (!InputManager.getInstance().isGamepad())
			{
				mcLeaderCard.selected = false;
			}
		}
		
		//protected function onLeaderMouseLeftClick(e:Event):void
		//{
		//}
		
		protected function onLeaderMouseRightClick(e:Event):void
		{
			if (!isInZoomMode)
			{
				tryZoomCard(mcLeaderCard);
				mcChoiceDialog.ignoreNextRightClick = true;
			}
		}
		
		protected function onLeaderMouseDoubleClick(e:Event):void
		{
			if (!isInZoomMode && !choosingLeader)
			{
				startChooseModeLeader();
			}
		}
		
		protected function handleControllerChange(event:ControllerChangeEvent):void
		{
			if (event.isGamepad)
			{
				if (mcLeaderCard && mcLeaderCard.selected)
				{
					mcLeaderCard.selected = false;
				}
			}
			else
			{
				if (mcLeaderCard && _leaderCardHovered)
				{
					mcLeaderCard.selected = true;
				}
			}
		}
		 
		protected function onCollectionRightClickCard(event:Event):void
		{
			trace("GFX ------------------------------------- Received Collection Right click ");
			if (!isInZoomMode)
			{
				if (mcCollectionHolder.mcCardSlotList.selectedIndex != -1)
				{
					trace("GFX --------- OK ------------"); 
					tryZoomCard(null, mcCollectionHolder);
					mcChoiceDialog.ignoreNextRightClick = true;
				}
			}
		}
		
		protected function onDeckRightClickCard(event:Event):void
		{
			trace("GFX ------------------------------------- Received Deck Right click ");
			if (!isInZoomMode)
			{
				if (mcDeckHolder.mcCardSlotList.selectedIndex != -1)
				{
					tryZoomCard(null, mcDeckHolder);
					mcChoiceDialog.ignoreNextRightClick = true;
				}
			}
		}
	}
}
