package red.game.witcher3.menus.gwint
{
	import com.gskinner.motion.GTweener;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.game.witcher3.constants.GwintInputFeedback;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.managers.InputFeedbackManager;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import red.game.witcher3.controls.W3UILoader;
	
	public class GwintEndGameDialog extends UIComponent
	{
		public static const EndGameDialogResult_EndVictory : int = 0;
		public static const EndGameDialogResult_EndDefeat : int = 1;
		public static const EndGameDialogResult_Restart : int = 2;
		
		public var txtPlayer1Name:TextField;
		public var txtPlayer2Name:TextField;
		
		public var txtRound1Title:TextField;
		public var txtRound2Title:TextField;
		public var txtRound3Title:TextField;
		
		public var txtP1Round1Score:TextField;
		public var txtP2Round1Score:TextField;
		public var txtP1Round2Score:TextField;
		public var txtP2Round2Score:TextField;
		public var txtP1Round3Score:TextField;
		public var txtP2Round3Score:TextField;
		
		public var mcIconLoader:W3UILoader;
		
		public var mcReplayButton:InputFeedbackButton;
		public var mcCloseButton:InputFeedbackButton;
		
		protected var _winningPlayer:int;
		protected var _resultFunctor:Function;
		
		private var _btnAccept:int = -1;
		private var _btnRestart:int = -1;
		
		override protected function configUI():void
		{
			super.configUI();
			
			txtRound1Title.text = "[[gwint_round]]";
			txtRound2Title.text = txtRound1Title.text + " 2";
			txtRound3Title.text = txtRound1Title.text + " 3";
			txtRound1Title.appendText(" 1");
			
			if (mcReplayButton != null)
			{
				mcReplayButton.clickable = true;
				mcReplayButton.label = "[[gwint_play_again]]";
				mcReplayButton.setDataFromStage(NavigationCode.GAMEPAD_Y, KeyCode.SPACE);
				mcReplayButton.addEventListener(ButtonEvent.PRESS, onReplayPressed, false, 0, true);
				mcReplayButton.validateNow();
			}
			
			if (mcCloseButton != null)
			{
				mcCloseButton.clickable = true;
				mcCloseButton.label = "[[panel_button_common_close]]";
				mcCloseButton.setDataFromStage(NavigationCode.GAMEPAD_B, KeyCode.ESCAPE);
				mcCloseButton.addEventListener(ButtonEvent.PRESS, closeButtonPressed, false, 0, true);
				mcCloseButton.validateNow();
			}
				 
			visible = false;
		}
		
		public function show(winningPlayer:int, callback:Function):void
		{
			_winningPlayer = winningPlayer;
			_resultFunctor = callback;
			
			alpha = 0;
			visible = true;
			
			GwintGameMenu.mSingleton.mcCloseBtn.visible = false;
			
			GTweener.removeTweens(this);
			GTweener.to(this, 0.2, { alpha:1.0 }, { } );
			
			if (winningPlayer == CardManager.PLAYER_1)
			{
				if (mcIconLoader)
				{
					mcIconLoader.x = 703.8;
					mcIconLoader.y = 79.35;
					mcIconLoader.source = "img://icons\\gwint\\results\\battle_victory.png";
				}
				
				gotoAndPlay("Victory");
			}
			else if (winningPlayer == CardManager.PLAYER_2)
			{
				if (mcIconLoader)
				{
					mcIconLoader.x = 702.05;
					mcIconLoader.y = 47.8;
					mcIconLoader.source = "img://icons\\gwint\\results\\battle_defeat.png";
				}
				
				gotoAndPlay("Defeat");
			}
			else
			{
				if (mcIconLoader)
				{
					mcIconLoader.x = 705.95;
					mcIconLoader.y = 29;
					mcIconLoader.source = "img://icons\\gwint\\results\\battle_draw.png";
				}
				
				gotoAndPlay("Draw");
			}
			
			setPlayerScores();
			updatePlayerNames();
			
			showInputFeedback();
			
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInputDialog, false, 0, true);
		}
		
		public function hide():void
		{
			if (visible)
			{
				GTweener.removeTweens(this);
				
				GwintGameMenu.mSingleton.mcCloseBtn.visible = true;
				
				GTweener.to(this, 0.2, { alpha:0.0 }, {  } );
				
				InputDelegate.getInstance().removeEventListener(InputEvent.INPUT, handleInputDialog);
				
				hideInputFeedback();
			}
		}
		
		protected function setPlayerScores():void
		{
			var cardManagerRef:CardManager = CardManager.getInstance();
			
			if (cardManagerRef)
			{
				if (cardManagerRef.roundResults.length < 3)
				{
					throw new Error("GFX - Tried to set Player scores in end game dialog but not enough round data available! " + cardManagerRef.roundResults.length);
				}
				
				var i:int;
				var p1RoundTextField:TextField;
				var p2RoundTextField:TextField;
				
				// Round 1
				updateTextFieldsWithRoundResult(cardManagerRef.roundResults[0], txtP1Round1Score, txtP2Round1Score);
				
				// Round 2
				updateTextFieldsWithRoundResult(cardManagerRef.roundResults[1], txtP1Round2Score, txtP2Round2Score);
				
				// Round 3
				updateTextFieldsWithRoundResult(cardManagerRef.roundResults[2], txtP1Round3Score, txtP2Round3Score);
			}
		}
		
		protected function updateTextFieldsWithRoundResult(curResult:GwintRoundResult, p1RoundTextField:TextField, p2RoundTextField:TextField)
		{
			if (curResult.played)
			{
				p1RoundTextField.text = curResult.getPlayerScore(CardManager.PLAYER_1).toString();
				p2RoundTextField.text = curResult.getPlayerScore(CardManager.PLAYER_2).toString();
				
				if (curResult.winningPlayer == CardManager.PLAYER_1)
				{
					p1RoundTextField.textColor = 0xe0a63d;
				}
				else
				{
					p1RoundTextField.textColor = 0XC2C1C0;
				}
				
				if (curResult.winningPlayer == CardManager.PLAYER_2)
				{
					p2RoundTextField.textColor = 0xe0a63d;
				}
				else
				{
					p2RoundTextField.textColor = 0XC2C1C0;
				}
			}
			else
			{
				p1RoundTextField.text = "-";
				p2RoundTextField.text = "-";
			}
		}
		
		protected function updatePlayerNames():void
		{
			var cardManagerRef:CardManager = CardManager.getInstance();
			
			if (cardManagerRef)
			{
				txtPlayer1Name.text = cardManagerRef.playerRenderers[CardManager.PLAYER_1].playerName;
				txtPlayer2Name.text = cardManagerRef.playerRenderers[CardManager.PLAYER_2].playerName;
			}
		}
		
		protected function showInputFeedback():void
		{
			InputFeedbackManager.cleanupButtons();
			
			if (!GwintGameMenu.mSingleton.mcTutorials.visible)
			{
				if (mcReplayButton != null)
				{
					if (_winningPlayer == CardManager.PLAYER_INVALID)
					{
						mcReplayButton.visible = true;
					}
					else
					{
						mcReplayButton.visible = false;
					}
				}
				
				if (mcCloseButton != null)
				{
					mcCloseButton.enabled = true;
					mcCloseButton.visible = true;
				}
			}
			else
			{
				if (mcCloseButton != null)
				{
					mcCloseButton.visible = false;
				}
				
				GwintGameMenu.mSingleton.mcTutorials.onHideCallback = showInputFeedback;
			}
		}
		
		protected function hideInputFeedback():void
		{
			InputFeedbackManager.removeButtonById(GwintInputFeedback.restart);
			InputFeedbackManager.removeButtonById(GwintInputFeedback.close);
		}
		
		public function closeButtonPressed( event : ButtonEvent ):void
		{
			if (_winningPlayer == CardManager.PLAYER_2 || _winningPlayer == CardManager.PLAYER_INVALID)
			{
				_resultFunctor(EndGameDialogResult_EndDefeat);
			}
			else
			{
				_resultFunctor(EndGameDialogResult_EndVictory);
			}
			
			hide();
		}
		
		private function handleInputDialog(event:InputEvent):void
		{
			if (visible && !GwintGameMenu.mSingleton.mcTutorials.visible)
			{
				var details:InputDetails = event.details;
				var keyUp:Boolean = (details.value == InputValue.KEY_UP);
				
				if ( keyUp && !event.handled && _resultFunctor != null)
				{
					switch(details.navEquivalent)
					{
					case NavigationCode.GAMEPAD_B:
						{
							closeButtonPressed(null);
						}
						break;
					case NavigationCode.GAMEPAD_Y:
						{
							onReplayPressed(null);
						}
						break;
					}
					
					if (details.code == KeyCode.SPACE)
					{
						if (_winningPlayer == CardManager.PLAYER_INVALID)
						{
							_resultFunctor(EndGameDialogResult_Restart);
							hide();
						}
					}
				}
			}
		}
		
		protected function onReplayPressed( event : ButtonEvent ) : void
		{
			if (_winningPlayer == CardManager.PLAYER_INVALID)
			{
				_resultFunctor(EndGameDialogResult_Restart);
				hide();
			}
		}
		
	}
}
