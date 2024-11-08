package red.game.witcher3.menus.gwint
{
	public class CardInstance
	{
		public static const INVALID_INSTANCE_ID:int = -1;
		
		public var templateId:int;
		public var templateRef:CardTemplate;
		public var instanceId:int = INVALID_INSTANCE_ID;
		public var owningPlayer:int = CardManager.PLAYER_INVALID;
		
		public var inList:int = CardManager.CARD_LIST_LOC_INVALID;
		public var listsPlayer:int = CardManager.PLAYER_INVALID;
		
		public var effectingCardsRefList:Vector.<CardInstance> = new Vector.<CardInstance>(); // The list of cards this card is effecting
		public var effectedByCardsRefList:Vector.<CardInstance> = new Vector.<CardInstance>(); // The list of cards this card is effected by
		
		public var lastListApplied:int = CardManager.CARD_LIST_LOC_INVALID;
		public var lastListPlayerApplied:int = CardManager.PLAYER_INVALID;
		
		public var powerChangeCallback:Function;
		
		public var playSummonedFX:Boolean = false;
		
		public var BanishInsteadOfGraveyard:Boolean = false;
		
		public var InstancePositioning:Boolean = false;
		
		public function getTotalPower(ignoreWeather:Boolean = false):int
		{
			var iter:int;
			var currentBuffer:CardInstance;
			var affectedByWeather:Boolean = false;
			var hornCounter:int = 0;	// Using a counter instead of a bool since cards like dandelion are essentially secondary horn sources
			var moraleCounter:int = 0;
			var tightBondsCounter:int = 0;
			var cardManager:CardManager = CardManager.getInstance();
			
			if (!templateRef.isType(CardTemplate.CardType_Hero))
			{
				for (iter = 0; iter < effectedByCardsRefList.length; ++iter)
				{
					currentBuffer = effectedByCardsRefList[iter];
					
					if (currentBuffer.templateRef.isType(CardTemplate.CardType_Weather))
					{
						affectedByWeather = true;
					}
					
					if (currentBuffer.templateRef.hasEffect(CardTemplate.CardEffect_Horn) ||
						currentBuffer.templateRef.hasEffect(CardTemplate.CardEffect_Siege_Horn) ||
						currentBuffer.templateRef.hasEffect(CardTemplate.CardEffect_Range_Horn) ||
						currentBuffer.templateRef.hasEffect(CardTemplate.CardEffect_Melee_Horn))
					{
						++hornCounter;
					}
					
					if (currentBuffer.templateRef.hasEffect(CardTemplate.CardEffect_ImproveNeighbours))
					{
						++moraleCounter;
					}
					
					if (currentBuffer.templateRef.hasEffect(CardTemplate.CardEffect_SameTypeMorale))
					{
						++tightBondsCounter;
					}
				}
			}
			
			var totalPower:int = cardManager.getCardTemplate(templateId).power;
			
			if (!ignoreWeather && affectedByWeather)
			{
				if (cardManager.halfWeatherEnabled(listsPlayer))
				{
					totalPower = Math.max(0, Math.floor(cardManager.getCardTemplate(templateId).power / 2));
				}
				else
				{
					totalPower = Math.min(1, cardManager.getCardTemplate(templateId).power);
				}
			}
			
			if (templateRef.isType(CardTemplate.CardType_Spy) && cardManager.cardEffectManager.doubleSpyEnabled && !templateRef.isType(CardTemplate.CardType_Hero))
			{
				totalPower = totalPower * 2;
			}
			
			var additionalPower:int = 0;
			
			additionalPower += totalPower * tightBondsCounter;
			
			additionalPower += moraleCounter;
			
			if (hornCounter > 0) // To prevent stacking with Dandilion
			//for (iter = 0; iter < hornCounter; ++iter)
			{
				additionalPower += totalPower + additionalPower;
			}
			
			return totalPower + additionalPower;
		}
		
		public function updateTemplateID(newTemplateId:int):void
		{
			templateId = newTemplateId;
			templateRef = CardManager.getInstance().getCardTemplate(templateId);
		}
		
		public function get notOwningPlayer():int
		{
			return owningPlayer == CardManager.PLAYER_1 ? CardManager.PLAYER_2 : CardManager.PLAYER_1;
		}
		
		public function get notListPlayer():int
		{
		return listsPlayer == CardManager.PLAYER_1 ? CardManager.PLAYER_2 : CardManager.PLAYER_1;
		}

		public function finializeSetup() : void
		{
			
		}
		
		public function toString():String
		{
			return " powerChange[ " + this.getOptimalTransaction().powerChangeResult + " ] , strategicValue[ " + this.getOptimalTransaction().strategicValue +  " ] , CardName[ " + templateRef.title + " ] [Gwint CardInstance] instanceID:" + instanceId + ", owningPlayer[ " + owningPlayer + " ], templateId[ " + templateId + " ], inList[ " + inList + " ]";
		}
		
		public function canBeCastOn(cardInstance:CardInstance):Boolean
		{
			if (templateRef.isType(CardTemplate.CardType_Hero) || cardInstance.templateRef.isType(CardTemplate.CardType_Hero)) // Nothing effects heroes muhaha
			{
				return false;
			}
			
			if (templateRef.hasEffect(CardTemplate.CardEffect_UnsummonDummy) && cardInstance.templateRef.isType(CardTemplate.CardType_Creature) && cardInstance.listsPlayer == listsPlayer &&
			    cardInstance.inList != CardManager.CARD_LIST_LOC_HAND && cardInstance.inList != CardManager.CARD_LIST_LOC_GRAVEYARD && cardInstance.inList != CardManager.CARD_LIST_LOC_LEADER)
			{
				return true;
			}
			
			return false;
		}
		
		public function canBePlacedInSlot(slotID:int, playerID:int):Boolean
		{
			var cardManagerRef:CardManager = CardManager.getInstance();
			
			// Automatically discount these
			if (slotID == CardManager.CARD_LIST_LOC_DECK || slotID == CardManager.CARD_LIST_LOC_GRAVEYARD)
			{
				return false;
			}
			
			// Handling weather first since the rest of the player validation does not apply to it
			if (playerID == CardManager.PLAYER_INVALID && slotID == CardManager.CARD_LIST_LOC_WEATHERSLOT && templateRef.isType(CardTemplate.CardType_Weather))
			{
				return true;
			}
			
			// Player Validation
			// {
			if (playerID == listsPlayer && templateRef.isType(CardTemplate.CardType_Spy))
			{
				return false;
			}
			else if (!templateRef.isType(CardTemplate.CardType_Spy) && playerID != listsPlayer && (templateRef.isType(CardTemplate.CardType_Creature) || templateRef.isType(CardTemplate.CardType_Row_Modifier)))
			{
				return false;
			}
			// }
			
			// Slot Validation
			// {
			if (templateRef.isType(CardTemplate.CardType_Creature))
			{
				if (slotID == CardManager.CARD_LIST_LOC_MELEE && templateRef.isType(CardTemplate.CardType_Melee))
				{
					return true;
				}
				else if (slotID == CardManager.CARD_LIST_LOC_RANGED && templateRef.isType(CardTemplate.CardType_Ranged))
				{
					return true;
				}
				else if (slotID == CardManager.CARD_LIST_LOC_SEIGE && templateRef.isType(CardTemplate.CardType_Siege))
				{
					return true;
				}
			}
			else if (templateRef.isType(CardTemplate.CardType_Row_Modifier))
			{
				if (slotID == CardManager.CARD_LIST_LOC_MELEEMODIFIERS && templateRef.isType(CardTemplate.CardType_Melee) && cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_MELEEMODIFIERS, listsPlayer).length == 0)
				{
					return true;
				}
				else if (slotID == CardManager.CARD_LIST_LOC_RANGEDMODIFIERS && templateRef.isType(CardTemplate.CardType_Ranged) && cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_RANGEDMODIFIERS, listsPlayer).length == 0)
				{
					return true;
				}
				else if (slotID == CardManager.CARD_LIST_LOC_SEIGEMODIFIERS && templateRef.isType(CardTemplate.CardType_Siege) && cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_SEIGEMODIFIERS, listsPlayer).length == 0)
				{
					return true;
				}
			}
			// }
			
			return false;
		}
		
		protected var _lastCalculatedPowerPotential:CardTransaction = new CardTransaction();
		// Makes the card recalculate the power change playing it would cause
		public function recalculatePowerPotential(cardManager:CardManager):void
		{
			var i = 0;
			var currentCard:CardInstance;
			_lastCalculatedPowerPotential.powerChangeResult = 0;
			_lastCalculatedPowerPotential.strategicValue = 0;
			_lastCalculatedPowerPotential.sourceCardInstanceRef = this;
			var weatherCardList:Vector.<CardInstance> = cardManager.getCardInstanceList(CardManager.CARD_LIST_LOC_WEATHERSLOT, CardManager.PLAYER_INVALID);
			var currentWeatherCard:CardInstance = weatherCardList.length > 0 ? weatherCardList[0] : null;
			var cardList:Vector.<CardInstance>;
			var opponentPlayer = listsPlayer == CardManager.PLAYER_1 ? CardManager.PLAYER_2 : CardManager.PLAYER_1;
			var currentRowList:Vector.<CardInstance>;
			var currentInstance:CardInstance;
			var ressurectedCardValue:int;
			var hasScorchInHand:Boolean = cardManager.getCardsInHandWithEffect(CardTemplate.CardEffect_Scorch, listsPlayer).length > 0;
			var playerCardsInHand:Vector.<CardInstance> = cardManager.getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, listsPlayer);
			var scorchRowList:Vector.<CardInstance> = null;
			var onlyScorchedCardsPower:int = 0;
			var totalScorchPower:int = 0;
			
			// Creatures
			// {
				if (templateRef.isType(CardTemplate.CardType_Creature))
				{
										
					_lastCalculatedPowerPotential.targetPlayerID = templateRef.isType(CardTemplate.CardType_Spy) ? opponentPlayer : listsPlayer;
					
					if (templateRef.isType(CardTemplate.CardType_Melee))
					{
						_lastCalculatedPowerPotential.targetSlotID = CardManager.CARD_LIST_LOC_MELEE;
					}
					else if (templateRef.isType(CardTemplate.CardType_Ranged))
					{
						_lastCalculatedPowerPotential.targetSlotID = CardManager.CARD_LIST_LOC_RANGED;
					}
					else
					{
						_lastCalculatedPowerPotential.targetSlotID = CardManager.CARD_LIST_LOC_SEIGE;
					}
					
					// Temporary add all the buffs he will receieve to calculate the true power of placing that card
					// {
						cardList = cardManager.cardEffectManager.getEffectsForList(_lastCalculatedPowerPotential.targetSlotID, listsPlayer); // Must use listsPlayer instead of owningPlayer in case its a spy the other guy dummied into his hand
						
						for (i = 0; i < cardList.length; ++i)
						{
							currentCard = cardList[i];
							if (currentCard != this)
							{
								effectedByCardsRefList.push(currentCard);
							}
						}
						
						var creaturePower:int = getTotalPower();
						
						effectedByCardsRefList.length = 0; // Resetting the temp application of buffs
					// }
					
					// Second calculation for ranged for agile characters. Melee was already calculated by default, just need to also check ranged
					// {
						if (templateRef.isType(CardTemplate.CardType_RangedMelee))
						{
							cardList = cardManager.cardEffectManager.getEffectsForList(CardManager.CARD_LIST_LOC_RANGED, listsPlayer);
							
							for (i = 0; i < cardList.length; ++i)
							{
								currentCard = cardList[i];
								if (currentCard != this)
								{
									effectedByCardsRefList.push(currentCard);
								}
							}
							
							var rangedPower:int = getTotalPower();
							
							effectedByCardsRefList.length = 0; // Resetting the temp application of buffs
							
							if (templateRef.hasEffect(CardTemplate.CardEffect_ImproveNeighbours))
							{
								currentRowList = new Vector.<CardInstance>();
								cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_MELEE, CardManager.PLAYER_1, currentRowList);
								var buffedCreaturePower:int = creaturePower + currentRowList.length;
								cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_RANGED, CardManager.PLAYER_1, currentRowList);
								var buffedRangedPower:int = rangedPower + currentRowList.length;
								
								if (buffedRangedPower > buffedCreaturePower || (buffedRangedPower == buffedCreaturePower && Math.random() < 0.5))
								{
									creaturePower = rangedPower;
									_lastCalculatedPowerPotential.targetSlotID = CardManager.CARD_LIST_LOC_RANGED;
								}
							}
							else
							{
								if (rangedPower > creaturePower || (rangedPower == creaturePower && Math.random() < 0.5))
								{
									creaturePower = rangedPower;
									_lastCalculatedPowerPotential.targetSlotID = CardManager.CARD_LIST_LOC_RANGED;
								}
							}
						}
					// }
					
					// same type morale && Improve Neightbours calculation
					if (templateRef.hasEffect(CardTemplate.CardEffect_SameTypeMorale) || templateRef.hasEffect(CardTemplate.CardEffect_ImproveNeighbours))
					{
						cardList = new Vector.<CardInstance>();
						
						if (_lastCalculatedPowerPotential.targetSlotID == CardTemplate.CardType_Melee)
						{
							cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_MELEE, listsPlayer, cardList);
						}
						if (_lastCalculatedPowerPotential.targetSlotID == CardTemplate.CardType_Ranged)
						{
							cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_RANGED, listsPlayer, cardList);
						}
						if (_lastCalculatedPowerPotential.targetSlotID == CardTemplate.CardType_Siege)
						{
							cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_SEIGE, listsPlayer, cardList);
						}
						
						if (templateRef.hasEffect(CardTemplate.CardEffect_ImproveNeighbours))
						{
							_lastCalculatedPowerPotential.powerChangeResult += cardList.length;
						}
						else
						{
							// Tricky calculation thats easy to make mistake. Placing this card will already calculate the buffs from other improveneighbours cards on the board in the creaturePower calculations
							// Therefore we need only need to add the positive effect place this card will have on other cards
							var oldPower:int
							
							for (i = 0; i < cardList.length; ++i)
							{
								currentCard = cardList[i];
								
								if (currentCard.templateId == templateId)
								{
									oldPower = currentCard.getTotalPower();
									currentCard.effectedByCardsRefList.push(this);
									_lastCalculatedPowerPotential.powerChangeResult += currentCard.getTotalPower() - oldPower;
									currentCard.effectedByCardsRefList.pop();
								}
							}
						}
					}
					
					// Summon Clones
					if (templateRef.hasEffect(CardTemplate.CardEffect_SummonClones))
					{
						var numClonesToSummon:int = 0;
						
						cardList = cardManager.getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, listsPlayer);
						
						for (i = 0; i < cardList.length; ++i)
						{
							if (templateRef.summonFlags.indexOf(cardList[i].templateId) != -1)
							{
								++numClonesToSummon;
							}
						}
						
						for (i = 0; i < templateRef.summonFlags.length; ++i)
						{
							numClonesToSummon += cardManager.playerDeckDefinitions[listsPlayer].numCopiesLeft(templateRef.summonFlags[i]);
						}
						
						//Cheeky trick where the creature power (all buffs) of this card's summoned brothers is the same as this cards creature power
						_lastCalculatedPowerPotential.powerChangeResult += numClonesToSummon * creaturePower; 
					}
					
					if (templateRef.isType(CardTemplate.CardType_Spy))
					{
						_lastCalculatedPowerPotential.powerChangeResult -= creaturePower;
					}
					else
					{
						_lastCalculatedPowerPotential.powerChangeResult += creaturePower;
					}
				}
			// }
			
			// Weather Cards
			// {
				if (templateRef.isType(CardTemplate.CardType_Weather))
				{
					var totalChange:int = 0;
					var prevPower:int = 0;
					
					currentRowList = new Vector.<CardInstance>();
					
					if (templateRef.hasEffect(CardTemplate.CardEffect_ClearSky))
					{
						// Add in positive gains for player
						// {
							currentRowList.length = 0;
							cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_MELEE, listsPlayer, currentRowList);
							cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_RANGED, listsPlayer, currentRowList);
							cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_SEIGE, listsPlayer, currentRowList);
							
							for (i = 0; i < currentRowList.length; ++i)
							{
								totalChange += currentRowList[i].getTotalPower(true) - currentRowList[i].getTotalPower();
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
								totalChange -= currentRowList[i].getTotalPower(true) - currentRowList[i].getTotalPower();
							}
						// }
					}
					else
					{
						if (templateRef.hasEffect(CardTemplate.CardEffect_Melee))
						{
							currentRowList.length = 0;
							cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_MELEE, listsPlayer, currentRowList);
							
							for (i = 0; i < currentRowList.length; ++i)
							{
								currentCard =  currentRowList[i];
								prevPower = currentCard.getTotalPower();
								
								// Temporarly buff it to see what the actual value is as normally calculated (avoids double logic)
								currentCard.effectedByCardsRefList.push(this);
								totalChange += currentCard.getTotalPower() - prevPower;
								currentCard.effectedByCardsRefList.pop();
							}
							
							currentRowList.length = 0;
							cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_MELEE, opponentPlayer, currentRowList);
							
							for (i = 0; i < currentRowList.length; ++i)
							{
								currentCard =  currentRowList[i];
								prevPower = currentCard.getTotalPower();
								
								// Temporarly buff it to see what the actual value is as normally calculated (avoids double logic)
								currentCard.effectedByCardsRefList.push(this);
								totalChange -= currentCard.getTotalPower() - prevPower;
								currentCard.effectedByCardsRefList.pop();
							}
						}
						
						if (templateRef.hasEffect(CardTemplate.CardEffect_Ranged))
						{
							currentRowList.length = 0;
							cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_RANGED, listsPlayer, currentRowList);
							
							for (i = 0; i < currentRowList.length; ++i)
							{
								currentCard =  currentRowList[i];
								prevPower = currentCard.getTotalPower();
								
								// Temporarly buff it to see what the actual value is as normally calculated (avoids double logic)
								currentCard.effectedByCardsRefList.push(this);
								totalChange += currentCard.getTotalPower() - prevPower;
								currentCard.effectedByCardsRefList.pop();
							}
							
							currentRowList.length = 0;
							cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_RANGED, opponentPlayer, currentRowList);
							
							for (i = 0; i < currentRowList.length; ++i)
							{
								currentCard =  currentRowList[i];
								prevPower = currentCard.getTotalPower();
								
								// Temporarly buff it to see what the actual value is as normally calculated (avoids double logic)
								currentCard.effectedByCardsRefList.push(this);
								totalChange -= currentCard.getTotalPower() - prevPower;
								currentCard.effectedByCardsRefList.pop();
							}
						}
						
						if (templateRef.hasEffect(CardTemplate.CardEffect_Siege))
						{
							currentRowList.length = 0;
							cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_SEIGE, listsPlayer, currentRowList);
							
							for (i = 0; i < currentRowList.length; ++i)
							{
								currentCard =  currentRowList[i];
								prevPower = currentCard.getTotalPower();
								
								// Temporarly buff it to see what the actual value is as normally calculated (avoids double logic)
								currentCard.effectedByCardsRefList.push(this);
								totalChange += currentCard.getTotalPower() - prevPower;
								currentCard.effectedByCardsRefList.pop();
							}
							
							currentRowList.length = 0;
							cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_SEIGE, opponentPlayer, currentRowList);
							
							for (i = 0; i < currentRowList.length; ++i)
							{
								currentCard =  currentRowList[i];
								prevPower = currentCard.getTotalPower();
								
								// Temporarly buff it to see what the actual value is as normally calculated (avoids double logic)
								currentCard.effectedByCardsRefList.push(this);
								totalChange -= currentCard.getTotalPower() - prevPower;
								currentCard.effectedByCardsRefList.pop();
							}
						}
					}
					
					_lastCalculatedPowerPotential.powerChangeResult = totalChange;
					_lastCalculatedPowerPotential.strategicValue = Math.max(0, cardManager.cardValues.weatherCardValue - totalChange);
					
					if (templateRef.hasEffect(CardTemplate.CardEffect_ClearSky))
					{
						_lastCalculatedPowerPotential.strategicValue = Math.max(_lastCalculatedPowerPotential.strategicValue, 8);
					}

					_lastCalculatedPowerPotential.targetSlotID = CardManager.CARD_LIST_LOC_WEATHERSLOT;
					_lastCalculatedPowerPotential.targetPlayerID = CardManager.PLAYER_INVALID;
				}
			// }
			
			// Scorch
			// {
				var cardsBeingRemoved:Vector.<CardInstance> = null;
				if (templateRef.hasEffect(CardTemplate.CardEffect_Scorch))
				{
					cardsBeingRemoved = cardManager.getScorchTargets();
				}
				
				if (cardsBeingRemoved != null)
				{
					if (templateRef.isType(CardTemplate.CardType_Creature))
					{
						if (cardsBeingRemoved.length == 0 || cardsBeingRemoved[0].getTotalPower() < _lastCalculatedPowerPotential.powerChangeResult)
						{
							_lastCalculatedPowerPotential.strategicValue = -1;
							_lastCalculatedPowerPotential.powerChangeResult = 0;
							return;
						}
					}
					
					for (i = 0; i < cardsBeingRemoved.length; ++i)
					{
						currentCard = cardsBeingRemoved[i];
						
						if (currentCard.listsPlayer == listsPlayer)
						{
							_lastCalculatedPowerPotential.powerChangeResult -= currentCard.getTotalPower();
						}
						else
						{
							_lastCalculatedPowerPotential.powerChangeResult += currentCard.getTotalPower();
						}
					}
					
					if (_lastCalculatedPowerPotential.powerChangeResult < 0) // A scorch that hurts you more is not very strategic
					{
						_lastCalculatedPowerPotential.strategicValue = -1;
					}
					else
					{
						_lastCalculatedPowerPotential.strategicValue = Math.max(templateRef.GetBonusValue(), _lastCalculatedPowerPotential.powerChangeResult);
					}
					
					return; // No further calculations should be done for scorch in this case
				}
			// }
			
			// Dummy
			// {
				if (templateRef.hasEffect(CardTemplate.CardEffect_UnsummonDummy))
				{
					_lastCalculatedPowerPotential.targetCardInstanceRef = cardManager.getHigherOrLowerValueTargetCardOnBoard(this, listsPlayer, false, false, true); //false = getLowest card, EXCEPTION Highest Nurse
					if (_lastCalculatedPowerPotential.targetCardInstanceRef)
					{
						if (_lastCalculatedPowerPotential.targetCardInstanceRef.templateRef.isType(CardTemplate.CardType_Spy))
						{
							_lastCalculatedPowerPotential.powerChangeResult = 0;
						}
						else
						{
							_lastCalculatedPowerPotential.powerChangeResult = -_lastCalculatedPowerPotential.targetCardInstanceRef.getTotalPower();
						}
						
						if ((cardManager.cardValues.unsummonCardValue + _lastCalculatedPowerPotential.powerChangeResult) >= 0)
						{
							_lastCalculatedPowerPotential.strategicValue = Math.abs(_lastCalculatedPowerPotential.powerChangeResult);
						}
						else
						{
							_lastCalculatedPowerPotential.strategicValue = cardManager.cardValues.unsummonCardValue + Math.abs(_lastCalculatedPowerPotential.powerChangeResult);
						}
					}
					else
					{
						_lastCalculatedPowerPotential.powerChangeResult = -1000; // AI should never play this card!
						_lastCalculatedPowerPotential.strategicValue = -1;
					}
				}
			// }
			
			// Mushroom row modifier
			// {
				if (templateRef.isType(CardTemplate.CardType_Row_Modifier) && templateRef.hasEffect(CardTemplate.CardEffect_Mushroom))
				{
					
					var beserkersOnBoard:Vector.<CardInstance> = new Vector.<CardInstance>();
					var beserkersInHand:Vector.<CardInstance> = new Vector.<CardInstance>();
					
					cardManager.getBeserkersOnBoard(listsPlayer, beserkersOnBoard);
					cardManager.getBeserkersInHand(listsPlayer, beserkersInHand);
					
					if (beserkersOnBoard.length == 0)
					{
						// In this case, the mushroom card is throwaway
						if (beserkersInHand.length == 0)
						{
							_lastCalculatedPowerPotential.powerChangeResult = 0;
							_lastCalculatedPowerPotential.strategicValue = 0;
							_lastCalculatedPowerPotential.targetPlayerID = listsPlayer;
							switch (Math.floor(Math.random() * 2)) // play on random row since it doesn't matter
							{
								case 0:
									if (cardManager.getCardInstanceList(CardManager.CARD_LIST_LOC_MELEEMODIFIERS, listsPlayer).length == 0)
									{
										_lastCalculatedPowerPotential.targetSlotID = CardManager.CARD_LIST_LOC_MELEEMODIFIERS;
									}
									else if (cardManager.getCardInstanceList(CardManager.CARD_LIST_LOC_RANGEDMODIFIERS, listsPlayer).length == 0)
									{
										_lastCalculatedPowerPotential.targetSlotID = CardManager.CARD_LIST_LOC_RANGEDMODIFIERS;
									}
									else
									{
										_lastCalculatedPowerPotential.strategicValue = -1;
										_lastCalculatedPowerPotential.powerChangeResult = -1000;
									}
									break;
								case 1:
									if (cardManager.getCardInstanceList(CardManager.CARD_LIST_LOC_RANGEDMODIFIERS, listsPlayer).length == 0)
									{
										_lastCalculatedPowerPotential.targetSlotID = CardManager.CARD_LIST_LOC_RANGEDMODIFIERS;
									}
									else if (cardManager.getCardInstanceList(CardManager.CARD_LIST_LOC_MELEEMODIFIERS, listsPlayer).length == 0)
									{
										_lastCalculatedPowerPotential.targetSlotID = CardManager.CARD_LIST_LOC_MELEEMODIFIERS;
									}
									else
									{
										_lastCalculatedPowerPotential.strategicValue = -1;
										_lastCalculatedPowerPotential.powerChangeResult = -1000;
									}
									break;
							}
							
							
						}
						else // We have beserkers in hand so lets not waste the mushroom, set values so this card is not likely to be played
						{
							_lastCalculatedPowerPotential.strategicValue = -1;
							_lastCalculatedPowerPotential.powerChangeResult = -1000;
							_lastCalculatedPowerPotential.targetSlotID = CardManager.CARD_LIST_LOC_SEIGEMODIFIERS; // set to seige modifer to indicate that the card was played even though it shouldn't have
							_lastCalculatedPowerPotential.targetPlayerID = listsPlayer;
						}
					}
					else
					{
						var hasErmionInHand:Boolean = false;
							
						for each (var cardInHand:CardInstance in cardManager.getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, listsPlayer))
						{
							if (cardInHand.templateId == 503)
							{
								hasErmionInHand = true;
								break;
							}
						}
						
						var targetRow:int = CardManager.CARD_LIST_LOC_SEIGEMODIFIERS;
						var meleeCount:int = 0;
						var rangedCount:int = 0;
						var meleeAvailable:Boolean = cardManager.getCardInstanceList(CardManager.CARD_LIST_LOC_MELEEMODIFIERS, listsPlayer).length == 0;
						var rangedAvailable:Boolean = cardManager.getCardInstanceList(CardManager.CARD_LIST_LOC_RANGEDMODIFIERS, listsPlayer).length == 0;
						
						for each (var beserkerCard:CardInstance in beserkersOnBoard)
						{
							if (beserkerCard.inList == CardManager.CARD_LIST_LOC_MELEE && meleeAvailable)
							{
								meleeCount += 1;
							}
							else if (beserkerCard.inList == CardManager.CARD_LIST_LOC_RANGED && rangedAvailable)
							{
								rangedCount += 1;
							}
						}
							
						if (beserkersInHand.length != 0)
						{
							for each (var beserkerCardInHand:CardInstance in beserkersInHand)
							{
								if (beserkerCardInHand.inList == CardManager.CARD_LIST_LOC_MELEE && meleeAvailable)
								{
									meleeCount += 1;
								}
								else if (beserkerCardInHand.inList == CardManager.CARD_LIST_LOC_RANGED && rangedAvailable)
								{
									rangedCount += 1;
								}
							}
						}
						
						if ((meleeCount > 0 && hasErmionInHand) || (meleeCount > 0 && meleeCount > rangedCount))
						{
							targetRow = CardManager.CARD_LIST_LOC_MELEEMODIFIERS;
							_lastCalculatedPowerPotential.strategicValue = 0;
							_lastCalculatedPowerPotential.powerChangeResult = meleeCount * 8; // Not accurate count but will seem like a powerful move to a potentially disapointed AI
						}
						else if (rangedCount > 0)
						{
							targetRow = CardManager.CARD_LIST_LOC_RANGEDMODIFIERS;
							_lastCalculatedPowerPotential.strategicValue = 0;
							_lastCalculatedPowerPotential.powerChangeResult = rangedCount * 8; // Not accurate count but will seem like a powerful move to a potentially disapointed AI
						}
						
						if (targetRow == CardManager.CARD_LIST_LOC_SEIGEMODIFIERS)
						{
							_lastCalculatedPowerPotential.strategicValue = -1;
							_lastCalculatedPowerPotential.powerChangeResult = -1000;
						}
						
						_lastCalculatedPowerPotential.targetPlayerID = listsPlayer;
						_lastCalculatedPowerPotential.targetSlotID = targetRow;
					}
				}
			// }
			
			// Horn row Modifier
			// {
				if (templateRef.isType(CardTemplate.CardType_Row_Modifier) && templateRef.hasEffect(CardTemplate.CardEffect_Horn))
				{
					// -1 indicates a row in which a horn cannot be played because the there is already a horn there
					var meleeRowIncrease:int = -1;
					var rangeRowIncrease:int = -1;
					var seigeRowIncrease:int = -1;
					var oldValue:int = 0;
					
					currentRowList = new Vector.<CardInstance>();
					
					if (cardManager.getCardInstanceList(CardManager.CARD_LIST_LOC_MELEEMODIFIERS, listsPlayer).length == 0) // If there is already a horn here, cannot place another
					{
						cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_MELEE, listsPlayer, currentRowList);
						
						meleeRowIncrease = 0;
						for (i = 0; i < currentRowList.length; ++i)
						{
							currentCard = currentRowList[i];
							
							oldValue = currentCard.getTotalPower();
							
							// Temporarly buff it to see what the actual value is as normally calculated (avoids double logic)
							currentCard.effectedByCardsRefList.push(this);
							meleeRowIncrease = currentCard.getTotalPower() - oldValue;
							currentCard.effectedByCardsRefList.pop();
						}
					}
					
					currentRowList.length = 0;
					
					if (cardManager.getCardInstanceList(CardManager.CARD_LIST_LOC_RANGEDMODIFIERS, listsPlayer).length == 0) // If there is already a horn here, cannot place another
					{
						cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_RANGED, listsPlayer, currentRowList);
						
						rangeRowIncrease = 0;
						for (i = 0; i < currentRowList.length; ++i)
						{
							currentCard = currentRowList[i];
							
							oldValue = currentCard.getTotalPower();
							
							// Temporarly buff it to see what the actual value is as normally calculated (avoids double logic)
							currentCard.effectedByCardsRefList.push(this);
							rangeRowIncrease = currentCard.getTotalPower() - oldValue;
							currentCard.effectedByCardsRefList.pop();
						}
					}
					
					currentRowList.length = 0;
					
					if (cardManager.getCardInstanceList(CardManager.CARD_LIST_LOC_SEIGEMODIFIERS, listsPlayer).length == 0) // If there is already a horn here, cannot place another
					{
						cardManager.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_SEIGE, listsPlayer, currentRowList);
						
						seigeRowIncrease = 0;
						for (i = 0; i < currentRowList.length; ++i)
						{
							currentCard = currentRowList[i];
							
							currentCard.effectedByCardsRefList.push(this);
							seigeRowIncrease = currentCard.getTotalPower() - oldValue;
							currentCard.effectedByCardsRefList.pop();
						}
					}
					
					if (seigeRowIncrease == -1 && meleeRowIncrease == -1 && rangeRowIncrease == -1)
					{
						_lastCalculatedPowerPotential.powerChangeResult = -1;
						_lastCalculatedPowerPotential.strategicValue = -1;
						return;
					}
					else if (meleeRowIncrease > seigeRowIncrease && meleeRowIncrease > rangeRowIncrease)
					{
						_lastCalculatedPowerPotential.powerChangeResult = meleeRowIncrease;
						_lastCalculatedPowerPotential.targetSlotID = CardManager.CARD_LIST_LOC_MELEEMODIFIERS;
						_lastCalculatedPowerPotential.targetPlayerID = listsPlayer;
					}
					else if (rangeRowIncrease > seigeRowIncrease)
					{
						_lastCalculatedPowerPotential.powerChangeResult = rangeRowIncrease;
						_lastCalculatedPowerPotential.targetSlotID = CardManager.CARD_LIST_LOC_RANGEDMODIFIERS;
						_lastCalculatedPowerPotential.targetPlayerID = listsPlayer;
					}
					else
					{
						_lastCalculatedPowerPotential.powerChangeResult = seigeRowIncrease;
						_lastCalculatedPowerPotential.targetSlotID = CardManager.CARD_LIST_LOC_SEIGEMODIFIERS;
						_lastCalculatedPowerPotential.targetPlayerID = listsPlayer;
					}
					
					if (_lastCalculatedPowerPotential.powerChangeResult > cardManager.cardValues.hornCardValue)
					{
						_lastCalculatedPowerPotential.strategicValue = Math.max(0, cardManager.cardValues.hornCardValue * 2 - _lastCalculatedPowerPotential.powerChangeResult);
					}
					else
					{
						_lastCalculatedPowerPotential.strategicValue = cardManager.cardValues.hornCardValue;
					}
				}
			// }


			// Scorch-Melee
			// {
				if (templateRef.hasEffect(CardTemplate.CardEffect_MeleeScorch))
				{
					scorchRowList = null;
					scorchRowList = cardManager.getScorchTargets(CardTemplate.CardType_Melee, notListPlayer);
					if (scorchRowList.length != 0 && cardManager.calculatePlayerScore(CardManager.CARD_LIST_LOC_MELEE, notListPlayer) >= 10)
					{
						i = 0;
						onlyScorchedCardsPower = 0;
						totalScorchPower = 0;
						for (i = 0; i < scorchRowList.length; ++i)
						{
							totalScorchPower = scorchRowList[i].getTotalPower();
							_lastCalculatedPowerPotential.powerChangeResult += totalScorchPower;
							onlyScorchedCardsPower += totalScorchPower;
							//trace("GFX -#IA#-----MARCIN------- Last calculated: [ " + _lastCalculatedPowerPotential.powerChangeResult + " ] onlyScorched: [ " + onlyScorchedCardsPower + " ]");
						}
						
						if (Math.random() >= (2 / scorchRowList.length) || Math.random() >= (4 / onlyScorchedCardsPower))
						{
							_lastCalculatedPowerPotential.strategicValue = 1;
						}
						else
						{
							_lastCalculatedPowerPotential.strategicValue = _lastCalculatedPowerPotential.powerChangeResult;
						}
					}
					else
					{
						_lastCalculatedPowerPotential.strategicValue = _lastCalculatedPowerPotential.powerChangeResult + cardManager.cardValues.scorchCardValue;
					}
				}


			// Scorch-Ranged
			// {
				if (templateRef.hasEffect(CardTemplate.CardEffect_RangedScorch))
				{
					scorchRowList = null;
					scorchRowList = cardManager.getScorchTargets(CardTemplate.CardType_Ranged, notListPlayer);
					if (scorchRowList.length != 0 && cardManager.calculatePlayerScore(CardManager.CARD_LIST_LOC_RANGED, notListPlayer) >= 10)
					{
						i = 0;
						onlyScorchedCardsPower = 0;
						totalScorchPower = 0;
						for (i = 0; i < scorchRowList.length; ++i)
						{
							totalScorchPower = scorchRowList[i].getTotalPower();
							_lastCalculatedPowerPotential.powerChangeResult += totalScorchPower;
							onlyScorchedCardsPower += totalScorchPower;
							//trace("GFX -#IA#-----MARCIN------- Last calculated: [ " + _lastCalculatedPowerPotential.powerChangeResult + " ] onlyScorched: [ " + onlyScorchedCardsPower + " ]");
						}
						
						if (Math.random() >= (2 / scorchRowList.length) || Math.random() >= (4 / onlyScorchedCardsPower))
						{
							_lastCalculatedPowerPotential.strategicValue = 1;
						}
						else
						{
							_lastCalculatedPowerPotential.strategicValue = _lastCalculatedPowerPotential.powerChangeResult;
						}
					}
					else
					{
						_lastCalculatedPowerPotential.strategicValue = _lastCalculatedPowerPotential.powerChangeResult + cardManager.cardValues.scorchCardValue;
					}
				}

			//_lastCalculatedPowerPotential.strategicValue = templateRef.GetBonusValue();
			
			if (templateRef.isType(CardTemplate.CardType_Creature))
			{
				if (templateRef.hasEffect(CardTemplate.CardEffect_Nurse))
				{
					var forNurseList = new Vector.<CardInstance>();
					var onlyNursesAtHand:Boolean = true;

					for (i = 0; i < playerCardsInHand.length; ++i)
					{
						if (playerCardsInHand[i].templateRef.hasEffect(CardTemplate.CardEffect_Nurse))
						{
							continue;
						}
						else
						{
							onlyNursesAtHand = false;
							break;
						}
					}

					cardManager.GetRessurectionTargets(listsPlayer, forNurseList, false);

					if (forNurseList.length == 0)
					{
						if (!onlyNursesAtHand)
						{
							_lastCalculatedPowerPotential.powerChangeResult = -1000; // AI should never play this card!
							_lastCalculatedPowerPotential.strategicValue = -1;
						}
					}
					else
					{
						for (i = 0; i < forNurseList.length; ++i)
						{
							// Recursion safety when you have nurses in graveyard. You lose a bit of accuracy, but can't be helped or the nurses will keep looking at each other
							if (!forNurseList[i].templateRef.hasEffect(CardTemplate.CardEffect_Nurse))
							{
								forNurseList[i].recalculatePowerPotential(cardManager);
							}
						}
						forNurseList.sort(powerChangeSorter);
						currentInstance = forNurseList[forNurseList.length - 1];
						// trace("GFX -#IA#- Nurse considers ressurecting:", currentInstance);
						ressurectedCardValue = currentInstance.getOptimalTransaction().powerChangeResult;
						_lastCalculatedPowerPotential.powerChangeResult += ressurectedCardValue;
						
						// trace("GFX -#IA#- Data for Nurse - playerCardsInHand.length[ "+ playerCardsInHand.length + " ] , ressurectedCardValue[ " + ressurectedCardValue + " ]");
						if (Math.random() <= (1 / playerCardsInHand.length) || Math.random() >= (8 / ressurectedCardValue))
						{
							_lastCalculatedPowerPotential.strategicValue = 0;
						}
						else
						{
							var nursePlusRessurectedValue:int = cardManager.cardValues.nurseCardValue + ressurectedCardValue;
							_lastCalculatedPowerPotential.strategicValue = Math.max(nursePlusRessurectedValue, templateRef.power);
						}
					}
				}
				else if (_lastCalculatedPowerPotential.strategicValue == 0)
				{
					_lastCalculatedPowerPotential.strategicValue += templateRef.power;
				}
			}
		}
		
		public function scoreGainOnReposition():int
		{
			var moveScore:int;
			var oldEffectList:Vector.<CardInstance> = new Vector.<CardInstance>();
			var newEffectList:Vector.<CardInstance>;
			var i:int;
			
			if (templateRef.isType(CardTemplate.CardType_RangedMelee))
			{
				for (i = 0; i < effectedByCardsRefList.length; ++i)
				{
					oldEffectList.push(effectedByCardsRefList[i]);
				}
				
				newEffectList = CardManager.getInstance().cardEffectManager.getEffectsForList(inList == CardManager.CARD_LIST_LOC_MELEE ? CardManager.CARD_LIST_LOC_RANGED : CardManager.CARD_LIST_LOC_MELEE, listsPlayer);
				
				effectedByCardsRefList.length = 0;
				for (i = 0; i < newEffectList.length; ++i)
				{
					effectedByCardsRefList.push(newEffectList[i]);
				}
				
				moveScore = getTotalPower();
				
				effectedByCardsRefList.length = 0;
				for (i = 0; i < oldEffectList.length; ++i)
				{
					effectedByCardsRefList.push(oldEffectList[i]);
				}
				
				if (moveScore > getTotalPower())
				{
					return moveScore - getTotalPower();
				} // Else return 0 and we won't be moving it
			}
			
			return 0;
		}
		
		// Returns the last calculated value of playing a card
		public function getOptimalTransaction():CardTransaction
		{
			return _lastCalculatedPowerPotential;
		}
		
		public function onFinishedMovingIntoHolder(listID:int, playerID:int):void 
		{
			if (lastListApplied != listID || lastListPlayerApplied != playerID) 
			{
				trace("GFX - finished Moving into holder:", listID, ", playerID:", playerID, ", for cardInstance:", this);
				
				var cardManagerRef:CardManager = CardManager.getInstance();
				lastListApplied = listID;
				lastListPlayerApplied = playerID;
				var it:int;
				var currentList:Vector.<CardInstance>;
				var currentCard:CardInstance;
				var cardFXManager:CardFXManager = CardFXManager.getInstance();
				
				if (listID == CardManager.CARD_LIST_LOC_DECK || listID == CardManager.CARD_LIST_LOC_LEADER)
				{
					return;
				}
				
				// If we are going to graveyard, remove all buffs applied to us. The removing of buffs we are applying should be couple with the logic that applies it (BELOW)
				{
					while (effectingCardsRefList.length > 0)
					{
						removeFromEffectingList(effectingCardsRefList[0]);
					}
					
					while (effectedByCardsRefList.length > 0)
					{
						effectedByCardsRefList[0].removeFromEffectingList(this);
					}
					
					effectingCardsRefList.length = 0;
					cardManagerRef.cardEffectManager.unregisterActiveEffectCardInstance(this);
					powerChangeCallback();
					
					if (listID == CardManager.CARD_LIST_LOC_GRAVEYARD || listID == CardManager.CARD_LIST_LOC_HAND)
					{
						return;
					}
				}
				
				if (templateRef.isType(CardTemplate.CardType_Creature) || templateRef.hasEffect(CardTemplate.CardEffect_UnsummonDummy) && templateId != 500)
				{
					cardFXManager.playCardDeployFX(this, updateEffectsApplied);
				}
				else if (templateRef.isType(CardTemplate.CardType_Weather))
				{
					if (templateRef.hasEffect(CardTemplate.CardEffect_ClearSky))
					{
						var cardList:Vector.<CardInstance> = cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_WEATHERSLOT, CardManager.PLAYER_INVALID);
						
						trace("GFX - Applying Clear weather effect, numTargets: " + cardList.length);
						
						while (cardList.length > 0)
						{
							cardManagerRef.sendToGraveyard(cardList[0]);
						}
					}
					else
					{
						currentList = new Vector.<CardInstance>();
						var weatherList:Vector.<CardInstance> = cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_WEATHERSLOT, CardManager.PLAYER_INVALID);
						
						for each (var curWeather:CardInstance in weatherList)
						{
							currentList.push(curWeather);
						}
						
						if (templateRef.effectFlags.length == 2) // Skellige storm
						{
							for (it = 0; it < currentList.length; ++it)
							{
								currentCard = currentList[it];
								
								if (currentCard != this)
								{	
									if (currentCard.templateId == templateId) // Same weather card, just needs to be replaced, no sfx
									{
										cardManagerRef.sendToGraveyard(currentCard);
									}
									else if (templateRef.effectFlags.indexOf(currentCard.templateRef.getFirstEffect()) != -1)
									{
										cardManagerRef.sendToGraveyard(currentCard);
									}
								}
							}
						}
						else
						{
							for (it = 0; it < currentList.length; ++it)
							{
								currentCard = currentList[it];
								
								if (currentCard.templateRef.effectFlags.indexOf(templateRef.getFirstEffect()) != -1 && currentCard != this) // Same weather card, just needs to be replaced, no sfx
								{
									cardManagerRef.sendToGraveyard(this);
									return;
								}
							}
						}
					}
					
					cardFXManager.playCardDeployFX(this, updateEffectsApplied);
				}
				else
				{
					updateEffectsApplied();
				}
			}
		}
		
		protected function removeFromEffectingList(cardInstance:CardInstance):void
		{
			var indexOf:int = effectingCardsRefList.indexOf(cardInstance);
			
			if (indexOf != -1)
			{
				effectingCardsRefList.splice(indexOf, 1);
				cardInstance.removeEffect(this);
				powerChangeCallback();
			}
		}
		
		protected function addToEffectingList(cardInstance:CardInstance):void
		{
			if (effectingCardsRefList.indexOf(cardInstance) == -1)
			{
				effectingCardsRefList.push(cardInstance);
				cardInstance.addEffect(this);
			}
		}
		
		protected function addEffect(sourceOfEffect:CardInstance):void
		{
			effectedByCardsRefList.push(sourceOfEffect);
			powerChangeCallback();
			
			//trace("GFX ----- Effected Added sourceID: ", sourceOfEffect.instanceId, ", targetID:", this.instanceId);
		}
		
		protected function removeEffect(sourceEffect:CardInstance):void
		{
			var indexOf:int = effectedByCardsRefList.indexOf(sourceEffect);
			if (indexOf != -1)
			{
				effectedByCardsRefList.splice(indexOf, 1);
				powerChangeCallback();
				//trace("GFX ----- Removing Added Effect sourceID: ", sourceEffect.instanceId, ", targetID:", this.instanceId);
			}
			else
			{
				//trace("GFX ------------------- WARNING, tried to remove effect fromID:", sourceEffect.instanceId, ", but could not find reference in list of:", this.instanceId);
			}
		}
		
		// #J used by the CardFXManager callback for playing fx so added in unused parameter to make life easier.
		public function updateEffectsApplied(cardInstance:CardInstance = null):void
		{
			var cardFXManager:CardFXManager = CardFXManager.getInstance();
			var cardManagerRef:CardManager = CardManager.getInstance();
			var it:int;
			var cardList:Vector.<CardInstance>;
			var copyList:Vector.<CardInstance>;
			var currentInstance:CardInstance;
			var gameFlowRef:GwintGameFlowController = GwintGameFlowController.getInstance();
			var effectedList:int = CardManager.CARD_LIST_LOC_INVALID;
			
			trace("GFX - updateEffectsApplied Called ----------");
			
			// Creatures
			// {
				if (templateRef.isType(CardTemplate.CardType_Creature) && !templateRef.isType(CardTemplate.CardType_Hero))
				{
					cardList = cardManagerRef.cardEffectManager.getEffectsForList(inList, listsPlayer);
					
					trace("GFX - fetched: ", cardList.length, ", effects for list:", inList, ", and Player:", listsPlayer);
					
					for (it = 0; it < cardList.length; ++it)
					{
						currentInstance = cardList[it];
						if (currentInstance != this)
						{
							currentInstance.addToEffectingList(this);
						}
					}
				}
			// }
			
			// Weather
			// {
				if (templateRef.isType(CardTemplate.CardType_Weather))
				{
					if (!templateRef.hasEffect(CardTemplate.CardEffect_ClearSky))
					{
						cardList = new Vector.<CardInstance>();
						
						if (templateRef.hasEffect(CardTemplate.CardEffect_Melee))
						{
							cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_MELEE, CardManager.PLAYER_1, cardList);
							cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_MELEE, CardManager.PLAYER_2, cardList);
							cardManagerRef.cardEffectManager.registerActiveEffectCardInstance(this, CardManager.CARD_LIST_LOC_MELEE, CardManager.PLAYER_1);
							cardManagerRef.cardEffectManager.registerActiveEffectCardInstance(this, CardManager.CARD_LIST_LOC_MELEE, CardManager.PLAYER_2);
							trace("GFX - Applying Melee Weather Effect");
						}
						
						if (templateRef.hasEffect(CardTemplate.CardEffect_Ranged))
						{
							cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_RANGED, CardManager.PLAYER_1, cardList);
							cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_RANGED, CardManager.PLAYER_2, cardList);
							cardManagerRef.cardEffectManager.registerActiveEffectCardInstance(this, CardManager.CARD_LIST_LOC_RANGED, CardManager.PLAYER_1);
							cardManagerRef.cardEffectManager.registerActiveEffectCardInstance(this, CardManager.CARD_LIST_LOC_RANGED, CardManager.PLAYER_2);
							trace("GFX - Applying Ranged Weather Effect");
						}
						
						if (templateRef.hasEffect(CardTemplate.CardEffect_Siege))
						{
							cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_SEIGE, CardManager.PLAYER_1, cardList);
							cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_SEIGE, CardManager.PLAYER_2, cardList);
							cardManagerRef.cardEffectManager.registerActiveEffectCardInstance(this, CardManager.CARD_LIST_LOC_SEIGE, CardManager.PLAYER_1);
							cardManagerRef.cardEffectManager.registerActiveEffectCardInstance(this, CardManager.CARD_LIST_LOC_SEIGE, CardManager.PLAYER_2);
							trace("GFX - Applying SIEGE Weather Effect");
						}
						
						for (it = 0; it < cardList.length; ++it)
						{
							currentInstance = cardList[it];
							addToEffectingList(currentInstance);
						}
					}
				}
			// }

			// Scorch
			// {
				if (templateRef.hasEffect(CardTemplate.CardEffect_Scorch))
				{
					var scorchList:Vector.<CardInstance> = cardManagerRef.getScorchTargets();
					var i:int;
					
					trace("GFX - Applying Scorch Effect, number of targets: " + scorchList.length);
					
					GwintGameMenu.mSingleton.playSound("gui_gwint_scorch");
					for (i = 0; i < scorchList.length; ++i)
					{
						cardFXManager.playScorchEffectFX(scorchList[i], onScorchFXEnd);
					}
				}
			// }

			// MeleeScorch - Dragon
			// {
				if (templateRef.hasEffect(CardTemplate.CardEffect_MeleeScorch))
				{
					var scorchMeleeList:Vector.<CardInstance>;
					if (cardManagerRef.calculatePlayerScore(CardManager.CARD_LIST_LOC_MELEE, notListPlayer) >= 10)
					{
						scorchMeleeList = cardManagerRef.getScorchTargets(CardTemplate.CardType_Melee, notListPlayer);
						
						trace("GFX - Applying scorchMeleeList, number of targets: " + scorchMeleeList.length);
						
						GwintGameMenu.mSingleton.playSound("gui_gwint_scorch");
						for (it = 0; it < scorchMeleeList.length; ++it)
						{
							cardFXManager.playScorchEffectFX(scorchMeleeList[it], onScorchFXEnd);
						}
					}
				}
			// }

			// RangedScorch - EP1 - Toad
			// {
				if (templateRef.hasEffect(CardTemplate.CardEffect_RangedScorch))
				{
					var scorchRangedList:Vector.<CardInstance>;
					if (cardManagerRef.calculatePlayerScore(CardManager.CARD_LIST_LOC_RANGED, notListPlayer) >= 10)
					{
						scorchRangedList = cardManagerRef.getScorchTargets(CardTemplate.CardType_Ranged, notListPlayer);
						
						trace("GFX - Applying scorchRangedList, number of targets: " + scorchRangedList.length);
						
						GwintGameMenu.mSingleton.playSound("gui_gwint_scorch");
						for (it = 0; it < scorchRangedList.length; ++it)
						{
							cardFXManager.playScorchEffectFX(scorchRangedList[it], onScorchFXEnd);
						}
					}
				}
			// }
			
			// RangedScorch - EP1 - Schirru
			// {
				if (templateRef.hasEffect(CardTemplate.CardEffect_Siege_Scorch))
				{
					var scorchSiegeList:Vector.<CardInstance>;
					if (cardManagerRef.calculatePlayerScore(CardManager.CARD_LIST_LOC_SEIGE, notListPlayer) >= 10)
					{
						scorchSiegeList = cardManagerRef.getScorchTargets(CardTemplate.CardType_Siege, notListPlayer);
						
						trace("GFX - Applying scorchSiegeList, number of targets: " + scorchSiegeList.length);
						
						GwintGameMenu.mSingleton.playSound("gui_gwint_scorch");
						for (it = 0; it < scorchSiegeList.length; ++it)
						{
							cardFXManager.playScorchEffectFX(scorchSiegeList[it], onScorchFXEnd);
						}
					}
				}
			// }
			
			// HORN
			// {
				if (templateRef.hasEffect(CardTemplate.CardEffect_Horn))
				{
					// Step 1 (TODO?) removed this buff from all currently buffed units (in case its being moved to graveyard/another row
					trace("GFX - Applying Horn Effect ----------");
					
					// Step 2, see if it is effecting a row and buff the respective card instances
					effectedList = CardManager.CARD_LIST_LOC_INVALID;
					if (inList == CardManager.CARD_LIST_LOC_MELEEMODIFIERS || inList == CardManager.CARD_LIST_LOC_MELEE)
					{
						effectedList = CardManager.CARD_LIST_LOC_MELEE;
					}
					else if (inList == CardManager.CARD_LIST_LOC_RANGEDMODIFIERS || inList == CardManager.CARD_LIST_LOC_RANGED)
					{
						effectedList = CardManager.CARD_LIST_LOC_RANGED;
					}
					else if (inList == CardManager.CARD_LIST_LOC_SEIGEMODIFIERS || inList == CardManager.CARD_LIST_LOC_SEIGE)
					{
						effectedList = CardManager.CARD_LIST_LOC_SEIGE;
					}
					
					if (effectedList != CardManager.PLAYER_INVALID)
					{
						cardList = cardManagerRef.getCardInstanceList(effectedList, listsPlayer);
						
						if (cardList)
						{
							for (it = 0; it < cardList.length; ++it)
							{
								currentInstance = cardList[it];
								if (!currentInstance.templateRef.isType(CardTemplate.CardType_Hero) && currentInstance != this)
								{
									addToEffectingList(currentInstance);
								}
							}
						}
						
						cardFXManager.playerCardEffectFX(this, null);
						cardFXManager.playRowEffect(effectedList, listsPlayer, cardFXManager._hornRowFXClassRef);
						
						cardManagerRef.cardEffectManager.registerActiveEffectCardInstance(this, effectedList, this.listsPlayer);
					}
				}
			// }
			
			// Mushroom
			// {
				if (templateRef.hasEffect(CardTemplate.CardEffect_Mushroom))
				{
					effectedList = CardManager.CARD_LIST_LOC_INVALID;
					if (inList == CardManager.CARD_LIST_LOC_MELEEMODIFIERS || inList == CardManager.CARD_LIST_LOC_MELEE)
					{
						effectedList = CardManager.CARD_LIST_LOC_MELEE;
					}
					else if (inList == CardManager.CARD_LIST_LOC_RANGEDMODIFIERS || inList == CardManager.CARD_LIST_LOC_RANGED)
					{
						effectedList = CardManager.CARD_LIST_LOC_RANGED;
					}
					else if (inList == CardManager.CARD_LIST_LOC_SEIGEMODIFIERS || inList == CardManager.CARD_LIST_LOC_SEIGE)
					{
						effectedList = CardManager.CARD_LIST_LOC_SEIGE;
					}

					var isSkelligeFaction:Boolean	= cardManagerRef.getSpawnedFaction(this) == CardTemplate.FactionId_Skellige;
					var sfxString:String			= isSkelligeFaction ? "gui_gwint_ske_mushroom" : "gui_gwint_mushroom";
					GwintGameMenu.mSingleton.playSound(sfxString);

					var mushroomFX:CardFX = cardFXManager.playRowEffect(effectedList, listsPlayer, cardFXManager._mushroomFXClassRef);
					mushroomFX.midFXPointCallback = mushroomFXTrigger;
					mushroomFX.associatedCardInstance = this;
				}
			// }
			
			// Morph
			// {
				if (templateRef.hasEffect(CardTemplate.CardEffect_Morph) && templateRef.summonFlags.length > 0)
				{
					var transformed:Boolean = false;
					
					// Check if theres a mushroom
					for each (var fellowRowInstance:CardInstance in cardManagerRef.getCardInstanceList(inList, listsPlayer))
					{
						if (fellowRowInstance.templateRef.hasEffect(CardTemplate.CardEffect_Mushroom))
						{
							
							transformed = true;
							break;
						}
					}
					
					if (!transformed)
					{
						if (inList == CardManager.CARD_LIST_LOC_MELEE && cardManagerRef.hasRowModifier(CardManager.CARD_LIST_LOC_MELEEMODIFIERS, listsPlayer, CardTemplate.CardEffect_Mushroom))
						{
							transformed = true;
						}
						else if (inList == CardManager.CARD_LIST_LOC_RANGED && cardManagerRef.hasRowModifier(CardManager.CARD_LIST_LOC_RANGEDMODIFIERS, listsPlayer, CardTemplate.CardEffect_Mushroom))
						{
							transformed = true;
						}
						else if (inList == CardManager.CARD_LIST_LOC_SEIGE && cardManagerRef.hasRowModifier(CardManager.CARD_LIST_LOC_SEIGEMODIFIERS, listsPlayer, CardTemplate.CardEffect_Mushroom))
						{
							transformed = true;
						}
					}
					
					if (transformed)
					{
						var spawnedFX:CardFX = cardFXManager.playerCardEffectFX(this, morphFXEnded);
						if (spawnedFX != null)
						{
							spawnedFX.associatedCardInstance = this;
							spawnedFX.midFXPointCallback = morphFXMidPointTrigger;
						}
					}
				}
			// }
			
			// Nurse
			// {
				if (templateRef.hasEffect(CardTemplate.CardEffect_Nurse))
				{
					var cardAndComboPoints:CardAndComboPoints;
					copyList = new Vector.<CardInstance>();
					cardManagerRef.GetRessurectionTargets(listsPlayer, copyList, true);
					
					trace("GFX - Applying Nurse Effect");

					if (copyList.length > 0)
					{
						if (cardManagerRef.cardEffectManager.randomResEnabled && !templateRef.isType(CardTemplate.CardType_Hero))
						{
							handleNurseChoice(copyList[Math.min(Math.floor(Math.random() * copyList.length), copyList.length - 1)].instanceId);
						}
						else if (gameFlowRef.playerControllers[listsPlayer] is AIPlayerController)
						{
							cardAndComboPoints = cardManagerRef.getHigherOrLowerValueCardFromTargetGraveyard(listsPlayer, true, true, false);
							currentInstance = cardAndComboPoints.cardInstance;
							//copyList.sort(powerChangeSorter);
							//currentInstance = copyList[copyList.length - 1];
							handleNurseChoice(currentInstance.instanceId);
						}
						else
						{
							gameFlowRef.mcChoiceDialog.showDialogCardInstances(copyList, handleNurseChoice, null, "[[gwint_choose_card_to_ressurect]]");
						}
					}
				}
			// }
			
			// Morale Boost
			// {
				if (templateRef.hasEffect(CardTemplate.CardEffect_ImproveNeighbours))
				{
					cardList = cardManagerRef.getCardInstanceList(inList, listsPlayer);
					
					trace("GFX - Applying Improve Neightbours effect");
					
					for (it = 0; it < cardList.length; ++it)
					{
						currentInstance = cardList[it];
						if (!currentInstance.templateRef.isType(CardTemplate.CardType_Hero) && !currentInstance.templateRef.hasEffect(CardTemplate.CardEffect_UnsummonDummy) && currentInstance != this)
						{
							addToEffectingList(currentInstance);
						}
					}
					
					cardFXManager.playerCardEffectFX(this, null);
					
					cardManagerRef.cardEffectManager.registerActiveEffectCardInstance(this, inList, listsPlayer);
				}
			// }
			
			// Tight Bonds
			// {
				if (templateRef.hasEffect(CardTemplate.CardEffect_SameTypeMorale))
				{
					cardList = new Vector.<CardInstance>();
					cardManagerRef.getAllCreaturesNonHero(inList, listsPlayer, cardList);
					
					trace("GFX - Applying Right Bonds effect");
					
					var foundOtherCard:Boolean = false;
					
					for (it = 0; it < cardList.length; ++it)
					{
						currentInstance = cardList[it];
						
						if (currentInstance != this && templateRef.summonFlags.indexOf(currentInstance.templateId) != -1)
						{
							// The buff each other ;)
							currentInstance.addToEffectingList(this);
							addToEffectingList(currentInstance);
							GwintGameMenu.mSingleton.playSound("gui_gwint_morale_boost");
							cardFXManager.playTightBondsFX(currentInstance, null);
							foundOtherCard = true;
						}
					}
					
					if (foundOtherCard)
					{
						cardFXManager.playTightBondsFX(this, null);
					}
				}
			// }
			
			// Summon Clones
			// {
				if (templateRef.hasEffect(CardTemplate.CardEffect_SummonClones))
				{
					var deck:GwintDeck = cardManagerRef.playerDeckDefinitions[listsPlayer];
					
					cardList = cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, listsPlayer);
					var hand_it:int;
					
					var hasSummons:Boolean = false;
					for (it = 0; it < templateRef.summonFlags.length && !hasSummons; ++it)
					{
						if (deck.numCopiesLeft(templateRef.summonFlags[it]) > 0)
						{
							hasSummons = true;
						}
						
						for (hand_it = 0; hand_it < cardList.length; ++hand_it)
						{
							if (cardList[hand_it].templateId == templateRef.summonFlags[it])
							{
								hasSummons = true;
								break;
							}
						}
					}
					
					trace("GFX - Applying Summon Clones Effect, found summons: " + hasSummons);
					
					if (hasSummons)
					{
						cardFXManager.playerCardEffectFX(this, summonFXEnded);
					}
				}
			// }
			
			// Draw Card
			// {
				if (templateRef.hasEffect(CardTemplate.CardEffect_Draw2))
				{
					trace("GFX - applying draw 2 effect");
					
					cardManagerRef.drawCards(listsPlayer == CardManager.PLAYER_1 ? CardManager.PLAYER_2 : CardManager.PLAYER_1, 2);
				}
			// }
			
			cardManagerRef.recalculateScores();
		}
		
		protected function summonFXEnded(cardInstance:CardInstance):void
		{
			var it:int;
			var cardManagerRef:CardManager = CardManager.getInstance();
			
			for (it = 0; it < templateRef.summonFlags.length; ++it)
			{
				cardManagerRef.summonFromDeck(listsPlayer, templateRef.summonFlags[it]);
				cardManagerRef.summonFromHand(listsPlayer, templateRef.summonFlags[it]);
			}
		}
		
		protected function mushroomFXTrigger(cardInstance:CardInstance):void
		{
			var effectedList:int = CardManager.CARD_LIST_LOC_INVALID;
			if (cardInstance.inList == CardManager.CARD_LIST_LOC_MELEEMODIFIERS || cardInstance.inList == CardManager.CARD_LIST_LOC_MELEE)
			{
				effectedList = CardManager.CARD_LIST_LOC_MELEE;
			}
			else if (cardInstance.inList == CardManager.CARD_LIST_LOC_RANGEDMODIFIERS || cardInstance.inList == CardManager.CARD_LIST_LOC_RANGED)
			{
				effectedList = CardManager.CARD_LIST_LOC_RANGED;
			}
			else if (cardInstance.inList == CardManager.CARD_LIST_LOC_SEIGEMODIFIERS || cardInstance.inList == CardManager.CARD_LIST_LOC_SEIGE)
			{
				effectedList = CardManager.CARD_LIST_LOC_SEIGE;
			}
			
			var targetList:Vector.<CardInstance> = CardManager.getInstance().getCardInstanceList(effectedList, cardInstance.listsPlayer);
			
			var cardFXManager:CardFXManager = CardFXManager.getInstance();
			for each (var potentialTarget:CardInstance in targetList)
			{
				if (potentialTarget.templateRef.hasEffect(CardTemplate.CardEffect_Morph) && potentialTarget.templateRef.summonFlags.length == 1)
				{
					var spawnedFX:CardFX = cardFXManager.playerCardEffectFX(potentialTarget, morphFXEnded);
					if (spawnedFX != null)
					{
						spawnedFX.associatedCardInstance = potentialTarget;
						spawnedFX.midFXPointCallback = morphFXMidPointTrigger;
					}
				}
			}
		}
		
		protected function morphFXMidPointTrigger(cardInstance:CardInstance):void
		{
			var targetSlot:CardSlot = CardManager.getInstance().boardRenderer.getCardSlotById(cardInstance.instanceId);
			
			if (targetSlot != null)
			{
				cardInstance.updateTemplateID(cardInstance.templateRef.summonFlags[0]);
				targetSlot.updateTemplate(cardInstance.templateRef);
			}
		}
		
		protected function morphFXEnded(cardInstance:CardInstance):void
		{
			cardInstance.updateEffectsApplied(cardInstance);
		}
		
		protected function handleNurseChoice(instanceId:int):void
		{
			var cardManagerRef:CardManager = CardManager.getInstance();
			var cardInstance:CardInstance = cardManagerRef.getCardInstance(instanceId);
			var cardFXManager:CardFXManager = CardFXManager.getInstance();
			var boardRenderer:GwintBoardRenderer = cardManagerRef.boardRenderer;
			
			// Try and move ressurecting card to top of graveyard render order
			if (boardRenderer)
			{
				var targetSlot:CardSlot = boardRenderer.getCardSlotById(instanceId);
				
				if (targetSlot)
				{
					targetSlot.parent.addChild(targetSlot);
				}
			}
			
			GwintGameMenu.mSingleton.playSound("gui_gwint_resurrect");
			cardFXManager.playRessurectEffectFX(cardInstance, onNurseEffectEnded);
			
			if (GwintGameFlowController.getInstance().mcChoiceDialog.visible)
			{
				GwintGameFlowController.getInstance().mcChoiceDialog.hideDialog();
			}
		}
		
		protected function noNurseChoice():void
		{
			if (GwintGameFlowController.getInstance().mcChoiceDialog.visible)
			{
				GwintGameFlowController.getInstance().mcChoiceDialog.hideDialog();
			}
		}
		
		protected function onNurseEffectEnded(cardInstance:CardInstance = null):void
		{
			var cardManagerRef:CardManager = CardManager.getInstance();
			
			if (cardInstance)
			{
				cardInstance.recalculatePowerPotential(cardManagerRef);
				cardManagerRef.addCardInstanceToList(cardInstance, cardInstance.getOptimalTransaction().targetSlotID, cardInstance.getOptimalTransaction().targetPlayerID);
			}
		}
		
		protected function onScorchFXEnd(cardInstance:CardInstance):void
		{
			CardManager.getInstance().sendToGraveyard(cardInstance);
		}
		
		protected function powerChangeSorter(element1:CardInstance, element2:CardInstance):Number
		{
			if (element1.getOptimalTransaction().powerChangeResult == element2.getOptimalTransaction().powerChangeResult)
			{
				return element1.getOptimalTransaction().strategicValue - element2.getOptimalTransaction().strategicValue;
			}
			
			return element1.getOptimalTransaction().powerChangeResult - element2.getOptimalTransaction().powerChangeResult;
		}
		
		public function potentialWeatherHarm():int
		{
			if (templateRef.isType(CardTemplate.CardType_Weather))
			{
				var cardManager:CardManager = CardManager.getInstance();
				var cardsInHand:Vector.<CardInstance> = cardManager.getAllCreaturesInHand(listsPlayer);
				var lossPointsPotential:int = 0;
				var currentCardInHand:CardInstance;
				var preWeatherDeBuff:int = 0;
				var effectList:Vector.<CardInstance>;
				var typeToCheck:int;
				var effectCard_it:int;
				
				if (templateRef.hasEffect(CardTemplate.CardEffect_Melee))
				{
					typeToCheck = CardManager.CARD_LIST_LOC_MELEE;
				}
				else if (templateRef.hasEffect(CardTemplate.CardEffect_Ranged))
				{
					typeToCheck = CardManager.CARD_LIST_LOC_RANGED;
				}
				else if (templateRef.hasEffect(CardTemplate.CardEffect_Siege))
				{
					typeToCheck = CardManager.CARD_LIST_LOC_SEIGE;
				}
				
				effectList = cardManager.cardEffectManager.getEffectsForList(typeToCheck, listsPlayer);
				
				for (var list_it:int = 0; list_it < cardsInHand.length; ++list_it)
				{
					currentCardInHand = cardsInHand[list_it];
					// RangedMelee is too complicated to put in this quick fallback and is so ignored as it would require a check of other weather effects
					if (currentCardInHand.templateRef.isType(CardTemplate.CardType_Creature) && !currentCardInHand.templateRef.isType(CardTemplate.CardType_RangedMelee)
						&& currentCardInHand.templateRef.isType(typeToCheck)) 
					{
						// Add current board buffs to card (has disadvantage of not checking how the cards in your hand will interact with each other but its better than nothing
						for (effectCard_it = 0; effectCard_it < effectList.length; ++effectCard_it)
						{
							currentCardInHand.effectedByCardsRefList.push(effectList[effectCard_it]);
						}
						
						preWeatherDeBuff = currentCardInHand.getTotalPower();
						
						currentCardInHand.effectedByCardsRefList.push(this);
						lossPointsPotential += Math.max(0, preWeatherDeBuff - currentCardInHand.getTotalPower());
						
						currentCardInHand.effectedByCardsRefList.length = 0;
					}
				}
				
				return lossPointsPotential;
			}
			else
			{
				return 0;
			}
		}
	}
}
