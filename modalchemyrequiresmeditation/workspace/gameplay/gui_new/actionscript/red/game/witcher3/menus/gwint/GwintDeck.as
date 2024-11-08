package red.game.witcher3.menus.gwint
{
	public class GwintDeck
	{
		/*---------------------------------------
		 *  Witcher Script variables
		 *---------------------------------------*/
		public var deckName:String;
		public var cardIndices:Array;
		public var selectedKingIndex:int;
		public var specialCard:int;
		public var isUnlocked:Boolean = false;
		public var dynamicCardRequirements:Array;
		public var dynamicCards:Array;
		/*---------------------------------------*/
		
		/*---------------------------------------
		 *  Deck Builder variables
		 *---------------------------------------*/
		public var refreshCallback:Function;
		public var onCardChangedCallback:Function;
		/*---------------------------------------*/
		
		private var _deckRenderer:GwintDeckRenderer;
		public function set DeckRenderer(value:GwintDeckRenderer):void
		{
			_deckRenderer = value;
			_deckRenderer.factionString = getDeckKingTemplate().getFactionString();
			_deckRenderer.cardCount = cardIndices.length;
		}
		
		public var cardIndicesInDeck:Vector.<int> = new Vector.<int>();
		
		public function getDeckFaction():int
		{
			var kingTemplate:CardTemplate = getDeckKingTemplate();
			
			if (kingTemplate)
			{
				return kingTemplate.factionIdx;
			}
			
			return CardTemplate.FactionId_Error;
		}
		
		public function getFactionNameString():String
		{
			switch (getDeckFaction())
			{
				case CardTemplate.FactionId_Nilfgaard:
					return "[[gwint_faction_name_nilfgaard]]";
				case CardTemplate.FactionId_No_Mans_Land:
					return "[[gwint_faction_name_no_mans_land]]";
				case CardTemplate.FactionId_Northern_Kingdom:
					return "[[gwint_faction_name_northern_kingdom]]";
				case CardTemplate.FactionId_Scoiatael:
					return "[[gwint_faction_name_scoiatael]]";
				case CardTemplate.FactionId_Skellige:
					return "[[gwint_faction_name_skellige]]";
			}
			
			return "Invalid Faction for Deck";
		}
		
		public function getFactionPerkString():String
		{
			switch (getDeckFaction())
			{
				case CardTemplate.FactionId_Nilfgaard:
					return "[[gwint_faction_ability_nilf]]";
				case CardTemplate.FactionId_No_Mans_Land:
					return "[[gwint_faction_ability_nml]]";
				case CardTemplate.FactionId_Northern_Kingdom:
					return "[[gwint_faction_ability_nr]]";
				case CardTemplate.FactionId_Scoiatael:
					return "[[gwint_faction_ability_scoia]]";
				case CardTemplate.FactionId_Skellige:
					return "[[gwint_faction_ability_ske]]";
			}
			
			return "Invalid Faction, no perk";
		}
		
		public function getDeckKingTemplate():CardTemplate
		{
			return CardManager.getInstance().getCardTemplate(selectedKingIndex);
		}
		
		public function toString():String
		{
			var indicesString:String = "";
			var i:int;
			
			for (i = 0; i < cardIndices.length; ++i)
			{
				indicesString += cardIndices[i].toString() + " - ";
			}
			
			return "[GwintDeck] Name:" + deckName + ", selectedKing:" + selectedKingIndex.toString() + ", indices:" + indicesString;
		}
		
		public function originalStength():int
		{
			var strength:int = 0;
			var i:int;
			var cardTemplate:CardTemplate;
			var cardManagerRef:CardManager = CardManager.getInstance();
			
			for (i = 0; i < cardIndices.length; ++i)
			{
				cardTemplate = cardManagerRef.getCardTemplate(cardIndices[i]);
				if (cardTemplate.isType(CardTemplate.CardType_Creature))
				{
					strength += cardTemplate.power;
				}
				
				switch (cardTemplate.getFirstEffect())
				{
					case CardTemplate.CardEffect_Melee:
					case CardTemplate.CardEffect_Ranged:
					case CardTemplate.CardEffect_Siege:
					case CardTemplate.CardEffect_ClearSky:
						strength += 2;
						break;
					case CardTemplate.CardEffect_UnsummonDummy:
						strength += 4;
						break;
					case CardTemplate.CardEffect_Horn:
						strength += 5;
						break;
					case CardTemplate.CardEffect_Scorch:
					case CardTemplate.CardEffect_MeleeScorch:
						strength += 6;
						break;
					case CardTemplate.CardEffect_SummonClones:
						strength += 3;
						break;
					case CardTemplate.CardEffect_ImproveNeighbours:
						strength += 4;
						break;
					case CardTemplate.CardEffect_Nurse:
						strength += 4;
						break;
					case CardTemplate.CardEffect_Draw2:
						strength += 6;
						break;
					case CardTemplate.CardEffect_SameTypeMorale:
						strength += 4;
						break;
				}
			}
			
			trace("GFX -#AI#----- > ", strength);
			return strength;
		}
		
		public function shuffleDeck(otherDeckStrength:int):void
		{
			var originalIndices:Vector.<int> = new Vector.<int>();
			var i:int;
			var randomIndex:int;
			var numItems:int = cardIndices.length;
			
			// Build a copy of the list (temporary)
			for (i = 0; i < numItems; ++i)
			{
				originalIndices.push(cardIndices[i]);
			}
			
			adjustDeckToDifficulty(otherDeckStrength, originalIndices);
			
			// Make sure the array is empty
			cardIndicesInDeck.length = 0;
			
			while (originalIndices.length > 0)
			{
				randomIndex = Math.min(Math.floor(Math.random() * originalIndices.length), originalIndices.length - 1);
				
				cardIndicesInDeck.push(originalIndices[randomIndex]);
				originalIndices.splice(randomIndex, 1);
			}
			
			if (specialCard != -1)
			{
				cardIndicesInDeck.push(specialCard);
			}
			
			if (_deckRenderer)
			{
				_deckRenderer.cardCount = cardIndicesInDeck.length;
			}
		}
		
		private function adjustDeckToDifficulty(otherDeckStr : int, listToAddTo:Vector.<int>):void
		{
			var i:int;
			
			if (dynamicCardRequirements.length > 0 && dynamicCardRequirements.length == dynamicCards.length)
			{
				trace("GFX -#AI#------------------- Deck balance --------------------");
				for (i = 0; i < dynamicCardRequirements.length; ++i)
				{
					if (otherDeckStr >= dynamicCardRequirements[i])
					{
						trace("GFX -#AI# Requirement [ " + dynamicCardRequirements[i] + " ] - Adding card with id [ " + dynamicCards[i] + "]");
						listToAddTo.push(dynamicCards[i]);
					}
				}
				trace("GFX -#AI#-----------------------------------------------------");
			}
		}
		
		public function readdCard(templateID:int, random:Boolean = false):void
		{
			if (random)
			{
				var newIndex:int = Math.min(Math.floor(Math.random() * cardIndicesInDeck.length), cardIndicesInDeck.length - 1);
				cardIndicesInDeck.splice(newIndex, 0, templateID);
			}
			else
			{
				cardIndicesInDeck.unshift(templateID);
			}
			
			_deckRenderer.cardCount = cardIndicesInDeck.length;
		}
		
		public function drawCard():int
		{
			if (cardIndicesInDeck.length > 0)
			{
				if (_deckRenderer) { _deckRenderer.cardCount = cardIndicesInDeck.length - 1; }
				
				// #J soooo im drawing from the end of the list because pop makes that easier and it doesn't really matter as long as were consistent
				return cardIndicesInDeck.pop();
			}
			else
			{
				return CardInstance.INVALID_INSTANCE_ID;
			}
		}

		public function getCardsInDeck(type:int, effect:int, list:Vector.<int>):void
		{
			var templateRef:CardTemplate;
			var cardManagerRef:CardManager = CardManager.getInstance();
			
			for (var i:int = 0; i < cardIndicesInDeck.length; ++i)
			{
				templateRef = cardManagerRef.getCardTemplate(cardIndicesInDeck[i]);
				
				if (templateRef)
				{
					if ((templateRef.isType(type) || type == CardTemplate.CardType_None) && 
						(templateRef.hasEffect(effect) || effect == CardTemplate.CardEffect_None))
					{
						list.push(cardIndicesInDeck[i]);
					}
				}
				else
				{
					throw new Error("GFX [ERROR] - failed to fetch template reference for card ID: " + cardIndicesInDeck[i]);
				}
			}
		}
		
		public function tryDrawSpecificCard(templateID:int):Boolean
		{
			for (var i:int = 0; i < cardIndicesInDeck.length; ++i)
			{
				if (cardIndicesInDeck[i] == templateID)
				{
					cardIndicesInDeck.splice(i, 1);
					return true;
				}
			}
			
			return false;
		}
		
		public function numCopiesLeft(cardID:int):int
		{
			var i:int;
			var numCopies:int = 0;
			
			for (i = 0; i < cardIndicesInDeck.length; ++i)
			{
				if (cardID == cardIndicesInDeck[i])
				{
					++numCopies;
				}
			}
			
			return numCopies;
		}
		
		/*---------------------------------------
		 *  Deck Builder functions
		 *---------------------------------------*/
		public function dbGetNumCopiesOfCard(cardID:int):int
		{
			var i:int;
			var numCopies:int = 0;
			
			for (i = 0; i < cardIndices.length; ++i)
			{
				if (cardID == cardIndices[i])
				{
					++numCopies;
				}
			}
			
			return numCopies;
		}
		
		public function triggerRefresh():void
		{
			if (refreshCallback != null)
			{
				refreshCallback();
			}
		}
		
		public function dbAddCard(cardID:int):void
		{
			cardIndices.push(cardID);
			
			if (onCardChangedCallback != null)
			{
				onCardChangedCallback(cardID, dbGetNumCopiesOfCard(cardID));
			}
		}
		
		public function dbRemoveCard(cardID:int):void
		{
			var i:int;
			
			for (i = 0; i < cardIndices.length; ++i)
			{
				if (cardIndices[i] == cardID)
				{
					cardIndices.splice(i, 1);
					break;
				}
			}
			
			if (onCardChangedCallback != null)
			{
				onCardChangedCallback(cardID, dbGetNumCopiesOfCard(cardID));
			}
		}
		
		public function dbIsValidDeck():Boolean
		{
			var unitCount:int = 0;
			var i:int;
			var curTemplate:CardTemplate;
			var cardManagerRef:CardManager = CardManager.getInstance();
			
			for (i = 0; i < cardIndices.length; ++i)
			{
				curTemplate = cardManagerRef.getCardTemplate(cardIndices[i]);
				
				if (curTemplate.isType(CardTemplate.CardType_Creature))
				{
					++unitCount;
				}
			}
			
			trace("GFX RRR dbIsValidDeck ", unitCount);
			
			if (unitCount < 22)
			{
				return false;
			}
			
			return true;
		}
		
		public function dbCanAddCard(cardID:int):Boolean
		{
			var specialCardCount:int = 0;
			var i:int;
			var curTemplate:CardTemplate;
			var cardManagerRef:CardManager = CardManager.getInstance();
			
			var addingCardTemplate:CardTemplate = cardManagerRef.getCardTemplate(cardID);
			
			if (!addingCardTemplate.isType(CardTemplate.CardType_Creature))
			{			
				for (i = 0; i < cardIndices.length; ++i)
				{
					curTemplate = cardManagerRef.getCardTemplate(cardIndices[i]);
					
					if (!curTemplate.isType(CardTemplate.CardType_Creature))
					{
						++specialCardCount;
					}
				}
				
				return specialCardCount < 10;
			}
			
			return true;
		}
		
		public function dbCountCards(type:int, effect:int):int
		{
			var count:int = 0;
			var templateRef:CardTemplate;
			var cardManagerRef:CardManager = CardManager.getInstance();
			
			for (var i:int = 0; i < cardIndices.length; ++i)
			{
				templateRef = cardManagerRef.getCardTemplate(cardIndices[i]);
				
				if ((templateRef.isType(type) || type == CardTemplate.CardType_None) && 
					(templateRef.hasEffect(effect) || effect == CardTemplate.CardEffect_None))
				{
					++count;
				}
			}
			
			return count;
		}
		/*---------------------------------------*/
	}
}