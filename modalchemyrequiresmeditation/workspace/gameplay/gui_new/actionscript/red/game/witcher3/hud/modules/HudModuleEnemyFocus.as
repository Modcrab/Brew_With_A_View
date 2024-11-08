package red.game.witcher3.hud.modules
{
	import adobe.utils.CustomActions;
	import flash.display.MovieClip;
	import flash.events.TextEvent;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.hud.modules.HudModuleBase;
	import scaleform.clik.controls.StatusIndicator;
	import flashx.textLayout.formats.Float;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Exponential;
	import scaleform.clik.core.UIComponent;
	
	
	public class HudModuleEnemyFocus extends HudModuleBase
	{
		//>------------------------------------------------------------------------------------------------------------------
		// VARIABLES
		//-------------------------------------------------------------------------------------------------------------------
		public var mcNPCFocus				:	 MovieClip;
		public var m_attitude				:	 int;
		
		private var _tweenedTFList	: Vector.<TextField>;
		private var _freeTFList		: Vector.<TextField>;	
		private var _maxTF			: Number;

		// gameplay visibility
		var m_showEverythingExceptName : Boolean = false;
		var m_showName                 : Boolean = false;
		var m_isBossOrDead             : Boolean = false;

		private var m_repositionOnNameChange : Boolean = false;

		var m_visibleHealthBar     : Boolean = false;	// mcHealthBar.visible
		var m_visibleStaminaBar    : Boolean = false;	// mcStaminaBar.visible
		var m_visibleFocusLock     : Boolean = false;	// mcFocusLock.visible
		var m_visibleEnemyLevel    : Boolean = false;	// mcEnemyLevel.visible
		var m_visibleDodgeFeedback : Boolean = false;	// mcDodgeFeedback.visible
		var m_visibleName          : Boolean = false;	// tfName.visible
		

		public function HudModuleEnemyFocus()
		{
			super();
			m_attitude = 0;
		}

		override public function get moduleName():String
		{
			return "EnemyFocusModule";
		}
		
		override protected function configUI():void
		{
			super.configUI();
			alpha = 0;
			
			setEssenceBarVisibility( false, true );
			displayMutationEight( false );

			// managed from WS
			mcNPCFocus.visible = false;
			
			
			//(mcNPCFocus.mcStaminaDelay as UIComponent).setActualScale(1.76, 1.09);
			
			mcNPCFocus.mcStaminaDelay.minimum = 0;
			mcNPCFocus.mcStaminaDelay.maximum = 100;
			//mcNPCFocus.mcStaminaDelay.value   = 33;
			
			
			_tweenedTFList = new Vector.<TextField>;
			_freeTFList = new Vector.<TextField>;			
			_maxTF = 5;
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}
		
		
		public function displayMutationEight( value:Boolean ) :void
		{	
			var feedback : MovieClip = mcNPCFocus.mcMutation8Feedback;
			if (feedback)
			{
				feedback.visible = value;
			}
		}

		public function setEnemyName( _Name:String )
		{
			mcNPCFocus.tfName.text = _Name;

			if (m_repositionOnNameChange)
			{
				mcNPCFocus.mcCharacterIcon.x = mcNPCFocus.tfName.x + (mcNPCFocus.tfName.width / 2) - (mcNPCFocus.tfName.textWidth / 2);
			}
		}
		
		public function setEnemyHealth( _Percentage:int )
		{
			mcNPCFocus.mcHealthBar.value = _Percentage;
		}

		var staminaTween : GTween;
		public function setEnemyStamina( _Percentage:int)
		{
			var oldStaminaPercent : int = mcNPCFocus.mcStaminaBar.value;
			
			mcNPCFocus.mcStaminaBar.value = _Percentage;
			if ( oldStaminaPercent > _Percentage )
			{
				mcNPCFocus.mcStaminaDelay.value = oldStaminaPercent;
				GTweener.removeTweens( mcNPCFocus.mcStaminaDelay );
				staminaTween = GTweener.to( mcNPCFocus.mcStaminaDelay, 1,  { value: _Percentage }, { onComplete:handleStaminaTweenCompleted } );
			}
			else
			{
				if ( !staminaTween )
				{
					//mcNPCFocus.mcStaminaDelay.value = _Percentage;
				}
			}
		}
		
		private function handleStaminaTweenCompleted( curTween : GTween ) : void
		{
			staminaTween = null;
			GTweener.removeTweens( mcNPCFocus.mcStaminaDelay );
			mcNPCFocus.mcStaminaDelay.value == 0;
		}

		public function setAttitude( attitude : int )
		{
			m_attitude = attitude;

			var attitudeStr:String;
			
			if( attitude == 4 ) //#hack for vip
				attitudeStr = "vip";
			else
				attitudeStr = getFrameByAttitude();

			setVisibility( attitudeStr );
		}

		public function setDodgeFeedback(value:Boolean)//Shows the feedback for dodge,parry,counter
		{
			m_visibleDodgeFeedback = value;
			
			UpdateVisibilityOfDodgeFeedback();
		}

		public function SetBossOrDead( bossOrDead : Boolean )
		{
			m_isBossOrDead = bossOrDead;
			
			UpdateVisibilityOfHealthStaminaBars();
			UpdateVisibilityOfFocusLock();
			UpdateVisibilityOfEnemyLevel();
			UpdateVisibilityOfDodgeFeedback();
		}
		
		private function createDamageTextField() : TextField
		{
			var textField : TextField = new TextField();
			var textFormat : TextFormat = new TextFormat("$NormalFont", 24);

			textFormat.align = TextFormatAlign.CENTER;			
			textFormat.font = "$NormalFont";
			textField.embedFonts = true;
			textField.defaultTextFormat = textFormat;			
			textField.setTextFormat(textFormat);
			
			mcNPCFocus.addChild(textField);
			textField.x = 0; textField.y = 0;

			return textField;
		}
		
		private function getNextFreeTextField() : TextField
		{
			var textField : TextField;
			
			//trace("SD tweened size: " + _tweenedTFList.length);
			
			//if we have any tf's in our free pool, use the 1st one
			if ( _freeTFList.length > 0 )
			{
				//trace("SD returning a free TF ");
				return _freeTFList.pop();
			}
			else if ( _tweenedTFList.length < _maxTF )   //if we can still create tf's, make one!
			{
				//trace("SD returning a newly created TF");
				return createDamageTextField();
			}
			else //if we're over capacity, recycle (reuse oldest textField in the list)
			{
				//trace("SD returning a recycled TF");
				return _tweenedTFList.shift();
			}		
		}
		
		public function setDamageText(label:String, damageValue:Number, color:Number) : void
		{	
			var textField : TextField = getNextFreeTextField();
			
			if (textField.textColor != color)
			{
				textField.textColor = color;
			}
			
			if (damageValue == 0)
				textField.text = label;			
			else
				textField.text = label + " " + damageValue;
				
			textField.y = 0;
			textField.width = textField.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			textField.x = -textField.width / 2;
			textField.visible = true;
			
			//add the tf into the tweened list
			_tweenedTFList.push( textField );
			
			//tween upwards
			GTweener.removeTweens( textField );
			GTweener.to( textField, 1, { y: -50 }, { ease: Exponential.easeOut, onComplete:handleTweenCompleted } );		
		}
		
		private function handleTweenCompleted( curTween : GTween ) : void
		{
			var textField : TextField = curTween.target as TextField;

			textField.visible = false;
			GTweener.removeTweens( textField );
			
			//remove the tf from the tweened list and put it back into the free pool
			_tweenedTFList.splice( _tweenedTFList.indexOf(textField), 1 );
			_freeTFList.push( textField );
		}
		
		
		public function hideDamageText():void
		{
			trace("GFX >>>>>>>>>>>>  HIDE DAMAGE TEXT");
			mcNPCFocus.mcDamageTextAnim.visible = false;
		}
		

		public function setStaminaVisibility(value:Boolean)
		{
			if ( m_attitude != 2 )
			{
				m_visibleStaminaBar = false;
			}
			else
			{
				m_visibleStaminaBar = value;
			}
			UpdateVisibilityOfHealthStaminaBars();
		}

		public function setVisibility(attitude:String)
		{
			m_visibleName = true;

			switch (attitude)
			{
				case "enemy":
					mcNPCFocus.tfName.textColor = 0xFF0000;//Red
					m_visibleHealthBar  = true;
					m_visibleStaminaBar = true;
					break;

				case "neutral":
					mcNPCFocus.tfName.textColor = 0X79B8FD;//Blue
					m_visibleHealthBar  = false;
					m_visibleStaminaBar = false;
					break;

				case "friendly":
					mcNPCFocus.tfName.textColor = 0xd3a37d;//Gold White
					m_visibleHealthBar  = false;
					m_visibleStaminaBar = false;
					break;

				case "axii":
					mcNPCFocus.tfName.textColor = 0xFCB549;//Orange
					m_visibleHealthBar  = true;
					m_visibleStaminaBar = true;
					break;
				
				case "vip":
					mcNPCFocus.tfName.textColor = 0x5aff00;//Green
					m_visibleHealthBar  = false;
					m_visibleStaminaBar = false;
					break;				
			}
			
			UpdateVisibilityOfHealthStaminaBars();
			UpdateVisibilityOfName();
		}

		private var m_lastEssenceVisibility : Boolean = false;

		public function setEssenceBarVisibility( essenceVisibility : Boolean, force : Boolean = false )
		{
			if ( !force )
			{
				if ( m_lastEssenceVisibility == essenceVisibility )
				{
					return;
				}
			}
			
			m_lastEssenceVisibility = essenceVisibility;

			if ( essenceVisibility )
			{
				mcNPCFocus.mcHealthBar.mcHealthBar.visible = false;
				mcNPCFocus.mcHealthBar.mcEssenceBar.visible = true;
			}
			else
			{
				mcNPCFocus.mcHealthBar.mcHealthBar.visible = true;
				mcNPCFocus.mcHealthBar.mcEssenceBar.visible = false;
			}
		}

		public function getFrameByAttitude() : String
		{
			switch ( m_attitude )
			{
				case 0:
					return "neutral";
				case 1:
					return "friendly";
				case 2:
					return "enemy";
				case 3:
					return "axii";
			}
			return "friendly";
		}
		override public function SetScaleFromWS( scale : Number ) : void
		{
		}

		public function setShowHardLock( value : Boolean )
		{
			m_visibleFocusLock = value;
			
			UpdateVisibilityOfFocusLock();
		}

		private var m_lastNPCQuestIcon : String;
		
		public function setNPCQuestIcon( value : String )
		{
			if ( m_lastNPCQuestIcon != value )
			{
				m_lastNPCQuestIcon = value;
				if ( mcNPCFocus.tfName )
				{
					mcNPCFocus.mcCharacterIcon.gotoAndStop(value);
					mcNPCFocus.mcCharacterIcon.x = mcNPCFocus.tfName.x + (mcNPCFocus.tfName.width / 2) - (mcNPCFocus.tfName.textWidth / 2);
				}
			}

			m_repositionOnNameChange = value != "none";
		}

		private var m_lastEnemyLevelDifference : String;
		private var m_lastEnemyLevelString : String;
		
		public function setEnemyLevel( value : String, text : String )
		{
			m_visibleEnemyLevel = true;
			UpdateVisibilityOfEnemyLevel();
			
			if ( m_lastEnemyLevelDifference != value )
			{
				m_lastEnemyLevelDifference = value;
				mcNPCFocus.mcEnemyLevel.gotoAndStop(value);
				if ( value == "none" || value == "deadlyLevel" )
				{
					mcNPCFocus.mcEnemyLevel.textField.alpha = 0;
				}
				else
				{
					mcNPCFocus.mcEnemyLevel.textField.alpha = 1;
				}
			}
			
			if ( m_lastEnemyLevelString != text )
			{
				m_lastEnemyLevelString = text;
				mcNPCFocus.mcEnemyLevel.textField.htmlText = text;
			}
		}
		
		private function UpdateVisibilityOfHealthStaminaBars()
		{
			mcNPCFocus.mcHealthBar.visible     = ( m_showEverythingExceptName && !m_isBossOrDead && m_visibleHealthBar );
			mcNPCFocus.mcStaminaBar.visible    = ( m_showEverythingExceptName && !m_isBossOrDead && m_visibleStaminaBar );
			mcNPCFocus.mcStaminaDelay.visible    = ( m_showEverythingExceptName && !m_isBossOrDead && m_visibleStaminaBar );
		}
		
		private function UpdateVisibilityOfFocusLock()
		{
			mcNPCFocus.mcFocusLock.visible     = ( m_showEverythingExceptName && !m_isBossOrDead && m_visibleFocusLock );
		}
		
		private function UpdateVisibilityOfEnemyLevel()
		{
			mcNPCFocus.mcEnemyLevel.visible    = ( m_showEverythingExceptName && !m_isBossOrDead && m_visibleEnemyLevel );
		}
		
		private function UpdateVisibilityOfDodgeFeedback()
		{
			mcNPCFocus.mcDodgeFeedback.visible = ( m_showEverythingExceptName && !m_isBossOrDead && m_visibleDodgeFeedback );
		}
		
		private function UpdateVisibilityOfName()
		{
			mcNPCFocus.mcCharacterIcon.visible = ( m_showName && m_visibleName );
			mcNPCFocus.tfName.visible          = ( m_showName && m_visibleName );
		}

		public function SetGeneralVisibility( showEverythingExceptName : Boolean, showName : Boolean )
		{
			m_showEverythingExceptName = showEverythingExceptName;
			m_showName                 = showName;
			
			UpdateVisibilityOfHealthStaminaBars();
			UpdateVisibilityOfFocusLock();
			UpdateVisibilityOfEnemyLevel();
			UpdateVisibilityOfDodgeFeedback();
			UpdateVisibilityOfName();
		}
	}
}
