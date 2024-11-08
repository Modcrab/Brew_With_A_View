package red.game.witcher3.menus.gwint
{
	import flash.events.MouseEvent;
	import red.core.constants.KeyCode;
	import red.game.witcher3.constants.GwintInputFeedback;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3ChoiceDialog;
	import red.game.witcher3.events.GwintCardEvent;
	import red.game.witcher3.events.GwintHolderEvent;
	import red.game.witcher3.events.InputFeedbackEvent;
	import red.game.witcher3.managers.InputFeedbackManager;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.MouseEventEx;
	
	public class HumanPlayerController extends BasePlayerController
	{
		protected var _handHolder:GwintCardHolder;
		protected var mcChoiceDialog:W3ChoiceDialog;
		
		protected var _currentZoomedHolder:GwintCardHolder = null;
		
		public function HumanPlayerController()
		{
			super();
			_stateMachine.AddState("Idle", 						state_begin_Idle, 			 	on_state_about_to_update,		 state_end_Idle);
			_stateMachine.AddState("ChoosingCard", 				state_begin_ChoosingCard,	 	state_update_ChoosingCard,		 state_end_ChoosingCard);
			_stateMachine.AddState("ChoosingHandler",		 	state_begin_ChoosingHandler, 	state_update_ChoosingHandler,	 null);
			_stateMachine.AddState("ChoosingTargetCard",		state_begin_ChoosingTargetCard, state_update_ChoosingTargetCard, null);
			_stateMachine.AddState("WaitConfirmation",			state_begin_WaitConfirmation,   state_update_WaitConfirmation,   null);
			_stateMachine.AddState("ApplyingCard",				state_begin_ApplyingCard,	 	state_update_ApplyingCard,		 null); // overrided
		}
		
		override public function set boardRenderer(value:GwintBoardRenderer):void
		{
			if (_boardRenderer != value && value)
			{
				value.addEventListener(GwintCardEvent.CARD_CHOSEN, handleCardChosen, false, 0, true);
				value.addEventListener(GwintCardEvent.CARD_SELECTED, handleCardSelected, false, 0, true);
				value.addEventListener(GwintHolderEvent.HOLDER_CHOSEN, handleHolderChosen, false, 0, true);				
				value.addEventListener(GwintHolderEvent.HOLDER_SELECTED, handleHolderSelected, false, 0, true);
				_handHolder = value.getCardHolder(CardManager.CARD_LIST_LOC_HAND, playerID);
			}
			super.boardRenderer = value;
		}
		
		public function setChoiceDialog(choiceDialog:W3ChoiceDialog):void
		{
			mcChoiceDialog = choiceDialog;
		}
		
		protected var _skipButton:InputFeedbackButton;
		public function get skipButton():InputFeedbackButton { return _skipButton }
		public function set skipButton(value:InputFeedbackButton):void
		{
			_skipButton = value;
			if (_skipButton)
			{
				_skipButton.holdCallback = handleSkipTurn;
				
				if (_stateMachine.currentState == "ChoosingCard")
				{
					_skipButton.visible = true;
				}
				else
				{
					_skipButton.visible = false;
				}
				
				_skipButton.addEventListener(MouseEvent.CLICK, handleSkipTurn, false, 0, true);
			}
		}
		
		private function handleSkipTurn(event:MouseEvent = null):void
		{
			skipTurn();
		}
		
		override public function startTurn():void
		{
			if (CardManager.getInstance().getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, playerID).length == 0 && !CardManager.getInstance().getCardLeader(playerID).canBeUsed)
			{
				currentRoundStatus = BasePlayerController.ROUND_PLAYER_STATUS_DONE
			}
			else
			{
				super.startTurn();
				_stateMachine.ChangeState("ChoosingCard");
			}
		}
		
		override public function skipTurn():void
		{
			if (_stateMachine.currentState == "ChoosingCard" && _currentZoomedHolder == null)
			{
				currentRoundStatus = BasePlayerController.ROUND_PLAYER_STATUS_DONE;
				_turnOver = true;
				
				if (_transactionCard != null)
				{
					_boardRenderer.activateAllHolders(true);
					_boardRenderer.selectCard(_transactionCard);
					declineCardTransaction();
				}
				
				_stateMachine.ChangeState("Idle");
			}
		}
		
		override public function set cardZoomEnabled(value:Boolean)
		{
			super.cardZoomEnabled = value;
			
			if (!value && _currentZoomedHolder != null)
			{
				closeZoomCB();
			}
		}
		
		/*
		 * 		States
		 */
		
		protected function on_state_about_to_update():void
		{
			if (_currentZoomedHolder && !mcChoiceDialog.visible)
			{
				closeZoomCB();
			}
		}
		 
		/*---------------------------------------
		 *  Idle State
		 *---------------------------------------*/
		protected function state_begin_Idle():void
		{
			_decidedCardTransaction = null;
			
			if (_boardRenderer)
			{
				_boardRenderer.activateAllHolders(true);
				if (_handHolder && _boardRenderer.getSelectedCardHolder() != _handHolder)
				{
					_boardRenderer.selectCardHolderAdv(_handHolder);
				}
				
				_boardRenderer.getCardHolder(CardManager.CARD_LIST_LOC_LEADER, CardManager.PLAYER_1).updateLeaderStatus(false);
			}
			declineCardTransaction();
			
			if (!GwintGameMenu.mSingleton.mcTutorials.visible && _currentZoomedHolder == null)
			{
				resetToDefaultButtons();
				InputFeedbackManager.appendButtonById(GwintInputFeedback.navigate, NavigationCode.GAMEPAD_L3, -1, "panel_button_common_navigation");
				
				if (_boardRenderer && _boardRenderer.getSelectedCard() != null && cardZoomEnabled)
				{
					InputFeedbackManager.appendButtonById(GwintInputFeedback.zoomCard, NavigationCode.GAMEPAD_R2, KeyCode.RIGHT_MOUSE, "panel_button_common_zoom");
				}
			}
		}
		
		protected function state_end_Idle():void
		{
			if (_boardRenderer)
			{
				if (_boardRenderer.getSelectedCardHolder() != _handHolder)
				{
					_boardRenderer.selectCardHolderAdv(_handHolder);
				}
				
				_boardRenderer.getCardHolder(CardManager.CARD_LIST_LOC_LEADER, CardManager.PLAYER_1).updateLeaderStatus(true);
			}
		}
		
		/*---------------------------------------
		 *  ChoosingCard State
		 *---------------------------------------*/
		
		protected function state_begin_ChoosingCard():void
		{
			if (_skipButton)
			{
				_skipButton.visible = true;
			}
			
			if (_currentZoomedHolder == null)
			{
				resetToDefaultButtons();
				InputFeedbackManager.appendButtonById(GwintInputFeedback.navigate, NavigationCode.GAMEPAD_L3, -1, "panel_button_common_navigation");
				var leaderCard:CardLeaderInstance = CardManager.getInstance().getCardLeader(playerID);
				if (leaderCard && leaderCard.canBeUsed)
				{
					InputFeedbackManager.appendButtonById(GwintInputFeedback.leaderCard, NavigationCode.GAMEPAD_X, KeyCode.X, "gwint_use_leader");
				}
				if (_handHolder.cardSlotsList.length > 0)
				{
					InputFeedbackManager.appendButtonById(GwintInputFeedback.apply, NavigationCode.GAMEPAD_A, KeyCode.ENTER, "panel_button_common_select");
				}
				
				if (_boardRenderer.getSelectedCard() != null && cardZoomEnabled)
				{
					InputFeedbackManager.appendButtonById(GwintInputFeedback.zoomCard, NavigationCode.GAMEPAD_R2, KeyCode.RIGHT_MOUSE, "panel_button_common_zoom");
				}
			}
		}
		
		protected function state_update_ChoosingCard():void
		{
			on_state_about_to_update();
			
			if (_transactionCard)
			{				
				var cardInstance:CardInstance = CardManager.getInstance().getCardInstance(_transactionCard.instanceId);
				var isLeaderCard:Boolean = cardInstance is CardLeaderInstance;
				var isCardEffect:Boolean = cardInstance.templateRef.hasEffect(CardTemplate.CardEffect_UnsummonDummy);
				var isGlobalEffect:Boolean = cardInstance.templateRef.isType(CardTemplate.CardType_Global_Effect);
				
				if (isLeaderCard || isGlobalEffect)
				{
					_stateMachine.ChangeState("WaitConfirmation");
				}
				else if (isCardEffect)
				{
					_stateMachine.ChangeState("ChoosingTargetCard");
				}
				else
				{
					_stateMachine.ChangeState("ChoosingHandler");
				}
			}
		}
		
		protected function state_end_ChoosingCard():void
		{
			if (_skipButton)
			{
				_skipButton.visible = false;
			}
		}
		
		/*---------------------------------------
		 *  ChoosingTargetCard State
		 *---------------------------------------*/
		
		protected function state_begin_ChoosingTargetCard():void
		{
			if (_transactionCard && _boardRenderer)
			{
				var cardInstance:CardInstance = CardManager.getInstance().getCardInstance(_transactionCard.instanceId);
				_boardRenderer.activateHoldersForCard(cardInstance, true);
			}
			
			if (_currentZoomedHolder == null)
			{
				resetToDefaultButtons();
				InputFeedbackManager.appendButtonById(GwintInputFeedback.navigate, NavigationCode.GAMEPAD_L3, -1, "panel_button_common_navigation");
				InputFeedbackManager.appendButtonById(GwintInputFeedback.cancel, NavigationCode.GAMEPAD_B, KeyCode.ESCAPE, "panel_common_cancel");
				
				var selectedHolder:GwintCardHolder = _boardRenderer.getSelectedCardHolder();
				if (selectedHolder.cardSelectionEnabled && selectedHolder.cardSlotsList.length > 0 && selectedHolder.getSelectedCardSlot() != null)
				{
					var transCardInstance:CardInstance = CardManager.getInstance().getCardInstance(_transactionCard.instanceId);
					var targetCardInstance:CardInstance = CardManager.getInstance().getCardInstance(selectedHolder.getSelectedCardSlot().instanceId);
					if (transCardInstance.canBeCastOn(targetCardInstance))
					{
						InputFeedbackManager.appendButtonById(GwintInputFeedback.apply, NavigationCode.GAMEPAD_A, KeyCode.ENTER, "panel_common_apply");
					}
				}
			}
		}
		
		protected function state_update_ChoosingTargetCard():void
		{
			on_state_about_to_update();
		}
		
		/*---------------------------------------
		 *  ChoosingHandler State
		 *---------------------------------------*/
		 
		protected function state_begin_ChoosingHandler():void
		{
			if (_transactionCard && _boardRenderer)
			{
				var cardInstance:CardInstance = CardManager.getInstance().getCardInstance(_transactionCard.instanceId);
				boardRenderer.activateHoldersForCard(cardInstance, true);
			}
			
			if (_currentZoomedHolder == null)
			{
				resetToDefaultButtons();
				InputFeedbackManager.appendButtonById(GwintInputFeedback.apply, NavigationCode.GAMEPAD_A, KeyCode.ENTER, "panel_common_apply");
				InputFeedbackManager.appendButtonById(GwintInputFeedback.cancel, NavigationCode.GAMEPAD_B, KeyCode.ESCAPE, "panel_common_cancel");
				InputFeedbackManager.appendButtonById(GwintInputFeedback.navigate, NavigationCode.GAMEPAD_L3, -1, "panel_button_common_navigation");
			}
		}
		
		protected function state_update_ChoosingHandler():void
		{
			on_state_about_to_update();
		}
		
		/*---------------------------------------
		 *  ChoosingHandler State
		 *---------------------------------------*/
		
		protected var _cardConfirmation:Boolean;
		protected function state_begin_WaitConfirmation():void
		{
			_cardConfirmation = false;
			
			if (_currentZoomedHolder == null)
			{
				resetToDefaultButtons();
				InputFeedbackManager.appendButtonById(GwintInputFeedback.cancel, NavigationCode.GAMEPAD_B, KeyCode.ESCAPE, "panel_common_cancel");
				InputFeedbackManager.appendButtonById(GwintInputFeedback.apply, NavigationCode.GAMEPAD_A, KeyCode.ENTER, "panel_common_apply");
			}
		}
		
		protected function state_update_WaitConfirmation():void
		{
			on_state_about_to_update();
			
			if (_cardConfirmation && _transactionCard)
			{
				_cardConfirmation = false;
				_decidedCardTransaction = new CardTransaction();
				_decidedCardTransaction.targetPlayerID = playerID;
				_decidedCardTransaction.sourceCardInstanceRef = CardManager.getInstance().getCardInstance(_transactionCard.instanceId);
				_stateMachine.ChangeState("ApplyingCard");
			}
		}
		
		/*---------------------------------------
		 *  ApplyingCard State OVERRIDED
		 *---------------------------------------*/
		
		override protected function cardEffectApplying():Boolean
		{
			return super.cardEffectApplying() || mcChoiceDialog.visible;
		}
		
		 override protected function state_begin_ApplyingCard():void
		 {
			super.state_begin_ApplyingCard();
			
			_boardRenderer.activateAllHolders(true);
			
			if (_handHolder && _boardRenderer.getSelectedCardHolder() != _handHolder)
			{
				_boardRenderer.selectCardHolderAdv(_handHolder);
			}
		 }
		
		override protected function state_update_ApplyingCard():void
		{
			on_state_about_to_update();
			
			if (!CardTweenManager.getInstance().isAnyCardMoving() && !gameFlowControllerRef.mcMessageQueue.ShowingMessage() && !CardFXManager.getInstance().isPlayingAnyCardFX() && !mcChoiceDialog.visible)
			{
				_turnOver = true;
				_stateMachine.ChangeState("Idle");
			}
		}
		
		/*
		 * 	Handle user actions on board
		 */
		
		protected function handleCardSelected(event:GwintCardEvent):void
		{
			if (_currentZoomedHolder != null || mcChoiceDialog.visible)
			{
				return;
			}
			
			trace("GFX handleCardSelected <", _stateMachine.currentState, "> ", event.cardSlot);
			
			if (event.cardSlot)
			{
				switch (_stateMachine.currentState)
				{
					case "ChoosingTargetCard":
						var transCardInstance:CardInstance = CardManager.getInstance().getCardInstance(_transactionCard.instanceId);
						var targetCardInstance:CardInstance = CardManager.getInstance().getCardInstance(event.cardSlot.instanceId);
						if (transCardInstance.canBeCastOn(targetCardInstance))
						{
							InputFeedbackManager.appendButtonById(GwintInputFeedback.apply, NavigationCode.GAMEPAD_A, KeyCode.ENTER, "panel_common_apply");
						}
						else
						{
							InputFeedbackManager.removeButtonById(GwintInputFeedback.apply);
						}
				}
			}
			
			if (_boardRenderer.getSelectedCard() != null && cardZoomEnabled && !mcChoiceDialog.visible && _stateMachine.currentState != "ChoosingTargetCard" && _stateMachine.currentState != "ChoosingHandler")
			{
				InputFeedbackManager.appendButtonById(GwintInputFeedback.zoomCard, NavigationCode.GAMEPAD_R2, KeyCode.RIGHT_MOUSE, "panel_button_common_zoom");
			}
			else
			{
				InputFeedbackManager.removeButtonById(GwintInputFeedback.zoomCard);
			}
		}
		
		protected function handleHolderSelected(event:GwintHolderEvent):void
		{
			if (_currentZoomedHolder != null || mcChoiceDialog.visible)
			{
				return;
			}
			
			trace("GFX handleHolderSelected <", _stateMachine.currentState, "> ", _transactionCard, event.cardHolder);
			
			switch (_stateMachine.currentState)
			{
				case "ChoosingHandler":
					if (_transactionCard)
					{
						InputFeedbackManager.appendButtonById(GwintInputFeedback.apply, NavigationCode.GAMEPAD_A, KeyCode.ENTER, "panel_common_apply");
					}
					break;
				case "ChoosingCard":
					
					var curHolder:GwintCardHolder = event.cardHolder;
					var leaderCard:CardLeaderInstance = CardManager.getInstance().getCardLeader(playerID);
					
					if (curHolder.cardSlotsList.length > 0 && 
					   (curHolder.cardHolderID == CardManager.CARD_LIST_LOC_HAND || 
					   (curHolder.cardHolderID == CardManager.CARD_LIST_LOC_LEADER && curHolder.playerID == CardManager.PLAYER_1 && leaderCard && leaderCard.canBeUsed)))
					{	
						InputFeedbackManager.appendButtonById(GwintInputFeedback.apply, NavigationCode.GAMEPAD_A, KeyCode.ENTER, "panel_button_common_select");
					}
					else
					{
						InputFeedbackManager.removeButtonById(GwintInputFeedback.apply);
					}
					
					if (_boardRenderer.getSelectedCard() != null && cardZoomEnabled && !mcChoiceDialog.visible)
					{
						InputFeedbackManager.appendButtonById(GwintInputFeedback.zoomCard, NavigationCode.GAMEPAD_R2, KeyCode.RIGHT_MOUSE, "panel_button_common_zoom");
					}
					else
					{
						InputFeedbackManager.removeButtonById(GwintInputFeedback.zoomCard);
					}
					break;
			}
		}
		
		protected function handleCardChosen(event:GwintCardEvent):void
		{
			if (_currentZoomedHolder != null)
			{
				return;
			}
			trace("GFX handleCardChosen <", _stateMachine.currentState, "> ", event.cardSlot);
			
			if (event.cardSlot)
			{
				switch (_stateMachine.currentState)
				{
					case "ChoosingCard":
						var curHolder:GwintCardHolder = event.cardHolder;
						if (curHolder.cardHolderID == CardManager.CARD_LIST_LOC_HAND || (curHolder.cardHolderID == CardManager.CARD_LIST_LOC_LEADER && curHolder.playerID == CardManager.PLAYER_1))
						{
							var leaderCard:CardLeaderInstance = event.cardSlot.cardInstance as CardLeaderInstance;
							if (leaderCard == null || leaderCard.canBeUsed)
							{
								startCardTransaction(event.cardSlot.instanceId);
							}
						}
						break;
					case "ChoosingTargetCard":
						var transCardInstance:CardInstance = CardManager.getInstance().getCardInstance(_transactionCard.instanceId);
						var targetCardInstance:CardInstance = CardManager.getInstance().getCardInstance(event.cardSlot.instanceId);
						
						if (transCardInstance.canBeCastOn(targetCardInstance))
						{
							_decidedCardTransaction = new CardTransaction();
							_decidedCardTransaction.targetPlayerID = playerID;
							_decidedCardTransaction.targetSlotID = CardManager.CARD_LIST_LOC_INVALID;
							_decidedCardTransaction.targetCardInstanceRef = targetCardInstance;
							_decidedCardTransaction.sourceCardInstanceRef = transCardInstance;
							
							_stateMachine.ChangeState("ApplyingCard");
						}
						break;
				}
			}
		}
		
		protected function handleHolderChosen(event:GwintHolderEvent):void
		{
			trace("GFX handleHolderChosen <", _stateMachine.currentState, "> ", _transactionCard, event.cardHolder);
			
			if (_transactionCard && _stateMachine.currentState == "ChoosingHandler")
			{
				var transCardInstance:CardInstance = CardManager.getInstance().getCardInstance(_transactionCard.instanceId);
				
				_decidedCardTransaction = new CardTransaction();
				_decidedCardTransaction.targetPlayerID = event.cardHolder.playerID;
				_decidedCardTransaction.targetSlotID = event.cardHolder.cardHolderID;
				_decidedCardTransaction.targetCardInstanceRef = null;
				_decidedCardTransaction.sourceCardInstanceRef = transCardInstance;
				
				_stateMachine.ChangeState("ApplyingCard");
			}
		}
		
		/*
		 * 	Handle user input directly / called after passing inbput to the BoardRenderer/
		 */
		
		override public function handleUserInput(event:InputEvent):void 
		{
			if (!inputEnabled)
			{
				return;
			}
			
			if (_boardRenderer && _currentZoomedHolder == null && (_transactionCard == null || CardManager.getInstance().getCardLeader(playerID) != _transactionCard.cardInstance))
			{
				_boardRenderer.handleInputPreset(event);
			}
			
			if (!event.handled)
			{
				processUserInput(event);
			}
		}
		
		override public function handleMouseMove(event:MouseEvent):void
		{
			if (!inputEnabled)
			{
				return;
			}
			
			if (_boardRenderer && _currentZoomedHolder == null && (_transactionCard == null || CardManager.getInstance().getCardLeader(playerID) != _transactionCard.cardInstance))
			{
				_boardRenderer.handleMouseMove(event);
			}
		}
		
		override public function handleMouseClick(event:MouseEvent):void
		{
			if (_boardRenderer && _currentZoomedHolder == null)
			{
				var superMouseEvent:MouseEventEx = event as MouseEventEx;
				if (superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
				{
					if (_stateMachine.currentState == "WaitConfirmation")
					{
						_cardConfirmation = true;
					}
					else
					{
						_boardRenderer.handleLeftClick(event);
					}
				}
				else if (superMouseEvent.buttonIdx == MouseEventEx.RIGHT_BUTTON && !CardTweenManager.getInstance().isAnyCardMoving())
				{
					if (_transactionCard == null)
					{
						if (_stateMachine.currentState == "Idle" || _stateMachine.currentState == "ChoosingCard")
						{
							if (_currentZoomedHolder == null)
							{
								tryStartZoom();
								if (mcChoiceDialog.visible)
								{
									mcChoiceDialog.ignoreNextRightClick = true;
								}
							}
							else
							{
								closeZoomCB( -1);
								event.stopImmediatePropagation();
							}
						}
					}
					else
					{
						_boardRenderer.activateAllHolders(true);
						//_boardRenderer.selectCard(_transactionCard);
						declineCardTransaction();
						
						_stateMachine.ChangeState("ChoosingCard");
					}
				}
			}
		}
		
		protected function processUserInput(event:InputEvent):void
		{
			var details:InputDetails = event.details;
			var keyUp:Boolean = (details.value == InputValue.KEY_UP );
			var navCommand:String = details.navEquivalent;
			
			// Disabling input while cards are animating to prevent bugs
			if (CardTweenManager.getInstance().isAnyCardMoving())
			{
				return;
			}
			
			if (keyUp && !event.handled)
			{
				if (_currentZoomedHolder)
				{
					if (navCommand == NavigationCode.GAMEPAD_R2)
					{
						closeZoomCB();
					}
				}
				else
				{
					switch (navCommand)
					{
						case NavigationCode.GAMEPAD_A:
							if (_stateMachine.currentState == "WaitConfirmation" && !(details.code == KeyCode.SPACE))
							{
								_cardConfirmation = true;
							}
							break;
							
						case NavigationCode.GAMEPAD_B:
							if (_transactionCard)
							{
								_boardRenderer.activateAllHolders(true);
								_boardRenderer.selectCard(_transactionCard);
								declineCardTransaction();
								event.handled = true;
								
								_stateMachine.ChangeState("ChoosingCard");
							}
							break;
						case NavigationCode.GAMEPAD_X:
							tryPutLeaderInTransaction();
							break;
						case NavigationCode.GAMEPAD_R2:
							if (_stateMachine.currentState == "Idle" || _stateMachine.currentState == "ChoosingCard")
							{
								tryStartZoom();
							}
					}
					switch (details.code)
					{
						case KeyCode.X:
							tryPutLeaderInTransaction();
							break;
					}
				}
				
				if (!event.handled && !mcChoiceDialog.visible && details.code == KeyCode.ESCAPE)
				{
					GwintGameMenu.mSingleton.tryQuitGame();
				}
			}
		}
		
		protected function tryPutLeaderInTransaction():void
		{
			if (_stateMachine.currentState == "ChoosingCard" && _transactionCard == null)
			{
				var leaderCard:CardLeaderInstance = CardManager.getInstance().getCardLeader(playerID);
				
				if (leaderCard)
				{
					if (leaderCard.canBeUsed)
					{
						startCardTransaction(leaderCard.instanceId);
					}
				}
				else
				{
					throw new Error("GFX [ERROR] - The leader card for player: " + playerID + " is not the correct type");
				}
			}
		}
		
		protected function resetToDefaultButtons():void
		{
			InputFeedbackManager.cleanupButtons();
			
			InputFeedbackManager.appendButtonById(GwintInputFeedback.quitGame, NavigationCode.START, KeyCode.Q, "gwint_pass_game");
			
			if (_stateMachine.currentState == "ChoosingCard")
			{
				InputFeedbackManager.appendButtonById(GwintInputFeedback.endTurn, NavigationCode.GAMEPAD_Y, -1, "qwint_skip_turn");
				
				if (_skipButton)
				{
					_skipButton.visible = true;
				}
			}
		}
		
		protected function tryStartZoom():void
		{
			if (_currentZoomedHolder || !cardZoomEnabled)
			{
				return;
			}
			
			if (_boardRenderer.getSelectedCardHolder() && _boardRenderer.getSelectedCardHolder().cardSlotsList.length > 0)
			{
				_currentZoomedHolder = _boardRenderer.getSelectedCardHolder();
			}
			
			if (_currentZoomedHolder.cardHolderID == CardManager.CARD_LIST_LOC_HAND && _currentZoomedHolder.playerID == CardManager.PLAYER_2) // Disabling zooming of enemy hand
			{
				_currentZoomedHolder = null;
				return;
			}
			
			if (_currentZoomedHolder)
			{
				if (_currentZoomedHolder.selectedCardIdx == -1)
				{
					return;
				}
				
				GwintGameMenu.mSingleton.playSound("gui_gwint_preview_card");
				
				InputFeedbackManager.cleanupButtons();
				InputFeedbackManager.appendButtonById(GwintInputFeedback.quitGame, NavigationCode.START, KeyCode.Q, "gwint_pass_game");
				InputFeedbackManager.appendButtonById(GwintInputFeedback.navigate, NavigationCode.GAMEPAD_L3, -1, "panel_button_common_navigation");
				InputFeedbackManager.appendButtonById(GwintInputFeedback.zoomCard, NavigationCode.GAMEPAD_R2, KeyCode.RIGHT_MOUSE, "panel_button_common_close");
				
				if (_skipButton)
				{
					_skipButton.visible = false;
				}
				
				var cardInstanceList:Vector.<CardInstance> = new Vector.<CardInstance>();
				
				for (var i:int = 0; i < _currentZoomedHolder.cardSlotsList.length; ++i)
				{
					cardInstanceList.push(_currentZoomedHolder.cardSlotsList[i].cardInstance);
				}
				
				if (_stateMachine.currentState == "ChoosingCard" &&
					((_currentZoomedHolder.cardHolderID == CardManager.CARD_LIST_LOC_HAND && _currentZoomedHolder.playerID == CardManager.PLAYER_1) ||
					(_currentZoomedHolder.cardHolderID == CardManager.CARD_LIST_LOC_LEADER && _currentZoomedHolder.playerID == CardManager.PLAYER_1 && CardManager.getInstance().getCardLeader(CardManager.PLAYER_1).canBeUsed)))
				{
					mcChoiceDialog.showDialogCardInstances(cardInstanceList, zoomCardToTransaction, closeZoomCB, "");
				}
				else
				{
					mcChoiceDialog.showDialogCardInstances(cardInstanceList, null, closeZoomCB, "");
				}
				mcChoiceDialog.cardsCarousel.validateNow();
				
				mcChoiceDialog.cardsCarousel.addEventListener(ListEvent.INDEX_CHANGE, onCarouselSelectionChanged, false, 0, true);
				
				if (_currentZoomedHolder.selectedCardIdx != -1)
				{
					mcChoiceDialog.cardsCarousel.selectedIndex = _currentZoomedHolder.selectedCardIdx;
				}
			}
		}
		
		protected function zoomCardToTransaction(instanceId:int = 0):void
		{
			if (instanceId != -1)
			{
				startCardTransaction(instanceId);
			}
			
			closeZoomCB(instanceId);
		}
		
		protected function closeZoomCB(instanceId:int = 0):void
		{
			if (_currentZoomedHolder)
			{
				GwintGameMenu.mSingleton.playSound("gui_gwint_preview_card");
				//_currentZoomedHolder.selectedCardIdx = mcChoiceDialog.cardsCarousel.selectedIndex;
				
				if (_skipButton)
				{
					_skipButton.visible = false;
				}
				
				if (mcChoiceDialog.visible) // So this callback can be called after it has already been hiden to do cleanup
				{
					mcChoiceDialog.hideDialog();
				}
				
				resetToDefaultButtons();
				
				var leaderCard:CardLeaderInstance = CardManager.getInstance().getCardLeader(playerID);
				var currentHolder:GwintCardHolder = _boardRenderer.getSelectedCardHolder();
				
				if (_stateMachine.currentState == "ChoosingCard" &&
					(_currentZoomedHolder.cardHolderID == CardManager.CARD_LIST_LOC_HAND || 
					(_currentZoomedHolder.cardHolderID == CardManager.CARD_LIST_LOC_LEADER && _currentZoomedHolder.playerID == CardManager.PLAYER_1 && leaderCard && leaderCard.canBeUsed)))
				{
					InputFeedbackManager.appendButtonById(GwintInputFeedback.apply, NavigationCode.GAMEPAD_A, KeyCode.ENTER, "panel_button_common_select");
				}
				
				InputFeedbackManager.appendButtonById(GwintInputFeedback.zoomCard, NavigationCode.GAMEPAD_R2, KeyCode.RIGHT_MOUSE, "panel_button_common_zoom");
				
				if (leaderCard && leaderCard.canBeUsed)
				{
					InputFeedbackManager.appendButtonById(GwintInputFeedback.leaderCard, NavigationCode.GAMEPAD_X, KeyCode.X, "gwint_use_leader");
				}
				
				mcChoiceDialog.cardsCarousel.removeEventListener(ListEvent.INDEX_CHANGE, onCarouselSelectionChanged, false);
				
				InputFeedbackManager.appendButtonById(GwintInputFeedback.navigate, NavigationCode.GAMEPAD_L3, -1, "panel_button_common_navigation");
				
				_currentZoomedHolder = null;
			}
		}
		
		public function attachToTutorialCarouselMessage():void
		{
			if (GwintTutorial.mSingleton)
			{
				GwintTutorial.mSingleton.hideCarouselCB = closeZoomCB;
			}
		}
		
		protected function onCarouselSelectionChanged( event:ListEvent ):void
		{
			if (_currentZoomedHolder)
			{
				_currentZoomedHolder.selectedCardIdx = event.index;
			}
		}
	}
}
