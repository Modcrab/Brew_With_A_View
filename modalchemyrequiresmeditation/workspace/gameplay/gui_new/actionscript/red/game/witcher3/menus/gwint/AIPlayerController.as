package red.game.witcher3.menus.gwint
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import scaleform.clik.core.UIComponent;
	import red.game.witcher3.utils.FiniteStateMachine;
	
	/**
	 * ...
	 * @author Jason Slama sept 2014
	 */
		
	public class AIPlayerController extends BasePlayerController
	{
		protected static const TACTIC_NONE					:int = 0;
		protected static const TACTIC_SPY_DUMMY_BEST_THEN_PASS	:int = 1;
		protected static const TACTIC_MINIMIZE_LOSS			:int = 1;
		protected static const TACTIC_MINIMIZE_WIN			:int = 2;
		protected static const TACTIC_MAXIMIZE_WIN			:int = 3;
		protected static const TACTIC_AVERAGE_WIN			:int = 4;
		protected static const TACTIC_MINIMAL_WIN			:int = 5;
		protected static const TACTIC_JUST_WAIT				:int = 6;
		protected static const TACTIC_PASS					:int = 7;
		protected static const TACTIC_WAIT_DUMMY			:int = 8;
		protected static const TACTIC_SPY					:int = 9;
		protected static const TACTIC_BESERKER				:int = 10;
		protected static const TACTIC_PLAY_SUICIDE			:int = 11;
		
		protected var attitude:int; 
		protected var chances:int;
		private var berserkerSelectedRowType:int;
		private var berserkerMushroomPlaced:Boolean;
		
		function AIPlayerController()
		{
			super();
			
			isAI = true;
			
			_stateMachine.AddState("Idle", 						state_begin_Idle, 			null,						state_end_Idle);
			_stateMachine.AddState("ChoosingMove", 				state_begin_ChoseMove,		state_update_ChooseMove,	null);
			_stateMachine.AddState("SendingCardToTransaction", 	state_begin_SendingCard,	state_update_SendingCard,	null);
			_stateMachine.AddState("DelayBetweenActions",		state_begin_DelayAction,	state_update_DelayAction,   null);
			_stateMachine.AddState("ApplyingCard",				state_begin_ApplyingCard,	state_update_ApplyingCard,	null);
		}
		
		override public function startTurn():void
		{
			if (currentRoundStatus == BasePlayerController.ROUND_PLAYER_STATUS_DONE)
			{
				return;
			}
			
			super.startTurn();
			_stateMachine.ChangeState("ChoosingMove");
		}
		
		/*---------------------------------------
		 *  Idle State
		 *---------------------------------------*/
		protected function state_begin_Idle():void
		{
			if (attitude == TACTIC_PASS)
			{
				currentRoundStatus = BasePlayerController.ROUND_PLAYER_STATUS_DONE
			}
			
			_turnOver = true;
			
			if (CardManager.getInstance().getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, playerID).length == 0 && CardManager.getInstance().getCardLeader(playerID) != null && !CardManager.getInstance().getCardLeader(playerID).canBeUsed)
			{
				currentRoundStatus = BasePlayerController.ROUND_PLAYER_STATUS_DONE
			}
			
			if (_boardRenderer)
			{
				_boardRenderer.getCardHolder(CardManager.CARD_LIST_LOC_LEADER, playerID).updateLeaderStatus(false);
			}
		}
		
		protected function state_end_Idle():void
		{
			if (_boardRenderer)
			{
				_boardRenderer.getCardHolder(CardManager.CARD_LIST_LOC_LEADER, playerID).updateLeaderStatus(true);
			}
		}
		
		/*---------------------------------------*/
		
		/*---------------------------------------
		 *  ChoosingMove State
		 *---------------------------------------*/
		
		protected function attitudeToString(_attitude:int):String
		{
			switch (_attitude)
			{
			case TACTIC_NONE:
				return "NONE - ERROR";
			case TACTIC_SPY_DUMMY_BEST_THEN_PASS:
				return "DUMMY BETS THEN PASS";
			case TACTIC_MINIMIZE_LOSS:
				return "MINIMIZE LOSS";
			case TACTIC_MINIMIZE_WIN:
				return "MINIMIZE WIN";
			case TACTIC_MAXIMIZE_WIN:
				return "MAXIMIZE WIN";
			case TACTIC_AVERAGE_WIN:
				return "AVERAGE WIN";
			case TACTIC_MINIMAL_WIN:
				return "MINIMAL WIN";
			case TACTIC_JUST_WAIT:
				return "JUST WAIT";
			case TACTIC_PASS:
				return "PASS";
			case TACTIC_WAIT_DUMMY:
				return "WAIT DUMMY";
			case TACTIC_SPY:
				return "SPIES";
			case TACTIC_BESERKER:
				return "BESERKER";
			case TACTIC_PLAY_SUICIDE:
				return "SUICIDE";
			}
			
			return _attitude.toString();
		}
		
		protected function state_begin_ChoseMove():void
		{
			CardManager.getInstance().CalculateCardPowerPotentials();
			
			ChooseAttitude();
			
			var attitudeName:String = attitudeToString(attitude);
			
			trace("GFX -#AI# ai has decided to use the following attitude:" + attitudeName);
			
			_decidedCardTransaction = decideWhichCardToPlay();
			
			// Don't play a card that hurts you if you have no creatures left to play and its the last round
			if (_decidedCardTransaction == null && attitude != TACTIC_PASS)
			{
				attitude = TACTIC_PASS;
			}
			else if (_decidedCardTransaction != null && _decidedCardTransaction.sourceCardInstanceRef != null)
			{
				if ( attitude != TACTIC_BESERKER && _decidedCardTransaction.sourceCardInstanceRef.templateRef != null)
				{
					// Need to check that we have the right cards to switch to Berserker Tactic.
					var hand:Vector.<CardInstance>;
					hand = CardManager.getInstance().getCardInstanceList( CardManager.CARD_LIST_LOC_HAND, playerID );
					var numShrooms:int = 0;
					var numZerkers:int = 0;
					
					trace( "GFX +--------------------------------------------------------------" );
					trace( "GFX | Evaluating chosen card + hand for Berserker Tactic potential" );
					var rowType:int;
					switch(_decidedCardTransaction.targetSlotID)
					{
					case CardManager.CARD_LIST_LOC_MELEE:	rowType = CardTemplate.CardType_Melee;	trace( "GFX | Selected Card being played on row: Melee" ); break;
					case CardManager.CARD_LIST_LOC_RANGED:	rowType = CardTemplate.CardType_Ranged;	trace( "GFX | Selected Card being played on row: Ranged" ); break;
					case CardManager.CARD_LIST_LOC_SEIGE:	rowType = CardTemplate.CardType_Siege;	trace( "GFX | Selected Card being played on row: Siege" ); break;
					default: trace( "GFX | Selected Card being played on row: !! UNKNOWN !!" ); break;
					}
					trace( "GFX |" );
					
					// How many muchroom cards + berserker cards do we have for this row?
					for ( var i:int = 0; i < hand.length; ++i)
					{
						var template:CardTemplate = hand[i].templateRef;
						if (template.isType(rowType))
						{
							if (template.hasEffect(CardTemplate.CardEffect_Morph))
							{
								++numZerkers;
							}
							if (template.hasEffect(CardTemplate.CardEffect_Mushroom))
							{
								++numShrooms;
							}
						}
					}
					
					trace( "GFX | Zerkers [" + numZerkers + "]" );
					trace( "GFX | Shrooms [" + numShrooms + "]" );
					
					// If we have at least 1 berserker and 1 mushroom then switch to Berserker tactic.
					if (numZerkers && numShrooms &&
						( _decidedCardTransaction.sourceCardInstanceRef.templateRef.hasEffect(CardTemplate.CardEffect_Morph) ||
						_decidedCardTransaction.sourceCardInstanceRef.templateRef.hasEffect(CardTemplate.CardEffect_Mushroom)))
					{
						trace( "GFX |" );
						attitude = TACTIC_BESERKER;
						berserkerSelectedRowType = rowType;
						berserkerMushroomPlaced = _decidedCardTransaction.sourceCardInstanceRef.templateRef.hasEffect(CardTemplate.CardEffect_Mushroom);
						switch( berserkerSelectedRowType )
						{
							case CardTemplate.CardType_Melee:	trace( "GFX | Activating Berserker Tactic on row: Melee" ); break;
							case CardTemplate.CardType_Ranged:	trace( "GFX | Activating Berserker Tactic on row: Ranged" ); break;
							case CardTemplate.CardType_Siege:	trace( "GFX | Activating Berserker Tactic on row: Siege" ); break;
						}
					}
					trace( "GFX +--------------------------------------------------------------" );
				}
			}
			else if (_currentRoundCritical && _decidedCardTransaction != null && !_decidedCardTransaction.sourceCardInstanceRef.templateRef.hasEffect(CardTemplate.CardEffect_UnsummonDummy) && 
				_decidedCardTransaction.powerChangeResult < 0 && CardManager.getInstance().getAllCreaturesInHand(playerID).length == 0)
			{
				_decidedCardTransaction = null;
				attitude = TACTIC_PASS;
			}
			
			trace("GFX -#AI# the ai decided on the following transaction: " + _decidedCardTransaction);
		}
		
		protected function state_update_ChooseMove():void
		{
			if (attitude == TACTIC_PASS || _decidedCardTransaction == null)
			{
				_stateMachine.ChangeState("Idle");
				
				if (attitude != TACTIC_PASS)
				{
					trace("GFX -#AI#--------------- WARNING ---------- AI is passing since chosen tactic was unable to find a transaction is liked");
				}
				attitude = TACTIC_PASS; // If the other attitudes did not find something valid to play, then technically its a pass.
			}
			else
			{
				_stateMachine.ChangeState("SendingCardToTransaction");
			}
		}
		
		/*---------------------------------------*/
		
		/*---------------------------------------
		 *  SendingCardToTransaction State
		 *---------------------------------------*/
		
		protected function state_begin_SendingCard():void
		{
			trace("GFX -#AI# AI is sending the following card into transaction: ", _decidedCardTransaction.sourceCardInstanceRef);
			startCardTransaction(_decidedCardTransaction.sourceCardInstanceRef.instanceId);
		}
		
		protected function state_update_SendingCard():void
		{
			if (!CardTweenManager.getInstance().isAnyCardMoving())
			{
				_stateMachine.ChangeState("DelayBetweenActions");
			}
		}
		
		/*---------------------------------------*/
		
		/*---------------------------------------
		 *  DelayBetweenActions State
		 *---------------------------------------*/
		
		protected var waitingForTimer:Boolean;
		protected var waitingTimer:Timer;
		protected function state_begin_DelayAction():void
		{
			waitingForTimer = true;
			waitingTimer = new Timer(1200, 1);
			waitingTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onWaitingTimerEnded, false, 0, true);
			waitingTimer.start();
		}
		
		protected function state_update_DelayAction():void
		{
			if (!waitingForTimer)
			{
				_stateMachine.ChangeState("ApplyingCard");
			}
		}
		
		protected function onWaitingTimerEnded(event:TimerEvent):void
		{
			waitingForTimer = false;
			waitingTimer = null;
		}
		
		/*---------------------------------------*/
		
		// -------------------------------------------------------------------------------------------------------------------------------------------
		// - AI Decision making logic
		// -------------------------------------------------------------------------------------------------------------------------------------------
		
		protected var _currentRoundCritical:Boolean = false;
		
		private function ChooseAttitude():void
		{
			var cardManagerRef:CardManager = CardManager.getInstance();
			var cardsInHand:Vector.<CardInstance> = new Vector.<CardInstance>();
			var i:int;
			cardsInHand = cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, playerID);
			
			if (cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, playerID).length == 0)
			{
				attitude = TACTIC_PASS;
				return;
			}
			
			// Gather score and status information
			// {
				var scoreIt:int;
				var roundWinner:int;
				var hasWon:Boolean = false;
				var opponentHasWon:Boolean = false;
				var numUnitsInHand:int = 0;
				var dummyCount:int = 0;
				var spyCount:int = 0;

				for (scoreIt = 0; scoreIt < cardManagerRef.roundResults.length; ++scoreIt)
				{
					if (cardManagerRef.roundResults[scoreIt].played)
					{
						roundWinner = cardManagerRef.roundResults[scoreIt].winningPlayer;
						
						if (roundWinner == playerID || roundWinner == CardManager.PLAYER_INVALID)
						{
							hasWon = true;
						}
						
						if (roundWinner == opponentID || roundWinner == CardManager.PLAYER_INVALID)
						{
							opponentHasWon = true;
						}
					}
				}
				
				_currentRoundCritical = opponentHasWon; // If opponent has already won, the current round is critical
				
				for (i = 0; i < cardsInHand.length; ++i)
				{
					if (cardsInHand[i].templateRef.isType(CardTemplate.CardType_Creature))
					{
						++numUnitsInHand;
					}
				}
				
				var playerCardsInHand:int = cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, playerID).length;
				var opponentCardsInHand:int = cardManagerRef.getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, opponentID).length;
				var cardAdvantage:int = playerCardsInHand - opponentCardsInHand;
				
				var scoreDifference:int = cardManagerRef.currentPlayerScores[playerID] - cardManagerRef.currentPlayerScores[opponentID];

				var opponentRoundStatus:int = gameFlowControllerRef.playerControllers[opponentID].currentRoundStatus;
			// }
			
			trace("GFX -#AI# ###############################################################################");			
			trace("GFX -#AI#---------------------------- AI Deciding his next move --------------------------------");
			trace("GFX -#AI#------ previousTactic: " + attitudeToString(attitude));
			trace("GFX -#AI#------ playerCardsInHand: " + playerCardsInHand);
			trace("GFX -#AI#------ opponentCardsInHand: " + opponentCardsInHand);
			trace("GFX -#AI#------ cardAdvantage: " + cardAdvantage);
			trace("GFX -#AI#------ scoreDifference: " + scoreDifference + ", his score: " + cardManagerRef.currentPlayerScores[playerID] + ", enemy score: " + cardManagerRef.currentPlayerScores[opponentID]);
			trace("GFX -#AI#------ opponent has won: " + opponentHasWon);
			trace("GFX -#AI#------ has won: " + hasWon);
			trace("GFX -#AI#------ Num units in hand: " + numUnitsInHand);
			if (gameFlowControllerRef.playerControllers[opponentID].currentRoundStatus == ROUND_PLAYER_STATUS_DONE)
			{
				trace("GFX -#AI#------ has opponent passed: true");
			}
			else
			{
				trace("GFX -#AI#------ has opponent passed: false");
			}
			trace("GFX =#AI#=======================================================================================");
			trace("GFX -#AI#-----------------------------   AI CARDS AT HAND   ------------------------------------");
			
			for (i = 0; i < cardsInHand.length; ++i)
			{
				trace("GFX -#AI# Card Points[ ", cardsInHand[i].templateRef.power, " ], Card -", cardsInHand[i]);
			}
			trace("GFX =#AI#=======================================================================================");
			
			var playerFaction:int = cardManagerRef.playerDeckDefinitions[playerID].getDeckFaction();
			var opponentFaction:int = cardManagerRef.playerDeckDefinitions[opponentID].getDeckFaction();
			var spiesOnMySide:int = cardManagerRef.getCardsInSlotIdWithEffect(CardTemplate.CardEffect_Draw2, opponentID).length;
			
			if (attitude == TACTIC_BESERKER)
			{
				var beserkersOnBoard:Vector.<CardInstance> = new Vector.<CardInstance>();
				var beserkersInHand:Vector.<CardInstance> = new Vector.<CardInstance>();
				
				cardManagerRef.getBeserkersOnBoard(playerID, beserkersOnBoard);
				cardManagerRef.getBeserkersInHand(playerID, beserkersInHand);
				
				if (beserkersInHand.length > 0 || (beserkersOnBoard.length > 0 && cardManagerRef.getCardsInHandWithEffect(CardTemplate.CardEffect_Mushroom, playerID).length > 0))
				{
					return; // keep playing beserker related cards
				}
			}
			
			if (cardManagerRef.getFirstCardInHandWithEffect(CardTemplate.CardEffect_SuicideSummon, playerID) != null)
			{
				attitude = TACTIC_PLAY_SUICIDE;
			}
			else if (playerFaction == CardTemplate.FactionId_Nilfgaard && opponentFaction != CardTemplate.FactionId_Nilfgaard && opponentRoundStatus == ROUND_PLAYER_STATUS_DONE && scoreDifference == 0) // Nilfgaard wins on draw so pass when same score and opponent passed too
			{
				attitude = TACTIC_PASS;
			}
			else if (!opponentHasWon && attitude == TACTIC_SPY_DUMMY_BEST_THEN_PASS) // Opponent didnt win yet spy&dummy&pass and spy attitudes
			{
				if (opponentRoundStatus != ROUND_PLAYER_STATUS_DONE)
				{
					attitude == TACTIC_SPY_DUMMY_BEST_THEN_PASS;
				}
			}
			else if ( !opponentHasWon && cardManagerRef.getFirstCardInHandWithEffect(CardTemplate.CardEffect_Draw2, playerID) != null && (Math.random() < 0.20 || spiesOnMySide > 1) && attitude != TACTIC_SPY_DUMMY_BEST_THEN_PASS)
			{
				attitude = TACTIC_SPY;
			}
			else if (attitude == TACTIC_SPY && cardManagerRef.getFirstCardInHandWithEffect(CardTemplate.CardEffect_Draw2, playerID) != null)
			{
				attitude = TACTIC_SPY;
			}
			else if (opponentRoundStatus == ROUND_PLAYER_STATUS_DONE)
			{
				// We already decided to minimize loss, see it through
				if (attitude == TACTIC_MINIMIZE_LOSS)
				{
					attitude = TACTIC_MINIMIZE_LOSS;
				}
				else if (!opponentHasWon && scoreDifference <= 0 && Math.random() < (scoreDifference / 20.0))
				{
					attitude = TACTIC_MINIMIZE_LOSS;
				}
				else if (!hasWon && scoreDifference > 0)
				{
					attitude = TACTIC_MINIMIZE_WIN;
				}
				else if (scoreDifference > 0)
				{
					attitude = TACTIC_PASS;
				}
				else // if (scoreDifferent <= 0)
				{
					attitude = TACTIC_MINIMAL_WIN;
				}
			}
			else
			{
				if (scoreDifference > 0)
				{
					if (opponentHasWon)
					{
						attitude = TACTIC_JUST_WAIT;
					}
					else
					{
						var numCardsInHandToPerf:Number = (numUnitsInHand) * (numUnitsInHand) / 36;
						
						attitude = TACTIC_NONE;
						
						if (hasWon)
						{
							dummyCount = cardManagerRef.getCardsInHandWithEffect(CardTemplate.CardEffect_UnsummonDummy, playerID).length;
							spyCount = cardManagerRef.getCardsInHandWithEffect(CardTemplate.CardEffect_Draw2, playerID).length;
							if (Math.random() < 0.2 || playerCardsInHand == (dummyCount + spyCount)) // Retreat!
							{
								attitude = TACTIC_SPY_DUMMY_BEST_THEN_PASS;
							}
							else
							{
								var dummyInstance = cardManagerRef.getFirstCardInHandWithEffect(CardTemplate.CardEffect_UnsummonDummy, playerID);
								if (dummyInstance != null && cardManagerRef.getHigherOrLowerValueTargetCardOnBoard(dummyInstance, playerID, false) != null)
								{
									attitude = TACTIC_WAIT_DUMMY;
								}
								else if ((Math.random() < (scoreDifference / 30.0)) && (Math.random() < numCardsInHandToPerf))
								{
									attitude = TACTIC_MAXIMIZE_WIN;
								}
							}
						}
						
						if (attitude == TACTIC_NONE)
						{
							// Full hand is typically 10 cards, so 100% chance to do this, the chance of doing this decreases the less cards he has in his hand
							if (Math.random() < (playerCardsInHand / 10) || playerCardsInHand > 8)
							{
								if (Math.random() < 0.2 || playerCardsInHand == (dummyCount + spyCount)) // Retreat!
								{
									attitude = TACTIC_SPY_DUMMY_BEST_THEN_PASS;
								}
								else
								{
									attitude = TACTIC_JUST_WAIT;
								}
							}
							else
							{
								attitude = TACTIC_PASS;
							}
						}
					}
				}
				else // ScoreDifference <= 0
				{
					if (hasWon)
					{
						dummyCount = cardManagerRef.getCardsInHandWithEffect(CardTemplate.CardEffect_UnsummonDummy, playerID).length;
						spyCount = cardManagerRef.getCardsInHandWithEffect(CardTemplate.CardEffect_Draw2, playerID).length;
						if (!opponentHasWon && (Math.random() < 0.2 || playerCardsInHand == (dummyCount + spyCount))) // Retreat!
						{
							attitude = TACTIC_SPY_DUMMY_BEST_THEN_PASS;
						}
						else
						{
							attitude = TACTIC_MAXIMIZE_WIN; // Go for the throat
						}
					}
					else if (opponentHasWon) // Make sure you don't lose this round
					{
						attitude = TACTIC_MINIMAL_WIN;
					}
					else // First round
					{
						if (!cardManagerRef.roundResults[0].played && scoreDifference < -11 && Math.random() < ((Math.abs(scoreDifference) - 10) / 20))
						{
							if (Math.random() < 0.9) // Retreat!
							{
								attitude = TACTIC_SPY_DUMMY_BEST_THEN_PASS;
							}
							else
							{
							attitude = TACTIC_PASS; // Sometimes be Homer Simpson - Doooh
							}
						}
						else if (Math.random() < playerCardsInHand / 10)
						{
							attitude = TACTIC_MINIMAL_WIN;
						}
						else if (Math.random() <  playerCardsInHand / 10)
						{
							attitude = TACTIC_AVERAGE_WIN;
						}
						else if (Math.random() <  playerCardsInHand / 10)
						{
							attitude = TACTIC_MAXIMIZE_WIN;
						}
						else if (playerCardsInHand <= 8 && Math.random() > (playerCardsInHand / 10))
						{
							attitude = TACTIC_PASS;
						}
						else
						{
							attitude = TACTIC_JUST_WAIT;
						}
					}
				}
			}
		}
		
		private static const SortType_None:int = 0;
		private static const SortType_StrategicValue:int = 1;
		private static const SortType_PowerChange:int = 2;
		
		protected function decideWhichCardToPlay() : CardTransaction
		{
			var sortedCards:Vector.<CardInstance>;
			var list_it:int;
			
			var cardManagerRef:CardManager = CardManager.getInstance();
			var playerScore:int = cardManagerRef.currentPlayerScores[playerID] 
			var opponentScore:int = cardManagerRef.currentPlayerScores[opponentID];
			var scoreDifference = playerScore - opponentScore;
			var currentTransaction:CardTransaction
			var currentCard:CardInstance;
			var bestCard:CardInstance;
			
			switch (attitude)
			{
				case TACTIC_PLAY_SUICIDE:
					{
						currentCard = cardManagerRef.getFirstCardInHandWithEffect(CardTemplate.CardEffect_SuicideSummon, playerID);
						
						if (currentCard != null)
						{
							return currentCard.getOptimalTransaction();
						}
						
						attitude = TACTIC_PASS;
					}
					break;
				case TACTIC_BESERKER:
					{
						// Do we have any berserker cards for the selected row?
						var cardList:Vector.<CardInstance>;
						cardList = cardManagerRef.getCardsInHandWithEffect(CardTemplate.CardEffect_Morph, playerID);
						for (var i:int = 0; i < cardList.length; ++i )
						{
							if (cardList[i].templateRef.isType(berserkerSelectedRowType))
							{
								currentCard = cardList[i];
								break;
							}
						}
						
						if (currentCard != null)
						{
							return currentCard.getOptimalTransaction();
						}
						else
						{
							if ( !berserkerMushroomPlaced )
							{
								// Do we have any mushroom cards for the selected row?
								cardList = cardManagerRef.getCardsInHandWithEffect(CardTemplate.CardEffect_Mushroom, playerID);
								for (var j:int = 0; j < cardList.length; ++j )
								{
									if (cardList[j].templateRef.isType(berserkerSelectedRowType))
									{
										currentCard = cardList[j];
										break;
									}
								}
								
								if (currentCard != null)
								{
									berserkerMushroomPlaced = true;
									return currentCard.getOptimalTransaction();
								}
							}
							
							attitude = TACTIC_PASS;
						}
					}
					break;
				case TACTIC_SPY_DUMMY_BEST_THEN_PASS:
					{
						currentCard = cardManagerRef.getFirstCardInHandWithEffect(CardTemplate.CardEffect_Draw2, playerID);
				
						if (currentCard != null)
						{
							return currentCard.getOptimalTransaction();
						}

						currentCard = cardManagerRef.getFirstCardInHandWithEffect(CardTemplate.CardEffect_UnsummonDummy, playerID);
						
						if (currentCard)
						{
							// Look for the highest / Best card
							bestCard = cardManagerRef.getHigherOrLowerValueTargetCardOnBoard(currentCard, playerID, true, true); //Highest card, EXCEPTION -> Lowest Spy
							
							if (bestCard)
							{
								currentTransaction = currentCard.getOptimalTransaction();
								currentTransaction.targetCardInstanceRef = bestCard;
								return currentTransaction;
							}
						}
						
						attitude = TACTIC_PASS;
					}
					break;
				case TACTIC_MINIMIZE_LOSS:
					{
						currentCard = cardManagerRef.getFirstCardInHandWithEffect(CardTemplate.CardEffect_UnsummonDummy, playerID);
						
						if (currentCard)
						{
							// Look for the highest value card that can be dummied
							bestCard = getHighestValueCardOnBoard();
							
							if (bestCard)
							{
								currentTransaction = currentCard.getOptimalTransaction();
								currentTransaction.targetCardInstanceRef = bestCard; // The optimal transaction is the weakest
								return currentTransaction;
							}
						}
						
						currentCard = cardManagerRef.getFirstCardInHandWithEffect(CardTemplate.CardEffect_Draw2, playerID);
				
						if (currentCard != null)
						{
							return currentCard.getOptimalTransaction();
						}
						
						attitude = TACTIC_PASS;
					}
					break;
				case TACTIC_MINIMIZE_WIN:
					{
						currentCard = cardManagerRef.getFirstCardInHandWithEffect(CardTemplate.CardEffect_UnsummonDummy, playerID);
						
						if (currentCard)
						{	
							// Look for the highest value card that can be dummied
							bestCard = getHighestValueCardOnBoardWithEffectLessThan(scoreDifference);
							
							if (bestCard)
							{
								currentTransaction = currentCard.getOptimalTransaction();
								
								if (currentTransaction)
								{
									currentTransaction.targetCardInstanceRef = bestCard; // The optimal transaction is the weakest
									return currentTransaction;
								}
							}
						}
						
						sortedCards = cardManagerRef.getCardsInHandWithEffect(CardTemplate.CardEffect_Draw2, playerID);
						
						for (list_it = 0; list_it < sortedCards.length; ++list_it)
						{
							currentCard = sortedCards[list_it];
							
							if (currentCard && Math.abs(currentCard.getOptimalTransaction().powerChangeResult) < Math.abs(scoreDifference))
							{
								return currentCard.getOptimalTransaction();
							}
						}
						
						attitude = TACTIC_PASS;
					}
					break;
				case TACTIC_MAXIMIZE_WIN:
					{
						sortedCards = getCardsBasedOnCriteria(SortType_PowerChange);
						
						if (sortedCards.length > 0)
						{
							bestCard = sortedCards[sortedCards.length - 1];
							
							if (bestCard)
							{
								return bestCard.getOptimalTransaction();
							}
						}
					}
					break;
				case TACTIC_AVERAGE_WIN:
					{
						sortedCards = getCardsBasedOnCriteria(SortType_PowerChange);
						var firstValidIndex:int = -1;
						
						while (list_it < sortedCards.length && firstValidIndex == -1)
						{
							currentCard = sortedCards[list_it];
							
							if (currentCard.getOptimalTransaction().powerChangeResult > Math.abs(scoreDifference))
							{
								firstValidIndex = list_it;
							}
							
							++list_it;
						}
						
						if (firstValidIndex != -1)
						{
							// #J Using Min and Max to protect against out of bounds with random calculation
							var targetIndex:int = Math.min(firstValidIndex, Math.max(sortedCards.length - 1, firstValidIndex + Math.floor(Math.random() * (sortedCards.length - 1 - firstValidIndex))));
							
							bestCard = sortedCards[targetIndex];
							
							if (bestCard)
							{
								return bestCard.getOptimalTransaction();
							}
						}
						else if (sortedCards.length > 0) // #J If this happens, none of the available cards will give the lead, pick the one that will get us the closest to it
						{
							bestCard = sortedCards[sortedCards.length - 1];
							
							if (bestCard)
							{
								return bestCard.getOptimalTransaction();
							}
						}
					}
					break;
				case TACTIC_MINIMAL_WIN:
					{
						sortedCards = getCardsBasedOnCriteria(SortType_PowerChange);
						
						for (list_it = 0; list_it < sortedCards.length; ++list_it)
						{
							currentCard = sortedCards[list_it];
							
							if (currentCard.getOptimalTransaction().powerChangeResult > Math.abs(scoreDifference))
							{
								bestCard = currentCard;
								break;
							}
						}
						
						if (!bestCard && sortedCards.length > 0)
						{
							bestCard = sortedCards[sortedCards.length - 1];
						}
						
						if (bestCard)
						{
							return bestCard.getOptimalTransaction();
						}
					}
					break;
				case TACTIC_JUST_WAIT:
					{
						sortedCards = getCardsBasedOnCriteria(SortType_StrategicValue);
						
						if (sortedCards.length == 0)
						{
							return null;
						}
						
						for (list_it = 0; list_it < sortedCards.length; ++list_it)
						{
							currentTransaction = sortedCards[list_it].getOptimalTransaction();
							if (currentTransaction)
							{
								if (_currentRoundCritical)
								{
									if (currentTransaction && currentTransaction.sourceCardInstanceRef.templateRef.isType(CardTemplate.CardType_Weather) &&
										(currentTransaction.powerChangeResult < 0 || currentTransaction.powerChangeResult < currentTransaction.sourceCardInstanceRef.potentialWeatherHarm()))
									{
										currentTransaction = null;
										continue;
									}
									else
									{
										break;
									}
								}
								else
								{
									break;
								}
							}
						}
						
						return currentTransaction;
					}
					break;
				case TACTIC_WAIT_DUMMY:
					{
						currentCard = cardManagerRef.getFirstCardInHandWithEffect(CardTemplate.CardEffect_UnsummonDummy, playerID);
						
						if (currentCard != null)
						{
							currentTransaction = currentCard.getOptimalTransaction();
							
							if (currentTransaction.targetCardInstanceRef == null)
							{
								currentTransaction.targetCardInstanceRef = cardManagerRef.getHigherOrLowerValueTargetCardOnBoard(currentCard, playerID, false);
							}
							
							if (currentTransaction.targetCardInstanceRef != null)
							{
								return currentTransaction;
							}
						}
						
						trace("GFX [ WARNING ] -#AI#---- Uh oh, was in TACTIC_WAIT_DUMMY but was unable to get a valid dummy transaction :S");
					}
					break;
				case TACTIC_SPY:
					{
						currentCard = cardManagerRef.getFirstCardInHandWithEffect(CardTemplate.CardEffect_Draw2, playerID);
				
						if (currentCard != null)
						{
							return currentCard.getOptimalTransaction();
						}
					}
					break;
			}
			
			if (attitude != TACTIC_PASS && attitude != TACTIC_MINIMIZE_WIN)
			{
				currentCard = cardManagerRef.getFirstCardInHandWithEffect(CardTemplate.CardEffect_Draw2, playerID);
				
				if (currentCard != null)
				{
					return currentCard.getOptimalTransaction();
				}
			}
			
			return null;
		}
		
		protected function getCardsBasedOnCriteria(criteriaType:int) : Vector.<CardInstance>
		{
			var sortedInstanceList:Vector.<CardInstance> = new Vector.<CardInstance>();
			var handInstanceList:Vector.<CardInstance> = CardManager.getInstance().getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, playerID);
			var i:int;
			var currentInstance:CardInstance;
			var cardManagerRef:CardManager = CardManager.getInstance();
			
			var leaderCard:CardLeaderInstance = cardManagerRef.getCardLeader(playerID);
			if (leaderCard && leaderCard.canBeUsed)
			{
				leaderCard.recalculatePowerPotential(cardManagerRef);
				
				if (leaderCard.getOptimalTransaction().strategicValue != -1)
				{
					sortedInstanceList.push(leaderCard);
				}
			}
			
			for (i = 0; i < handInstanceList.length; ++i)
			{
				currentInstance = handInstanceList[i];
				
				switch (criteriaType)
				{
					case SortType_None:
						sortedInstanceList.push(currentInstance);
						break;
					case SortType_PowerChange:
						if (currentInstance.getOptimalTransaction().powerChangeResult >= 0)
						{
							sortedInstanceList.push(currentInstance);
						}
						break;
					case SortType_StrategicValue:
						if (currentInstance.getOptimalTransaction().strategicValue >= 0)
						{
							sortedInstanceList.push(currentInstance);
						}
						break;
						
				}
			}
			
			switch (criteriaType)
			{
				case SortType_StrategicValue:
					sortedInstanceList.sort(strategicValueSorter);
					break;
				case SortType_PowerChange:
					sortedInstanceList.sort(powerChangeSorter);
					break;
			}
			
			return sortedInstanceList;
		}
		
		protected function strategicValueSorter(element1:CardInstance, element2:CardInstance):Number
		{
			return element1.getOptimalTransaction().strategicValue - element2.getOptimalTransaction().strategicValue;
		}
		
		protected function powerChangeSorter(element1:CardInstance, element2:CardInstance):Number
		{
			if (element1.getOptimalTransaction().powerChangeResult == element2.getOptimalTransaction().powerChangeResult)
			{
				return element1.getOptimalTransaction().strategicValue - element2.getOptimalTransaction().strategicValue;
			}
			
			return element1.getOptimalTransaction().powerChangeResult - element2.getOptimalTransaction().powerChangeResult;
		}
		
		protected function getHighestValueCardOnBoard():CardInstance
		{
			var elligibleCardList:Vector.<CardInstance> = new Vector.<CardInstance>();
			var cardManagerRef:CardManager = CardManager.getInstance();
				
			cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_MELEE, playerID, elligibleCardList);
			cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_RANGED, playerID, elligibleCardList);
			cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_SEIGE, playerID, elligibleCardList);
			
			var i:int;
			var currentInstance:CardInstance;
			var currentlyFoundCard:CardInstance = null;
			
			for (i = 0; i < elligibleCardList.length; ++i)
			{
				currentInstance = elligibleCardList[i];
				
				if (currentlyFoundCard == null || (currentInstance.templateRef.power + currentInstance.templateRef.GetBonusValue()) > (currentlyFoundCard.templateRef.power + currentlyFoundCard.templateRef.GetBonusValue()))
				{
					currentlyFoundCard = currentInstance;
				}
			}
			
			return currentlyFoundCard;
		}
		
		protected function getHighestValueCardOnBoardWithEffectLessThan(lessThan:int):CardInstance
		{
			// TODO: Due to the abilities not being done yet, we just ignore cards with improve neighbours or improve morale
			var elligibleCardList:Vector.<CardInstance> = new Vector.<CardInstance>();
			var cardManagerRef:CardManager = CardManager.getInstance();
			
			cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_MELEE, playerID, elligibleCardList);
			cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_RANGED, playerID, elligibleCardList);
			cardManagerRef.getAllCreaturesNonHero(CardManager.CARD_LIST_LOC_SEIGE, playerID, elligibleCardList);
			
			var i:int;
			var currentInstance:CardInstance;
			var currentlyFoundCard:CardInstance = null;
			
			for (i = 0; i < elligibleCardList.length; ++i)
			{
				currentInstance = elligibleCardList[i];
				
				if (!currentInstance.templateRef.hasEffect(CardTemplate.CardEffect_SameTypeMorale) && !currentInstance.templateRef.hasEffect(CardTemplate.CardEffect_ImproveNeighbours) && currentInstance.getTotalPower() < lessThan &&
					(currentlyFoundCard == null || ((currentlyFoundCard.templateRef.power + currentlyFoundCard.templateRef.GetBonusValue()) < (currentInstance.templateRef.power + currentInstance.templateRef.GetBonusValue()))))
				{
					currentlyFoundCard = currentInstance;
				}
			}
			
			return currentlyFoundCard;
		}
	}
}
