package red.game.witcher3.menus.gwint
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.ConditionalCloseButton;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3ChoiceDialog;
	import red.game.witcher3.controls.W3MessageQueue;
	import red.game.witcher3.events.InputFeedbackEvent;
	import red.game.witcher3.managers.InputFeedbackManager;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	
	/**
	 * ...
	 * @author Jason Slama sept 2014
	 */
	public class GwintGameMenu extends GwintBaseMenu
	{
		private static const SKIP_TURN_HOLD_DELAY:Number = 1000;
		
		public var gameFlowController:GwintGameFlowController;
		public var mcMessageQueue:W3MessageQueue;
		public var mcChoiceDialog:W3ChoiceDialog;
		public var mcCardFXManager:CardFXManager;
		public var mcEndGameDialog:GwintEndGameDialog;
		public var btnSkipTurn:InputFeedbackButton;
		
		public var mcCloseBtn:ConditionalCloseButton;
		
		public var mcTutorials:GwintTutorial;
		public var tutorialsOn:Boolean = false;
		
		public var mcPlayer1Renderer:GwintPlayerRenderer;
		public var mcPlayer2Renderer:GwintPlayerRenderer;
		
		public var mcP1DeckRenderer:GwintDeckRenderer;
		public var mcP2DeckRenderer:GwintDeckRenderer;
		
		public var mcBoardRenderer:GwintBoardRenderer;
		
		function GwintGameMenu()
		{
			super();
			InputFeedbackManager.useOverlayPopup = true;
			InputFeedbackManager.eventDispatcher = this;
			gameFlowController = new GwintGameFlowController();
			GwintGameMenu.mSingleton = this;
			_enableMouse = false;
		}
		
		public static var mSingleton:GwintGameMenu;
		public function playSound(soundID:String)
		{
			dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", [soundID]));
		}
		
		public function sendNeutralRoundVictoryAchievement():void
		{
			dispatchEvent(new GameEvent(GameEvent.CALL, "OnNeutralRoundVictoryAchievement"));
		}
		
		public function sendHeroRoundVictoryAchievement():void
		{
			dispatchEvent(new GameEvent(GameEvent.CALL, "OnHeroRoundVictoryAchievement"));
		}
		
		public function sendKilledItAchievement():void
		{
			dispatchEvent(new GameEvent(GameEvent.CALL, "OnKilledItAchievement"));
		}
		
		public function showTutorial():void
		{
			if (mcTutorials)
			{
				tutorialsOn = true;
				mcTutorials.show();
			}
		}
		
		override protected function configUI():void
		{
			mcTutorials.currentTutorialFrame = 7; // #Y #HACK
			mcTutorials.messageQueue = mcMessageQueue;
			
			super.configUI();
			
			_cardManager.playerRenderers.push(mcPlayer1Renderer);
			_cardManager.playerRenderers.push(mcPlayer2Renderer);
			
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "gwint.game.player.deck", [setPlayerDeck]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "gwint.game.enemy.deck", [setEnemyDeck]));
			
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "gwint.game.cardValues", [setCardValues]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "gwint.game.toggleAI", [setAIEnabled]));
			
			if (mcCloseBtn)
			{
				mcCloseBtn.addEventListener(ButtonEvent.PRESS, handleClosePressed, false, 0, true);
				mcCloseBtn.label = "[[gwint_pass_game]]";
			}
			
			gameFlowController.mcMessageQueue = mcMessageQueue;
			gameFlowController.mcTutorials = mcTutorials;
			gameFlowController.mcChoiceDialog = mcChoiceDialog;
			gameFlowController.mcEndGameDialog = mcEndGameDialog;
			gameFlowController.closeMenuFunctor = onGameFlowDone;
			
			gameFlowController.addEventListener(GwintGameFlowController.COIN_TOSS_POPUP_NEEDED, chooseCoingPopup, false, 0, true);
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
			stage.addEventListener(MouseEvent.CLICK, handleMouseClick, false, 2, true);
			
			btnSkipTurn.label = "[[qwint_skip_turn]]";
			btnSkipTurn.setDataFromStage(NavigationCode.GAMEPAD_Y, KeyCode.SPACE);
			btnSkipTurn.holdDuration = SKIP_TURN_HOLD_DELAY;
			btnSkipTurn.visible = false;
			gameFlowController.skipButton = btnSkipTurn;
			
			mcChoiceDialog.visible = false; // #J WIP component, hiding it permentaly for now
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			
			//#Y We shoud have some exit dialog, for now it just a hack, so don't show inputf for it
			//InputFeedbackManager.appendButton(this, NavigationCode.START, -1, "[[panel_button_common_exit]]");
		}
		
		protected function handleClosePressed( event : ButtonEvent ) : void
		{
			if (mcEndGameDialog && mcEndGameDialog.visible)
			{
				mcEndGameDialog.closeButtonPressed(null);
			}
			else
			{
				tryQuitGame();
			}
		}
		
		/*
		protected var m_CheatCardID:int = 0;
		*/
		override public function handleInput(event:InputEvent):void
		{
			if (mcTutorials && mcTutorials.visible && !mcTutorials.isPaused)
			{
				mcTutorials.handleInput(event);
				return;
			}
			
			if (gameFlowController.gameStarted)
			{
				for (var i = 0; i < gameFlowController.playerControllers.length; ++i)
				{
					var currentController:BasePlayerController = gameFlowController.playerControllers[i];
					if (currentController)
					{
						currentController.handleUserInput(event);
					}
				}
				
				/*
				var details:InputDetails = event.details;
				var keyUp:Boolean = (details.value == InputValue.KEY_UP );
				
				if (keyUp)
				{
					if (details.code == KeyCode.I)
					{
						m_CheatCardID = 0;
						trace("GFX ----------------- reset cheat id to: ", m_CheatCardID);
					}
					else if (details.code == KeyCode.O)
					{
						trace("GFX ----------------- Spawning card for player 1 with id: ", m_CheatCardID);
						_cardManager.spawnCardInstance(m_CheatCardID, CardManager.PLAYER_1);
					}
					else if (details.code == KeyCode.P)
					{
						trace("GFX ----------------- Spawning card for player 2 with id: ", m_CheatCardID);
						_cardManager.spawnCardInstance(m_CheatCardID, CardManager.PLAYER_2);
					}
					else 
					{
						var newNumber:String = "";
						
						if (details.code == KeyCode.NUMBER_0 || details.code == KeyCode.NUMPAD_0)
						{
							newNumber = "0";
						}
						
						if (details.code == KeyCode.NUMBER_1 || details.code == KeyCode.NUMPAD_1)
						{
							newNumber = "1";
						}
						
						if (details.code == KeyCode.NUMBER_2 || details.code == KeyCode.NUMPAD_2)
						{
							newNumber = "2";
						}
						
						if (details.code == KeyCode.NUMBER_3 || details.code == KeyCode.NUMPAD_3)
						{
							newNumber = "3";
						}
						
						if (details.code == KeyCode.NUMBER_4 || details.code == KeyCode.NUMPAD_4)
						{
							newNumber = "4";
						}
						
						if (details.code == KeyCode.NUMBER_5 || details.code == KeyCode.NUMPAD_5)
						{
							newNumber = "5";
						}
						
						if (details.code == KeyCode.NUMBER_6 || details.code == KeyCode.NUMPAD_6)
						{
							newNumber = "6";
						}
						
						if (details.code == KeyCode.NUMBER_7 || details.code == KeyCode.NUMPAD_7)
						{
							newNumber = "7";
						}
						
						if (details.code == KeyCode.NUMBER_8 || details.code == KeyCode.NUMPAD_8)
						{
							newNumber = "8";
						}
						
						if (details.code == KeyCode.NUMBER_9 || details.code == KeyCode.NUMPAD_9)
						{
							newNumber = "9";
						}
						
						if (m_CheatCardID == 0)
						{
							m_CheatCardID = parseInt(newNumber, 10);
						}
						else 
						{
							newNumber = m_CheatCardID.toString() + newNumber;
							m_CheatCardID = parseInt(newNumber, 10);
						}
						
						trace("GFX ----------------- Cheat card ID changed to:", m_CheatCardID);
					}
				}
				*/
			}
		}
		
		override protected function handleMouseMove(event:MouseEvent):void
		{
			super.handleMouseMove(event);
			
			if (mcTutorials && mcTutorials.visible && !mcTutorials.isPaused)
			{
				return;
			}
			
			if (gameFlowController.gameStarted)
			{
				for (var i = 0; i < gameFlowController.playerControllers.length; ++i)
				{
					var currentController:BasePlayerController = gameFlowController.playerControllers[i];
					if (currentController)
					{
						currentController.handleMouseMove(event);
					}
				}
			}
		}
		
		public function handleMouseClick(event:MouseEvent):void
		{
			if (mcTutorials && mcTutorials.visible && !mcTutorials.isPaused)
			{
				return;
			}
			
			if (mcMessageQueue && mcMessageQueue.trySkipMessage())
			{
				return;
			}
			
			if (gameFlowController.gameStarted)
			{
				for (var i = 0; i < gameFlowController.playerControllers.length; ++i)
				{
					var currentController:BasePlayerController = gameFlowController.playerControllers[i];
					if (currentController)
					{
						currentController.handleMouseClick(event);
					}
				}
			}
		}
		
		override protected function handleInputNavigate(event:InputEvent):void
		{
			if (mcTutorials && mcTutorials.visible && !mcTutorials.isPaused)
			{
				return;
			}
			
			var details:InputDetails = event.details;
			var keyUp:Boolean = details.value == InputValue.KEY_UP;
			if (!event.handled && keyUp)
			{
				switch (details.navEquivalent)
				{
					case NavigationCode.START:
						tryQuitGame();
						break;
					case NavigationCode.DPAD_UP:
						testCardsCalculations();
						break;
					case NavigationCode.GAMEPAD_A:
					case NavigationCode.ENTER:
						if (mcMessageQueue && mcMessageQueue.trySkipMessage())
						{
							event.handled = true;
						}
						break;
				}
				
				switch (details.code)
				{
					case KeyCode.Q:
						tryQuitGame();
						break;
				}
			}
		}
		
		public function tryQuitGame():void
		{
			if( gameFlowController.stateMachine.currentState != "ShowingFinalResult" &&
				(!mcTutorials.visible || mcTutorials.isPaused))
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfirmSurrender" ) );
			}
		}
		
		override protected function get menuName():String
		{ 
			return "GwintGame";
		}
		
		protected function onGameFlowDone(hasWon:Boolean):void
		{
			dispatchEvent(new GameEvent(GameEvent.CALL, "OnMatchResult", [hasWon]));
			closeMenu();
		}
		
		public function setPlayerDeck(deckDefinition:Object):void
		{
			var gwintDeck:GwintDeck = deckDefinition as GwintDeck;
			if (gwintDeck)
			{	
				_cardManager.playerDeckDefinitions[CardManager.PLAYER_1] = gwintDeck;
				gwintDeck.DeckRenderer = mcP1DeckRenderer;
			}
			else
			{
				throw new Error("GFX - Invalid type for deckDefinition passed from witcher script (player 1)");
			}
		}
		
		public function setEnemyDeck(deckDefinition:Object):void
		{
			var gwintDeck:GwintDeck = deckDefinition as GwintDeck;
			if (gwintDeck)
			{
				_cardManager.playerDeckDefinitions[CardManager.PLAYER_2] = gwintDeck;
				gwintDeck.DeckRenderer = mcP2DeckRenderer;
			}
			else
			{
				throw new Error("GFX - Invalid type for deckDefinition passed from witcher script (player 2)");
			}
		}
		
		public function setCardValues(cardValues:Object):void
		{
			trace("GFX ----------------- cardValues received:", cardValues);
			_cardManager.cardValues = cardValues as GwintCardValues;
		}
		
		public function setAIEnabled(turnAIOn:Boolean):void
		{
			if (turnAIOn)
			{
				gameFlowController.turnOnAI(CardManager.PLAYER_1);
			}
			else
			{
				gameFlowController.turnOffAI(CardManager.PLAYER_2);
			}
		}
		
		public function chooseCoingPopup(event:Event):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnChooseCoinFlip" ) );
		}
		
		public function setFirstTurn(playerFirst:Boolean):void
		{
			if (playerFirst)
			{
				mcMessageQueue.PushMessage("[[gwint_player_will_go_first_message]]");
				gameFlowController.currentPlayer = CardManager.PLAYER_1;
			}
			else
			{
				mcMessageQueue.PushMessage("[[gwint_opponent_will_go_first]]");
				gameFlowController.currentPlayer = CardManager.PLAYER_2;
			}
		}
		
		protected function testCardsCalculations():void
		{
			var cardInstances:Vector.<CardInstance> = new Vector.<CardInstance>();
			var newInstance:CardInstance;
			
			trace("GFX --------------------------------------------------------- Commencing card test ---------------------------------------------------------" );
			trace("GFX ================================================== Creating temporary card instances ===================================================" );
			
			for each(var curTemplate:CardTemplate in _cardManager._cardTemplates)
			{
				newInstance = new CardInstance();
				
				newInstance.templateId = curTemplate.index;
				newInstance.templateRef = curTemplate;
				newInstance.owningPlayer = CardManager.PLAYER_1;
				newInstance.instanceId = 100;
				
				cardInstances.push(newInstance);
			}
			
			trace("GFX - Successfully created: " + cardInstances.length + " card instances" );
			
			for (var i:int = 0; i < cardInstances.length; ++i)
			{
				trace("GFX - Checking Card with ID: " + cardInstances[i].templateId + " --------------------------");
				trace("GFX ---------------------------------------------------------" );
				trace("GFX - template Ref: " + cardInstances[i].templateRef);
				trace("GFX - instance info: " + cardInstances[i]);
				trace("GFX - recalulating optimal transaction for card");
				cardInstances[i].recalculatePowerPotential(_cardManager);
				trace("GFX - successfully recalculated following power info: ");
				trace("GFX - " + cardInstances[i].getOptimalTransaction());
			}
			
			trace("GFX ================================ Successfully Finished Test of Card Instances ====================================" );
			trace("GFX ------------------------------------------------------------------------------------------------------------------" );
		}
		
		public function /* Witcherscript */ winGwint( result : int ) : void
		{
			var gameWinner:int = CardManager.PLAYER_INVALID;
			var playerUser:int = CardManager.PLAYER_1;
			var playerNPC:int = CardManager.PLAYER_2;

			switch (result)
			{
				case 0:
					gameWinner = CardManager.PLAYER_2;
					break;
				case 1:
					gameWinner = CardManager.PLAYER_1;
					break;
				default:
					gameWinner = CardManager.PLAYER_INVALID;
					break;
			}	
			
			if (gameFlowController)
			{
				mcEndGameDialog.show(gameWinner, gameFlowController.EndGame);
			}
		}
		
	}
	
}
