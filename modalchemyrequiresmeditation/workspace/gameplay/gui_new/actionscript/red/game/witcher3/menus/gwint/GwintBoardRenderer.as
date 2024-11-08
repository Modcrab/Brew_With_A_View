package red.game.witcher3.menus.gwint
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import red.game.witcher3.controls.W3TextArea;
	import red.game.witcher3.events.GwintHolderEvent;
	import red.game.witcher3.slots.SlotsListBase;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.events.InputEvent;
	import scaleform.gfx.MouseEventEx;
	
	public class GwintBoardRenderer extends SlotsListBase
	{
		public var mcGodCardHolder:MovieClip;
		public var mcTransitionAnchor:MovieClip;
		
		public var rowScoreP2Seige:MovieClip;
		public var rowScoreP2Ranged:MovieClip;
		public var rowScoreP2Melee:MovieClip;
		public var rowScoreP1Melee:MovieClip;
		public var rowScoreP1Ranged:MovieClip;
		public var rowScoreP1Seige:MovieClip;
		
		public var mcP1LeaderHolder:GwintCardHolder;
		public var mcP2LeaderHolder:GwintCardHolder;
		
		public var mcP1Deck:GwintCardHolder;
		public var mcP2Deck:GwintCardHolder;
		
		public var mcP1Hand:GwintCardHolder;
		public var mcP2Hand:GwintCardHolder;
		
		public var mcP1Graveyard:GwintCardHolder;
		public var mcP2Graveyard:GwintCardHolder;
		
		public var mcP1Siege:GwintCardHolder;
		public var mcP2Siege:GwintCardHolder;
		
		public var mcP1Range:GwintCardHolder;
		public var mcP2Range:GwintCardHolder;
		
		public var mcP1Melee:GwintCardHolder;
		public var mcP2Melee:GwintCardHolder;
		
		public var mcP1SiegeModif:GwintCardHolder;
		public var mcP2SiegeModif:GwintCardHolder;
		
		public var mcP1RangeModif:GwintCardHolder;
		public var mcP2RangeModif:GwintCardHolder;
		
		public var mcP1MeleeModif:GwintCardHolder;
		public var mcP2MeleeModif:GwintCardHolder;
		
		public var mcWeather:GwintCardHolder;
		
		public var mcTransactionTooltip:MovieClip;
		
		private var cardManager:CardManager;
		private var allRenderers:Vector.<GwintCardHolder>;
		private var allCardSlotInstances:Dictionary = new Dictionary();
		
		public function getSelectedCardHolder():GwintCardHolder
		{
			if (selectedIndex == -1)
			{
				return null;
			}
			
			return getSelectedRenderer() as GwintCardHolder;
		}
		
		public function getSelectedCard():CardSlot
		{
			var curHolder:GwintCardHolder = getSelectedCardHolder();
			
			if (curHolder == null)
			{
				return null;
			}
			
			return curHolder.getSelectedCardSlot();
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			cardManager = CardManager.getInstance();
			CardManager.getInstance().boardRenderer = this;
			
			updateRowScores(0, 0, 0, 0, 0, 0);
			
			fillRenderersList();
			
			if (mcTransactionTooltip)
			{
				mcTransactionTooltip.visible = false;
				mcTransactionTooltip.alpha = 0;
			}
			setupCardHolders();
		}
		
		protected function setupCardHolders():void
		{
			setupCardHolder(mcP1Deck);
			setupCardHolder(mcP2Deck);
			
			setupCardHolder(mcP1Hand);
			setupCardHolder(mcP2Hand);
			
			setupCardHolder(mcP1Graveyard);
			setupCardHolder(mcP2Graveyard);
			
			setupCardHolder(mcP1Siege);
			setupCardHolder(mcP2Siege);
			
			setupCardHolder(mcP1Range);
			setupCardHolder(mcP2Range);
			
			setupCardHolder(mcP1Melee);
			setupCardHolder(mcP2Melee);
			
			setupCardHolder(mcP1SiegeModif);
			setupCardHolder(mcP2SiegeModif);
			
			setupCardHolder(mcP1RangeModif);
			setupCardHolder(mcP2RangeModif);
			
			setupCardHolder(mcP1MeleeModif);
			setupCardHolder(mcP2MeleeModif);
			
			setupCardHolder(mcP1LeaderHolder);
			setupCardHolder(mcP2LeaderHolder);
			
			setupCardHolder(mcWeather);
		}
		
		override public function handleInputPreset(event:InputEvent):void
		{
			if (selectedIndex < 0)
			{
				selectCardHolder(CardManager.CARD_LIST_LOC_HAND, CardManager.PLAYER_1);
			}
			
			var curHolder:GwintCardHolder = getSelectedRenderer() as GwintCardHolder;
			
			if (!curHolder)
			{
				for (var i:int = 0; i < _renderers.length; ++i)
				{
					curHolder = _renderers[i] as GwintCardHolder;
					
					if (curHolder && curHolder.selectable)
					{
						selectedIndex = i;
					}
					else
					{
						curHolder = null;
					}
				}
			}
			
			if (curHolder)
			{
				curHolder.handleInput(event);
			}
			
			if (!event.handled)
			{
				super.handleInputPreset(event);
			}
		}
		
		protected function fillRenderersList():void
		{
			allRenderers = new Vector.<GwintCardHolder>();
			var i:int;
			
			for (i = 0; i < numChildren; ++i)
			{
				if (getChildAt(i) is GwintCardHolder)
				{
					allRenderers.push(getChildAt(i));
				}
			}
			
			allRenderers.sort(cardHolderSorter);
			
			for (i = 0; i < allRenderers.length; ++i)
			{
				allRenderers[i].boardRendererRef = this;
				_renderers.push(allRenderers[i]);
			}
			_renderersCount = allRenderers.length;
		}
		
		protected function cardHolderSorter(element1:GwintCardHolder, element2:GwintCardHolder):Number
		{
			return element1.uniqueID - element2.uniqueID;
		}
		
		public function selectCardHolder(typeID:int, playerID:int):void
		{
			selectCardHolderAdv(getCardHolder(typeID, playerID));
		}
		
		public function selectCardHolderAdv(targetHolder:GwintCardHolder):void
		{
			if (targetHolder == null)
			{
				return;
			}
			
			var targetIdx:int = allRenderers.indexOf(targetHolder);
			if (targetIdx > -1)
			{
				selectedIndex = targetIdx;
				
				if (targetHolder.selectedCardIdx == -1)
				{
					targetHolder.selectedCardIdx = 0;
				}
			}
		}
		
		public function selectCardInstance(targetCard:CardInstance):void
		{
			if (targetCard)
			{
				var selectedCardsHolder:GwintCardHolder = getCardHolder(targetCard.inList, targetCard.listsPlayer);
				
				if (selectedCardsHolder)
				{
					selectCardHolderAdv(selectedCardsHolder);
					
					selectedCardsHolder.selectCardInstance(targetCard);
				}
				else
				{
					throw new Error("GFX [ERROR] - tried to select card with no matching card holder on board! list: " + targetCard.inList + ", listsPlayer: " + targetCard.listsPlayer);
				}
			}
			else
			{
				throw new Error("GFX [ERROR] - tried to select card slot with unknown card instance. Should not happen in this context: " + targetCard);
			}
		}
		
		public function flushNewlyAddedCards():void
		{
			for (var i:int = 0; i < allRenderers.length; ++i)
			{
				allRenderers[i].newlySpawnedCards.length = 0;
			}
		}
		
		public function selectCard(targetCard:CardSlot):void
		{
			var cardInstance:CardInstance = targetCard.cardInstance;
			
			selectCardInstance(cardInstance);
		}
		
		public function getCardHolder(typeID:int, playerID:int):GwintCardHolder
		{
			var i:int;
			var currentRenderer:GwintCardHolder;
			
			for (i = 0; i < allRenderers.length; ++i)
			{
				currentRenderer = allRenderers[i];
				if (currentRenderer.cardHolderID == typeID && currentRenderer.playerID == playerID)
				{
					return currentRenderer;
				}
			}
			return null;
		}
		
		public function activateAllHolders(value:Boolean):void
		{
			allRenderers.forEach(function(curHandler:GwintCardHolder) { curHandler.selectable = value; curHandler.disableNavigation = false; curHandler.cardSelectionEnabled = true; curHandler.alwaysHighlight = false; } );
		}
		
		public function activateHoldersForCard(cardInstance:CardInstance, selectFirstActive:Boolean = false):void
		{
			var currentRenderer:GwintCardHolder;
			var len:int = allRenderers.length;
			var validSlot:Boolean;
			var slotTargets:Vector.<CardInstance> = new Vector.<CardInstance>();
			
			for (var i:int = 0; i < len; i++)
			{
				currentRenderer = allRenderers[i];
				
				validSlot = false;
				
				if (cardInstance.templateRef.hasEffect(CardTemplate.CardEffect_UnsummonDummy) && currentRenderer.playerID == cardInstance.owningPlayer && 
					(currentRenderer.cardHolderID == CardManager.CARD_LIST_LOC_MELEE || currentRenderer.cardHolderID == CardManager.CARD_LIST_LOC_RANGED || currentRenderer.cardHolderID == CardManager.CARD_LIST_LOC_SEIGE) &&
					currentRenderer.playerID == cardInstance.owningPlayer)
				{
					slotTargets.length = 0;
					CardManager.getInstance().getAllCreaturesNonHero(currentRenderer.cardHolderID, currentRenderer.playerID, slotTargets);
					
					validSlot = slotTargets.length > 0;
					currentRenderer.selectFirstValid(cardInstance);
				}
				else
				{
					currentRenderer.cardSelectionEnabled = false;
					
					if (cardInstance.canBePlacedInSlot(currentRenderer.cardHolderID, currentRenderer.playerID))
					{
						validSlot = true;
					}
				}
				
				trace("GFX ----- Analyzing slot for placement, valid: " + validSlot + ", for slot: " + currentRenderer);
				
				currentRenderer.selectable = validSlot;
				currentRenderer.alwaysHighlight = validSlot;
				
				if (validSlot && selectFirstActive)
				{
					selectedIndex =	i;
					selectFirstActive = false;
				}
			}
		}
		
		public function getCardSlotById(cardInstanceId:int):CardSlot
		{
			return allCardSlotInstances[cardInstanceId];
		}
		
		public function wasRemovedFromList(cardInstance:CardInstance, sourceTypeID:int, sourcePlayerID:int):void
		{
			var correspondingHolder:GwintCardHolder = getCardHolder(sourceTypeID, sourcePlayerID);
			var targetCardSlot:CardSlot = allCardSlotInstances[cardInstance.instanceId];
			
			if (!correspondingHolder || !targetCardSlot)
			{
				throw new Error("GFX ---- spawnCardInstance failed because it was called with unknown params, sourceTypeID: " + sourceTypeID.toString() + ", sourcePlayerID: " + sourcePlayerID.toString());
			}
			
			correspondingHolder.cardRemoved(targetCardSlot);
		}
		
		public function wasAddedToList(cardInstance:CardInstance, sourceTypeID:int, sourcePlayerID:int):void
		{
			var correspondingHolder:GwintCardHolder = getCardHolder(sourceTypeID, sourcePlayerID);
			var targetCardSlot:CardSlot = allCardSlotInstances[cardInstance.instanceId];
			
			if (!correspondingHolder || !targetCardSlot)
			{
				throw new Error("GFX ---- spawnCardInstance failed because it was called with unknown params, sourceTypeID: " + sourceTypeID.toString() + ", sourcePlayerID: " + sourcePlayerID.toString());
			}
			
			correspondingHolder.cardAdded(targetCardSlot);
		}
		
		public function spawnCardInstance(cardInstance:CardInstance, sourceTypeID:int, sourcePlayerID:int)
		{
			var correspondingHolder:GwintCardHolder = getCardHolder(sourceTypeID, sourcePlayerID);
			
			if (!correspondingHolder)
			{
				throw new Error("GFX ---- spawnCardInstance failed because it was called with unknown params, sourceTypeID: " + sourceTypeID.toString() + ", sourcePlayerID: " + sourcePlayerID.toString());
			}
			
			var newCardSlot:CardSlot = new _slotRendererRef() as CardSlot;
			newCardSlot.useContextMgr = false;
			newCardSlot.instanceId = cardInstance.instanceId;
			newCardSlot.cardState = "Board";
			mcGodCardHolder.addChild(newCardSlot);
			allCardSlotInstances[cardInstance.instanceId] = newCardSlot;
			newCardSlot.setCallbacksToCardInstance(cardInstance);
			
			correspondingHolder.spawnCard(newCardSlot);
		}
		
		public function returnToDeck(cardInstance:CardInstance):void
		{
			var targetCardSlot:CardSlot = allCardSlotInstances[cardInstance.instanceId];
			
			if (targetCardSlot)
			{
				var targetDeckHolder:GwintCardHolder = getCardHolder(CardManager.CARD_LIST_LOC_DECK, cardInstance.owningPlayer);
				CardTweenManager.getInstance().tweenTo(targetCardSlot, targetDeckHolder.x + CardSlot.CARD_BOARD_WIDTH / 2, targetDeckHolder.y + CardSlot.CARD_BOARD_HEIGHT / 2, onReturnToDeckEnded);
			}
		}
		
		public function onReturnToDeckEnded(finishedTween:GTween):void
		{
			var resultedCard:CardSlot = finishedTween.target as CardSlot;
			if (resultedCard)
			{
				mcGodCardHolder.removeChild(resultedCard);
			}
		}
		
		public function removeCardInstance(cardInstance:CardInstance):void
		{
			var targetCardSlot:CardSlot = allCardSlotInstances[cardInstance.instanceId];
			
			if (targetCardSlot)
			{
				mcGodCardHolder.removeChild(targetCardSlot);
			}
		}
		
		public function updateRowScores(p1Seige:int, p1Ranged:int, p1Melee:int, p2Melee:int, p2Ranged:int, p2Seige:int):void
		{
			var currentTextArea:W3TextArea;
			
			currentTextArea = rowScoreP1Seige.getChildByName("txtScore") as W3TextArea;
			if (currentTextArea)
			{
				currentTextArea.text = p1Seige.toString();
			}
			
			currentTextArea = rowScoreP1Ranged.getChildByName("txtScore") as W3TextArea;
			if (currentTextArea)
			{
				currentTextArea.text = p1Ranged.toString();
			}
			
			currentTextArea = rowScoreP1Melee.getChildByName("txtScore") as W3TextArea;
			if (currentTextArea)
			{
				currentTextArea.text = p1Melee.toString();
			}
			
			currentTextArea = rowScoreP2Melee.getChildByName("txtScore") as W3TextArea;
			if (currentTextArea)
			{
				currentTextArea.text = p2Melee.toString();
			}
			
			currentTextArea = rowScoreP2Ranged.getChildByName("txtScore") as W3TextArea;
			if (currentTextArea)
			{
				currentTextArea.text = p2Ranged.toString();
			}
			
			currentTextArea = rowScoreP2Seige.getChildByName("txtScore") as W3TextArea;
			if (currentTextArea)
			{
				currentTextArea.text = p2Seige.toString();
			}
		}
		
		public function clearAllCards():void
		{
			mcP1Deck.clearAllCards();
			mcP2Deck.clearAllCards();
			
			mcP1Hand.clearAllCards();
			mcP2Hand.clearAllCards();
			
			mcP1Graveyard.clearAllCards();
			mcP2Graveyard.clearAllCards();
			
			mcP1Siege.clearAllCards();
			mcP2Siege.clearAllCards();
			
			mcP1Range.clearAllCards();
			mcP2Range.clearAllCards();
			
			mcP1Melee.clearAllCards();
			mcP2Melee.clearAllCards();
			
			mcP1SiegeModif.clearAllCards();
			mcP2SiegeModif.clearAllCards();
			
			mcP1RangeModif.clearAllCards();
			mcP2RangeModif.clearAllCards();
			
			mcP1MeleeModif.clearAllCards();
			mcP2MeleeModif.clearAllCards();
			
			mcP1LeaderHolder.clearAllCards();
			mcP2LeaderHolder.clearAllCards();
			
			var currentItem:CardSlot;
			
			while (mcGodCardHolder.numChildren > 0)
			{
				mcGodCardHolder.removeChildAt(0);
			}
		}
		
		public function updateTransactionCardTooltip(targetCard:CardSlot):void
		{
			if (mcTransactionTooltip)
			{
				if (targetCard != null)
				{
					visible = true;
					GTweener.removeTweens(mcTransactionTooltip);
					GTweener.to(mcTransactionTooltip, 0.2, { alpha:1.0 }, { } );
					if (cardManager)
					{
						var cardTemplate:CardTemplate = cardManager.getCardTemplate(targetCard.cardIndex);
						var tooltipString:String = cardTemplate.tooltipString;
						
						var titleText:TextField = mcTransactionTooltip.getChildByName("txtTooltipTitle") as TextField;
						var descText:TextField = mcTransactionTooltip.getChildByName("txtTooltip") as TextField;
						
						if (tooltipString == "" || !titleText || !descText)
						{
							mcTransactionTooltip.visible = false;
						}
						else
						{
							mcTransactionTooltip.visible = true;
							
							if (cardTemplate.index >= 1000) // Leaders are special ;)
							{
								titleText.text = "[[gwint_leader_ability]]";
							}
							else
							{
								titleText.text = "[[" + tooltipString + "_title]]";
							}
							
							if ( cardTemplate.index == 524 ) // Hack for Clan Dimun Pirate description
							{
								descText.text = "[[gwint_card_tooltip_scorch_creature]]";
							}
							else
							{
								descText.text = "[[" + tooltipString + "]]";
							}
							
							var tooltipIcon:MovieClip = mcTransactionTooltip.getChildByName("mcTooltipIcon") as MovieClip;
							
							if (tooltipIcon)
							{
								tooltipIcon.gotoAndStop(cardTemplate.tooltipIcon);
							}
						}
					}
				}
				else
				{
					if (mcTransactionTooltip.visible)
					{
						GTweener.removeTweens(mcTransactionTooltip);
						
						GTweener.to(mcTransactionTooltip, 0.2, { alpha:0.0 }, { onComplete:onTooltipHideEnded } );
					}
				}
			}
		}
		
		protected function setupCardHolder(curHolder:GwintCardHolder):void
		{
			/*if (curHolder)
			{
				curHolder.addEventListener(MouseEvent.CLICK, onHolderClicked, false, 0, true);
				curHolder.addEventListener(MouseEvent.MOUSE_OVER, onHolderMouseOver, false, 0, true);
				curHolder.addEventListener(MouseEvent.MOUSE_OUT, onHolderMouseOut, false, 0, true);
			}*/
		}
		
		/*protected function onHolderClicked(event:MouseEvent):void
		{
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			if (superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
			{
			}
		}
		
		protected var _lastSelectedCardHolder:int = -1;
		protected function onHolderMouseOver(event:MouseEvent):void
		{
			var currentTarget:GwintCardHolder = event.currentTarget as GwintCardHolder;
			if (currentTarget && currentTarget.selectable && !currentTarget.disableNavigation)
			{
				_lastSelectedCardHolder = getRendererIndex(currentTarget);
				selectedIndex = _lastSelectedCardHolder;
			}
		}
		
		protected function onHolderMouseOut(event:MouseEvent):void
		{
			_lastSelectedCardHolder = -1;
			selectedIndex = -1;
		}*/
		
		public function handleMouseMove(event:MouseEvent):void
		{
			// Disable mouse events while the choice dialog is visible
			if (GwintGameMenu.mSingleton.mcChoiceDialog.visible)
			{
				return;
			}
			
			var i:int;
			var currentRenderer:GwintCardHolder;
			var collisionIndex:int = -1;
			
			for (i = 0; i < _renderers.length; ++i)
			{
				currentRenderer = _renderers[i] as GwintCardHolder;
				
				if (currentRenderer && (currentRenderer.selectable || currentRenderer.cardSelectionEnabled) && currentRenderer.handleMouseMove(event.stageX, event.stageY))
				{
					collisionIndex = i;
					break;
				}
			}
			
			selectedIndex = collisionIndex;
		}
		
		public function handleLeftClick(event:MouseEvent):void
		{
			// Disable mouse events while the choice dialog is visible
			if (GwintGameMenu.mSingleton.mcChoiceDialog.visible)
			{
				return;
			}
			
			handleMouseMove(event); // Make sure selection is updated to current mouse position
			
			var curSelectedHolder:GwintCardHolder = getSelectedCardHolder();
			if (curSelectedHolder)
			{
				curSelectedHolder.handleLeftClick(event);
			}
		}
		
		protected function onTooltipHideEnded(curTween:GTween):void
		{
			if (mcTransactionTooltip)
			{
				mcTransactionTooltip.visible = false;
			}
		}
	}
}
