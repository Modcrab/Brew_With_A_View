package red.game.witcher3.menus.gwint
{
	import com.gskinner.motion.GTween;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import red.game.witcher3.events.GwintCardEvent;
	import red.game.witcher3.events.GwintHolderEvent;
	import red.game.witcher3.slots.SlotBase;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import red.core.constants.KeyCode;
	
	public class GwintCardHolder extends SlotBase
	{
		protected var _cardHolderID:int = CardManager.CARD_LIST_LOC_INVALID;
		[Inspectable(defaultValue=CardManager.CARD_LIST_LOC_INVALID)]
		public function get cardHolderID():int { return _cardHolderID; }
		public function set cardHolderID(value:int):void
		{
			_cardHolderID = value;
		}
		
		protected var _playerID:int = CardManager.PLAYER_INVALID;
		[Inspectable(defaultValue=CardManager.PLAYER_INVALID)]
		public function get playerID():int { return _playerID; }
		public function set playerID(value:int):void
		{
			_playerID = value;
		}
		
		protected var _uniqueID:int = 0;
		[Inspectable(defaultValue=0)]
		public function get uniqueID():int { return _uniqueID; }
		public function set uniqueID(value:int):void
		{
			_uniqueID = value;
		}
		
		protected var _paddingX:int = 3;
		[Inspectable(defaultValue=3)]
		public function get paddingX():int { return _paddingX; }
		public function set paddingX(value:int):void
		{
			_paddingX = value;
		}
		
		protected var _paddingY:int = 5;
		[Inspectable(defaultValue=5)]
		public function get paddingY():int { return _paddingY; }
		public function set paddingY(value:int):void
		{
			_paddingY = value;
		}
		
		public var boardRendererRef:GwintBoardRenderer;
		
		public var mcHighlight:MovieClip;
		public var mcSelected:MovieClip;
		public var mcStatus:MovieClip; // Used for leader slots
		
		public var cardSlotsList:Vector.<CardSlot> = new Vector.<CardSlot>();
		protected var _selectedCardIdx:int = -1;
		public var newlySpawnedCards:Vector.<CardSlot> = new Vector.<CardSlot>();
		
		protected var centerX:int;
		
		protected var _disableNavigation:Boolean;
		public function get disableNavigation():Boolean { return _disableNavigation }
		public function set disableNavigation(value:Boolean):void
		{
			_disableNavigation = value;
		}
		
		protected var _cardSelectionEnabled:Boolean = true;
		public function get cardSelectionEnabled():Boolean { return _cardSelectionEnabled; }
		public function set cardSelectionEnabled(value:Boolean)
		{
			_cardSelectionEnabled = value;
			updateCardSelectionAvailable();
		}
		
		protected var _alwaysHighlight:Boolean = false;
		public function set alwaysHighlight(value:Boolean):void
		{
			if (_alwaysHighlight == value)
			{
				return;
			}
			
			_alwaysHighlight = value;
			
			if (mcHighlight)
			{
				if (mcSelected)
				{
					if (mcSelected.visible)
					{
						mcHighlight.visible = false;
					}
					else
					{
						mcHighlight.visible = _alwaysHighlight
					}
				}
				else
				{
					mcHighlight.visible = _alwaysHighlight;
				}
			}
		}
		
		public function handleMouseMove(stageX:Number, stageY:Number):Boolean
		{
			if (cardHolderID == CardManager.CARD_LIST_LOC_HAND && playerID == CardManager.PLAYER_2) // Disabling selection of enemy hand
			{
				return false;
			}
			
			var i:int;
			var currentCardSlot:CardSlot;
			for (i = 0; i < cardSlotsList.length; ++i)
			{
				currentCardSlot = cardSlotsList[i] as CardSlot;
				
				if (currentCardSlot && currentCardSlot.mcHitBox.hitTestPoint(stageX, stageY))
				{
					selectedCardIdx = i;
					return true;
				}
			}
			
			selectedCardIdx = -1;
			
			return hitTestPoint(stageX, stageY);
		}
		
		protected function updateCardSelectionAvailable()
		{
			var i:int;
			var currentCard:CardSlot;
			
			for (i = 0; i < cardSlotsList.length; ++i)
			{
				currentCard = cardSlotsList[i];
				
				if (currentCard)
				{
					currentCard.activeSelectionEnabled = _cardSelectionEnabled && selected;
				}
			}
			
			updateDrawOrder();
		}
		
		private var _lastSelectedCard:CardSlot;
		public function get selectedCardIdx():int { return _selectedCardIdx }
		public function set selectedCardIdx(value:int):void
		{	
			if (value == -1 && _lastSelectedCard == null)
			{
				return;
			}
			
			if (_lastSelectedCard != null && cardSlotsList.indexOf(_lastSelectedCard) != -1)
			{
				if (cardSlotsList[value] == _lastSelectedCard)
				{
					if (!_lastSelectedCard.selected)
					{
						_lastSelectedCard.selected = true;
					}
					_selectedCardIdx = value;
					return; // No update neccessary when same card selected
				}
				
				_lastSelectedCard.selected = false;
			}
			
			if (value < 0 || value >= cardSlotsList.length)
			{
				value = -1;
			}
			else
			{
				value = value;
			}
			
			if (value != -1)
			{
				_selectedCardIdx = value;
				_lastSelectedCard = cardSlotsList[_selectedCardIdx];
				_lastSelectedCard.selected = true;
				dispatchEvent(new GwintCardEvent(GwintCardEvent.CARD_SELECTED, true, false, _lastSelectedCard, this));
			}
			else if (selected)
			{
			}
			
			updateDrawOrder();
		}
		
		public function selectCardInstance(cardInstance:CardInstance):void
		{
			var i:int;
			
			for (i = 0; i < cardSlotsList.length; ++i)
			{
				if (cardSlotsList[i].cardInstance == cardInstance)
				{
					selectedCardIdx = i;
					return;
				}
			}
			
			throw new Error("GFX [ERROR] - tried to select card in slot: (" + cardHolderID + ", " + playerID + "), but could could not find reference to: " + cardInstance);
		}
		
		public function selectCard(cardSlot:CardSlot):void
		{
			var indexOf:int = cardSlotsList.indexOf(cardSlot);
			
			if (indexOf != -1)
			{
				selectedCardIdx = indexOf;
			}
			else
			{
				throw new Error("GFX [ERROR] - tried to select card in slot: (" + cardHolderID + ", " + playerID + "), but could could not find reference to: " + cardSlot);
			}
		}
		
		public function findSelection():void
		{
			if (selectedCardIdx < 0)
			{
				selectedCardIdx = 0;
			}
		}
		
		public function getSelectedCardSlot():CardSlot
		{
			if (_selectedCardIdx >= 0 && _selectedCardIdx < cardSlotsList.length)
			{
				return cardSlotsList[_selectedCardIdx];
			}
			
			return null;
		}
		
		override public function set selected(value:Boolean):void
		{
			if (!boardRendererRef || value == selected)
			{
				return;
			}
			
			super.selected = value;
			
			if (value)
			{
				if (mcSelected != null)
				{
					mcSelected.visible = true;
				}
				mcHighlight.visible = false;
				
				dispatchEvent(new GwintHolderEvent(GwintHolderEvent.HOLDER_SELECTED, true, false, this));
				
				if (selectedCardIdx == -1 && cardSlotsList.length > 0)
				{
					selectedCardIdx = 0;
				}
			}
			else
			{
				if (mcSelected != null)
				{
					mcSelected.visible = false;
				}
				mcHighlight.visible = _alwaysHighlight;
			}
			
			updateCardSelectionAvailable();
			
			updateDrawOrder();
		}
		
		override public function set selectable(value:Boolean):void 
		{
			super.selectable = value;
			if (selectable && enabled && mcSelected)	
			{
				mcSelected.visible = selected;
			}
			else 
			if (!selectable && mcSelected)
			{
				mcSelected.visible = false;
			}
		}
		
		public function selectFirstValid(castingCard:CardInstance):void
		{
			_selectedCardIdx = -1;
			
			for (var i:int = 0; i < cardSlotsList.length; ++i)
			{
				if (castingCard.canBeCastOn(cardSlotsList[i].cardInstance))
				{
					selectedCardIdx = i;
					break;
				}
			}
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			if (mcHighlight)
			{
				mcHighlight.visible = false;
				mcHighlight.stop();
			}
			if (mcSelected)
			{
				mcSelected.visible = false;
			}
			if (mcStatus)
			{
				mcStatus.visible = false;
			}
		}
		
		public function updateLeaderStatus(playerTurn:Boolean):void
		{
			var currentCardSlot:CardSlot = null;
			
			if (cardSlotsList.length > 0)
			{
				currentCardSlot = cardSlotsList[0] as CardSlot;
			}
			
			if (!currentCardSlot)
			{
				return;
			}
			
			var currentLeaderCard:CardLeaderInstance = currentCardSlot.cardInstance as CardLeaderInstance;
			
			if (!currentLeaderCard)
			{
				return;
			}
			
			if (currentLeaderCard.hasBeenUsed)
			{
				mcStatus.visible = false;
				
				if (currentCardSlot)
				{
					currentCardSlot.darkenIcon(0.3);
				}
			}
			else
			{
				if (currentCardSlot)
				{
					currentCardSlot.filters = [];
				}
				
				if (mcStatus)
				{
					if (playerTurn)
					{
						mcStatus.visible = true;
						
						if (currentLeaderCard.canBeUsed)
						{
							mcStatus.gotoAndStop(1);
						}
						else
						{
							mcStatus.gotoAndStop(2);
						}
					}
					else
					{
						mcStatus.visible = false;
					}
				}
			}
		}
		
		override public function handleInput(event:InputEvent):void 
		{
			super.handleInput(event);
			
			var details:InputDetails = event.details;
			var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			var navCommand:String = details.navEquivalent;
			
			if (keyPress)
			{
				switch (navCommand)
				{		
					case NavigationCode.LEFT:
						
						if (cardHolderID != CardManager.CARD_LIST_LOC_GRAVEYARD)
						{
							if ((selectedCardIdx > 0) && !_disableNavigation && (cardSlotsList.length > 0))
							{
								selectedCardIdx--;
								event.handled = true;
							}
						}
						break;
						
					case NavigationCode.RIGHT:
						
						if (cardHolderID != CardManager.CARD_LIST_LOC_GRAVEYARD)
						{
							if ((selectedCardIdx < (cardSlotsList.length - 1)) && !_disableNavigation && (cardSlotsList.length > 0))
							{
								selectedCardIdx++;
								event.handled = true;
							}
						}
						break;
				}
			}
			
			if (details.value == InputValue.KEY_UP && navCommand == NavigationCode.GAMEPAD_A && details.code != KeyCode.SPACE)
			{
				handleActivatePressed();
			}
		}
		
		public function handleLeftClick(event:MouseEvent):void
		{
			handleActivatePressed();
		}
		
		protected function handleActivatePressed():void
		{
			var selectedCard:CardSlot;
			if (selectedCardIdx > -1 && selectedCardIdx < cardSlotsList.length)
			{
				selectedCard = cardSlotsList[selectedCardIdx];
			}
			if (selectedCard)
			{
				dispatchEvent(new GwintCardEvent(GwintCardEvent.CARD_CHOSEN, true, false, selectedCard, this));
			}
			dispatchEvent(new GwintHolderEvent(GwintHolderEvent.HOLDER_CHOSEN, true, false, this));
		}
		
		// Used by things like the deck slot to make cards appear at correct position, no animation. Does not add them to the list
		public function spawnCard(newCard:CardSlot):void
		{
			if (cardHolderID == CardManager.CARD_LIST_LOC_MELEE || 
					 cardHolderID == CardManager.CARD_LIST_LOC_SEIGE || 
					 cardHolderID == CardManager.CARD_LIST_LOC_RANGED ||
					 cardHolderID == CardManager.CARD_LIST_LOC_HAND)
			{
				newlySpawnedCards.push(newCard);
			}
			else
			{
				newCard.x = this.x;
				newCard.y = this.y;
			}
		}
		
		protected function cardSorter(e1:CardSlot, e2:CardSlot):Number
		{
			//#J based on card Instance
			
			var cardInstance1:CardInstance = e1.cardInstance;
			var cardInstance2:CardInstance = e2.cardInstance;
			
			if (cardInstance1.templateId == cardInstance2.templateId)
			{
				return 0;
			}
			
			var battlefield1:int = cardInstance1.templateRef.getCreatureType();
			var battlefield2:int = cardInstance2.templateRef.getCreatureType();
			
			if (battlefield1 == CardTemplate.CardType_None && battlefield2 == CardTemplate.CardType_None)
			{
				return cardInstance1.templateId - cardInstance2.templateId;
			}
			else if (battlefield1 == CardTemplate.CardType_None)
			{
				return -1;
			}
			else if (battlefield2 == CardTemplate.CardType_None)
			{
				return 1;
			}
			else
			{
				if (cardInstance1.templateRef.power != cardInstance2.templateRef.power)
				{
					return cardInstance1.templateRef.power - cardInstance2.templateRef.power;
				}
				else
				{
					return cardInstance1.templateId - cardInstance2.templateId;
				}
			}
		}
		
		public function cardAdded(newCard:CardSlot):void
		{
			var currentCard:CardSlot;
			
			if (selectedCardIdx != -1 && selectedCardIdx < cardSlotsList.length)
			{
				currentCard = cardSlotsList[selectedCardIdx];
			}
			
			cardSlotsList.push(newCard);
			
			cardSlotsList.sort(cardSorter);
			
			// After the sort, the card index of the currently selected card may have changed. We must update it to prevent bugs like 
			// TTP#85471 - [Editor][Game] Cannot select newly added card by Northern Kingdom Ability
			if (currentCard != null)
			{
				var targetIndex:int = cardSlotsList.indexOf(currentCard);
				
				if (targetIndex != selectedCardIdx)
				{
					selectedCardIdx = targetIndex;
				}
			}
			
			repositionAllCards();
			
			newCard.activeSelectionEnabled = selected && _cardSelectionEnabled;
			
			// Transfers the selection to this card properly.
			if (newCard.selected) // #J Might cause problems on PC mouse controls
			{
				newCard.selected = false;
			}
			
			updateWeatherEffects();
			
			registerCard(newCard);
		}
		
		public function cardRemoved(newCard:CardSlot):void
		{
			unregisterCard(newCard);
			
			var indexOf:int = cardSlotsList.indexOf(newCard);
			if (indexOf != -1)
			{
				cardSlotsList.splice(indexOf, 1);
				findCardSelection(indexOf >= _selectedCardIdx);
			}
			repositionAllCards();
			updateWeatherEffects();
		}
		
		protected function registerCard(targetCard:CardSlot):void
		{
			if (targetCard)
			{
				//targetCard.addEventListener(CardSlot.CardMouseOver, onCardMouseOver, false, 0, true);
				//targetCard.addEventListener(CardSlot.CardMouseOut, onCardMouseOut, false, 0, true);
				//targetCard.addEventListener(CardSlot.CardMouseLeftClick, onCardLeftClick, false, 0, true);
				//targetCard.addEventListener(CardSlot.CardMouseRightClick, onCardRightClick, false, 0, true);
				//targetCard.addEventListener(CardSlot.CardMouseDoubleClick, onCardDoubleClick, false, 0, true);
			}
		}
		
		protected function unregisterCard(targetCard:CardSlot):void
		{
			if (targetCard)
			{
				//targetCard.removeEventListener(CardSlot.CardMouseOver, onCardMouseOver);
				//targetCard.removeEventListener(CardSlot.CardMouseOut, onCardMouseOut);
				//targetCard.removeEventListener(CardSlot.CardMouseLeftClick, onCardLeftClick);
				//targetCard.removeEventListener(CardSlot.CardMouseRightClick, onCardRightClick);
				//targetCard.removeEventListener(CardSlot.CardMouseDoubleClick, onCardDoubleClick);
			}
		}
		
		protected function onCardMouseOver(event:Event):void
		{
			var currentTarget:CardSlot = event.target as CardSlot;
			if (currentTarget)
			{
				var targetIndex:int = cardSlotsList.indexOf(currentTarget);
				
				if (targetIndex != -1)
				{
					selectedCardIdx = targetIndex;
				}
			}
		}
		
		protected function onCardMouseOut(event:Event):void
		{
			var currentTarget:CardSlot = event.target as CardSlot;
			if (currentTarget)
			{
				var targetIndex:int = cardSlotsList.indexOf(currentTarget);
				
				if (targetIndex != -1)
				{
					selectedCardIdx = -1;
				}
			}
		}
		
		protected function updateWeatherEffects():void
		{
			if (boardRendererRef && cardHolderID == CardManager.CARD_LIST_LOC_WEATHERSLOT)
			{
				var hasMeleeEffect:Boolean = false;
				var hasRangedEffect:Boolean = false;
				var hasSiegeEffect:Boolean = false;
				var i:int;
				var currentSlot:CardSlot;
				
				for (i = 0; i < cardSlotsList.length; ++i)
				{
					currentSlot = cardSlotsList[i];
					
					for each (var effectID:int in currentSlot.cardInstance.templateRef.effectFlags)
					{
						switch (effectID)
						{
							case CardTemplate.CardEffect_Melee:
								hasMeleeEffect = true;
								break;
							case CardTemplate.CardEffect_Ranged:
								hasRangedEffect = true;
								break;
							case CardTemplate.CardEffect_Siege:
								hasSiegeEffect = true;
								break;
						}
					}
				}
				
				var cardFXManagerRef:CardFXManager = CardFXManager.getInstance();
				
				cardFXManagerRef.ShowWeatherOngoing(CardManager.CARD_LIST_LOC_MELEE, hasMeleeEffect);
				cardFXManagerRef.ShowWeatherOngoing(CardManager.CARD_LIST_LOC_RANGED, hasRangedEffect);
				cardFXManagerRef.ShowWeatherOngoing(CardManager.CARD_LIST_LOC_SEIGE, hasSiegeEffect);
			}
		}
		
		protected function findCardSelection(backward:Boolean):void
		{
			// #Y TODO: Update selected card index
			/*if (backward)
			{
				// #Y TODO: Move selection
			}
			else
			{*/
				selectedCardIdx = Math.max(0, Math.min(cardSlotsList.length - 1, _selectedCardIdx));
			//}
		}
		
		public function repositionAllCards():void
		{
			if (cardHolderID == CardManager.CARD_LIST_LOC_GRAVEYARD)
			{
				repositionAllCards_Graveyard();
			}
			else if (cardHolderID == CardManager.CARD_LIST_LOC_MELEE || 
					 cardHolderID == CardManager.CARD_LIST_LOC_SEIGE || 
					 cardHolderID == CardManager.CARD_LIST_LOC_RANGED ||
					 cardHolderID == CardManager.CARD_LIST_LOC_HAND)
			{
				repositionAllCards_Standard(true);
			}
			else
			{
				repositionAllCards_Standard(false);
			}
		}
		
		private function repositionAllCards_Graveyard():void
		{
			var cardTweener:CardTweenManager = CardTweenManager.getInstance();
			
			if (cardSlotsList.length == 0 || !cardTweener)
			{
				return;
			}
			
			var i:int;
			var curCardSlot:CardSlot;
			var godCardHolder:MovieClip = cardSlotsList[0].parent as MovieClip;
			
			// Applies a 1 x and 2 y offset to each card going upward to create a pile effect
			var curX:Number = this.x + this.width / 2;
			curX -= (cardSlotsList.length - 1) * 1;
			var curY:Number = this.y + this.height / 2;
			curY -= (cardSlotsList.length - 1) * 2;
			
			for (i = 0; i < cardSlotsList.length; ++i)
			{
				curCardSlot = cardSlotsList[i];
				godCardHolder.addChildAt(curCardSlot, 0); // Move it to the back as we go through the list so they are rendered in the order they are in the graveyard
				cardTweener.tweenTo(curCardSlot, curX, curY, onPositionCardEnded);
				curX += 1;
				curY += 2;
			}
		}
		
		private function repositionAllCards_Standard(allowOverlap:Boolean):void
		{
			var cardTweener:CardTweenManager = CardTweenManager.getInstance();
			
			if (!cardTweener)
			{
				throw new Error("GFX -- Trying to reposition all cards but the CardTweenManager instance does not exist !!!");
			}
			
			if (cardSlotsList.length > 0)
			{
				var totalWidth:int = (cardSlotsList.length - 1) * _paddingX + cardSlotsList.length * CardSlot.CARD_BOARD_WIDTH;
				
				var curX:int = this.x + this.width / 2 - totalWidth / 2;
				var stepX:int = CardSlot.CARD_BOARD_WIDTH + _paddingX;
				
				if (cardHolderID == CardManager.CARD_LIST_LOC_LEADER)
				{
					curX = this.x + mcSelected.width / 2 - totalWidth / 2;
				}
				
				if (allowOverlap && totalWidth > this.width)
				{
					stepX -= (totalWidth - this.width) / (cardSlotsList.length - 1);
					curX = this.x;
				}
				
				curX += CardSlot.CARD_BOARD_WIDTH / 2; // #J Since they are centered ><
				
				var i:int;
				var currentCard:CardSlot;
				var targetY:Number = this.y + this.height / 2;
				
				for (i = 0; i < cardSlotsList.length; ++i)
				{
					currentCard = cardSlotsList[i];
					
					var foundInNewlySpawned:Boolean = false;
					if (currentCard.cardInstance.InstancePositioning)
					{
						foundInNewlySpawned = true;
						currentCard.x = curX;
						currentCard.y = targetY;
					}
					else
					{
						for (var p:int = 0; p < newlySpawnedCards.length; ++p)
						{
							if (newlySpawnedCards[p] == currentCard)
							{
								foundInNewlySpawned = true;
								currentCard.x = curX;
								currentCard.y = targetY;
								newlySpawnedCards.splice(p, 1);
								break;
							}
						}
					}
					
					if (!foundInNewlySpawned)
					{
						cardTweener.tweenTo(currentCard, curX, targetY, onPositionCardEnded);
					}
					
					curX += stepX; 
				}
				
				updateDrawOrder();
			}
		}
		
		private function updateDrawOrder():void 
		{
			var i:int;
			
			var curCardSlot:CardSlot;
			
			// Update z order
			if (cardHolderID == CardManager.CARD_LIST_LOC_GRAVEYARD)
			{
				for (i  = (cardSlotsList.length - 1); i >= 0; --i)
				{
					curCardSlot = cardSlotsList[i];
					curCardSlot.parent.addChild(curCardSlot);
				}
			}
			else
			{
				for (i  = 0; i < cardSlotsList.length; ++i)
				{
					curCardSlot = cardSlotsList[i];
					curCardSlot.parent.addChild(curCardSlot);
				}
			}
			
			curCardSlot = getSelectedCardSlot();
			if (selected && curCardSlot != null && cardSelectionEnabled)
			{
				curCardSlot.parent.addChild(curCardSlot);
			}
		}
		
		public function onPositionCardEnded(finishedTween:GTween):void
		{
			var cardManagerRef:CardManager = CardManager.getInstance();
			var cardInstanceRef:CardInstance = cardManagerRef.getCardInstance((finishedTween.target as CardSlot).instanceId);
			
			if (cardInstanceRef)
			{
				cardInstanceRef.onFinishedMovingIntoHolder(_cardHolderID, _playerID);
			}
		}
		
		
		public function clearAllCards():void
		{
			cardSlotsList.length = 0;
		}
	}
}
