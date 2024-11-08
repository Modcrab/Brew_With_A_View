package red.game.witcher3.menus.gwint
{
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	import red.core.events.GameEvent;
	import scaleform.clik.core.UIComponent;
	import red.game.witcher3.menus.gwint.CardAndComboPoints;
	import red.game.witcher3.utils.CommonUtils;
	
	/**
	 * ...
	 * @author Jason Slama sept 2014
	 */
	public class CardManager extends UIComponent // #J need to extend this simply to be able to dispatch events
	{
		public static const PLAYER_INVALID:int = -1;
		public static const PLAYER_1:int = 0;
		public static const PLAYER_2:int = 1;
		public static const PLAYER_BOTH:int = 2;
		
		public static const CARD_LIST_LOC_INVALID:int = -1;
		public static const CARD_LIST_LOC_DECK:int = 0;	//#J Currently not same as others because there are no instances, can change if needed
		public static const CARD_LIST_LOC_HAND:int = 1;
		public static const CARD_LIST_LOC_GRAVEYARD:int = 2;
		public static const CARD_LIST_LOC_SEIGE:int = 3;
		public static const CARD_LIST_LOC_RANGED:int = 4;
		public static const CARD_LIST_LOC_MELEE:int = 5;
		public static const CARD_LIST_LOC_SEIGEMODIFIERS:int = 6;
		public static const CARD_LIST_LOC_RANGEDMODIFIERS:int = 7;
		public static const CARD_LIST_LOC_MELEEMODIFIERS:int = 8;
		public static const CARD_LIST_LOC_WEATHERSLOT:int = 9;
		public static const CARD_LIST_LOC_LEADER:int = 10;
		
		public static const cardTemplatesLoaded:String = "CardManager.templates.received"; 
		
		public var _cardTemplates : Dictionary = null; // Avoid using directly. Made public for test cheats
		private var _cardInstances:Dictionary;
		
		public var cardTemplatesReceived:Boolean = false;
		
		public var boardRenderer:GwintBoardRenderer;
		
		public var cardValues:GwintCardValues;
		
		public var cardEffectManager:CardEffectManager;
		
		//#J Used by game and not deck builder
		// {
		// Full Deck Definitions
		public var playerDeckDefinitions:Vector.<GwintDeck>;
		
		public var playerRenderers:Vector.<GwintPlayerRenderer> = new Vector.<GwintPlayerRenderer>();
		
		public var currentPlayerScores:Vector.<int>;
		
		public var roundResults:Vector.<GwintRoundResult>;
		
		// Card holder Lists
		private var cardListHand:Array;
		private var cardListGraveyard:Array;
		private var cardListSeige:Array;
		private var cardListRanged:Array;
		private var cardListMelee:Array;
		private var cardListSeigeModifier:Array;
		private var cardListRangedModifier:Array;
		private var cardListMeleeModifier:Array;
		private var cardListWeather:Vector.<CardInstance>;
		private var cardListLeader:Array;
		// }
		
		private var pendingSpawnedCards:Vector.<int> = new Vector.<int>();
		private var pendingSpawnedCardsPlayerTargets:Vector.<int> = new Vector.<int>();
		
		protected static var _instance:CardManager;
		public static function getInstance():CardManager
		{
			if (_instance == null) { _instance = new CardManager(); }
			return _instance;
		}
		
		function CardManager()
		{
			super();
			
			cardEffectManager = new CardEffectManager();
			
			initializeLists();
			
			_cardTemplates = new Dictionary();
			_cardInstances = new Dictionary();
			
			_instance = this;
		}
		
		private function initializeLists():void
		{
			// Two lists, one for each player
			playerDeckDefinitions = new Vector.<GwintDeck>();
			playerDeckDefinitions.push(new GwintDeck()); // Replaced by witcherscript but to ensure order I created the indexes now (would pushing null work?)
			playerDeckDefinitions.push(new GwintDeck());
			
			currentPlayerScores = new Vector.<int>();
			currentPlayerScores.push(0);
			currentPlayerScores.push(0);
			
			cardListHand = new Array();
			cardListHand.push(new Vector.<CardInstance>());
			cardListHand.push(new Vector.<CardInstance>());
			
			cardListGraveyard = new Array();
			cardListGraveyard.push(new Vector.<CardInstance>());
			cardListGraveyard.push(new Vector.<CardInstance>());
			
			cardListSeige = new Array();
			cardListSeige.push(new Vector.<CardInstance>());
			cardListSeige.push(new Vector.<CardInstance>());
			
			cardListRanged = new Array();
			cardListRanged.push(new Vector.<CardInstance>());
			cardListRanged.push(new Vector.<CardInstance>());
			
			cardListMelee = new Array();
			cardListMelee.push(new Vector.<CardInstance>());
			cardListMelee.push(new Vector.<CardInstance>());
			
			cardListSeigeModifier = new Array();
			cardListSeigeModifier.push(new Vector.<CardInstance>());
			cardListSeigeModifier.push(new Vector.<CardInstance>());
			
			cardListRangedModifier = new Array();
			cardListRangedModifier.push(new Vector.<CardInstance>());
			cardListRangedModifier.push(new Vector.<CardInstance>());
			
			cardListMeleeModifier = new Array();
			cardListMeleeModifier.push(new Vector.<CardInstance>());
			cardListMeleeModifier.push(new Vector.<CardInstance>());
			
			cardListWeather = new Vector.<CardInstance>();
			
			cardListLeader = new Array();
			cardListLeader.push(new Vector.<CardInstance>());
			cardListLeader.push(new Vector.<CardInstance>());
			
			roundResults = new Vector.<GwintRoundResult>();
			roundResults.push(new GwintRoundResult());
			roundResults.push(new GwintRoundResult());
			roundResults.push(new GwintRoundResult());
		}
		
		public function reset():void
		{
			boardRenderer.clearAllCards();
			
			_cardInstances = new Dictionary();
			
			cardListHand = new Array();
			cardListHand.push(new Vector.<CardInstance>());
			cardListHand.push(new Vector.<CardInstance>());
			
			cardListGraveyard = new Array();
			cardListGraveyard.push(new Vector.<CardInstance>());
			cardListGraveyard.push(new Vector.<CardInstance>());
			
			cardListSeige = new Array();
			cardListSeige.push(new Vector.<CardInstance>());
			cardListSeige.push(new Vector.<CardInstance>());
			
			cardListRanged = new Array();
			cardListRanged.push(new Vector.<CardInstance>());
			cardListRanged.push(new Vector.<CardInstance>());
			
			cardListMelee = new Array();
			cardListMelee.push(new Vector.<CardInstance>());
			cardListMelee.push(new Vector.<CardInstance>());
			
			cardListSeigeModifier = new Array();
			cardListSeigeModifier.push(new Vector.<CardInstance>());
			cardListSeigeModifier.push(new Vector.<CardInstance>());
			
			cardListRangedModifier = new Array();
			cardListRangedModifier.push(new Vector.<CardInstance>());
			cardListRangedModifier.push(new Vector.<CardInstance>());
			
			cardListMeleeModifier = new Array();
			cardListMeleeModifier.push(new Vector.<CardInstance>());
			cardListMeleeModifier.push(new Vector.<CardInstance>());
			
			cardListLeader = new Array();
			cardListLeader.push(new Vector.<CardInstance>());
			cardListLeader.push(new Vector.<CardInstance>());
			
			cardListWeather = new Vector.<CardInstance>();
			
			roundResults[0].reset();
			roundResults[1].reset();
			roundResults[2].reset();
			
			playerRenderers[0].reset();
			playerRenderers[1].reset();
			
			cardEffectManager.flushAllEffects();
			
			recalculateScores();
		}
		
		public function getCardTemplate( index:int ) : CardTemplate
		{
			return _cardTemplates[index];
		}
		
		public function getCardInstance( uniqueID:int ) : CardInstance
		{
			return _cardInstances[uniqueID];
		}
		
		public function onGetCardTemplates( gameData:Object, index:int ):void
		{
			var dataArray:Array = gameData as Array;
			
			if (!dataArray)
			{
				throw new Error("GFX - Information sent from WS regarding card templates was wrong!");
			}
			
			//trace("GFX - got a data array!");
			
			for each (var cardTemplate:CardTemplate in dataArray)
			{
				if (_cardTemplates[cardTemplate.index] != null)
				{
					throw new Error("GFX - receieved a duplicate template, new:" + cardTemplate + ", old:" + _cardTemplates[cardTemplate.index]); 
				}
				
				_cardTemplates[cardTemplate.index] = cardTemplate;
				//trace("GFX - received the following card template information: " + cardTemplate);
			}
			
			dispatchEvent(new Event(cardTemplatesLoaded, false, false));
			cardTemplatesReceived = true;
		}
		
		public function updatePlayerLives():void
		{
			var livesCount:Array = new Array();
			livesCount.push(2);
			livesCount.push(2);
			
			var i:int;
			
			for (i = 0; i < roundResults.length; ++i)
			{
				if (roundResults[i].played)
				{
					if (roundResults[i].winningPlayer == PLAYER_1 || roundResults[i].winningPlayer == PLAYER_INVALID)
					{
						livesCount[PLAYER_2] = Math.max(0, livesCount[PLAYER_2] - 1); // Can't have less than 0 lives :S
					}
					
					if (roundResults[i].winningPlayer == PLAYER_2 || roundResults[i].winningPlayer == PLAYER_INVALID) // We have to add this check instead of else as value could possibly be PLAYER_INVALID (draws)
					{
						livesCount[PLAYER_1] = Math.max(0, livesCount[PLAYER_1] - 1);
					}
				}
				else
				{
					break;
				}
			}
			
			playerRenderers[PLAYER_1].setPlayerLives(livesCount[PLAYER_1]);
			playerRenderers[PLAYER_2].setPlayerLives(livesCount[PLAYER_2]);
		}
		
		public function getFirstCardInHandWithEffect(effectID:int, playerID:int):CardInstance
		{
			var handList:Vector.<CardInstance> = getCardInstanceList(CARD_LIST_LOC_HAND, playerID);
			var list_it:int;
			var currentCard:CardInstance;
			
			for (list_it = 0; list_it < handList.length; ++list_it)
			{
				currentCard = handList[list_it];
				
				if (currentCard.templateRef.hasEffect(effectID))
				{
					return currentCard;
				}
			}
			
			return null;
		}
		
		public function getCardsInHandWithEffect(effectID:int, playerID:int) : Vector.<CardInstance>
		{
			var matchingList:Vector.<CardInstance> = new Vector.<CardInstance>();
			var handList:Vector.<CardInstance> = getCardInstanceList(CARD_LIST_LOC_HAND, playerID);
			var list_it:int;
			var currentCard:CardInstance;
			
			for (list_it = 0; list_it < handList.length; ++list_it)
			{
				currentCard = handList[list_it];
				
				if (currentCard.templateRef.hasEffect(effectID))
				{
					matchingList.push(currentCard);
				}
			}
			
			return matchingList;
		}

		public function getCardsInSlotIdWithEffect(effectID:int, playerID:int, slotID:int = -1) : Vector.<CardInstance>
		{
			var matchingList:Vector.<CardInstance> = new Vector.<CardInstance>();
			var currentCard:CardInstance;
			var list_it:int;

			if (slotID == -1) // -1 = Check all rows
			{
				var rowList:Vector.<CardInstance> = getCardInstanceList(CARD_LIST_LOC_MELEE, playerID);
				for (list_it = 0; list_it < rowList.length; ++list_it)
				{
					currentCard = rowList[list_it];
					
					if (currentCard.templateRef.hasEffect(effectID))
					{
						matchingList.push(currentCard);
					}
				}
				rowList = getCardInstanceList(CARD_LIST_LOC_RANGED, playerID);
				for (list_it = 0; list_it < rowList.length; ++list_it)
				{
					currentCard = rowList[list_it];
					
					if (currentCard.templateRef.hasEffect(effectID))
					{
						matchingList.push(currentCard);
					}
				}
				rowList = getCardInstanceList(CARD_LIST_LOC_SEIGE, playerID);
				for (list_it = 0; list_it < rowList.length; ++list_it)
				{
					currentCard = rowList[list_it];
					
					if (currentCard.templateRef.hasEffect(effectID))
					{
						matchingList.push(currentCard);
					}
				}
			}
			else
			{
				var handList:Vector.<CardInstance> = getCardInstanceList(slotID, playerID);
				for (list_it = 0; list_it < handList.length; ++list_it)
				{
					currentCard = handList[list_it];
					
					if (currentCard.templateRef.hasEffect(effectID))
					{
						matchingList.push(currentCard);
					}
				}
			}
			
			return matchingList;
		}
		
		public function getCardInstanceList(listID:int, playerID:int) : Vector.<CardInstance>
		{
			switch (listID)
			{
				case CARD_LIST_LOC_DECK:
					return null; // #J MAY need to implement this at some point. for now ignoring it
				case CARD_LIST_LOC_HAND:
					if (playerID != PLAYER_INVALID)
					{
						return cardListHand[playerID];
					}
					break;
				case CARD_LIST_LOC_GRAVEYARD:
					if (playerID != PLAYER_INVALID)
					{
						return cardListGraveyard[playerID];
					}
					break;
				case CARD_LIST_LOC_SEIGE:
					if (playerID != PLAYER_INVALID)
					{
						return cardListSeige[playerID];
					}
					break;
				case CARD_LIST_LOC_RANGED:
					if (playerID != PLAYER_INVALID)
					{
						return cardListRanged[playerID];
					}
					break;
				case CARD_LIST_LOC_MELEE:
					if (playerID != PLAYER_INVALID)
					{
						return cardListMelee[playerID];
					}
					break;
				case CARD_LIST_LOC_SEIGEMODIFIERS:
					if (playerID != PLAYER_INVALID)
					{
						return cardListSeigeModifier[playerID];
					}
					break;
				case CARD_LIST_LOC_RANGEDMODIFIERS:
					if (playerID != PLAYER_INVALID)
					{
						return cardListRangedModifier[playerID];
					}
					break;
				case CARD_LIST_LOC_MELEEMODIFIERS:
					if (playerID != PLAYER_INVALID)
					{
						return cardListMeleeModifier[playerID];
					}
					break;
				case CARD_LIST_LOC_WEATHERSLOT:
					return cardListWeather;
				case CARD_LIST_LOC_LEADER:
					if (playerID != PLAYER_INVALID) 
					{
						return cardListLeader[playerID];
					}
			}
			
			trace("GFX [WARNING] - CardManager: failed to get card list with player: " + playerID + ", and listID: " + listID);
			
			return null;
		}
		
		private function flushPendingSpawnedCards():void
		{
			var newInstances:Vector.<CardInstance> = new Vector.<CardInstance>();
			var currentInstance:CardInstance;
			
			for (var i:int = 0; i < pendingSpawnedCards.length; ++i)
			{
				// #JS hardcoded to melee as only one exists right now and im being lazy.
				// Fix if you need this for anything else
				var newInstance:CardInstance = spawnCardInstance(pendingSpawnedCards[i], pendingSpawnedCardsPlayerTargets[i], CARD_LIST_LOC_MELEE);
				newInstance.InstancePositioning = true;
				newInstance.BanishInsteadOfGraveyard = true;
				addCardInstanceToList(newInstance, CARD_LIST_LOC_MELEE, pendingSpawnedCardsPlayerTargets[i]);
				newInstances.push(newInstance);
			}
			
			for (var x:int = 0; x < newInstances.length; ++x)
			{
				currentInstance = newInstances[x];
				currentInstance.InstancePositioning = false;
				CardFXManager.getInstance().spawnFX(currentInstance, null, CardFXManager.getInstance()._placeFiendFXClassRef);
				currentInstance.onFinishedMovingIntoHolder(currentInstance.inList, currentInstance.listsPlayer);
			}
			
			pendingSpawnedCards.length = 0;
			pendingSpawnedCardsPlayerTargets.length = 0;
		}
		
		public function clearBoard(allowMonsterFactionAbility:Boolean):void
		{
			var list_it:int;
			var player_it:int;
			var cardToIgnore:CardInstance;
			var currentCard:CardInstance;
			var currentList:Vector.<CardInstance>;
			
			// Clear weather
			while (cardListWeather.length > 0)
			{
				currentCard = cardListWeather[0];
				addCardInstanceToList(currentCard, CARD_LIST_LOC_GRAVEYARD, currentCard.owningPlayer);
			}
			
			for (player_it = PLAYER_1; player_it <= PLAYER_2; ++player_it)
			{
				if (allowMonsterFactionAbility)
				{
					cardToIgnore = chooseCreatureToExclude(player_it);
				}
				
				sendListToGraveyard(CARD_LIST_LOC_MELEE, player_it, cardToIgnore, false);
				sendListToGraveyard(CARD_LIST_LOC_RANGED, player_it, cardToIgnore, false);
				sendListToGraveyard(CARD_LIST_LOC_SEIGE, player_it, cardToIgnore, false);
				sendListToGraveyard(CARD_LIST_LOC_MELEEMODIFIERS, player_it, cardToIgnore, false);
				sendListToGraveyard(CARD_LIST_LOC_RANGEDMODIFIERS, player_it, cardToIgnore, false);
				sendListToGraveyard(CARD_LIST_LOC_SEIGEMODIFIERS, player_it, cardToIgnore, false);
			}
			
			flushPendingSpawnedCards();
		}
		
		private function sendListToGraveyard(listID:int, playerID:int, cardToIgnore:CardInstance, allowFlush:Boolean = true):void
		{
			var currentCard:CardInstance;
			var currentList:Vector.<CardInstance> = getCardInstanceList(listID, playerID);
			var indexToCheck:int = 0;
			
			while (currentList.length > indexToCheck)
			{
				currentCard = currentList[indexToCheck];
				if (currentCard == cardToIgnore)
				{
					++indexToCheck;
				}
				else
				{
					if (currentCard.BanishInsteadOfGraveyard)
					{
						CardFXManager.getInstance().spawnFX(currentCard, null, CardFXManager.getInstance()._placeFiendFXClassRef);
						removeCardInstanceFromItsList(currentCard);
						boardRenderer.removeCardInstance(currentCard);
					}
					else if (playerID == -1) // Weather slot does not have playerID - Fix for weathers
					{
						addCardInstanceToList(currentCard, CARD_LIST_LOC_GRAVEYARD, currentCard.owningPlayer);
					}
					else
					{
						addCardInstanceToList(currentCard, CARD_LIST_LOC_GRAVEYARD, currentCard.listsPlayer);
					}
				}
			}
		}
		
		public function chooseCreatureToExclude(playerIndex:int):CardInstance
		{
			if (playerDeckDefinitions[playerIndex].getDeckFaction() == CardTemplate.FactionId_No_Mans_Land)
			{
				var elligibleCardList:Vector.<CardInstance> = new Vector.<CardInstance>();
				
				getAllCreaturesNonHero(CARD_LIST_LOC_MELEE, playerIndex, elligibleCardList);
				getAllCreaturesNonHero(CARD_LIST_LOC_RANGED, playerIndex, elligibleCardList);
				getAllCreaturesNonHero(CARD_LIST_LOC_SEIGE, playerIndex, elligibleCardList);
				
				if (elligibleCardList.length > 0)
				{
					var keepIndex:int = Math.min(Math.floor(Math.random() * elligibleCardList.length), elligibleCardList.length - 1);
					
					return elligibleCardList[keepIndex];
				}
			}
			
			return null;
		}
		
		public function getAllCreatures(playerIndex:int):Vector.<CardInstance>
		{
			var returnVal:Vector.<CardInstance> = new Vector.<CardInstance>();
			var list_it:int;
			var currentRowList:Vector.<CardInstance>;
			
			currentRowList = getCardInstanceList(CARD_LIST_LOC_MELEE, playerIndex);
			for (list_it = 0; list_it < currentRowList.length; ++list_it)
			{
				returnVal.push(currentRowList[list_it]);
			}
			
			currentRowList = getCardInstanceList(CARD_LIST_LOC_RANGED, playerIndex);
			for (list_it = 0; list_it < currentRowList.length; ++list_it)
			{
				returnVal.push(currentRowList[list_it]);
			}
			
			currentRowList = getCardInstanceList(CARD_LIST_LOC_SEIGE, playerIndex);
			for (list_it = 0; list_it < currentRowList.length; ++list_it)
			{
				returnVal.push(currentRowList[list_it]);
			}
			
			return returnVal;
		}
		
		public function getAllCreaturesInHand(playerIndex:int):Vector.<CardInstance>
		{
			var returnVal:Vector.<CardInstance> = new Vector.<CardInstance>();
			var list_it:int;
			var handList:Vector.<CardInstance> = getCardInstanceList(CARD_LIST_LOC_HAND, playerIndex);
			var currentCard:CardInstance;
			
			for (list_it = 0; list_it < handList.length; ++list_it)
			{
				currentCard = handList[list_it];
				if (currentCard.templateRef.isType(CardTemplate.CardType_Creature))
				{
					returnVal.push(currentCard);
				}
			}
			
			return returnVal;
		}
		
		public function getAllCreaturesNonHero(listID:int, playerIndex:int, listToAdd:Vector.<CardInstance>):void
		{
			var list_it:int;
			var currentCard:CardInstance;
			var currentList:Vector.<CardInstance> = getCardInstanceList(listID, playerIndex);
			
			if (currentList == null)
			{
				throw new Error("GFX [ERROR] - Failed to get card instance list for listID: " + listID + ", and playerIndex: " + playerIndex);
			}
			
			for (list_it = 0; list_it < currentList.length; ++list_it)
			{
				currentCard = currentList[list_it];
				
				if (currentCard.templateRef.isType(CardTemplate.CardType_Creature) && !currentCard.templateRef.isType(CardTemplate.CardType_Hero))
				{
					listToAdd.push(currentCard);
				}
			}
		}
		
		public function replaceCardInstanceIDs(replacerInstanceID:int, replaceeInstanceID:int):void
		{
			replaceCardInstance(getCardInstance(replacerInstanceID), getCardInstance(replaceeInstanceID));
		}
		
		// For dummy's!
		public function replaceCardInstance(replacerInstance:CardInstance, replaceeInstance:CardInstance):void
		{
			if (replaceeInstance == null || replacerInstance == null)
			{
				return;
			}
			
			GwintGameMenu.mSingleton.playSound("gui_gwint_dummy");
			
			var targetList:int = replaceeInstance.inList;
			var targetListPlayer:int = replaceeInstance.listsPlayer;
			
			addCardInstanceToList(replaceeInstance, CARD_LIST_LOC_HAND, replaceeInstance.listsPlayer);
			addCardInstanceToList(replacerInstance, targetList, targetListPlayer);
		}
		
		public function addCardInstanceIDToList(instanceID:int, listID:int, playerID:int):void
		{
			var cardInstance:CardInstance = getCardInstance(instanceID);
			if (cardInstance)
			{
				addCardInstanceToList(cardInstance, listID, playerID);
			}
		}
		
		public function addCardInstanceToList(cardInstance:CardInstance, listID:int, playerID:int):void
		{
			removeCardInstanceFromItsList(cardInstance);
			
			cardInstance.inList = listID;
			cardInstance.listsPlayer = playerID;
			var newList:Vector.<CardInstance> = getCardInstanceList(listID, playerID);
			
			if (listID == CARD_LIST_LOC_GRAVEYARD && cardInstance.templateRef.hasEffect(CardTemplate.CardEffect_SuicideSummon) &&
				!GwintGameFlowController.getInstance().isGameOver())
			{
				if (cardInstance.templateRef.summonFlags.length > 0)
				{
					GwintGameMenu.mSingleton.playSound(
						cardInstance.templateRef.factionIdx == CardTemplate.FactionId_Skellige ?
							"gui_gwint_hero" :
							"gui_gwint_cow_death");
				}
				
				for (var i:int = 0; i < cardInstance.templateRef.summonFlags.length; ++i)
				{
					pendingSpawnedCards.push(cardInstance.templateRef.summonFlags[i]);
					pendingSpawnedCardsPlayerTargets.push(cardInstance.listsPlayer);
				}
			}
			
			trace("GFX ====== Adding card with instance ID: " + cardInstance.instanceId + ", to List ID: " + listIDToString(listID) + ", for player: " + playerID);
			
			newList.push(cardInstance);
			if (boardRenderer) { boardRenderer.wasAddedToList(cardInstance, listID, playerID); }
			recalculateScores();
			
			if (listID == CARD_LIST_LOC_HAND)
			{
				playerRenderers[playerID].numCardsInHand = newList.length;
			}
		}
		
		public function removeCardInstanceFromItsList(cardInstance:CardInstance):void
		{
			removeCardInstanceFromList(cardInstance, cardInstance.inList, cardInstance.listsPlayer);
		}
		
		public function removeCardInstanceFromList(cardInstance:CardInstance, listID:int, playerID:int):void
		{
			if (cardInstance.inList != CARD_LIST_LOC_INVALID)
			{
				cardInstance.inList = CARD_LIST_LOC_INVALID;
				cardInstance.listsPlayer = PLAYER_INVALID;
				
				var containingList:Vector.<CardInstance> = getCardInstanceList(listID, playerID);
				if (!containingList)
				{
					throw new Error("GFX - Tried to remove from unknown listID:" + listID + ", and player:" + playerID + ", the following card: " + cardInstance);
				}
				else
				{
					var indexOf:int = containingList.indexOf(cardInstance);
					
					if (indexOf < 0 || indexOf >= containingList.length)
					{
						throw new Error("GFX - tried to remove card instance from a list that does not contain it: " + listID + ", " + playerID + ", " + cardInstance);
					}
					else
					{
						containingList.splice(indexOf, 1);
						if (boardRenderer) { boardRenderer.wasRemovedFromList(cardInstance, listID, playerID); }
						recalculateScores();
					}
				}
				
				if (listID == CARD_LIST_LOC_HAND)
				{
					playerRenderers[playerID].numCardsInHand = containingList.length;
				}
			}
		}
		
		public function spawnLeaders():void
		{
			var templateId:int;
			var newCardInstance:CardInstance;
			
			templateId = playerDeckDefinitions[PLAYER_1].selectedKingIndex;
			newCardInstance = spawnCardInstance(templateId, PLAYER_1);
			addCardInstanceToList(newCardInstance, CARD_LIST_LOC_LEADER, PLAYER_1);
			
			templateId = playerDeckDefinitions[PLAYER_2].selectedKingIndex;
			newCardInstance = spawnCardInstance(templateId, PLAYER_2);
			addCardInstanceToList(newCardInstance, CARD_LIST_LOC_LEADER, PLAYER_2);
		}
		
		public function halfWeatherEnabled(playerID:int):Boolean
		{
			var playerToCheckInstance:CardLeaderInstance = getCardLeader(playerID);
			var otherPlayerLeader:CardLeaderInstance;
			
			if (playerID == PLAYER_1)
			{
				otherPlayerLeader = getCardLeader(PLAYER_2);
			}
			else
			{
				otherPlayerLeader = getCardLeader(PLAYER_1);
			}
			
			return otherPlayerLeader.templateRef.getFirstEffect() != CardTemplate.CardEffect_Counter_King && playerToCheckInstance.templateRef.getFirstEffect() == CardTemplate.CardEffect_WeatherResistant;
		}
		
		public function getCardLeader(playerIndex:int):CardLeaderInstance
		{
			var leaderCardList:Vector.<CardInstance> = CardManager.getInstance().getCardInstanceList(CardManager.CARD_LIST_LOC_LEADER, playerIndex);
							
			if (leaderCardList.length < 1)
			{
				return null;
			}
			else
			{
				return leaderCardList[0] as CardLeaderInstance;
			}
		}
		
		public function shuffleAndDrawCards():void
		{
			var player1Deck:GwintDeck = playerDeckDefinitions[PLAYER_1];
			var player2Deck:GwintDeck = playerDeckDefinitions[PLAYER_2];
			
			var player1Leader:CardLeaderInstance = getCardLeader(PLAYER_1);
			var player2Leader:CardLeaderInstance = getCardLeader(PLAYER_2);
			
			if (player1Deck.getDeckKingTemplate() == null || player2Deck.getDeckKingTemplate() == null)
			{
				throw new Error("GFX - Trying to shuffle and draw cards when one of the following decks is null:" + player1Deck.getDeckKingTemplate() + ", " + player2Deck.getDeckKingTemplate());
			}

			trace("GFX -#AI#------------------- DECK STRENGTH --------------------");
			trace("GFX -#AI#--- PLAYER 1:");
			player1Deck.shuffleDeck(player2Deck.originalStength());
			trace("GFX -#AI#--- PLAYER 2:");
			player2Deck.shuffleDeck(player1Deck.originalStength());
			trace("GFX -#AI#------------------------------------------------------");
			
			var numToDraw:int;
			
			if (player1Leader.canBeUsed && player1Leader.templateRef.getFirstEffect() == CardTemplate.CardEffect_11th_card)
			{
				player1Leader.canBeUsed = false;
				numToDraw = 11;
			}
			else
			{
				numToDraw = 10;
			}
			
			if (GwintGameMenu.mSingleton.tutorialsOn)
			{
				if (tryDrawSpecificCard(PLAYER_1, 3))
				{
					--numToDraw;
				}
				
				if (tryDrawSpecificCard(PLAYER_1, 5))
				{
					--numToDraw;
				}
				
				if (tryDrawSpecificCard(PLAYER_1, 150))
				{
					--numToDraw;
				}
				
				if (tryDrawSpecificCard(PLAYER_1, 115))
				{
					--numToDraw;
				}
				
				if (tryDrawSpecificCard(PLAYER_1, 135))
				{
					--numToDraw;
				}
				
				if (tryDrawSpecificCard(PLAYER_1, 111))
				{
					--numToDraw;
				}
				
				if (tryDrawSpecificCard(PLAYER_1, 145))
				{
					--numToDraw;
				}
				
				if (tryDrawSpecificCard(PLAYER_1, 113))
				{
					--numToDraw;
				}
				
				if (tryDrawSpecificCard(PLAYER_1, 114))
				{
					--numToDraw;
				}
				
				if (tryDrawSpecificCard(PLAYER_1, 107))
				{
					--numToDraw;
				}
				
				GwintGameMenu.mSingleton.playSound("gui_gwint_draw_card");
			}
			
			drawCards(PLAYER_1, numToDraw);
			
			// Sort Player hand
			var cardList:Vector.<CardInstance> = getCardInstanceList(CARD_LIST_LOC_HAND, PLAYER_1);
			cardList.sort(cardSorter);
			
			if (player2Leader.canBeUsed && player2Leader.templateRef.getFirstEffect() == CardTemplate.CardEffect_11th_card)
			{
				player2Leader.canBeUsed = false;
				numToDraw = 11;
			}
			else
			{
				numToDraw = 10;
			}

			drawCards(PLAYER_2, numToDraw);
		}
		
		public function drawCards(playerID:int, quantity:int):Boolean
		{
			var i:int;
			
			_heroDrawSoundsAllowed = 1;
			_normalDrawSoundsAllowed = 1;
			
			for (i = 0; i < quantity; ++i)
			{
				if (!drawCard(playerID))
				{
					return false;
				}
			}
			
			_heroDrawSoundsAllowed = -1;
			_normalDrawSoundsAllowed = -1;
			
			return true;
		}
		
		private var _heroDrawSoundsAllowed:int = -1;
		private var _normalDrawSoundsAllowed:int = -1;
		public function drawCard(playerID:int):Boolean
		{
			var templateId:int;
			var newCardInstance:CardInstance;
			var playerDeck:GwintDeck = playerDeckDefinitions[playerID];

			if (playerDeck.cardIndicesInDeck.length > 0)
			{
				templateId = playerDeckDefinitions[playerID].drawCard();
				newCardInstance = spawnCardInstance(templateId, playerID);
				addCardInstanceToList(newCardInstance, CARD_LIST_LOC_HAND, playerID);
				
				if (newCardInstance.templateRef.isType(CardTemplate.CardType_Hero))
				{
					if (_heroDrawSoundsAllowed > 0)
					{
						_heroDrawSoundsAllowed -= 1;
						GwintGameMenu.mSingleton.playSound("gui_gwint_hero_card_drawn");
					}
					else if (_heroDrawSoundsAllowed == -1)
					{
						GwintGameMenu.mSingleton.playSound("gui_gwint_hero_card_drawn");
					}
				}
				else
				{
					if (_normalDrawSoundsAllowed > 0)
					{
						_normalDrawSoundsAllowed -= 1;
						GwintGameMenu.mSingleton.playSound("gui_gwint_draw_card");
					}
					else if (_normalDrawSoundsAllowed == -1)
					{
						GwintGameMenu.mSingleton.playSound("gui_gwint_draw_card");
					}
				}
				
				trace("GFX - Player ", playerID, " drew the following Card:", newCardInstance);
				return true;
			}
			else
			{
				trace("GFX - Player ", playerID, " has no more cards to draw!");
				return false;
			}
		}
		
		//#J WARNING due to time constraints and specific need, did this quickly and only works for weather cards
		public function tryDrawAndPlaySpecificCard_Weather(playerID:int, cardID:int):Boolean
		{
			var newCardInstance:CardInstance;
			var playerDeck:GwintDeck = playerDeckDefinitions[playerID];
			
			if (playerDeck.tryDrawSpecificCard(cardID))
			{
				newCardInstance = spawnCardInstance(cardID, playerID);
				addCardInstanceToList(newCardInstance, CARD_LIST_LOC_WEATHERSLOT, CardManager.PLAYER_INVALID);
				
				trace("GFX - Player ", playerID, " drew the following Card:", newCardInstance);
				
				return true;
			}
			
			return false;
		}
		
		public function tryDrawSpecificCard(playerID:int, cardID:int):Boolean
		{
			var newCardInstance:CardInstance;
			var playerDeck:GwintDeck = playerDeckDefinitions[playerID];
			
			if (playerDeck.tryDrawSpecificCard(cardID))
			{
				newCardInstance = spawnCardInstance(cardID, playerID);
				addCardInstanceToList(newCardInstance, CARD_LIST_LOC_HAND, playerID);
				
				trace("GFX - Player ", playerID, " drew the following Card:", newCardInstance);
				
				return true;
			}
			
			return false;
		}
		
		public function mulliganCard( cardInstance:CardInstance ) : CardInstance
		{
			var playerDeck:GwintDeck = null;
			
			if (cardInstance.owningPlayer >= 0 && cardInstance.owningPlayer < playerDeckDefinitions.length)
			{
				playerDeck = playerDeckDefinitions[cardInstance.owningPlayer];
			}
			
			if (playerDeck)
			{
				playerDeck.readdCard(cardInstance.templateId);
				var newtemplateID = playerDeck.drawCard();
				
				if (newtemplateID != CardInstance.INVALID_INSTANCE_ID)
				{
					var newCardInstance:CardInstance = spawnCardInstance(newtemplateID, cardInstance.owningPlayer);
					
					if (newCardInstance)
					{
						addCardInstanceToList(newCardInstance, CARD_LIST_LOC_HAND, cardInstance.owningPlayer);
						unspawnCardInstance(cardInstance);
						
						if (newCardInstance.templateRef.isType(CardTemplate.CardType_Hero))
						{
							GwintGameMenu.mSingleton.playSound("gui_gwint_hero_card_drawn");
						}
						
						var cardList:Vector.<CardInstance> = getCardInstanceList(CARD_LIST_LOC_HAND, PLAYER_1);
						cardList.sort(cardSorter);
						return newCardInstance;
					}
				}
			}
			
			return null;
		}
		
		private static var lastInstanceID : int = 0;
		public function spawnCardInstance( templateId : int, forPlayer : int, startingLocation : int = CARD_LIST_LOC_INVALID ) : CardInstance
		{
			lastInstanceID += 1;
			
			var newInstance : CardInstance;
			
			if (templateId >= 1000)
			{
				newInstance = new CardLeaderInstance();
			}
			else
			{
				newInstance = new CardInstance();
			}
			
			var spawnLocation:int = startingLocation;
			
			if (spawnLocation == CARD_LIST_LOC_INVALID)
			{
				spawnLocation = CARD_LIST_LOC_DECK;
			}
			
			newInstance.templateId = templateId;
			newInstance.templateRef = getCardTemplate(templateId);
			newInstance.owningPlayer = forPlayer;
			newInstance.instanceId = lastInstanceID;
			_cardInstances[newInstance.instanceId] = newInstance;
			newInstance.finializeSetup();
			
			if (boardRenderer) { boardRenderer.spawnCardInstance(newInstance, spawnLocation, forPlayer); }
			
			if (startingLocation == CARD_LIST_LOC_INVALID)
			{
				addCardInstanceToList(newInstance, CARD_LIST_LOC_HAND, forPlayer);
			}
			
			return newInstance;
		}
		
		public function unspawnCardInstance(cardInstance:CardInstance) : void
		{
			removeCardInstanceFromItsList(cardInstance);
			if (boardRenderer) { boardRenderer.returnToDeck(cardInstance); }
			delete _cardInstances[cardInstance.instanceId];
		}
		
		public function applyCardEffectsID(instanceID:int):void
		{
			applyCardEffects(getCardInstance(instanceID));
		}
		
		public function applyCardEffects(sourceInstance:CardInstance):void
		{
			if (sourceInstance != null)
			{
				sourceInstance.updateEffectsApplied();
			}
		}
		
		public function sendToGraveyardID(instanceID:int):void
		{
			sendToGraveyard(getCardInstance(instanceID));
		}
		
		public function sendToGraveyard(targetInstance:CardInstance):void
		{
			if (targetInstance)
			{
				if (targetInstance.BanishInsteadOfGraveyard)
				{
					CardFXManager.getInstance().spawnFX(targetInstance, null, CardFXManager.getInstance()._placeFiendFXClassRef);
					removeCardInstanceFromItsList(targetInstance);
					boardRenderer.removeCardInstance(targetInstance);
					unspawnCardInstance(targetInstance);
				}
				else if (targetInstance.templateRef.isType(CardTemplate.CardType_Weather)) // Weather slot does not have playerID - Fix for weathers
				{
					addCardInstanceToList(targetInstance, CARD_LIST_LOC_GRAVEYARD, targetInstance.owningPlayer);
				}
				else
				{
					addCardInstanceToList(targetInstance, CARD_LIST_LOC_GRAVEYARD, targetInstance.listsPlayer);
				}
			}
			
			flushPendingSpawnedCards();
		}
		
		public function getSpawnedFaction(instance:CardInstance):int
		{
			return playerDeckDefinitions[instance.owningPlayer].getDeckFaction();
		}
		
		public function getStrongestNonHeroFromGraveyard(playerID:int):CardInstance
		{
			var graveyard:Vector.<CardInstance> = getCardInstanceList(CARD_LIST_LOC_GRAVEYARD, playerID);
			var strongestCard:CardInstance = null;
			var list_it:int;
			
			for (list_it = 0; list_it < graveyard.length; ++list_it)
			{
				if (!graveyard[list_it].templateRef.isType(CardTemplate.CardType_Hero) && (strongestCard == null || strongestCard.getTotalPower() < graveyard[list_it].getTotalPower()))
				{
					strongestCard = graveyard[list_it];
				}
			}
			return strongestCard;
		}
		
		// #J Fairly expensive function, avoid calling too often
		public function getScorchTargets(tags:int = CardTemplate.CardType_SeigeRangedMelee, validPlayer:int = PLAYER_BOTH):Vector.<CardInstance>
		{
			var outputList:Vector.<CardInstance> = new Vector.<CardInstance>();
			var highestPower:int = 0;
			var listIt:int;
			var playerIt:int;
			var currentList:Vector.<CardInstance>;
			var currentCard:CardInstance;
			
			for (playerIt = PLAYER_1; playerIt < (PLAYER_2 + 1); ++playerIt)
			{
				if (playerIt == validPlayer || validPlayer == PLAYER_BOTH)
				{
					
					if ((tags & CardTemplate.CardType_Melee) != CardTemplate.CardType_None)
					{
						currentList = getCardInstanceList(CARD_LIST_LOC_MELEE, playerIt);
						for (listIt = 0; listIt < currentList.length; ++listIt)
						{
							currentCard = currentList[listIt];
							
							if (currentCard.getTotalPower() >= highestPower && (currentCard.templateRef.typeArray & tags) != CardTemplate.CardType_None && !currentCard.templateRef.isType(CardTemplate.CardType_Hero))
							{
								if (currentCard.getTotalPower() > highestPower)
								{
									highestPower = currentCard.getTotalPower();
									outputList.length = 0;
									outputList.push(currentCard);
								}
								else
								{
									outputList.push(currentCard);
								}
							}
						}
					}
					
					if ((tags & CardTemplate.CardType_Ranged) != CardTemplate.CardType_None)
					{
						currentList = getCardInstanceList(CARD_LIST_LOC_RANGED, playerIt);
						for (listIt = 0; listIt < currentList.length; ++listIt)
						{
							currentCard = currentList[listIt];
							
							if (currentCard.getTotalPower() >= highestPower && (currentCard.templateRef.typeArray & tags) != CardTemplate.CardType_None && !currentCard.templateRef.isType(CardTemplate.CardType_Hero))
							{
								if (currentCard.getTotalPower() > highestPower)
								{
									highestPower = currentCard.getTotalPower();
									outputList.length = 0;
									outputList.push(currentCard);
								}
								else
								{
									outputList.push(currentCard);
								}
							}
						}
					}
					
					if ((tags & CardTemplate.CardType_Siege) != CardTemplate.CardType_None)
					{
						currentList = getCardInstanceList(CARD_LIST_LOC_SEIGE, playerIt);
						for (listIt = 0; listIt < currentList.length; ++listIt)
						{
							currentCard = currentList[listIt];
							
							if (currentCard.getTotalPower() >= highestPower && (currentCard.templateRef.typeArray & tags) != CardTemplate.CardType_None && !currentCard.templateRef.isType(CardTemplate.CardType_Hero))
							{
								if (currentCard.getTotalPower() > highestPower)
								{
									highestPower = currentCard.getTotalPower();
									outputList.length = 0;
									outputList.push(currentCard);
								}
								else
								{
									outputList.push(currentCard);
								}
							}
						}
					}
				}
			}
			
			return outputList;
		}
		
		public function summonFromDeck(playerID:int, templateID:int) : Boolean
		{
			var hadCard:Boolean = false;
			var newCardInstance:CardInstance;
			var playerDeck:GwintDeck = playerDeckDefinitions[playerID];
			
			while (playerDeck.tryDrawSpecificCard(templateID))
			{
				hadCard = true;
				newCardInstance = spawnCardInstance(templateID, playerID);
				newCardInstance.playSummonedFX = true;
				
				if (newCardInstance.templateRef.isType(CardTemplate.CardType_Melee))
				{
					addCardInstanceToList(newCardInstance, CARD_LIST_LOC_MELEE, playerID);
				}
				else if (newCardInstance.templateRef.isType(CardTemplate.CardType_Ranged))
				{
					addCardInstanceToList(newCardInstance, CARD_LIST_LOC_RANGED, playerID);
				}
				else if (newCardInstance.templateRef.isType(CardTemplate.CardType_Siege))
				{
					addCardInstanceToList(newCardInstance, CARD_LIST_LOC_SEIGE, playerID);
				}
			}
			
			return hadCard;
		}
		
		public function summonFromHand(playerID:int, templateID:int):void
		{
			var cardsInHand:Vector.<CardInstance>;
			var currentCard:CardInstance;
			var it:int;
			
			cardsInHand = getCardInstanceList(CARD_LIST_LOC_HAND, playerID);
			
			it = 0;
			while (it < cardsInHand.length)
			{
				currentCard = cardsInHand[it];
				
				if (currentCard.templateId == templateID)
				{
					currentCard.playSummonedFX = true;
					
					if (currentCard.templateRef.isType(CardTemplate.CardType_Melee))
					{
						addCardInstanceToList(currentCard, CARD_LIST_LOC_MELEE, playerID);
					}
					else if (currentCard.templateRef.isType(CardTemplate.CardType_Ranged))
					{
						addCardInstanceToList(currentCard, CARD_LIST_LOC_RANGED, playerID);
					}
					else if (currentCard.templateRef.isType(CardTemplate.CardType_Siege))
					{
						addCardInstanceToList(currentCard, CARD_LIST_LOC_SEIGE, playerID);
					}
				}
				else
				{
					++it;
				}
			}
		}
		
		public function ressurectFromGraveyard(playerID:int, count:int):void
		{
			var elligibleCardListFromOpponentsGrave:Vector.<CardInstance> = new Vector.<CardInstance>();
				
			getAllCreaturesNonHero(CARD_LIST_LOC_GRAVEYARD, playerID, elligibleCardListFromOpponentsGrave);
			
			var leftSummonCounter:int = count;
			
			while (elligibleCardListFromOpponentsGrave.length > 0 && leftSummonCounter > 0)
			{
				var resIndex:int = Math.min(Math.floor(Math.random() * elligibleCardListFromOpponentsGrave.length), elligibleCardListFromOpponentsGrave.length - 1);
				
				var ressurectInstance:CardInstance = elligibleCardListFromOpponentsGrave[resIndex];
				
				var location:int = CardManager.CARD_LIST_LOC_INVALID;
				
				if (ressurectInstance.templateRef.isType(CardTemplate.CardType_Melee))
				{
					location = CardManager.CARD_LIST_LOC_MELEE;
				}
				else if (ressurectInstance.templateRef.isType(CardTemplate.CardType_Ranged))
				{
					location = CardManager.CARD_LIST_LOC_RANGED;
				}
				else if (ressurectInstance.templateRef.isType(CardTemplate.CardType_Siege))
				{
					location = CardManager.CARD_LIST_LOC_SEIGE;
				}
				
				if (location != CardManager.CARD_LIST_LOC_INVALID)
				{
					var targetPlayerID:int = playerID;
					
					if (ressurectInstance.templateRef.isType(CardTemplate.CardType_Spy))
					{
						if (playerID == PLAYER_1)
						{
							targetPlayerID = PLAYER_2;
						}
						else
						{
							targetPlayerID = PLAYER_1;
						}
					}
					
					addCardInstanceToList(ressurectInstance, location, targetPlayerID);
					elligibleCardListFromOpponentsGrave.splice(resIndex, 1);
				}
				
				--leftSummonCounter;
			}
		}
		
		public function shuffleGraveyards():void
		{
			var currentRowList:Vector.<CardInstance> = new Vector.<CardInstance>();
			getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_GRAVEYARD, CardManager.PLAYER_1, currentRowList);
			getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_GRAVEYARD, CardManager.PLAYER_2, currentRowList);
			
			var listPlayer:int;
			var player1Affected:Boolean = false;
			var player2Affected:Boolean = false;
			
			for each (var cardInstance:CardInstance in currentRowList)
			{
				listPlayer = cardInstance.listsPlayer;
				
				if (listPlayer == CardManager.PLAYER_1 && !player1Affected)
				{
					player1Affected = true;
				}
				else if (listPlayer == CardManager.PLAYER_2 && !player2Affected)
				{
					player2Affected = true;
				}
				
				unspawnCardInstance(cardInstance);
				playerDeckDefinitions[listPlayer].readdCard(cardInstance.templateId, true);
			}
			
			if (player1Affected)
			{
				CardFXManager.getInstance().spawnFX_Location(1601, 901, CardFXManager.getInstance()._placeFiendFXClassRef);
			}
			
			if (player2Affected)
			{
				CardFXManager.getInstance().spawnFX_Location(1601, 141, CardFXManager.getInstance()._placeFiendFXClassRef);
			}
		}
		
		public function getBeserkersOnBoard(player:int, list:Vector.<CardInstance>):void
		{
			var currentInstance:CardInstance;
			
			for each (currentInstance in getCardInstanceList(CARD_LIST_LOC_MELEE, player))
			{
				if (currentInstance.templateRef.hasEffect(CardTemplate.CardEffect_Morph))
				{
					list.push(currentInstance);
				}
			}
			
			for each (currentInstance in getCardInstanceList(CARD_LIST_LOC_RANGED, player))
			{
				if (currentInstance.templateRef.hasEffect(CardTemplate.CardEffect_Morph))
				{
					list.push(currentInstance);
				}
			}
			
			for each (currentInstance in getCardInstanceList(CARD_LIST_LOC_SEIGE, player))
			{
				if (currentInstance.templateRef.hasEffect(CardTemplate.CardEffect_Morph))
				{
					list.push(currentInstance);
				}
			}
		}
		
		public function getBeserkersInHand(player:int, list:Vector.<CardInstance>):void
		{
			var currentInstance:CardInstance;
			
			for each (currentInstance in getCardInstanceList(CARD_LIST_LOC_HAND, player))
			{
				if (currentInstance.templateRef.hasEffect(CardTemplate.CardEffect_Morph))
				{
					list.push(currentInstance);
				}
			}
		}

		public function getHigherOrLowerValueCardFromTargetGraveyard(playerID:int, higherOrLower:Boolean = true, overrideSpy:Boolean = false, overrideNurse:Boolean = false, considerOwnGraveyard:Boolean = false):CardAndComboPoints
		{
			var elligibleCardListFromOpponentsGrave:Vector.<CardInstance> = new Vector.<CardInstance>();
				
			getAllCreaturesNonHero(CARD_LIST_LOC_GRAVEYARD, playerID, elligibleCardListFromOpponentsGrave);
			
			var list_it:int;
			var choosenCard:CardInstance;
			var currentCard:CardInstance;
			var cachedBestUnit:CardInstance;			
			var cachedBestNurseFromTargetGrave:CardInstance;
			var cachedBestSpy:CardInstance;
			var cachedBestMeleeScorch:CardInstance;
			var listOfNursesFromTargetGrave:Vector.<CardInstance> = new Vector.<CardInstance>();
			var spyPointsFromTargetGrave:int;
			var spyPointsFromOppositeGrave:int;
			var comboPoints:int = 0;
			var comboPointsFromOppositeGrave:int;
			var cardAndPoints:CardAndComboPoints = new CardAndComboPoints();

			// Main loop that collects best cards from Target grave
			for (list_it = 0; list_it < elligibleCardListFromOpponentsGrave.length; ++list_it)
			{
				currentCard = elligibleCardListFromOpponentsGrave[list_it];
				if (choosenCard == null) // First card
				{
					choosenCard = currentCard; 
				}

				if (currentCard.templateRef.isType(CardTemplate.CardType_Spy))
				{
					if (cachedBestSpy == null)
					{
						cachedBestSpy = currentCard; // First spy card
					}
					else if (cachedBestSpy && isBetterMatchForGrave(currentCard, cachedBestSpy, playerID, higherOrLower, overrideSpy, overrideNurse))
					{
						cachedBestSpy = currentCard; // Better spy
					}
				}
				else if (currentCard.templateRef.hasEffect(CardTemplate.CardEffect_MeleeScorch))
				{
					cachedBestMeleeScorch = currentCard;
				}
				else if (currentCard.templateRef.hasEffect(CardTemplate.CardEffect_Nurse)) // We want each nurse to ressurect another nurse
				{
					if (cachedBestNurseFromTargetGrave == null)
					{
						cachedBestNurseFromTargetGrave = currentCard; // First Nurse
					}
					else if (cachedBestNurseFromTargetGrave && isBetterMatchForGrave(currentCard, cachedBestNurseFromTargetGrave, playerID, higherOrLower, overrideSpy, overrideNurse))
					{
						cachedBestNurseFromTargetGrave = currentCard; // Better Nurse
					}
					listOfNursesFromTargetGrave.push(currentCard); // This is needed if we consider only own grave and for ex nurse can ressurect another nurse
				}
				else
				{
					if (cachedBestUnit == null)
					{
						cachedBestUnit = currentCard; // First Unit card
					}	
					else if (cachedBestUnit && isBetterMatchForGrave(currentCard, cachedBestUnit, playerID, higherOrLower, overrideSpy, overrideNurse))
					{
						cachedBestUnit = currentCard; // Better Unit card
					}				
				}
			}

			//trace("GFX -/////////////////////////////////////////////////////////////////////////////////////////////////////");
			//trace("GFX -/////// considerOwnGraveyard - ",considerOwnGraveyard);
			//trace("GFX -/////// listOfNursesFromTargetGrave.length - ",listOfNursesFromTargetGrave.length);
			//trace("GFX -/////// cachedBestNurseFromTargetGrave - ",cachedBestNurseFromTargetGrave);
			//trace("GFX -/////// overrideSpy - ",overrideSpy);
			//trace("GFX -/////// overrideNurse - ",overrideNurse);

			// IMPORTANT:
			// Consider ressurecting nurse from Target's grave in order to ressurect better cards from Opposite(own) grave
			// This [if] collects best cards of each type, translates them to ComboPoints which are compared to ComboPoints from other grave
			// If ComboPoints are higher from Opposite(own) grave -> ressurect best nurse
			if (considerOwnGraveyard && listOfNursesFromTargetGrave.length > 0)
			{
				var elligibleCardListOppositeGrave:Vector.<CardInstance> = new Vector.<CardInstance>();
				var oppositePlayer = playerID == CardManager.PLAYER_1 ? CardManager.PLAYER_2 : CardManager.PLAYER_1;
				getAllCreaturesNonHero(CARD_LIST_LOC_GRAVEYARD, oppositePlayer, elligibleCardListOppositeGrave);
				
				var choosenCardFromOppositeGrave:CardInstance;
				var currentCardFromOppositeGrave:CardInstance;
				var cachedBestUnitFromOppositeGrave:CardInstance;			
				var cachedBestSpyFromOppositeGrave:CardInstance;
				var listOfNursesFromOppositeGrave:Vector.<CardInstance> = new Vector.<CardInstance>();
				var cachedBestMeleeScorchFromOppositeGrave:CardInstance;

				// Main loop that collects best cards from Opposite grave
				for (list_it = 0; list_it < elligibleCardListOppositeGrave.length; ++list_it)
				{
					currentCardFromOppositeGrave = elligibleCardListOppositeGrave[list_it];
					if (choosenCardFromOppositeGrave == null) // First card
					{
						choosenCardFromOppositeGrave = currentCardFromOppositeGrave; 
					}

					if (currentCardFromOppositeGrave.templateRef.isType(CardTemplate.CardType_Spy))
					{
						if (cachedBestSpyFromOppositeGrave == null)
						{
							cachedBestSpyFromOppositeGrave = currentCardFromOppositeGrave; // First spy card
						}
						if (cachedBestSpyFromOppositeGrave && isBetterMatchForGrave(currentCardFromOppositeGrave, cachedBestSpyFromOppositeGrave, oppositePlayer, higherOrLower, overrideSpy, overrideNurse))
						{
							cachedBestSpyFromOppositeGrave = currentCardFromOppositeGrave; // Better spy
						}
					}
					else if (currentCardFromOppositeGrave.templateRef.hasEffect(CardTemplate.CardEffect_MeleeScorch))
					{
						cachedBestMeleeScorchFromOppositeGrave = currentCardFromOppositeGrave;
					}
					else if (currentCardFromOppositeGrave.templateRef.hasEffect(CardTemplate.CardEffect_Nurse)) // We want each nurse to ressurect another nurse
					{
						listOfNursesFromOppositeGrave.push(currentCardFromOppositeGrave);
					}
					else
					{
						if (cachedBestUnitFromOppositeGrave == null)
						{
							cachedBestUnitFromOppositeGrave = currentCardFromOppositeGrave; // First Unit card
						}						
						else if (cachedBestUnitFromOppositeGrave && isBetterMatchForGrave(currentCardFromOppositeGrave, cachedBestUnitFromOppositeGrave, oppositePlayer, higherOrLower, overrideSpy, overrideNurse))
						{
							cachedBestUnitFromOppositeGrave = currentCardFromOppositeGrave; // Better Unit card
						}				
					}
				}
				//trace("GFX -/////////////////////////////////////////////////////////////////////////////////////////////////////");
				//trace("GFX -////////////////////////////////////     OPPOSITE GRAVE     /////////////////////////////////////////");
				//trace("GFX -/////////////////////////////////////////////////////////////////////////////////////////////////////");
				// Calculating [comboPointsFromOppositeGrave]
				if (cachedBestSpyFromOppositeGrave)
				{
					comboPointsFromOppositeGrave = Math.max(0, (10-cachedBestSpyFromOppositeGrave.getTotalPower())); // 10 because the highest spy has 9 points
					spyPointsFromOppositeGrave = comboPointsFromOppositeGrave;
					//trace("GFX - Cached Spy [ ", comboPointsFromOppositeGrave, " ][ ", cachedBestSpyFromOppositeGrave," ]");
				}
				else if (cachedBestMeleeScorchFromOppositeGrave)
				{
					comboPointsFromOppositeGrave = cachedBestMeleeScorchFromOppositeGrave.getTotalPower();
					//trace("GFX - Cached MeleeScorch [ ", comboPointsFromOppositeGrave, " ][ ", cachedBestMeleeScorchFromOppositeGrave," ]");
				}
				else if (cachedBestUnitFromOppositeGrave)
				{
					comboPointsFromOppositeGrave = cachedBestUnitFromOppositeGrave.getTotalPower();
					//trace("GFX - Cached BestUnit [ ", comboPointsFromOppositeGrave, " ][ ", cachedBestUnitFromOppositeGrave," ]");
				}

				if (listOfNursesFromOppositeGrave)
				{
					for (var i = 0; i < listOfNursesFromOppositeGrave.length; ++i)
					{
						comboPointsFromOppositeGrave += listOfNursesFromOppositeGrave[i].getTotalPower();
						//trace("GFX - Cached Nurses [ ", listOfNursesFromOppositeGrave[i].getTotalPower(), " ][ ", listOfNursesFromOppositeGrave[i]," ]");
					}
				}
				if (cachedBestNurseFromTargetGrave)
				{
					comboPointsFromOppositeGrave += cachedBestNurseFromTargetGrave.getTotalPower();
					//trace("GFX - Adding Nurse from own grave [ ", cachedBestNurseFromTargetGrave.getTotalPower(), " ][ ", cachedBestNurseFromTargetGrave," ]");					
				}

				//trace("GFX - Total combo points after considering own grave [ ", comboPointsFromOppositeGrave, " ]");
			}

			//trace("GFX -/////////////////////////////////////////////////////////////////////////////////////////////////////");
			//trace("GFX -//////////////////////////////////////     TARGET GRAVE     /////////////////////////////////////////");
			//trace("GFX -/////////////////////////////////////////////////////////////////////////////////////////////////////");
			// Calculating [comboPoints] for Target's grave
			if (cachedBestSpy)
			{
				// Calculating how much spy is worth to us
				// Highest Spy has 9 points - and it is worth 1 combo point
				comboPoints = Math.max(0, (10-cachedBestSpy.getTotalPower()));
				spyPointsFromTargetGrave = comboPoints;
				choosenCard = cachedBestSpy;
				//trace("GFX - Cached Spy [ ", comboPoints, " ][ ", choosenCard," ]");
			}
			else if (cachedBestMeleeScorch)
			{
				comboPoints = cachedBestMeleeScorch.getTotalPower();
				choosenCard = cachedBestMeleeScorch;
				//trace("GFX - Cached MeleeScorch [ ", comboPoints, " ][ ", choosenCard," ]");
			}
			else if (cachedBestUnit)
			{
				comboPoints = cachedBestUnit.getTotalPower();
				choosenCard = cachedBestUnit;
				//trace("GFX - Cached BestUnit [ ", comboPoints, " ][ ", choosenCard," ]");
			}

			if (!considerOwnGraveyard && listOfNursesFromTargetGrave)
			{
				for (i = 0; i < listOfNursesFromTargetGrave.length; ++i)
				{
					comboPoints += listOfNursesFromTargetGrave[i].getTotalPower();
					//trace("GFX - Cached Nurses [ ", listOfNursesFromTargetGrave[i].getTotalPower(), " ][ ", listOfNursesFromTargetGrave[i]," ]");
				}
			}
			else if (!cachedBestSpy && !cachedBestMeleeScorch && !cachedBestUnit && cachedBestNurseFromTargetGrave)
			{
				comboPoints = cachedBestNurseFromTargetGrave.getTotalPower();
				choosenCard = cachedBestNurseFromTargetGrave;
				//trace("GFX - Cached Best Nurse [ ", cachedBestNurseFromTargetGrave.getTotalPower(), " ][ ", cachedBestNurseFromTargetGrave," ]");
			}
			//trace("GFX - Total combo points [ ", comboPoints, " ] and instance ", choosenCard);
			//trace("GFX -/////////////////////////////////////////////////////////////////////////////////////////////////////");
			//trace("GFX - spyPointsFromTargetGrave [ ", spyPointsFromTargetGrave, " ]");
			//trace("GFX - spyPointsFromOppositeGrave [ ", spyPointsFromOppositeGrave, " ]");

			// Choose from which grave its better to ressurect
			
			// [ 0 ] Just consider Target graveyard == Ressurect best card from own grave
			// ELSE
			// [ 1 ] No spies && My grave has better combo == Ressurect Nurse from his grave
			// [ 2 ] Spy in my grave || My Spy > His spy == Ressurect Nurse from his grave
			// [ 3 ] No spies && My grave has better combo == Ressurect card from own grave
			if (considerOwnGraveyard && cachedBestNurseFromTargetGrave)
			{
				if (!spyPointsFromOppositeGrave && !spyPointsFromTargetGrave && comboPointsFromOppositeGrave > comboPoints)
				{
					cardAndPoints.cardInstance = cachedBestNurseFromTargetGrave;
					cardAndPoints.comboPoints = comboPointsFromOppositeGrave;
					//trace("GFX - Choosing 1[comboPointsFromOppositeGrave]");
				}
				else if ((!spyPointsFromTargetGrave && spyPointsFromOppositeGrave) || (spyPointsFromOppositeGrave > spyPointsFromTargetGrave))
				{
					cardAndPoints.cardInstance = cachedBestNurseFromTargetGrave;
					cardAndPoints.comboPoints = comboPointsFromOppositeGrave;
					//trace("GFX - Choosing 2[comboPointsFromOppositeGrave]");
				}
				else
				{
					cardAndPoints.cardInstance = choosenCard;
					cardAndPoints.comboPoints = comboPoints;
					//trace("GFX - Choosing 3[comboPoints]");
				}
			}
			else
			{
				cardAndPoints.cardInstance = choosenCard;
				cardAndPoints.comboPoints = comboPoints;
				//trace("GFX - Choosing 4[comboPoints]");
			}
			
			//trace("GFX -/////////////////////////////////////////////////////////////////////////////////////////////////////");
			//trace("GFX - Choosen combo points [ ", cardAndPoints.comboPoints, " ] and instance ", cardAndPoints.cardInstance);
			//trace("GFX -/////////////////////////////////////////////////////////////////////////////////////////////////////");
			//trace("GFX -/////////////////////////////////////////////////////////////////////////////////////////////////////");
			return cardAndPoints;
		}

		// higherOrLower -> true = higher , false = lower 
		public function isBetterMatchForGrave(currentCard:CardInstance, choosenCard:CardInstance, playerID:int, higherOrLower:Boolean, overrideSpy:Boolean, overrideNurse:Boolean):Boolean
		{
			var currentIsSpy:Boolean = currentCard.templateRef.isType(CardTemplate.CardType_Spy);
			var choosenIsSpy:Boolean = choosenCard.templateRef.isType(CardTemplate.CardType_Spy);
			var currentIsMeleeScorch:Boolean = currentCard.templateRef.hasEffect(CardTemplate.CardEffect_MeleeScorch);
			var choosenIsMeleeScorch:Boolean = choosenCard.templateRef.hasEffect(CardTemplate.CardEffect_MeleeScorch);
			var currentIsNurse:Boolean = currentCard.templateRef.hasEffect(CardTemplate.CardEffect_Nurse);
			var choosenIsNurse:Boolean = choosenCard.templateRef.hasEffect(CardTemplate.CardEffect_Nurse);

			var opponentPlayer = playerID == CardManager.PLAYER_1 ? CardManager.PLAYER_2 : CardManager.PLAYER_1;
			var opponentsMeleeScore:int = calculatePlayerScore(CARD_LIST_LOC_MELEE, opponentPlayer);

			if (overrideSpy || overrideNurse) // Opposite value if override enabled 
			{
				var oppositeBehavior = higherOrLower == true ? false : true;
			}

			if (currentIsSpy || choosenIsSpy)
			{
				if (!choosenIsSpy)
				{
					return true;
				}
				if (overrideSpy && currentIsSpy && checkIfHigherOrLower(currentCard, choosenCard, oppositeBehavior)) // Override -> if higher then lower
				{
					//trace("GFX - 1 oppositeBehavior [ ", oppositeBehavior, " checkIfHigherOrLower(currentCard, choosenCard, oppositeBehavior) ",checkIfHigherOrLower(currentCard, choosenCard, oppositeBehavior));
					//trace("GFX - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
					return true;
				}
				if (currentIsSpy && checkIfHigherOrLower(currentCard, choosenCard, higherOrLower))
				{
					//trace("GFX - 2 oppositeBehavior [ ", higherOrLower, " checkIfHigherOrLower(currentCard, choosenCard, oppositeBehavior) ",checkIfHigherOrLower(currentCard, choosenCard, higherOrLower));
					//trace("GFX - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
					return true;
				}
				return false;
			}
			else if (currentIsMeleeScorch || choosenIsMeleeScorch) // I didnt change this setup for future override (will be easier to implement)
			{
				if (choosenIsMeleeScorch)
				{
					return false;
				}
				if (opponentsMeleeScore >= 10)
				{
					return true;
				}
				return false;
			}
			else if (currentIsNurse || choosenIsNurse)
			{
				if (!choosenIsNurse)
				{
					return true;
				}
				if (overrideNurse && currentIsNurse && checkIfHigherOrLower(currentCard, choosenCard, oppositeBehavior)) // Override -> if higher then lower
				{
					return true;
				}
				if (currentIsNurse && checkIfHigherOrLower(currentCard, choosenCard, true))
				{
					return true;
				}
				return false;
			}
			else if (checkIfHigherOrLower(currentCard, choosenCard, higherOrLower))
			{
				return true;
			}
			return false;
		}

		public function getHigherOrLowerValueTargetCardOnBoard(castingInstance:CardInstance, playerID:int, higherOrLower:Boolean = true, overrideSpy:Boolean = false, overrideNurse:Boolean = false):CardInstance
		{
			var elligibleCardList:Vector.<CardInstance> = new Vector.<CardInstance>();
				
			getAllCreaturesNonHero(CARD_LIST_LOC_MELEE, playerID, elligibleCardList);
			getAllCreaturesNonHero(CARD_LIST_LOC_RANGED, playerID, elligibleCardList);
			getAllCreaturesNonHero(CARD_LIST_LOC_SEIGE, playerID, elligibleCardList);
			
			var list_it:int;
			var choosenCard:CardInstance;
			var currentCard:CardInstance;

			for (list_it = 0; list_it < elligibleCardList.length; ++list_it)
			{
				currentCard = elligibleCardList[list_it];
				if (castingInstance.canBeCastOn(currentCard))
				{
					if (choosenCard == null) // First card
					{
						choosenCard = currentCard; 
					}
					else if (isBetterMatch(currentCard, choosenCard, playerID, higherOrLower, overrideSpy, overrideNurse)) // #J/M this algorithm prioritizes dummying cards
					{
						choosenCard = currentCard; 
					}
				}
			}
			return choosenCard;
		}
		
		// higherOrLower -> true = higher , false = lower 
		public function isBetterMatch(currentCard:CardInstance, choosenCard:CardInstance, playerID:int, higherOrLower:Boolean, overrideSpy:Boolean, overrideNurse:Boolean):Boolean
		{
			var currentIsSpy:Boolean = currentCard.templateRef.isType(CardTemplate.CardType_Spy);
			var choosenIsSpy:Boolean = choosenCard.templateRef.isType(CardTemplate.CardType_Spy);
			var currentIsMeleeScorch:Boolean = currentCard.templateRef.hasEffect(CardTemplate.CardEffect_MeleeScorch);
			var choosenIsMeleeScorch:Boolean = choosenCard.templateRef.hasEffect(CardTemplate.CardEffect_MeleeScorch);
			var currentIsNurse:Boolean = currentCard.templateRef.hasEffect(CardTemplate.CardEffect_Nurse);
			var choosenIsNurse:Boolean = choosenCard.templateRef.hasEffect(CardTemplate.CardEffect_Nurse);

			var opponentPlayer = playerID == CardManager.PLAYER_1 ? CardManager.PLAYER_2 : CardManager.PLAYER_1;
			var opponentsMeleeScore:int = calculatePlayerScore(CARD_LIST_LOC_MELEE, opponentPlayer);

			if (overrideSpy || overrideNurse) // Opposite value if override enabled 
			{
				var oppositeBehavior = higherOrLower == true ? false : true;
			}

			if (currentIsSpy || choosenIsSpy)
			{
				if (!choosenIsSpy)
				{
					return true;
				}
				if (overrideSpy && currentIsSpy && checkIfHigherOrLower(currentCard, choosenCard, oppositeBehavior)) // Override -> if higher then lower
				{
					return true;
				}
				if (currentIsSpy && checkIfHigherOrLower(currentCard, choosenCard, higherOrLower))
				{
					return true;
				}
				return false;
			}
			else if (currentIsMeleeScorch || choosenIsMeleeScorch) // I didnt change this setup for future override (will be easier to implement)
			{
				if (choosenIsMeleeScorch)
				{
					return false;
				}
				if (opponentsMeleeScore >= 10)
				{
					return true;
				}
				return false;
			}
			else if (currentIsNurse || choosenIsNurse)
			{
				if (!choosenIsNurse)
				{
					return true;
				}
				if (overrideNurse && currentIsNurse && checkIfHigherOrLower(currentCard, choosenCard, oppositeBehavior)) // Override -> if higher then lower
				{
					return true;
				}
				if (currentIsNurse && checkIfHigherOrLower(currentCard, choosenCard, true))
				{
					return true;
				}
				return false;
			}
			else if (checkIfHigherOrLower(currentCard, choosenCard, higherOrLower))
			{
				return true;
			}
			return false;
		}


		public function checkIfHigherOrLower(firstCard:CardInstance, secondCard:CardInstance, higherOrLower):Boolean
		{
			if (higherOrLower)
			{
				if (firstCard.getTotalPower() > secondCard.getTotalPower())
				{
					//trace("GFX - [higherOrLower] firstCard.getTotalPower() [ ", firstCard.getTotalPower(), "] , secondCard.getTotalPower() [ ", secondCard.getTotalPower(), " ]");
					return true;
				}
				return false;
			}
			else
			{
				if (firstCard.getTotalPower() < secondCard.getTotalPower())
				{
					//trace("GFX - [oppositeBehavior] firstCard.getTotalPower() [ ", firstCard.getTotalPower(), "] , secondCard.getTotalPower() [ ", secondCard.getTotalPower(), " ]");
					return true;
				}
				return false;
			}
		}		

		public function recalculateScores():void
		{
			var currentWinningPlayer = getWinningPlayer();
			
			var p2SeigeScore:int = calculatePlayerScore(CARD_LIST_LOC_SEIGE, PLAYER_2);
			var p2RangedScore:int = calculatePlayerScore(CARD_LIST_LOC_RANGED, PLAYER_2);
			var p2MeleeScore:int = calculatePlayerScore(CARD_LIST_LOC_MELEE, PLAYER_2);
			var p1MeleeScore:int = calculatePlayerScore(CARD_LIST_LOC_MELEE, PLAYER_1);
			var p1RangedScore:int = calculatePlayerScore(CARD_LIST_LOC_RANGED, PLAYER_1);
			var p1SeigeScore:int = calculatePlayerScore(CARD_LIST_LOC_SEIGE, PLAYER_1);
			
			currentPlayerScores[PLAYER_1] = p1MeleeScore + p1RangedScore + p1SeigeScore;
			playerRenderers[PLAYER_1].score = currentPlayerScores[PLAYER_1];
			currentPlayerScores[PLAYER_2] = p2MeleeScore + p2RangedScore + p2SeigeScore;
			playerRenderers[PLAYER_2].score = currentPlayerScores[PLAYER_2];
			
			playerRenderers[PLAYER_1].setIsWinning(currentPlayerScores[PLAYER_1] > currentPlayerScores[PLAYER_2]);
			playerRenderers[PLAYER_2].setIsWinning(currentPlayerScores[PLAYER_2] > currentPlayerScores[PLAYER_1]);
			
			boardRenderer.updateRowScores(p1SeigeScore, p1RangedScore, p1MeleeScore, p2MeleeScore, p2RangedScore, p2SeigeScore);
			
			if (currentWinningPlayer != getWinningPlayer())
			{
				GwintGameMenu.mSingleton.playSound("gui_gwint_whose_winning_changed");
			}
		}
		
		public function getWinningPlayer() : int
		{
			if (currentPlayerScores[PLAYER_1] > currentPlayerScores[PLAYER_2])
			{
				return PLAYER_1;
			}
			else if (currentPlayerScores[PLAYER_1] < currentPlayerScores[PLAYER_2])
			{
				return PLAYER_2;
			}
			
			return PLAYER_INVALID;
		}
		
		public function calculatePlayerScore(listID:int, playerID:int):int
		{
			var score:int = 0;
			var i:int;
			var currentList:Vector.<CardInstance>;
			
			currentList = getCardInstanceList(listID, playerID);
			for (i = 0; i < currentList.length; ++i)
			{
				score += currentList[i].getTotalPower();
			}
			
			return score;
		}
		
		public function CalculateCardPowerPotentials():void
		{
			var i:int;
			var currentList:Vector.<CardInstance>;
			
			currentList = getCardInstanceList(CARD_LIST_LOC_HAND, PLAYER_1);
			for (i = 0; i < currentList.length; ++i)
			{
				currentList[i].recalculatePowerPotential(this);
			}
			
			currentList = getCardInstanceList(CARD_LIST_LOC_HAND, PLAYER_2);
			for (i = 0; i < currentList.length; ++i)
			{
				currentList[i].recalculatePowerPotential(this);
			}
		}
		
		public function GetRessurectionTargets(playerID:int, copyList:Vector.<CardInstance>, allowRecalculations:Boolean):void
		{
			var currentInstance:CardInstance;
			var cardList:Vector.<CardInstance> = getCardInstanceList(CardManager.CARD_LIST_LOC_GRAVEYARD, playerID);
			
			for (var it:int = 0; it < cardList.length; ++it)
			{
				currentInstance = cardList[it];
				
				if (currentInstance.templateRef.isType(CardTemplate.CardType_Creature) && !currentInstance.templateRef.isType(CardTemplate.CardType_Hero))
				{
					if (allowRecalculations)
					{
						currentInstance.recalculatePowerPotential(this);
					}
					copyList.push(currentInstance);
				}
			}
		}
		
		public function hasRowModifier(list:int, player:int, effect:int):Boolean
		{
			for each (var instance:CardInstance in getCardInstanceList(list, player))
			{
				if (instance.templateRef.hasEffect(effect))
				{
					return true;
				}
			}
			
			return false;
		}
		
		protected function cardSorter(element1:CardInstance, element2:CardInstance):Number
		{
			//#J based on card Instance
			
			if (element1.templateId == element2.templateId)
			{
				return 0;
			}
			
			var element1Template:CardTemplate = element1.templateRef;
			var element2Template:CardTemplate = element2.templateRef;
			
			var battlefield1:int = element1Template.getCreatureType();
			var battlefield2:int = element2Template.getCreatureType();
			
			if (battlefield1 == CardTemplate.CardType_None && battlefield2 == CardTemplate.CardType_None)
			{
				return element1.templateId - element2.templateId;
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
				if (element1Template.power != element2Template.power)
				{
					return element1Template.power - element2Template.power;
				}
				else
				{
					return element1.templateId - element2.templateId;
				}
			}
		}
		
		public function traceRoundResults():void
		{
			trace("GFX -------------------------------- START TRACE ROUND RESULTS ----------------------------------");
			trace("GFX =============================================================================================");
			if (roundResults == null)
			{
				trace("GFX -------------- Round Results is empty!!! -------------");
			}
			else
			{
				var i:int;
				
				for (i = 0; i < roundResults.length; ++i)
				{
					trace("GFX - " + roundResults[i]);
				}
			}
			
			trace("GFX =============================================================================================");
			trace("GFX ---------------------------------- END TRACE ROUND RESULTS ----------------------------------");
		}
		
		public function listIDToString(listID:int):String
		{
			switch (listID)
			{
			case CARD_LIST_LOC_DECK:
				return "DECK";
			case CARD_LIST_LOC_HAND:
				return "HAND";
			case CARD_LIST_LOC_GRAVEYARD:
				return "GRAVEYARD";
			case CARD_LIST_LOC_SEIGE:
				return "SEIGE";
			case CARD_LIST_LOC_RANGED:
				return "RANGED";
			case CARD_LIST_LOC_MELEE:
				return "MELEE";
			case CARD_LIST_LOC_SEIGEMODIFIERS:
				return "SEIGEMODIFIERS";
			case CARD_LIST_LOC_RANGEDMODIFIERS:
				return "RANGEDMODIFIERS";
			case CARD_LIST_LOC_MELEEMODIFIERS:
				return "MELEEMODIFIERS";
			case CARD_LIST_LOC_WEATHERSLOT:
				return "WEATHER";
			case CARD_LIST_LOC_LEADER:
				return "LEADER";
			case CARD_LIST_LOC_INVALID:
			default:
				return "INVALID";
			}
			
			return "???";
		}
	}
}