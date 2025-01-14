package red.game.witcher3.menus.gwint
{
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.menus.gwint.CardAndComboPoints;
	public class CardLeaderInstance extends CardInstance
	{
		public var leaderEffect:int;
		
		public function get hasBeenUsed() : Boolean
		{
			return !_canBeUsed;
		}
		
		private var _canBeUsed:Boolean = true;
		public function get canBeUsed() : Boolean
		{
			if (!_canBeUsed)
			{
				return false;
			}
			else
			{
				return canAbilityBeApplied();
			}
		}
		public function set canBeUsed(value:Boolean):void 
		{
			_canBeUsed = value;
		}
		
		override public function finializeSetup() : void
		{
			super.finializeSetup();
			
			if (templateRef == null || templateRef.getFirstEffect() == CardTemplate.CardEffect_None)
			{
				throw new Error("GFX [ERROR] tried to finalize card leader with invalid template info - " + templateId);
			}
			else
			{
				leaderEffect = templateRef.getFirstEffect();
				
				if (leaderEffect == CardTemplate.CardEffect_Counter_King)
				{
					_canBeUsed = false;
				}
			}
		}
		
		override public function recalculatePowerPotential(cardManager:CardManager):void
		{
			var i = 0;
			var currentCard:CardInstance;
			_lastCalculatedPowerPotential.powerChangeResult = 0;
			_lastCalculatedPowerPotential.strategicValue = -1;
			_lastCalculatedPowerPotential.sourceCardInstanceRef = this;
			var cardManagerRef:CardManager = CardManager.getInstance();
			var currentRowList:Vector.<CardInstance> = new Vector.<CardInstance>();
			var opponentPlayer = owningPlayer == CardManager.PLAYER_1 ? CardManager.PLAYER_2 : CardManager.PLAYER_1;
			var cardsInHand = cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, owningPlayer);
			var cardAndComboPoints:CardAndComboPoints;
			var comboPoints:int;

			switch (templateRef.getFirstEffect())
			{
			case CardTemplate.CardEffect_11th_card: // Nothing to calculate
			case CardTemplate.CardEffect_Counter_King:
			case CardTemplate.CardEffect_RandomRessurect:
			case CardTemplate.CardEffect_DoubleSpy:
				break;
			case CardTemplate.CardEffect_Pick_Fog:
			case CardTemplate.CardEffect_Pick_Frost:
			case CardTemplate.CardEffect_Pick_Weather:
			case CardTemplate.CardEffect_Pick_Rain:
				_lastCalculatedPowerPotential.strategicValue = cardManagerRef.cardValues.weatherCardValue;
				break;
			case CardTemplate.CardEffect_View_3_Enemy:
				_lastCalculatedPowerPotential.strategicValue = 0; // For AI, this ability is just a time burner
				break;
			case CardTemplate.CardEffect_Siege_Horn:
			case CardTemplate.CardEffect_Range_Horn:
			case CardTemplate.CardEffect_Melee_Horn:
				if (templateRef.getFirstEffect() == CardTemplate.CardEffect_Siege_Horn)
				{
					cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_SEIGE, owningPlayer, currentRowList);
				}
				else if (templateRef.getFirstEffect() == CardTemplate.CardEffect_Range_Horn)
				{
					cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_RANGED, owningPlayer, currentRowList);
				}
				else if (templateRef.getFirstEffect() == CardTemplate.CardEffect_Melee_Horn)
				{
					cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_MELEE, owningPlayer, currentRowList);
				}
				
				var rowIncrease:int = 0;
				for (i = 0; i < currentRowList.length; ++i)
				{
					currentCard = currentRowList[i];
					
					var oldValue:int = currentCard.getTotalPower();
					
					// Temporarly buff it to see what the actual value is as normally calculated (avoids double logic)
					currentCard.effectedByCardsRefList.push(this);
					rowIncrease = currentCard.getTotalPower() - oldValue;
					currentCard.effectedByCardsRefList.pop();
				}
				_lastCalculatedPowerPotential.powerChangeResult = rowIncrease;
				_lastCalculatedPowerPotential.strategicValue = cardManagerRef.cardValues.hornCardValue;
				break;
			case CardTemplate.CardEffect_Siege_Scorch:
				currentRowList = cardManagerRef.getScorchTargets(CardTemplate.CardType_Siege, opponentPlayer);
				
				for (i = 0; i < currentRowList.length; ++i)
				{
					currentCard = currentRowList[i];
					
					if (currentCard.listsPlayer == owningPlayer)
					{
						_lastCalculatedPowerPotential.powerChangeResult -= currentCard.getTotalPower();
					}
					else
					{
						_lastCalculatedPowerPotential.powerChangeResult += currentCard.getTotalPower();
					}
				}
				
				_lastCalculatedPowerPotential.strategicValue = cardManagerRef.cardValues.scorchCardValue;
				break;
			case CardTemplate.CardEffect_MeleeScorch:
				currentRowList = cardManagerRef.getScorchTargets(CardTemplate.CardType_Melee, opponentPlayer);
				
				for (i = 0; i < currentRowList.length; ++i)
				{
					currentCard = currentRowList[i];
					
					if (currentCard.listsPlayer == owningPlayer)
					{
						_lastCalculatedPowerPotential.powerChangeResult -= currentCard.getTotalPower();
					}
					else
					{
						_lastCalculatedPowerPotential.powerChangeResult += currentCard.getTotalPower();
					}
				}
				
				_lastCalculatedPowerPotential.strategicValue = cardManagerRef.cardValues.scorchCardValue;
				break;
			case CardTemplate.CardEffect_Clear_Weather:
				// Add in positive gains for player
				// {
					currentRowList.length = 0;
					cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_MELEE, owningPlayer, currentRowList);
					cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_RANGED, owningPlayer, currentRowList);
					cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_SEIGE, owningPlayer, currentRowList);
					
					for (i = 0; i < currentRowList.length; ++i)
					{
						_lastCalculatedPowerPotential.powerChangeResult += currentRowList[i].getTotalPower(true) - currentRowList[i].getTotalPower();
					}
				// }
				
				// Remove in positive gains for opponent
				// {
					currentRowList.length = 0;
					cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_MELEE, opponentPlayer, currentRowList);
					cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_RANGED, opponentPlayer, currentRowList);
					cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_SEIGE, opponentPlayer, currentRowList);
					
					for (i = 0; i < currentRowList.length; ++i)
					{
						_lastCalculatedPowerPotential.powerChangeResult -= currentRowList[i].getTotalPower(true) - currentRowList[i].getTotalPower();
					}
				// }
				
				_lastCalculatedPowerPotential.strategicValue = cardManagerRef.cardValues.weatherCardValue;
				break;
			case CardTemplate.CardEffect_Resurect_Enemy:
				cardAndComboPoints = cardManagerRef.getHigherOrLowerValueCardFromTargetGraveyard(opponentPlayer, true, true, false, true);
				if (cardAndComboPoints != null)
				{
					comboPoints = cardAndComboPoints.comboPoints;
					// Seems counterintuitive, but the lower the strategic value, the higher chance he'll play it just to buy time. The strongest the card, the more likely this is a good move
					if (cardsInHand.length < 8 || Math.random() <= (1 / cardsInHand*0.5))
					{
						_lastCalculatedPowerPotential.strategicValue = Math.max(0, (10 - comboPoints));
						_lastCalculatedPowerPotential.powerChangeResult = cardAndComboPoints.cardInstance.getTotalPower();
						//trace("GFX - CardEffect_Resurect_Enemy strategicValue = [ ",_lastCalculatedPowerPotential.strategicValue," ]");
					}
					else
					{
						_lastCalculatedPowerPotential.strategicValue = 1000;
						//trace("GFX - CardEffect_Resurect_Enemy - NOT CONSIDERING BECAUSE (cardsInHand < 8 || Math.random() <= (1 / cardsInHand))");
					}
					//trace("GFX -/////////////////////////////////////////////////////////////////////////////////////////////////////");
				}
				break;
			case CardTemplate.CardEffect_Resurect:
				cardAndComboPoints = cardManagerRef.getHigherOrLowerValueCardFromTargetGraveyard(owningPlayer, true, true, false);
				if (cardAndComboPoints != null)
				{
					comboPoints = cardAndComboPoints.comboPoints;
					// Seems counterintuitive, but the lower the strategic value, the higher chance he'll play it just to buy time. The strongest the card, the more likely this is a good move
					if (cardsInHand.length < 8 || Math.random() <= (1 / cardsInHand*0.5))
					{
						_lastCalculatedPowerPotential.strategicValue = Math.max(0, (10 - comboPoints));
						_lastCalculatedPowerPotential.powerChangeResult = cardAndComboPoints.cardInstance.getTotalPower();
						//trace("GFX - CardEffect_Resurect_Enemy strategicValue = [ ",_lastCalculatedPowerPotential.strategicValue," ]");
					}
					else
					{
						_lastCalculatedPowerPotential.strategicValue = 1000;
						//trace("GFX - CardEffect_Resurect_Enemy - NOT CONSIDERING BECAUSE (cardsInHand < 8 || Math.random() <= (1 / cardsInHand))");
					}
					//trace("GFX -/////////////////////////////////////////////////////////////////////////////////////////////////////");
				}
				break;
			case CardTemplate.CardEffect_Bin2_Pick1: // TODO - For now AI just doesn't use this card as its the most complicated one to implement
				//var numCardsUnder3:int = 0;
				//return 0;
				break;
			case CardTemplate.CardEffect_RangedScorch:
				currentRowList = cardManagerRef.getScorchTargets(CardTemplate.CardType_Ranged, opponentPlayer);
				
				for (i = 0; i < currentRowList.length; ++i)
				{
					currentCard = currentRowList[i];
					
					if (currentCard.listsPlayer == owningPlayer)
					{
						_lastCalculatedPowerPotential.powerChangeResult -= currentCard.getTotalPower();
					}
					else
					{
						_lastCalculatedPowerPotential.powerChangeResult += currentCard.getTotalPower();
					}
				}
				
				_lastCalculatedPowerPotential.strategicValue = cardManagerRef.cardValues.scorchCardValue;
				break;
			case CardTemplate.CardEffect_AgileReposition:
				{
					currentRowList.length = 0;
					cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_RANGED, owningPlayer, currentRowList);
					cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_MELEE, owningPlayer, currentRowList);
					
					for (i = 0; i < currentRowList.length; ++i)
					{
						currentCard = currentRowList[i];
						_lastCalculatedPowerPotential.powerChangeResult += currentCard.scoreGainOnReposition();
					}
					
					_lastCalculatedPowerPotential.strategicValue = Math.max(0, 10 - _lastCalculatedPowerPotential.powerChangeResult);
					break;
				}
			case CardTemplate.CardEffect_WeatherResistant:
				{
					// Does nothing
					break;
				}
			case CardTemplate.CardEffect_GraveyardShuffle:
				{
					currentRowList.length = 0;
					cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_GRAVEYARD, CardManager.PLAYER_1, currentRowList);
					cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_GRAVEYARD, CardManager.PLAYER_2, currentRowList);
					_lastCalculatedPowerPotential.strategicValue = Math.max(0, 15 - currentRowList.length);
					break;
				}
			}
		}
		
		protected function canAbilityBeApplied():Boolean
		{
			var cardManagerRef:CardManager = CardManager.getInstance();
			var playerDeck:GwintDeck = cardManagerRef.playerDeckDefinitions[owningPlayer];
			var templateList:Vector.<int> = new Vector.<int>();
			var instanceList:Vector.<CardInstance> = new Vector.<CardInstance>();
			var currentRowList:Vector.<CardInstance> = new Vector.<CardInstance>();
			var currentCard:CardInstance;
			var i:int;
			
			switch (templateRef.getFirstEffect())
			{
			case CardTemplate.CardEffect_Clear_Weather:
				if (cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_WEATHERSLOT, CardManager.PLAYER_INVALID).length == 0)
				{
					return false;
				}
				break;
			case CardTemplate.CardEffect_Pick_Fog:
				playerDeck.getCardsInDeck(CardTemplate.CardType_Weather, CardTemplate.CardEffect_Ranged, templateList); 
				for ( i = 0; i < templateList.length; ++i )
				{
					// Skellige storm is both Ranged and Siege, so we need check against this.
					var cardTemplate:CardTemplate = cardManagerRef.getCardTemplate( templateList[ i ] );
					if ( !cardTemplate.hasEffect( CardTemplate.CardEffect_Siege ) )
					{
						return true;
					}
				}
				return false;
				break;
			case CardTemplate.CardEffect_Siege_Horn:
				if (cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_SEIGEMODIFIERS, owningPlayer).length > 0)
				{
					return false;
				}
				break;
			case CardTemplate.CardEffect_Siege_Scorch:
				if (cardManagerRef.getScorchTargets(CardTemplate.CardType_Siege, notOwningPlayer).length == 0 || cardManagerRef.calculatePlayerScore(CardManager.CARD_LIST_LOC_SEIGE, notOwningPlayer) < 10)
				{
					return false;
				}
				break;
			case CardTemplate.CardEffect_Pick_Frost:
				playerDeck.getCardsInDeck(CardTemplate.CardType_Weather, CardTemplate.CardEffect_Melee, templateList);
				return templateList.length > 0;
				break;
			case CardTemplate.CardEffect_Range_Horn:
				if (cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_RANGEDMODIFIERS, owningPlayer).length > 0)
				{
					return false;
				}
				break;
			case CardTemplate.CardEffect_11th_card:
				return true;
				break;
			case CardTemplate.CardEffect_MeleeScorch:
				if (cardManagerRef.getScorchTargets(CardTemplate.CardType_Melee, notOwningPlayer).length == 0 || cardManagerRef.calculatePlayerScore(CardManager.CARD_LIST_LOC_MELEE, notOwningPlayer) < 10)
				{
					return false;
				}
				break;
			case CardTemplate.CardEffect_Pick_Rain:
				playerDeck.getCardsInDeck(CardTemplate.CardType_Weather, CardTemplate.CardEffect_Siege, templateList);
				return templateList.length > 0;
				break;
			case CardTemplate.CardEffect_View_3_Enemy:
				if (cardManagerRef && cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, notOwningPlayer))
				{
					return cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, notOwningPlayer).length > 0;
				}
				break;
			case CardTemplate.CardEffect_Resurect_Enemy:
				cardManagerRef.GetRessurectionTargets(notOwningPlayer, instanceList, false);
				if (instanceList.length == 0)
				{
					return false;
				}
				break;
			case CardTemplate.CardEffect_Counter_King:
				return false;
				break;
			case CardTemplate.CardEffect_Bin2_Pick1:
				instanceList = cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, owningPlayer);
				return instanceList != null && instanceList.length > 1 && playerDeck.cardIndicesInDeck.length > 0;
				break;
			case CardTemplate.CardEffect_Pick_Weather:
				playerDeck.getCardsInDeck(CardTemplate.CardType_Weather, CardTemplate.CardEffect_None, templateList);
				return templateList.length > 0;
				break;
			case CardTemplate.CardEffect_Resurect:
				cardManagerRef.GetRessurectionTargets(owningPlayer, instanceList, false);
				if (instanceList.length == 0)
				{
					return false;
				}
				break;
			case CardTemplate.CardEffect_Melee_Horn:
				if (cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_MELEEMODIFIERS, owningPlayer).length > 0)
				{
					return false;
				}
				break;
			case CardTemplate.CardEffect_RangedScorch:
				if (cardManagerRef.getScorchTargets(CardTemplate.CardType_Ranged, notOwningPlayer).length == 0 || cardManagerRef.calculatePlayerScore(CardManager.CARD_LIST_LOC_RANGED, notOwningPlayer) < 10)
				{
					return false;
				}
				break;
			case CardTemplate.CardEffect_AgileReposition:
				{
					currentRowList.length = 0;
					cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_RANGED, owningPlayer, currentRowList);
					cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_MELEE, owningPlayer, currentRowList);
					
					for (i = 0; i < currentRowList.length; ++i)
					{
						currentCard = currentRowList[i];
						if (currentCard.scoreGainOnReposition() > 0)
						{
							return true;
						}
					}
					
					return false;
				}
				break;
			case CardTemplate.CardEffect_RandomRessurect:
			case CardTemplate.CardEffect_DoubleSpy:
				{
					return false;
				}
			case CardTemplate.CardEffect_WeatherResistant:
				{
					return false;
				}
			case CardTemplate.CardEffect_GraveyardShuffle:
				{
					currentRowList.length = 0;
					cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_GRAVEYARD, CardManager.PLAYER_1, currentRowList);
					cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_GRAVEYARD, CardManager.PLAYER_2, currentRowList);
					return currentRowList.length > 0;
				}
			}
			
			return true;
		}
		
		public function ApplyLeaderAbility(isAI:Boolean) : void
		{
			if (!_canBeUsed)
			{
				throw new Error("GFX [ERROR] - Tried to apply a card ability when its disabled!");
			}
			
			var cardManagerRef:CardManager = CardManager.getInstance();
			var playerDeck:GwintDeck = cardManagerRef.playerDeckDefinitions[owningPlayer];
			var templateList:Vector.<int> = new Vector.<int>();
			var currentCard:CardInstance;
			var cardAndComboPoints:CardAndComboPoints;
			var currentRowList:Vector.<CardInstance> = new Vector.<CardInstance>();
			var i:int;
			
			_canBeUsed = false;
			
		 	if( templateId == 5001 )
			{
				GwintGameMenu.mSingleton.playSound("gui_gwint_ske_leader_weather_half_damage");
			}
			else if( templateId == 5002 )
			{
				GwintGameMenu.mSingleton.playSound("gui_gwint_ske_leader_graveyard");
			}
			else
			{
				GwintGameMenu.mSingleton.playSound("gui_gwint_using_ability");	
			}
			
			switch (templateRef.getFirstEffect())
			{
			case CardTemplate.CardEffect_Clear_Weather:
				clearWeather();
				break;
			case CardTemplate.CardEffect_Pick_Fog:
				playerDeck.getCardsInDeck(CardTemplate.CardType_Weather, CardTemplate.CardEffect_Ranged, templateList);
				var cardId:int = -1;
				for (i = 0; i < templateList.length; ++i)
				{
					// Skellige storm is both Ranged and Siege, so we need check against this.
					var cardTemplate:CardTemplate = cardManagerRef.getCardTemplate(templateList[i]);
					if (!cardTemplate.hasEffect(CardTemplate.CardEffect_Siege))
					{
						cardId = templateList[i];
						break;
					}
				}
				
				if (cardId >= 0)
				{
					cardManagerRef.tryDrawAndPlaySpecificCard_Weather(owningPlayer, cardId);
				}
				else
				{
					throw new Error("GFX [ERROR] - tried to pick fog but did not have any");
				}
				break;
			case CardTemplate.CardEffect_Siege_Horn:
				applyHorn(CardManager.CARD_LIST_LOC_SEIGEMODIFIERS, owningPlayer);
				break;
			case CardTemplate.CardEffect_Siege_Scorch:
				scorch(CardTemplate.CardType_Siege);
				break;
			case CardTemplate.CardEffect_Pick_Frost:
				playerDeck.getCardsInDeck(CardTemplate.CardType_Weather, CardTemplate.CardEffect_Melee, templateList);
				if (templateList.length > 0)
				{
					cardManagerRef.tryDrawAndPlaySpecificCard_Weather(owningPlayer, templateList[0]);
				}
				else
				{
					throw new Error("GFX [ERROR] - tried to pick frost but did not have any");
				}
				break;
			case CardTemplate.CardEffect_Range_Horn:
				applyHorn(CardManager.CARD_LIST_LOC_RANGEDMODIFIERS, owningPlayer);
				break;
			case CardTemplate.CardEffect_11th_card:
				throw new Error("GFX [ERROR] - tried to apply 11th card ability which should not occur through here");
				break;
			case CardTemplate.CardEffect_MeleeScorch:
				scorch(CardTemplate.CardType_Melee);
				break;
			case CardTemplate.CardEffect_Pick_Rain:
				playerDeck.getCardsInDeck(CardTemplate.CardType_Weather, CardTemplate.CardEffect_Siege, templateList);
				if (templateList.length > 0)
				{
					cardManagerRef.tryDrawAndPlaySpecificCard_Weather(owningPlayer, templateList[0]);
				}
				else
				{
					throw new Error("GFX [ERROR] - tried to pick Rain but did not have any");
				}
				break;
			case CardTemplate.CardEffect_View_3_Enemy:
				if (!isAI)
				{
					ShowEnemyHand(3);
				}
				break;
			case CardTemplate.CardEffect_Resurect_Enemy:
				if (isAI && !cardManagerRef.cardEffectManager.randomResEnabled)
				{
					cardAndComboPoints = cardManagerRef.getHigherOrLowerValueCardFromTargetGraveyard(notOwningPlayer, true, true, false, true);
					if (cardAndComboPoints)
					{
						currentCard = cardAndComboPoints.cardInstance;
						handleResurrectChoice(currentCard.instanceId);
					}
					else
					{
						throw new Error("GFX [ERROR] - AI tried to ressurect enemy card when there wasn't a valid target!");
					}
				}
				else
				{
					resurrectGraveyard(notOwningPlayer);
				}
				break;
			case CardTemplate.CardEffect_Counter_King:
				throw new Error("GFX [ERROR] - tried to apply couner king ability which should not occur through here");
				break;
			case CardTemplate.CardEffect_Bin2_Pick1:
				if (isAI)
				{
					trace("GFX [WARNING] - AI tried to bin2, pick 1 but it was never properly implemented");
				}
				else
				{
					binPick(2, 1);
				}
				break;
			case CardTemplate.CardEffect_Pick_Weather:
				pickWeather(isAI);
				break;
			case CardTemplate.CardEffect_Resurect:
				if (isAI && !cardManagerRef.cardEffectManager.randomResEnabled)
				{
					cardAndComboPoints = cardManagerRef.getHigherOrLowerValueCardFromTargetGraveyard(owningPlayer, true, true, false);
					if (cardAndComboPoints)
					{
						currentCard = cardAndComboPoints.cardInstance;
						handleResurrectChoice(currentCard.instanceId);
					}
					else
					{
						throw new Error("GFX [ERROR] - AI tried to ressurect enemy card when there wasn't a valid target!");
					}
				}
				else
				{
					resurrectGraveyard(owningPlayer);
				}
				break;
			case CardTemplate.CardEffect_Melee_Horn:
				applyHorn(CardManager.CARD_LIST_LOC_MELEEMODIFIERS, owningPlayer);
				break;
			case CardTemplate.CardEffect_RangedScorch:
				scorch(CardTemplate.CardType_Ranged);
				break;
			case CardTemplate.CardEffect_AgileReposition:
				{
					currentRowList.length = 0;
					cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_RANGED, owningPlayer, currentRowList);
					cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_MELEE, owningPlayer, currentRowList);
					
					for (i = 0; i < currentRowList.length; ++i)
					{
						currentCard = currentRowList[i];
						if (currentCard.scoreGainOnReposition() > 0)
						{
							cardManagerRef.addCardInstanceToList(currentCard, currentCard.inList == CardManager.CARD_LIST_LOC_MELEE ? CardManager.CARD_LIST_LOC_RANGED : CardManager.CARD_LIST_LOC_MELEE, currentCard.listsPlayer);
						}
					}
				}
				break;
			case CardTemplate.CardEffect_RandomRessurect:
				throw new Error("GFX [ERROR] - tried to apply random ressurect ability which should not occur through here");
				break;
			case CardTemplate.CardEffect_DoubleSpy:
				throw new Error("GFX [ERROR] - tried to apply double ability which should not occur through here");
				break;
			case CardTemplate.CardEffect_WeatherResistant:
				{
					throw new Error("GFX [ERROR] - tried to apply double ability which should not occur through here");
					break;
				}
			case CardTemplate.CardEffect_GraveyardShuffle:
				{
					cardManagerRef.shuffleGraveyards();
					break;
				}
			}
		}
		
		protected function clearWeather() : void
		{
			var cardFXManager:CardFXManager = CardFXManager.getInstance();
			cardFXManager.spawnFX(null, applyClearWeather, cardFXManager._clearWeatherFXClassRef);
		}
		
		protected function applyClearWeather(cardInstance:CardInstance = null) : void
		{
			var cardManagerRef:CardManager = CardManager.getInstance();
			var cardList:Vector.<CardInstance> = cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_WEATHERSLOT, CardManager.PLAYER_INVALID);
						
			while (cardList.length > 0)
			{
				cardManagerRef.sendToGraveyard(cardList[0]);
			}
		}
		
		protected function applyHorn(location:int, player:int):void
		{
			var cardManagerRef:CardManager = CardManager.getInstance();
			
			var newHornCard:CardInstance = cardManagerRef.spawnCardInstance(1, player, CardManager.CARD_LIST_LOC_LEADER);
			cardManagerRef.addCardInstanceToList(newHornCard, location, player);
		}
		
		protected function scorch(location:int):void
		{
			var cardManagerRef:CardManager = CardManager.getInstance();
			var cardFXManager:CardFXManager = CardFXManager.getInstance();
			
			var scorchList:Vector.<CardInstance> = cardManagerRef.getScorchTargets(location, notOwningPlayer);
			var i:int;
			
			GwintGameMenu.mSingleton.playSound("gui_gwint_scorch");
			for (i = 0; i < scorchList.length; ++i)
			{
				cardFXManager.playScorchEffectFX(scorchList[i], onScorchFXEnd);
			}
		}
		
		protected function ShowEnemyHand(maxCards:int):void
		{
			var cardManagerRef:CardManager = CardManager.getInstance();
			var cardsInHand:Vector.<CardInstance>;
			var cardsToChoose:Vector.<CardInstance> = new Vector.<CardInstance>();
			var cardsToShow:Vector.<CardInstance> = new Vector.<CardInstance>();
			var numCardsLeft:int = maxCards;
			var i:int;
			
			cardsInHand = cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, notOwningPlayer);
			
			for (i = 0; i < cardsInHand.length; ++i)
			{
				cardsToChoose.push(cardsInHand[i]);
			}
			
			var randomIndex:int;
			
			while (numCardsLeft > 0 && cardsToChoose.length > 0)
			{
				randomIndex = Math.min(Math.floor(Math.random() * cardsToChoose.length), cardsToChoose.length - 1);
				cardsToShow.push(cardsToChoose[randomIndex]);
				cardsToChoose.splice(randomIndex, 1);
				numCardsLeft -= 1;
			}
			
			if (cardsToShow.length > 0)
			{
				GwintGameFlowController.getInstance().mcChoiceDialog.showDialogCardInstances(cardsToShow, null, handleHandShowClose, "[[gwint_showing_enemy_hand]]");
			}
			else
			{
				throw new Error("GFX [ERROR] - Tried to ShowEnemyHand with no cards chosen?! - " + cardsInHand.length);
			}
		}
		
		protected function handleHandShowClose(instanceId:int = -1):void
		{
			GwintGameFlowController.getInstance().mcChoiceDialog.hideDialog();
		}
		
		protected function resurrectGraveyard(targetPlayer:int):void
		{
			var cardManagerRef:CardManager = CardManager.getInstance();
			
			var cardsInGraveyard:Vector.<CardInstance> = new Vector.<CardInstance>();
			
			cardManagerRef.GetRessurectionTargets(targetPlayer, cardsInGraveyard, true);
			
			if (cardsInGraveyard.length > 0)
			{
				if (cardManagerRef.cardEffectManager.randomResEnabled)
				{
					var randomIndex:int = Math.min(Math.floor(Math.random() * cardsInGraveyard.length), cardsInGraveyard.length - 1);
					cardManagerRef.addCardInstanceToList(cardsInGraveyard[randomIndex], CardManager.CARD_LIST_LOC_HAND, owningPlayer);
				}
				else if (cardsInGraveyard.length == 1)
				{
					cardManagerRef.addCardInstanceToList(cardsInGraveyard[0], CardManager.CARD_LIST_LOC_HAND, owningPlayer);
				}
				else
				{
					GwintGameFlowController.getInstance().mcChoiceDialog.showDialogCardInstances(cardsInGraveyard, handleResurrectChoice, null, "[[gwint_choose_card_to_ressurect]]");
				}
			}
			else
			{
				throw new Error("GFX [ERROR] - tried to ressurect from player: " + targetPlayer + "'s graveyard but found no cards");
			}
		}
		
		protected function handleResurrectChoice(instanceId:int = -1):void
		{
			GwintGameFlowController.getInstance().mcChoiceDialog.hideDialog();
			
			if (instanceId == -1)
			{
				throw new Error("GFX [ERROR] - tried to ressurect card with no valid id");
			}
			
			CardManager.getInstance().addCardInstanceIDToList(instanceId, CardManager.CARD_LIST_LOC_HAND, owningPlayer);
		}
		
		protected function pickWeather(isAI:Boolean):void
		{
			var cardManagerRef:CardManager = CardManager.getInstance();
			var playerDeck:GwintDeck = cardManagerRef.playerDeckDefinitions[owningPlayer];
			var templateList:Vector.<int> = new Vector.<int>();
			playerDeck.getCardsInDeck(CardTemplate.CardType_Weather, CardTemplate.CardEffect_None, templateList);
			
			if (templateList.length == 1 || (isAI && templateList.length > 0))
			{
				cardManagerRef.tryDrawAndPlaySpecificCard_Weather(owningPlayer, templateList[0]);
			}
			else if (templateList.length > 0)
			{
				GwintGameFlowController.getInstance().mcChoiceDialog.showDialogCardTemplates(templateList, handleCardDrawChoice_Weather, null, "[[gwint_pick_card_to_draw]]");
			}
			else
			{
				throw new Error("GFX [ERROR] - tried to pick weather card when there was none");
			}
		}
		
		protected function handleCardDrawChoice_Weather(templateID:int = -1):void
		{
			GwintGameFlowController.getInstance().mcChoiceDialog.hideDialog();
			
			if (templateID == -1)
			{
				throw new Error("GFX [ERROR] - tried to draw card with invalid ID");
			}
			
			CardManager.getInstance().tryDrawAndPlaySpecificCard_Weather(owningPlayer, templateID);
		}
		
		protected var numToBin:int;
		protected var numBinnedSoFar:int;
		protected var numToPick:int;
		protected var numPickedSoFar:int;
		protected function binPick(numBin:int, numPick:int):void
		{
			numToBin = numBin;
			numBinnedSoFar = 0;
			numToPick = numPick;
			numPickedSoFar = 0;
			
			if (numToBin > numBinnedSoFar)
			{
				askBin();
			}
			else if (numToPick > numPickedSoFar)
			{
				askPick();
			}
			else
			{
				throw new Error("GFX [ERROR] - called binPick with invalid values");
			}
		}
		
		protected function askBin():void
		{
			var cardsInHand:Vector.<CardInstance> = CardManager.getInstance().getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, owningPlayer);
			if (cardsInHand.length == 0)
			{
				throw new Error("GFX [ERROR] - Tried to bin a card when there are none left in the hand");
			}
			else
			{
				GwintGameFlowController.getInstance().mcChoiceDialog.showDialogCardInstances(cardsInHand, handleBinChoice, null, "[[gwint_choose_card_to_dump]]");
			}
		}
		
		protected function handleBinChoice(instanceId:int = -1):void
		{
			var cardManagerRef:CardManager = CardManager.getInstance();
			++numBinnedSoFar;
			cardManagerRef.addCardInstanceIDToList(instanceId, CardManager.CARD_LIST_LOC_GRAVEYARD, owningPlayer);
			GwintGameMenu.mSingleton.playSound("gui_gwint_discard_card");
			
			if (numToBin > numBinnedSoFar)
			{
				askBin();
			}
			else if (numToPick > numPickedSoFar)
			{
				askPick();
			}
			else
			{
				GwintGameFlowController.getInstance().mcChoiceDialog.hideDialog();
			}
		}
		
		protected function askPick():void
		{
			var cardManagerRef:CardManager = CardManager.getInstance();
			var playerDeck:GwintDeck = cardManagerRef.playerDeckDefinitions[owningPlayer];
			var templateList:Vector.<int> = new Vector.<int>();
			
			playerDeck.getCardsInDeck(CardTemplate.CardType_None, CardTemplate.CardEffect_None, templateList);
			
			if (templateList.length == 0)
			{
				throw new Error("GFX [ERROR] - Tried to pick a card when there are none left in the deck");
			}
			else
			{
				GwintGameFlowController.getInstance().mcChoiceDialog.showDialogCardTemplates(templateList, handlePickChoice, null, "[[gwint_pick_card_to_draw]]");
			}
		}
		
		protected function handlePickChoice(templateID:int = -1):void
		{
			++numPickedSoFar;
			CardManager.getInstance().tryDrawSpecificCard(owningPlayer, templateID);
			
			if (numToPick > numPickedSoFar)
			{
				askPick();
			}
			else
			{
				GwintGameFlowController.getInstance().mcChoiceDialog.hideDialog();
			}
		}
		
		override public function toString():String
		{
			return super.toString() + ", canBeUsed: " + canBeUsed + ", canBeApplied: " + canAbilityBeApplied;
		}
	}
}