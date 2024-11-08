package red.game.witcher3.menus.gwint
{
	import flash.events.MouseEvent;
	import red.game.witcher3.utils.FiniteStateMachine;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	
	public class BasePlayerController extends UIComponent
	{
		public static const ROUND_PLAYER_STATUS_ACTIVE 	: int = 1;
		public static const ROUND_PLAYER_STATUS_DONE 	: int = 2;
		
		public var gameFlowControllerRef:GwintGameFlowController;
		public var playerID:int;
		public var opponentID:int;
		
		protected var isAI:Boolean = false;
		
		protected var _stateMachine:FiniteStateMachine;
		protected var _decidedCardTransaction:CardTransaction;
		
		public var inputEnabled:Boolean = true;
		
		protected var _boardRenderer:GwintBoardRenderer;
		public function get boardRenderer():GwintBoardRenderer { return _boardRenderer; }
		public function set boardRenderer(value:GwintBoardRenderer):void
		{
			_boardRenderer = value;
			
		}
		
		protected var _playerRenderer:GwintPlayerRenderer;
		public function get playerRenderer():GwintPlayerRenderer { return _playerRenderer; }
		public function set playerRenderer(value:GwintPlayerRenderer):void
		{
			_playerRenderer = value;
			
			var deckDefinition:GwintDeck = CardManager.getInstance().playerDeckDefinitions[_playerRenderer.playerID];
			
			_playerRenderer.txtFactionName.text = deckDefinition.getFactionNameString();
			_playerRenderer.mcFactionIcon.gotoAndStop(deckDefinition.getDeckKingTemplate().getFactionString());
			_playerRenderer.numCardsInHand = 0;
		}
		
		protected var _cardZoomEnabled:Boolean = true;
		public function set cardZoomEnabled(value:Boolean)
		{
			_cardZoomEnabled = value;
		}
		public function get cardZoomEnabled():Boolean
		{
			return _cardZoomEnabled;
		}
		
		private var _currentRoundStatus:int = ROUND_PLAYER_STATUS_ACTIVE;
		public function get currentRoundStatus():int 
		{ 
			if (CardManager.getInstance().getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, playerID).length == 0 && !CardManager.getInstance().getCardLeader(playerID).canBeUsed)
			{
				return ROUND_PLAYER_STATUS_DONE;
			}
			
			return _currentRoundStatus; 
		}
		public function set currentRoundStatus(value:int):void
		{
			_currentRoundStatus = value;
			
			if (_playerRenderer)
			{
				_playerRenderer.showPassed(_currentRoundStatus == ROUND_PLAYER_STATUS_DONE);
			}
		}
		
		protected var _turnOver:Boolean;
		
		protected var _transactionCard:CardSlot;
		public function set transactionCard(slot:CardSlot):void
		{
			if (_transactionCard)
			{
				_transactionCard.cardState = CardSlot.STATE_BOARD;
			}
			
			_transactionCard = slot;
			
			if (_boardRenderer)
			{
				_boardRenderer.updateTransactionCardTooltip(slot);
			}
			
			if (_transactionCard)
			{
				_transactionCard.cardState = CardSlot.STATE_CAROUSEL;
			}
		}
		
		function BasePlayerController()
		{
			_stateMachine = new FiniteStateMachine();
		}
		
		public function get turnOver():Boolean
		{
			return _turnOver && !_transactionCard;
		}
		
		public function startTurn():void
		{
			if (currentRoundStatus == ROUND_PLAYER_STATUS_DONE)
			{
				return;
			}
			
			_turnOver = false;
		}
		
		public function skipTurn():void
		{
			//
		}
		
		public function resetCurrentRoundStatus():void
		{
			if (CardManager.getInstance().getCardInstanceList(CardManager.CARD_LIST_LOC_HAND, playerID).length > 0)
			{
				currentRoundStatus = ROUND_PLAYER_STATUS_ACTIVE;
			}
		}
		
		protected function startCardTransaction(cardInstanceId:int):void
		{
			if (boardRenderer)
			{
				var targetCard:CardSlot = boardRenderer.getCardSlotById(cardInstanceId);
				var targetX:Number = boardRenderer.mcTransitionAnchor.x;
				var targetY:Number = boardRenderer.mcTransitionAnchor.y
				CardTweenManager.getInstance().storePosition(targetCard); 
				CardTweenManager.getInstance().tweenTo(targetCard, targetX, targetY);
				transactionCard = targetCard;
			}
		}
		
		protected function declineCardTransaction():void
		{
			if (_transactionCard)
			{
				CardTweenManager.getInstance().restorePosition(_transactionCard, true);
				transactionCard = null;
			}
		}
		
		protected function transferTransactionCardToDestination(slotID:int, playerID:int):void
		{
			if (_transactionCard)
			{
				CardManager.getInstance().addCardInstanceIDToList(_transactionCard.instanceId, slotID, playerID);
				transactionCard = null;
			}
		}
		
		protected function applyTransactionCardToCardInstance(cardInstance:CardInstance):void
		{
			CardManager.getInstance().replaceCardInstanceIDs(_transactionCard.instanceId, cardInstance.instanceId);
			transactionCard = null;
		}
		
		protected function applyGlobalEffectTransactionCard():void
		{
			if (_transactionCard)
			{
				CardManager.getInstance().applyCardEffectsID(_transactionCard.instanceId);
				CardManager.getInstance().sendToGraveyardID(_transactionCard.instanceId);
				transactionCard = null;
			}
		}
		
		/*---------------------------------------
		 *  ApplyingCard State
		 *---------------------------------------*/
		
		protected function state_begin_ApplyingCard():void
		{
			var leaderCard:CardLeaderInstance = _decidedCardTransaction.sourceCardInstanceRef as CardLeaderInstance;
			
			if (leaderCard)
			{
				leaderCard.ApplyLeaderAbility(isAI);
				CardTweenManager.getInstance().restorePosition(_transactionCard, true);
				transactionCard = null;
			}
			else if (_decidedCardTransaction.targetSlotID != CardManager.CARD_LIST_LOC_INVALID)
			{
				transferTransactionCardToDestination(_decidedCardTransaction.targetSlotID, _decidedCardTransaction.targetPlayerID);
			}
			else if (_decidedCardTransaction.targetCardInstanceRef)
			{
				applyTransactionCardToCardInstance(_decidedCardTransaction.targetCardInstanceRef);
			}
			else if (_decidedCardTransaction.sourceCardInstanceRef.templateRef.isType(CardTemplate.CardType_Global_Effect))
			{
				applyGlobalEffectTransactionCard();
			}
			else
			{
				declineCardTransaction();
			}
		}
		
		protected function cardEffectApplying():Boolean
		{
			return CardTweenManager.getInstance().isAnyCardMoving() || gameFlowControllerRef.mcMessageQueue.ShowingMessage() || CardFXManager.getInstance().isPlayingAnyCardFX();
		}
		
		protected function state_update_ApplyingCard():void
		{
			if (!cardEffectApplying())
			{
				if (gameFlowControllerRef.playerControllers[opponentID].currentRoundStatus == ROUND_PLAYER_STATUS_DONE)
				{
					_stateMachine.ChangeState("ChoosingMove");
				}
				else
				{
					_stateMachine.ChangeState("Idle");
				}
			}
		}
		
		/*
		 *  Handle user input
		 */
		
		public function handleUserInput(event:InputEvent):void 
		{
		}
		
		public function handleMouseMove(event:MouseEvent):void
		{
		}
		
		public function handleMouseClick(event:MouseEvent):void
		{
		}
	}
}
