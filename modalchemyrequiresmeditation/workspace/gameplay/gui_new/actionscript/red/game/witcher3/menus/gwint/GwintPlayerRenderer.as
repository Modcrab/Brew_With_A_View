package red.game.witcher3.menus.gwint
{
	import flash.display.MovieClip;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import scaleform.clik.core.UIComponent;
	import red.game.witcher3.controls.W3TextArea;
	
	public class GwintPlayerRenderer extends UIComponent
	{
		public var txtPassed:W3TextArea;
		public var mcPassed:MovieClip;
		public var txtPlayerName:W3TextArea;
		public var txtFactionName:W3TextArea;
		public var txtCardCount:W3TextArea;
		public var mcPlayerPortrait:MovieClip;
		public var mcScore:MovieClip;
		public var mcLifeIndicator:MovieClip;
		public var mcFactionIcon:MovieClip;
		public var mcWinningRound:MovieClip;
		
		
		public function set playerName(value:String):void
		{
			txtPlayerName.text = value;
		}
		
		public function get playerName() : String
		{
			return txtPlayerName.text;
		}
		
		protected var _playerNameDataProvider:String = CommonConstants.INVALID_STRING_PARAM;
		[Inspectable(defaultValue=CommonConstants.INVALID_STRING_PARAM)]
		public function get playerNameDataProvider():String { return _playerNameDataProvider; }
		public function set playerNameDataProvider(value:String):void
		{
			_playerNameDataProvider = value;
		}
		
		protected var _playerID:int = CardManager.PLAYER_INVALID;
		[Inspectable(defaultValue = CardManager.PLAYER_INVALID)]
		public function get playerID():int { return _playerID; }
		public function set playerID(value:int):void
		{
			_playerID = value;
			
			if (mcPlayerPortrait)
			{
				if (_playerID == CardManager.PLAYER_1)
				{
					mcPlayerPortrait.gotoAndStop("geralt");
				}
				else
				{
					mcPlayerPortrait.gotoAndStop("npc");
				}
			}
		}
		
		private var _score:int = -1;
		public function set score(value:int):void
		{
			if (_score != value)
			{
				if (mcScore.currentFrameLabel == "Idle") // to prevent spamming of this animation
				{
					if (_score < value)
					{
						mcScore.gotoAndPlay("Grew");
					}
					else
					{
						mcScore.gotoAndPlay("Shrank");
					}
				}
				
				_score = value;
				
				var scoreTextArea:W3TextArea = mcScore.getChildByName("txtScore") as W3TextArea;
				if (scoreTextArea)
				{
					scoreTextArea.text = _score.toString();
				}
			}
		}
		
		public function set numCardsInHand(value:int):void
		{
			txtCardCount.text = value.toString();
		}
		
		private var _turnActive:Boolean = false;
		public function set turnActive(value:Boolean):void
		{
			if (value != _turnActive)
			{
				_turnActive = value;
				
				if (_turnActive)
				{
					gotoAndPlay("Selected");
				}
				else
				{
					gotoAndPlay("Idle");
				}
			}
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			if (_playerNameDataProvider != CommonConstants.INVALID_STRING_PARAM)
			{
				dispatchEvent( new GameEvent(GameEvent.REGISTER, _playerNameDataProvider, [setPlayerName]));
			}
			
			if (mcPassed)
			{
				txtPassed = mcPassed.getChildByName("txtPassed") as W3TextArea;
			}
			
			if (mcWinningRound)
			{
				mcWinningRound.stop();
				mcWinningRound.visible = false;
			}
			
			reset();
		}
		
		protected function setPlayerName(value:String):void
		{
			playerName = value;
		}
		
		protected var _lastSetPlayerLives:int = -1;
		public function setPlayerLives(value:int):void
		{
			trace("GFX - Updating life for Player: " + playerName + ", to: " + value + " and life indicator: " + mcLifeIndicator);
			
			if (_lastSetPlayerLives != value)
			{
				_lastSetPlayerLives = value;
				
				var gem1:MovieClip = mcLifeIndicator.getChildByName("mcLifeGemAnim1") as MovieClip;
				var gem2:MovieClip = mcLifeIndicator.getChildByName("mcLifeGemAnim2") as MovieClip;
				
				switch (value)
				{
				case 0:
					if (gem2.currentLabel != "play")
					{
						gem2.gotoAndPlay("play");
					}
					
					if (gem1.currentLabel != "play")
					{
						gem1.gotoAndPlay("play");
					}
					break;
				case 1:
					if (gem2.currentLabel != "visible")
					{
						gem2.gotoAndStop("visible");
					}
					
					if (gem1.currentLabel != "play")
					{
						gem1.gotoAndPlay("play");
						//trace("GFX - Updating life for Player: " + "GEM 1 PLAY");
					}
					break;
				case 2:
					if (gem2.currentLabel != "visible")
					{
						gem2.gotoAndStop("visible");
					}
					
					if (gem1.currentLabel != "visible")
					{
						gem1.gotoAndStop("visible");
					}
					break;
				}
			}
		}
		
		protected var passedShown:Boolean = false;
		public function showPassed(shouldShow:Boolean):void
		{
			if (txtPassed)
			{
				txtPassed.visible = shouldShow;
			}
			
			if (mcPassed)
			{
				if (shouldShow)
				{
					if (!passedShown)
					{
						//#J Doing this here as the flow for passing is hacky (especially when considering auto passing when round start or no more cards)
						// Prefer putting this here because if its broken, will have visual clue, and fixing visual will also fix audio automatically
						GwintGameMenu.mSingleton.playSound("gui_gwint_turn_passed");
					}
					
					passedShown = true;
					mcPassed.gotoAndPlay("passed");
				}
				else
				{
					passedShown = false;
					mcPassed.gotoAndStop("Idle");
				}
			}
		}
		
		public function setIsWinning(isWinning:Boolean):void
		{
			if (mcWinningRound)
			{
				if (isWinning)
				{
					mcWinningRound.visible = true;
					mcWinningRound.play();
				}
				else
				{
					mcWinningRound.visible = false;
					mcWinningRound.stop();
				}
			}
		}
		
		public function reset():void
		{
			if (txtPassed)
			{
				txtPassed.text = "[[gwint_player_passed_element]]";
				txtPassed.visible = false;
			}
			
			score = 0;
			setPlayerLives(2);
			txtCardCount.text = "0";
		}
	}
}