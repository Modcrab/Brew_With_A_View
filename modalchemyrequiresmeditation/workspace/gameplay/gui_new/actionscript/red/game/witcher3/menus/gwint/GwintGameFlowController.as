package red.game.witcher3.menus.gwint
{
	import adobe.utils.CustomActions;
	import flash.events.Event;
	import red.core.constants.KeyCode;
	import red.game.witcher3.constants.GwintInputFeedback;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3ChoiceDialog;
	import red.game.witcher3.controls.W3MessageQueue;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.utils.FiniteStateMachine;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * ...
	 * @author Jason Slama sept 2014
	 */
		
	public class GwintGameFlowController extends UIComponent
	{
		public var currentPlayer:int = CardManager.PLAYER_INVALID;
		
		public var closeMenuFunctor:Function;
		public var mcMessageQueue:W3MessageQueue;
		public var mcTutorials:GwintTutorial;
		public var mcChoiceDialog:W3ChoiceDialog;
		public var mcEndGameDialog:GwintEndGameDialog;
		private var cardManager:CardManager;
		private var currentRound:int;
		protected var allNeutralInRound:Boolean = true;
		protected var playedCreaturesInRound:Boolean = false;
		
		protected var lastRoundWinner:int = CardManager.PLAYER_INVALID;
		protected var playedThreeHeroesOneRound:Boolean = false;
		
		public var playerControllers:Vector.<BasePlayerController>;
		
		public var gameStarted:Boolean = false;
		
		protected static var _instance:GwintGameFlowController;
		public static function getInstance():GwintGameFlowController
		{
			return _instance;
		}
		
		protected var sawRoundEndTutorial:Boolean = false;
		
		public var stateMachine:FiniteStateMachine;
		function GwintGameFlowController()
		{
			super();
			_instance = this;
			
			stateMachine = new FiniteStateMachine();
			
			stateMachine.AddState("Initializing", 			null, 								state_update_Initializing, 			state_leave_Initializing);
			stateMachine.AddState("Tutorials", 				state_begin_Tutorials,				state_update_Tutorials,			null);
			stateMachine.AddState("SpawnLeaders", 			state_begin_SpawnLeaders,			state_update_SpawnLeaders,			null);
			stateMachine.AddState("CoinToss", 				state_begin_CoinToss, 				state_update_CoinToss, 				null);
			stateMachine.AddState("Mulligan", 				state_begin_Mulligan, 				state_update_Mulligan, 				null);
			stateMachine.AddState("RoundStart",             state_begin_RoundStart,             state_update_RoundStart,            null);
			stateMachine.AddState("PlayerTurn", 			state_begin_PlayerTurn, 			state_update_PlayerTurn, 			state_leave_PlayerTurn);
			stateMachine.AddState("ChangingPlayer", 		state_begin_ChangingPlayer,			state_update_ChangingPlayer, 		null);
			stateMachine.AddState("ShowingRoundResult", 	state_begin_ShowingRoundResult, 	state_update_ShowingRoundResult, 	null);
			stateMachine.AddState("ClearingBoard",			state_begin_ClearingBoard,			state_update_ClearingBoard,			state_leave_ClearingBoard);
			stateMachine.AddState("ShowingFinalResult", 	state_begin_ShowingFinalResult, 	state_update_ShowingFinalResult,	null);
			stateMachine.AddState("Reset",                  state_begin_reset,					null,								null);
			
			var newController:BasePlayerController;
			playerControllers = new Vector.<BasePlayerController>();
			newController = new HumanPlayerController();
			newController.gameFlowControllerRef = this;
			newController.playerID = CardManager.PLAYER_1;
			newController.opponentID = CardManager.PLAYER_2;
			(newController as HumanPlayerController).skipButton = _skipButton;
			playerControllers.push(newController);
			
			newController = new AIPlayerController();
			newController.gameFlowControllerRef = this;
			newController.playerID = CardManager.PLAYER_2;
			newController.opponentID = CardManager.PLAYER_1;
			playerControllers.push(newController);
			
			currentRound = 0;
		}
		
		protected function shouldDisallowStateChangeFunc():Boolean
		{
			if (mcTutorials && mcTutorials.visible && !mcTutorials.isPaused)
			{
				return true;
			}
			
			return mcMessageQueue.ShowingMessage() || CardFXManager.getInstance().isPlayingAnyCardFX() || mcChoiceDialog.isShown() || CardTweenManager.getInstance().isAnyCardMoving();
		}
		
		public function turnOnAI(playerIndex:int):void
		{
			var newController:BasePlayerController;
			newController = new AIPlayerController();
			newController.gameFlowControllerRef = this;
			newController.playerID = CardManager.PLAYER_1;
			newController.opponentID = CardManager.PLAYER_2;
			playerControllers[CardManager.PLAYER_1] = newController;
		}
		
		public function turnOffAI(playerIndex:int):void
		{
			var newController:BasePlayerController;
			newController = new HumanPlayerController();
			newController.gameFlowControllerRef = this;
			newController.playerID = CardManager.PLAYER_1;
			newController.opponentID = CardManager.PLAYER_2;
			(newController as HumanPlayerController).setChoiceDialog(mcChoiceDialog);
			playerControllers[CardManager.PLAYER_1] = newController;
		}
		
		protected var _skipButton:InputFeedbackButton;
		public function get skipButton():InputFeedbackButton { return _skipButton }
		public function set skipButton(value:InputFeedbackButton):void
		{
			_skipButton = value;
			var curHumanController:HumanPlayerController = playerControllers[CardManager.PLAYER_1] as HumanPlayerController;
			
			if (curHumanController)
			{
				curHumanController.skipButton = _skipButton;
			}
		}
		
		/*---------------------------------------
		 *  Initializing State
		 *---------------------------------------*/
		protected function state_update_Initializing():void
		{
			if (CardManager.getInstance() && CardManager.getInstance().cardTemplatesReceived && CardFXManager.getInstance() != null)
			{
				stateMachine.ChangeState("Tutorials");
			}
		}
		
		protected function state_leave_Initializing():void
		{
			cardManager = CardManager.getInstance(); //#J At this point is had to be created so we cache it to save overhead later on
			
			if (!cardManager)
			{
				throw new Error("GFX --- Tried to link reference to card manager after initializing, was unable to!");
			}
			
			if (playerControllers[CardManager.PLAYER_1] is HumanPlayerController)
			{
				(playerControllers[CardManager.PLAYER_1] as HumanPlayerController).setChoiceDialog(mcChoiceDialog);
			}
			
			playerControllers[CardManager.PLAYER_1].boardRenderer = cardManager.boardRenderer;
			playerControllers[CardManager.PLAYER_2].boardRenderer = cardManager.boardRenderer;
			
			playerControllers[CardManager.PLAYER_1].playerRenderer = cardManager.playerRenderers[CardManager.PLAYER_1];
			playerControllers[CardManager.PLAYER_2].playerRenderer = cardManager.playerRenderers[CardManager.PLAYER_2];
			
			stateMachine.pauseOnStateChangeIfFunc = shouldDisallowStateChangeFunc;
			
			if (_skipButton != null)
			{
				var curHumanController:HumanPlayerController = playerControllers[CardManager.PLAYER_1] as HumanPlayerController;
				
				if (curHumanController)
				{
					curHumanController.skipButton = _skipButton;
				}
			}
		}
		/*---------------------------------------*/
		
		/*---------------------------------------
		 *  Tutorials State
		 *---------------------------------------*/
		
		protected function state_begin_Tutorials():void
		{
		}
		 
		protected function state_update_Tutorials():void
		{
			if (!mcTutorials.visible || mcTutorials.isPaused)
			{
				stateMachine.ChangeState("SpawnLeaders");
				InputFeedbackManager.cleanupButtons();
				InputFeedbackManager.appendButtonById(GwintInputFeedback.navigate, NavigationCode.GAMEPAD_L3, -1, "panel_button_common_navigation");
				InputFeedbackManager.appendButtonById(GwintInputFeedback.quitGame, NavigationCode.START, KeyCode.Q, "gwint_pass_game");
			}
		}
		
		/*---------------------------------------*/
		
		/*---------------------------------------
		 *  SpawnLeaders State
		 *---------------------------------------*/
		
		protected function state_begin_SpawnLeaders():void
		{
			trace("GFX ##########################################################");
			trace("GFX -#AI#-----------------------------------------------------------------------------------------------------");
			trace("GFX -#AI#----------------------------- NEW GWINT GAME ------------------------------------");
			trace("GFX -#AI#-----------------------------------------------------------------------------------------------------");
			
			cardManager.spawnLeaders();
			gameStarted = false;
			playedThreeHeroesOneRound = false;
			
			var player1Leader:CardLeaderInstance = cardManager.getCardLeader(CardManager.PLAYER_1);
			var player2Leader:CardLeaderInstance = cardManager.getCardLeader(CardManager.PLAYER_2);
			var disableLeaderAbilities:Boolean = false;
			
			if (playerControllers[CardManager.PLAYER_1] is HumanPlayerController)
			{
				(playerControllers[CardManager.PLAYER_1] as HumanPlayerController).attachToTutorialCarouselMessage();
			}
			
			playerControllers[CardManager.PLAYER_1].cardZoomEnabled = false;
			playerControllers[CardManager.PLAYER_2].cardZoomEnabled = false;
			
			playerControllers[CardManager.PLAYER_1].inputEnabled = true;
			playerControllers[CardManager.PLAYER_2].inputEnabled = true;
			
			if (player1Leader != null && player2Leader != null && player1Leader.templateId != player2Leader.templateId)
			{
				if (player1Leader.templateRef.getFirstEffect() == CardTemplate.CardEffect_Counter_King || player2Leader.templateRef.getFirstEffect() == CardTemplate.CardEffect_Counter_King)
				{
					disableLeaderAbilities = true;
					if (player1Leader.templateRef.getFirstEffect() != player2Leader.templateRef.getFirstEffect())
					{
						if (player1Leader.templateRef.getFirstEffect() == CardTemplate.CardEffect_Counter_King)
						{
							mcMessageQueue.PushMessage("[[gwint_player_counter_leader]]");
							GwintGameMenu.mSingleton.playSound("gui_gwint_using_ability");
						}
						else
						{
							mcMessageQueue.PushMessage("[[gwint_opponent_counter_leader]]");
							GwintGameMenu.mSingleton.playSound("gui_gwint_using_ability");
						}
					}
					
					player1Leader.canBeUsed = false;
					player2Leader.canBeUsed = false;
					
					if (cardManager.boardRenderer)
					{
						cardManager.boardRenderer.getCardHolder(CardManager.CARD_LIST_LOC_LEADER, CardManager.PLAYER_1).updateLeaderStatus(false);
						cardManager.boardRenderer.getCardHolder(CardManager.CARD_LIST_LOC_LEADER, CardManager.PLAYER_2).updateLeaderStatus(false);
					}
				}
			}
			
			if (disableLeaderAbilities)
			{
				cardManager.cardEffectManager.doubleSpyEnabled = false;
				cardManager.cardEffectManager.randomResEnabled = false;
			}
			else
			{
				cardManager.cardEffectManager.doubleSpyEnabled = player1Leader.templateRef.getFirstEffect() == CardTemplate.CardEffect_DoubleSpy || player2Leader.templateRef.getFirstEffect() == CardTemplate.CardEffect_DoubleSpy;
				cardManager.cardEffectManager.randomResEnabled = player1Leader.templateRef.getFirstEffect() == CardTemplate.CardEffect_RandomRessurect || player2Leader.templateRef.getFirstEffect() == CardTemplate.CardEffect_RandomRessurect;
			}
			
			playerControllers[CardManager.PLAYER_1].currentRoundStatus = BasePlayerController.ROUND_PLAYER_STATUS_ACTIVE;
			playerControllers[CardManager.PLAYER_2].currentRoundStatus = BasePlayerController.ROUND_PLAYER_STATUS_ACTIVE;
		}
		
		protected function state_update_SpawnLeaders():void
		{
			stateMachine.ChangeState("CoinToss");
		}
		 
		/*---------------------------------------*/
		
		/*---------------------------------------
		 *  Coin Toss State
		 *---------------------------------------*/
		public static const COIN_TOSS_POPUP_NEEDED:String = "Gameflow.event.Cointoss.needed";
		
		protected function state_begin_CoinToss():void
		{
			var player1Faction:int = cardManager.playerDeckDefinitions[CardManager.PLAYER_1].getDeckFaction();
			var player2Faction:int = cardManager.playerDeckDefinitions[CardManager.PLAYER_2].getDeckFaction();
			
			trace("GFX - Coing flip logic, player1faction:", player1Faction, ", player2Faction:", player2Faction);
			
			if (player1Faction != player2Faction && !mcTutorials.visible && (player1Faction == CardTemplate.FactionId_Scoiatael || player2Faction == CardTemplate.FactionId_Scoiatael))
			{
				GwintGameMenu.mSingleton.playSound("gui_gwint_scoia_tael_ability");
				
				if (player1Faction == CardTemplate.FactionId_Scoiatael)
				{
					currentPlayer = CardManager.PLAYER_INVALID;
					dispatchEvent(new Event(COIN_TOSS_POPUP_NEEDED, false, false));
				}
				else
				{
					currentPlayer = CardManager.PLAYER_2;
					mcMessageQueue.PushMessage("[[gwint_opponent_scoiatael_start_special]]", "sco_ability");
					//mcMessageQueue.PushMessage("[[gwint_opponent_will_go_first]]");
				}
			}
			else
			{
				if (mcTutorials.visible)
				{
					currentPlayer = CardManager.PLAYER_1;
				}
				else
				{
					currentPlayer = Math.floor(Math.random() * 2);
				}
				
				//#M Coin flip animation and text who starts - less screens to show to player
				if (currentPlayer == CardManager.PLAYER_1)
				{
					mcMessageQueue.PushMessage("[[gwint_player_will_go_first_message]]", "coin_flip_win");
				}
				else if (currentPlayer == CardManager.PLAYER_2)
				{
					mcMessageQueue.PushMessage("[[gwint_opponent_will_go_first]]", "coin_flip_loss");
				}
				GwintGameMenu.mSingleton.playSound("gui_gwint_coin_toss");
				/*
				//#J Add coin flip animation/dialog/w.e here, for now just go straight to random
				mcMessageQueue.PushMessage("[[gwint_flipping_coin]]", (currentPlayer == CardManager.PLAYER_1 ? "coin_flip_win" : "coin_flip_loss"));
				GwintGameMenu.mSingleton.playSound("gui_gwint_coin_toss");
				
				if (currentPlayer == CardManager.PLAYER_1)
				{
					mcMessageQueue.PushMessage("[[gwint_player_will_go_first_message]]");
				}
				else if (currentPlayer == CardManager.PLAYER_2)
				{
					mcMessageQueue.PushMessage("[[gwint_opponent_will_go_first]]");
				}
				*/
			}
		}
		
		protected function state_update_CoinToss():void
		{
			if (currentPlayer != CardManager.PLAYER_INVALID)
			{
				stateMachine.ChangeState("Mulligan");
			}
		}
		/*---------------------------------------*/
		
		/*---------------------------------------
		 * Mulligan State
		 *---------------------------------------*/
		protected var _mulliganCardsCount:int = 0;
		protected var _mulliganDecided:Boolean;
		 
		 
		protected function state_begin_Mulligan():void
		{
			var cardsInHand:Vector.<CardInstance>;
			
			_mulliganDecided = false;
			_mulliganCardsCount = 0;
			
			cardManager.shuffleAndDrawCards();
			
			cardsInHand = cardManager.getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, CardManager.PLAYER_1);
			mcChoiceDialog.showDialogCardInstances(cardsInHand, handleAcceptMulligan, handleDeclineMulligan, "[[gwint_can_choose_card_to_redraw]]");
			mcChoiceDialog.appendDialogText(" 0/2");
			
			if (mcTutorials.visible)
			{
				mcTutorials.continueTutorial();
				mcChoiceDialog.inputEnabled = false;
				mcTutorials.hideCarouselCB = handleDeclineMulligan;
				mcTutorials.changeChoiceCB = handleForceCardSelected;
			}
			
			GwintGameMenu.mSingleton.playSound("gui_gwint_draw_2");
		}
		
		protected function state_update_Mulligan():void
		{	
			if (_mulliganDecided && (!mcTutorials.visible || mcTutorials.isPaused))
			{
				stateMachine.ChangeState("RoundStart");
				mcChoiceDialog.hideDialog();
				gameStarted = true;
				
				playerControllers[CardManager.PLAYER_1].cardZoomEnabled = true;
				playerControllers[CardManager.PLAYER_2].cardZoomEnabled = true;
				
				GwintGameMenu.mSingleton.playSound("gui_gwint_game_start");
			}
		}
		
		protected function handleAcceptMulligan(instanceId:int):void
		{
			var selectedCard:CardInstance = cardManager.getCardInstance(instanceId);
			if (selectedCard)
			{
				var newCard:CardInstance =  cardManager.mulliganCard(selectedCard);
				mcChoiceDialog.replaceCard(selectedCard, newCard);
				_mulliganCardsCount++;
				
				GwintGameMenu.mSingleton.playSound("gui_gwint_card_redrawn");
				
				if (_mulliganCardsCount < 2)
				{
					mcChoiceDialog.updateDialogText("[[gwint_can_choose_card_to_redraw]]");
					mcChoiceDialog.appendDialogText(" 1/2");
				}
				
				_mulliganDecided = _mulliganCardsCount >= 2;
			}
		}
		
		protected function handleDeclineMulligan():void
		{
			mcChoiceDialog.hideDialog();
			_mulliganDecided = true;
			
			if (playerControllers[CardManager.PLAYER_1] is HumanPlayerController)
			{
				(playerControllers[CardManager.PLAYER_1] as HumanPlayerController).attachToTutorialCarouselMessage();
			}
		}
		
		protected function handleForceCardSelected(index:int):void
		{
			if (mcChoiceDialog && mcChoiceDialog.visible)
			{
				mcChoiceDialog.cardsCarousel.selectedIndex = index;
			}
		}
		
		/*---------------------------------------*/
		
		/*---------------------------------------
		 * RoundStart State
		 *---------------------------------------*/
		protected function state_begin_RoundStart():void
		{
			mcMessageQueue.PushMessage("[[gwint_round_start]]", "round_start");
			
			allNeutralInRound = true;
			playedCreaturesInRound = false;
			
			// Northern Kingdoms faction ability impl
			if (lastRoundWinner != CardManager.PLAYER_INVALID && cardManager.playerDeckDefinitions[lastRoundWinner].getDeckFaction() == CardTemplate.FactionId_Northern_Kingdom)
			{
				mcMessageQueue.PushMessage("[[gwint_northern_ability_triggered]]", "north_ability", onShowNorthAbilityShown, null);
				GwintGameMenu.mSingleton.playSound("gui_gwint_northern_realms_ability");
			}
			
			if (currentRound == 2)
			{
				if (cardManager.playerDeckDefinitions[CardManager.PLAYER_1].getDeckFaction() == CardTemplate.FactionId_Skellige)
				{
					mcMessageQueue.PushMessage("[[gwint_skel_ability_player_triggered]]", "skel_ability", OnPlayerSkelAbilityShown, null);
					GwintGameMenu.mSingleton.playSound("gui_gwint_skellige_ability");
				}
				
				if (cardManager.playerDeckDefinitions[CardManager.PLAYER_2].getDeckFaction() == CardTemplate.FactionId_Skellige)
				{
					mcMessageQueue.PushMessage("[[gwint_skel_ability_ai_triggered]]", "skel_ability", OnAISkelAbilityShown, null);
					GwintGameMenu.mSingleton.playSound("gui_gwint_skellige_ability");
				}
			}
		}
		
		protected function state_update_RoundStart():void
		{	
			if (!mcMessageQueue.ShowingMessage())
			{
				if (mcTutorials.visible && !sawRoundStartTutorial)
				{
					sawRoundStartTutorial = true;
					mcTutorials.continueTutorial();
				}
				
				if (shouldDisallowStateChangeFunc() == false)
				{
					playerControllers[CardManager.PLAYER_1].resetCurrentRoundStatus();
					playerControllers[CardManager.PLAYER_2].resetCurrentRoundStatus();
					
					if (playerControllers[currentPlayer].currentRoundStatus == BasePlayerController.ROUND_PLAYER_STATUS_DONE) //#J If winning player has no cards, he auto loses
					{
						currentPlayer = currentPlayer == CardManager.PLAYER_1 ? CardManager.PLAYER_2 : CardManager.PLAYER_1;
						
						if (playerControllers[currentPlayer].currentRoundStatus == BasePlayerController.ROUND_PLAYER_STATUS_DONE) // #J If other player also is auto passing, then... round is auto draw
						{
							stateMachine.ChangeState("ShowingRoundResult");
						}
						else
						{
							stateMachine.ChangeState("PlayerTurn");
						}
					}
					else
					{
						stateMachine.ChangeState("PlayerTurn");
					}
					
				}
			}
		}
		
		protected var sawRoundStartTutorial:Boolean = false;
		
		protected function onShowNorthAbilityShown():void
		{
			cardManager.drawCard(lastRoundWinner);
		}
		
		protected function OnPlayerSkelAbilityShown():void
		{
			// Ryan if the player was STATUS_DONE and one of the resurected card is CardTemplate.CardType_Spy
			// switch status back to STATUS_ACTIVE
			cardManager.ressurectFromGraveyard(CardManager.PLAYER_1, 2);
		}
		
		protected function OnAISkelAbilityShown():void
		{
			cardManager.ressurectFromGraveyard(CardManager.PLAYER_2, 2);
		}
		/*---------------------------------------*/
		
		/*---------------------------------------
		 *  PlayerTurn State
		 *---------------------------------------*/
		private var sawStartMessage:Boolean;
		protected function state_begin_PlayerTurn():void
		{
			trace("GFX -#AI# starting player turn for player: " + currentPlayer);
			
			if (currentPlayer == CardManager.PLAYER_1)
			{
				mcMessageQueue.PushMessage("[[gwint_player_turn_start_message]]", "your_turn");
				GwintGameMenu.mSingleton.playSound("gui_gwint_your_turn");
			}
			else if (currentPlayer == CardManager.PLAYER_2)
			{
				mcMessageQueue.PushMessage("[[gwint_opponent_turn_start_message]]", "Opponents_turn");
				GwintGameMenu.mSingleton.playSound("gui_gwint_opponents_turn");
			}
			sawStartMessage = false;
			playerControllers[currentPlayer].playerRenderer.turnActive = true;
		}
		
		protected function state_update_PlayerTurn():void
		{
			var currentPlayerController:BasePlayerController = playerControllers[currentPlayer];
			var otherPlayerController:BasePlayerController = playerControllers[currentPlayer == CardManager.PLAYER_1 ? CardManager.PLAYER_2 : CardManager.PLAYER_1];
			
			if (!currentPlayerController)
			{
				throw new Error("GFX ---- currentPlayerController not found for player: " + currentPlayer.toString());
			}
			
			if (mcMessageQueue.ShowingMessage())
			{
				return;
			}
			else if (!sawStartMessage)
			{
				sawStartMessage = true;
				currentPlayerController.startTurn();
			}
			
			if (currentPlayerController.turnOver)
			{
				if (mcTutorials.visible && !sawScoreChangeTutorial)
				{
					if (cardManager.currentPlayerScores[CardManager.PLAYER_1] != 0 ||
						cardManager.currentPlayerScores[CardManager.PLAYER_2] != 0)
					{
						sawScoreChangeTutorial = true;
						mcTutorials.continueTutorial();
					}
				}
				
				if (mcTutorials.visible && !mcTutorials.isPaused)
				{
					return;
				}
				
				if (currentPlayerController.currentRoundStatus == BasePlayerController.ROUND_PLAYER_STATUS_ACTIVE)
				{
					if (otherPlayerController.currentRoundStatus == BasePlayerController.ROUND_PLAYER_STATUS_DONE)
					{
						currentPlayerController.startTurn();
					}
					else
					{
						stateMachine.ChangeState("ChangingPlayer");
					}
				}
				else
				{
					if (otherPlayerController.currentRoundStatus == BasePlayerController.ROUND_PLAYER_STATUS_ACTIVE)
					{
						stateMachine.ChangeState("ChangingPlayer");
					}
					else
					{
						stateMachine.ChangeState("ShowingRoundResult");
					}
				}
			}
		}
		
		protected function state_leave_PlayerTurn():void
		{
			playerControllers[currentPlayer].playerRenderer.turnActive = false;
			
			if (allNeutralInRound || !playedCreaturesInRound) // Once this condition fails once, no point checking it again
			{			
				var allCreatures:Vector.<CardInstance> = cardManager.getAllCreatures(CardManager.PLAYER_1);
				var currentTemplate:CardTemplate;
				var list_it:int;
				
				for (list_it = 0; list_it < allCreatures.length; ++list_it)
				{
					currentTemplate = allCreatures[list_it].templateRef;
					
					if (!currentTemplate.isType(CardTemplate.CardType_Spy))
					{
						playedCreaturesInRound = true;
						
						if (currentTemplate.factionIdx != CardTemplate.FactionId_Neutral)
						{
							allNeutralInRound = false;
						}
					}
				}
				
				allCreatures = cardManager.getAllCreatures(CardManager.PLAYER_2);
				
				for (list_it = 0; list_it < allCreatures.length; ++list_it)
				{
					currentTemplate = allCreatures[list_it].templateRef;
					if (currentTemplate.isType(CardTemplate.CardType_Spy))
					{
						playedCreaturesInRound = true;
						
						if (currentTemplate.factionIdx != CardTemplate.FactionId_Neutral)
						{
							allNeutralInRound = false;
						}
					}
				}
			}
			cardManager.recalculateScores();
		}
		/*---------------------------------------*/
		
		/*---------------------------------------
		 *  ChangingPlayer State
		 *---------------------------------------*/
		
		protected function state_begin_ChangingPlayer():void
		{
			if (playerControllers[currentPlayer].currentRoundStatus == BasePlayerController.ROUND_PLAYER_STATUS_DONE)
			{
				if (currentPlayer == CardManager.PLAYER_1)
				{
					mcMessageQueue.PushMessage("[[gwint_player_passed_turn]]", "passed");
				}
				else
				{
					mcMessageQueue.PushMessage("[[gwint_opponent_passed_turn]]", "passed");
				}
			}
		}
		 
		protected function state_update_ChangingPlayer():void
		{
			if (!mcMessageQueue.ShowingMessage())
			{
				currentPlayer = currentPlayer == CardManager.PLAYER_1 ? CardManager.PLAYER_2 : CardManager.PLAYER_1;
				stateMachine.ChangeState("PlayerTurn");
			}
		}
		
		protected var sawScoreChangeTutorial:Boolean = false;
		
		/*---------------------------------------*/
		
		/*---------------------------------------
		 *  ShowingRoundResult State
		 *---------------------------------------*/
		protected function state_begin_ShowingRoundResult():void
		{
			var player1Score:int = cardManager.currentPlayerScores[CardManager.PLAYER_1];
			var player2Score:int = cardManager.currentPlayerScores[CardManager.PLAYER_2];
			var player1Faction:int = cardManager.playerDeckDefinitions[CardManager.PLAYER_1].getDeckFaction();
			var player2Faction:int = cardManager.playerDeckDefinitions[CardManager.PLAYER_2].getDeckFaction();
			var roundWinner:int = CardManager.PLAYER_INVALID;
			
			playerControllers[CardManager.PLAYER_1].resetCurrentRoundStatus();
			playerControllers[CardManager.PLAYER_2].resetCurrentRoundStatus();
			
			if (mcTutorials.visible && !sawRoundEndTutorial)
			{
				sawRoundEndTutorial = true;
				mcTutorials.continueTutorial();
			}
			
			if (player1Score == player2Score)
			{
				if (player1Faction != player2Faction && 
					(player1Faction == CardTemplate.FactionId_Nilfgaard || player2Faction == CardTemplate.FactionId_Nilfgaard))
				{
					mcMessageQueue.PushMessage("[[gwint_nilfgaard_ability_triggered]]", "nilf_ability");
					GwintGameMenu.mSingleton.playSound("gui_gwint_nilfgaardian_ability");
					
					if (player1Faction == CardTemplate.FactionId_Nilfgaard)
					{
						mcMessageQueue.PushMessage("[[gwint_player_won_round]]", "battle_won");
						roundWinner = CardManager.PLAYER_1;
						lastRoundWinner = CardManager.PLAYER_1;
						GwintGameMenu.mSingleton.playSound("gui_gwint_clash_victory");
					}
					else
					{
						mcMessageQueue.PushMessage("[[gwint_opponent_won_round]]", "battle_lost");
						roundWinner = CardManager.PLAYER_2;
						lastRoundWinner = CardManager.PLAYER_2;
						GwintGameMenu.mSingleton.playSound("gui_gwint_clash_defeat");
					}
				}
				else
				{
					mcMessageQueue.PushMessage("[[gwint_round_draw]]", "battle_draw");
					roundWinner = CardManager.PLAYER_INVALID;
					lastRoundWinner = CardManager.PLAYER_INVALID;
					GwintGameMenu.mSingleton.playSound("gui_gwint_round_draw");
					GwintGameMenu.mSingleton.playSound("gui_gwint_gem_destruction");
				}
			}
			else if (player1Score > player2Score)
			{
				mcMessageQueue.PushMessage("[[gwint_player_won_round]]", "battle_won");
				roundWinner = CardManager.PLAYER_1;
				lastRoundWinner = CardManager.PLAYER_1;
				GwintGameMenu.mSingleton.playSound("gui_gwint_clash_victory");
			}
			else
			{
				mcMessageQueue.PushMessage("[[gwint_opponent_won_round]]", "battle_lost");
				roundWinner = CardManager.PLAYER_2;
				lastRoundWinner = CardManager.PLAYER_2;
				GwintGameMenu.mSingleton.playSound("gui_gwint_clash_defeat");
			}
			
			if (roundWinner != CardManager.PLAYER_INVALID)
			{
				GwintGameMenu.mSingleton.playSound("gui_gwint_gem_destruction");
			}
			
			cardManager.roundResults[currentRound].setResults(player1Score, player2Score, roundWinner);
			
			cardManager.traceRoundResults();
			
			cardManager.updatePlayerLives();
			
			// Achievement stuff
			
			var list_it:int;
			var numHeroes:int = 0;
			var allCreatures:Vector.<CardInstance> = cardManager.getAllCreatures(CardManager.PLAYER_1);
			
			for (list_it = 0; list_it < allCreatures.length; ++list_it)
			{
				if (allCreatures[list_it].templateRef.isType(CardTemplate.CardType_Hero))
				{
					++numHeroes;
				}
			}
			
			if (numHeroes >= 3)
			{
				playedThreeHeroesOneRound = true;
			}
				
			if (allNeutralInRound && playedCreaturesInRound && roundWinner == CardManager.PLAYER_1)
			{
				GwintGameMenu.mSingleton.sendNeutralRoundVictoryAchievement();
			}
			
			if (player1Score >= 187 && roundWinner == CardManager.PLAYER_1)
			{
				GwintGameMenu.mSingleton.sendKilledItAchievement();
			}
		}
		
		public function isGameOver():Boolean
		{
			return (currentRound == 2 || 
					(currentRound == 1 && 
					  (cardManager.roundResults[0].winningPlayer == cardManager.roundResults[1].winningPlayer ||
					   cardManager.roundResults[0].winningPlayer == CardManager.PLAYER_INVALID ||
					   cardManager.roundResults[1].winningPlayer == CardManager.PLAYER_INVALID)));
		}
		
		protected function state_update_ShowingRoundResult():void
		{
			if (!mcMessageQueue.ShowingMessage())
			{
				if (isGameOver())
				{
					cardManager.clearBoard(false);
					stateMachine.ChangeState("ShowingFinalResult");
				}
				else
				{
					if (lastRoundWinner != CardManager.PLAYER_INVALID)
					{
						currentPlayer = lastRoundWinner;
					}
					
					
					stateMachine.ChangeState("ClearingBoard");
				}
			}
		}
		/*---------------------------------------*/
		
		/*---------------------------------------
		 *  ClearingBoard State
		 *---------------------------------------*/
		
		protected function state_begin_ClearingBoard():void
		{
			var monsterAbilityTriggered:Boolean = false;
			//chooseCreatureToExclude
			if (cardManager.playerDeckDefinitions[CardManager.PLAYER_1].getDeckFaction() == CardTemplate.FactionId_No_Mans_Land && cardManager.chooseCreatureToExclude(CardManager.PLAYER_1) != null)
			{
				monsterAbilityTriggered = true;
			}
			else if (!monsterAbilityTriggered && cardManager.playerDeckDefinitions[CardManager.PLAYER_2].getDeckFaction() == CardTemplate.FactionId_No_Mans_Land && cardManager.chooseCreatureToExclude(CardManager.PLAYER_2) != null)
			{
				monsterAbilityTriggered = true;
			}
			
			if (monsterAbilityTriggered)
			{
				mcMessageQueue.PushMessage("[[gwint_monster_faction_ability_triggered]]", "monster_ability");
				GwintGameMenu.mSingleton.playSound("gui_gwint_monster_ability");
			}
			
			cardManager.clearBoard(true);
		}
		
		protected function state_update_ClearingBoard():void
		{
			if (!mcMessageQueue.ShowingMessage())
			{
				cardManager.recalculateScores();
				++currentRound;
				stateMachine.ChangeState("RoundStart");
			}
		}
		
		protected function state_leave_ClearingBoard():void
		{
			cardManager.recalculateScores();
		}
		
		 /*---------------------------------------*/
		
		/*---------------------------------------
		 *  ShowingFinalResult State
		 *---------------------------------------*/
		protected function state_begin_ShowingFinalResult():void
		{
			var gameWinner:int = CardManager.PLAYER_INVALID;
			var round1Winner:int = cardManager.roundResults[0].winningPlayer;
			var round2Winner:int = cardManager.roundResults[1].winningPlayer;
			
			// Theoretically should never come to this but added it in as a fallback
			if (currentRound == 1 && round1Winner != round2Winner && !cardManager.roundResults[2].played)
			{
				var player1Faction:int = cardManager.playerDeckDefinitions[CardManager.PLAYER_1].getDeckFaction();
				var player2Faction:int = cardManager.playerDeckDefinitions[CardManager.PLAYER_2].getDeckFaction();
				
				if (player1Faction != player2Faction)
				{
					if (player1Faction == CardTemplate.FactionId_Nilfgaard)
					{
						cardManager.roundResults[2].setResults(0, 0, CardManager.PLAYER_1);
					}
					else if (player2Faction == CardTemplate.FactionId_Nilfgaard)
					{
						cardManager.roundResults[2].setResults(0, 0, CardManager.PLAYER_2);
					}
				}
			}
			
			if (mcTutorials.visible && !sawEndGameTutorial)
			{
				sawEndGameTutorial = true;
				mcTutorials.continueTutorial();
			}
			
			var round3Winner:int = cardManager.roundResults[2].winningPlayer;
			
			// Disable and remove the zoom if we reach here
			// {
			playerControllers[CardManager.PLAYER_1].cardZoomEnabled = false;
			playerControllers[CardManager.PLAYER_2].cardZoomEnabled = false;
			
			playerControllers[CardManager.PLAYER_1].inputEnabled = false;
			playerControllers[CardManager.PLAYER_2].inputEnabled = false;
			
			mcChoiceDialog.hideDialog();
			// }
			
			if (currentRound == 1 && (round1Winner == round2Winner || round1Winner == CardManager.PLAYER_INVALID || round2Winner == CardManager.PLAYER_INVALID))
			{
				if (round1Winner == CardManager.PLAYER_INVALID)
				{
					gameWinner = round2Winner;
				}
				else
				{
					gameWinner = round1Winner;
				}
			}
			else if (currentRound == 2)
			{
				if (round1Winner == round2Winner || round1Winner == round3Winner)
				{
					gameWinner = round1Winner
				}
				else if (round2Winner == round3Winner)
				{
					gameWinner = round2Winner;
				}
			}
			else
			{
				throw new Error("GFX - Danger will robinson, danger!");
			}
			
			cardManager.traceRoundResults();
			
			trace("GFX -#AI#--- game winner was: " + gameWinner);
			trace("GFX -#AI#--- current round was: " + currentRound);
			trace("GFX -#AI#--- Round 1 winner: " + round1Winner);
			trace("GFX -#AI#--- Round 2 winner: " + round1Winner);
			trace("GFX -#AI#--- Round 3 winner: " + round1Winner);
			
			if (gameWinner == CardManager.PLAYER_1)
			{
				if (playedThreeHeroesOneRound)
				{
					GwintGameMenu.mSingleton.sendHeroRoundVictoryAchievement();
				}
				GwintGameMenu.mSingleton.playSound("gui_gwint_battle_won");
			}
			else if (gameWinner == CardManager.PLAYER_2)
			{
				GwintGameMenu.mSingleton.playSound("gui_gwint_battle_lost");
			}
			else
			{
				GwintGameMenu.mSingleton.playSound("gui_gwint_battle_draw");
			}
			
			mcEndGameDialog.show(gameWinner, OnEndGameResult);
		}
		
		protected function state_update_ShowingFinalResult():void
		{
		}
		
		protected function OnEndGameResult(result:int):void
		{
			if (result == GwintEndGameDialog.EndGameDialogResult_Restart)
			{
				stateMachine.ChangeState("Reset");
			}
			else
			{
				closeMenuFunctor(result == GwintEndGameDialog.EndGameDialogResult_EndVictory);
			}
		}
		
		protected var sawEndGameTutorial:Boolean = false;
		/*---------------------------------------*/
		
		/*---------------------------------------
		 *  Reset State
		 *---------------------------------------*/
		protected function state_begin_reset():void
		{
			currentRound = 0;
			
			cardManager.reset();
			
			mcMessageQueue.PushMessage("[[gwint_resetting]]"); 
			
			stateMachine.ChangeState("SpawnLeaders");
		}
		
		/*---------------------------------------*/
		
		public function EndGame(result:int):void
		{
			OnEndGameResult(result);
		}
	}
}
