package red.game.witcher3.menus.gwint
{
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import scaleform.clik.core.UIComponent;
	import flash.utils.getDefinitionByName;
	
	public class CardFXManager extends UIComponent
	{
		protected static var _instance:CardFXManager;
		public static function getInstance():CardFXManager
		{
			return _instance;
		}
		
		private var effectDictionary:Dictionary = new Dictionary();
		private var numEffectsPlaying:int = 0;
		
		private var weatherParent:MovieClip;
		
		override protected function configUI():void 
		{
			super.configUI();
			_instance = this;
			
			mouseEnabled = false;
			mouseChildren = false;
			
			setupWeatherEffects();
		}
		
		public var activeFXDictionary:Dictionary = new Dictionary();
		
		private static var _instanceIDGenerator:int = 0;
		public function playCardDeployFX(cardInstance:CardInstance, finishedCallback:Function):void
		{
			var fxClass:Class;
			
			if (cardInstance.playSummonedFX)
			{
				fxClass = _summonClonesArriveFXClassRef;
				cardInstance.playSummonedFX = false;
				if (cardInstance.templateRef.isType(CardTemplate.CardType_Siege))
				{
					GwintGameMenu.mSingleton.playSound("gui_gwint_siege_weapon");
				}
				else if (cardInstance.templateRef.isType(CardTemplate.CardType_Ranged))
				{
					GwintGameMenu.mSingleton.playSound("gui_gwint_long_range");
				}
				else if (cardInstance.templateRef.isType(CardTemplate.CardType_Melee))
				{
					GwintGameMenu.mSingleton.playSound("gui_gwint_close_combat");
				}
			}
			else
			{
				fxClass = getDeployFX(cardInstance);
			}
			
			if (fxClass)
			{
				spawnFX(cardInstance, finishedCallback, fxClass);
			}
			else
			{
				finishedCallback(cardInstance);
				trace("GFX ---- [WARNING] ---- CardFXManager tried to play Card Deploy FX with no matching fxClass: " + cardInstance.toString());
			}
		}
		
		public function playerCardEffectFX(cardInstance:CardInstance, finishedCallback:Function):CardFX
		{
			var fxClass:Class = getEffectFX(cardInstance.templateRef);
			var spawnedFX:CardFX;
			
			if (fxClass)
			{
				spawnedFX = spawnFX(cardInstance, finishedCallback, fxClass);
				return spawnedFX;
			}
			else
			{
				finishedCallback(cardInstance);
				trace("GFX ---- [WARNING] ---- CardFXManager tried to play Card Effect FX with no matching fxClass: " + cardInstance.toString());
			}
			
			return null;
		}
		
		public function playRessurectEffectFX(cardInstance:CardInstance, finishedCallback:Function):void
		{
			if (_resurrectFXClassRef)
			{
				spawnFX(cardInstance, finishedCallback, _resurrectFXClassRef);
			}
			else
			{
				finishedCallback(cardInstance);
				trace("GFX ---- [WARNING] ---- CardFXManager tried to play Card Resurrect FX with no matching fxClass: " + cardInstance.toString());
			}
		}
		
		public function playScorchEffectFX(cardInstance:CardInstance, finishedCallback:Function):void
		{
			if (_scorchFXClassRef)
			{
				spawnFX(cardInstance, finishedCallback, _scorchFXClassRef);
			}
			else
			{
				trace("GFX ---- [WARNING] ---- CardFXManager tried to play Card Scorch FX with no matching fxClass: " + cardInstance.toString());
				finishedCallback(cardInstance);
			}
		}
		
		public function playTightBondsFX(cardInstance:CardInstance, finishedCallback:Function):void
		{
			if (_tightBondsFXClassRef)
			{
				spawnFX(cardInstance, finishedCallback, _tightBondsFXClassRef);
			}
			else
			{
				trace("GFX ---- [WARNING] ---- CardFXManager tried to play Tight Bonds FX with no matching fxClass: " + cardInstance.toString());
				finishedCallback(cardInstance);
			}
		}
		
		public function spawnFX_Location(xLocation:int, yLocation:int, targetClass:Class):void
		{
			var newInstanceID:int = ++_instanceIDGenerator;
			var newCardFX:CardFX = new targetClass();
			newCardFX.associatedCardInstance = null;
			newCardFX.instanceID = newInstanceID;
			newCardFX.cardFXManagerFinishCallback = finishedFXCallback;
			this.addChild(newCardFX);
			this.addChild(weatherParent); // Force weather back above the newly spawned fx
			newCardFX.x = xLocation;
			newCardFX.y = yLocation;
			newCardFX.play();
			++numEffectsPlaying;
		}
		
		public function spawnFX(cardInstance:CardInstance, finishedCallback:Function, targetClass:Class):CardFX
		{
			var newInstanceID:int = ++_instanceIDGenerator;
			var newCardFX:CardFX = new targetClass();
			newCardFX.associatedCardInstance = cardInstance;
			newCardFX.instanceID = newInstanceID;
			newCardFX.finalFinishCallback = finishedCallback;
			newCardFX.cardFXManagerFinishCallback = finishedFXCallback;
			this.addChild(newCardFX);
			this.addChild(weatherParent); // Force weather back above the newly spawned fx
			if (cardInstance != null && !cardInstance.templateRef.isType(CardTemplate.CardType_Weather))
			{
				var cardSlot:CardSlot = CardManager.getInstance().boardRenderer.getCardSlotById(cardInstance.instanceId);
				if (cardSlot)
				{
					newCardFX.x = cardSlot.x;
					newCardFX.y = cardSlot.y;
				}
			}
			else
			{
				newCardFX.x = 0;
				newCardFX.y = 0;
			}
			newCardFX.play();
			++numEffectsPlaying;
			
			return newCardFX;
		}
		
		protected function finishedFXCallback(cardFX:CardFX):void
		{
			if (cardFX.finalFinishCallback != null)
			{
				cardFX.finalFinishCallback(cardFX.associatedCardInstance);
			}
			
			removeChild(cardFX);
			--numEffectsPlaying;
			effectDictionary[cardFX.instanceID] = null;
		}
		
		public function isPlayingAnyCardFX():Boolean
		{
			return numEffectsPlaying > 0;
		}
		
		public function playRowEffect(slotID:int, playerID:int, targetClass:Class):CardFX
		{
			var newCardFX:CardFX = new targetClass();
			var yPos : Number;
			
			if (newCardFX)
			{
				newCardFX.cardFXManagerFinishCallback = finishedFXCallback;
				this.addChild(newCardFX);
				this.addChild(weatherParent); // Force weather back above the newly spawned fx
				
				if (playerID == CardManager.PLAYER_1)
				{
					switch (slotID)
					{
					case CardManager.CARD_LIST_LOC_SEIGE:
					case CardManager.CARD_LIST_LOC_SEIGEMODIFIERS:
						yPos = _seigePlayerRowEffectY;
						break;
					case CardManager.CARD_LIST_LOC_RANGED:
					case CardManager.CARD_LIST_LOC_RANGEDMODIFIERS:
						yPos = _rangedPlayerRowEffectY;
						break;
					case CardManager.CARD_LIST_LOC_MELEE:
					case CardManager.CARD_LIST_LOC_MELEEMODIFIERS:
						yPos = _meleePlayerRowEffectY;
						break;
					}
				}
				else if (playerID == CardManager.PLAYER_2)
				{
					switch (slotID)
					{
					case CardManager.CARD_LIST_LOC_SEIGE:
					case CardManager.CARD_LIST_LOC_SEIGEMODIFIERS:
						yPos = _seigeEnemyRowEffectY;
						break;
					case CardManager.CARD_LIST_LOC_RANGED:
					case CardManager.CARD_LIST_LOC_RANGEDMODIFIERS:
						yPos = _rangedEnemyRowEffectY;
						break;
					case CardManager.CARD_LIST_LOC_MELEE:
					case CardManager.CARD_LIST_LOC_MELEEMODIFIERS:
						yPos = _meleeEnemyRowEffectY;
						break;
					}
				}
				
				newCardFX.x = _rowEffectX;
				newCardFX.y = yPos;
				
				newCardFX.play();
				++numEffectsPlaying;
			}
			
			return newCardFX;
		}
		
		private var weatherMeleeOngoing_Active:Boolean = false;
		private var weatherRangedOngoing_Active:Boolean = false;
		private var weatherSeigeOngoing_Active:Boolean = false;
		
		public var weatherMeleeP1Ongoing:MovieClip;
		public var weatherMeleeP2Ongoing:MovieClip;
		public var weatherRangedP1Ongoing:MovieClip;
		public var weatherRangedP2Ongoing:MovieClip;
		public var weatherSeigeP1Ongoing:MovieClip;
		public var weatherSeigeP2Ongoing:MovieClip;
		
		protected var hidingWeatherMeleeTimer:Timer;
		protected var hidingWeatherRangedTimer:Timer;
		protected var hidingWeatherSiegeTimer:Timer;
		
		protected function setupWeatherEffects():void
		{
			weatherParent = new MovieClip();
			this.addChild(weatherParent);
			
			weatherParent.addChild(weatherMeleeP1Ongoing);
			weatherParent.addChild(weatherMeleeP2Ongoing);
			weatherParent.addChild(weatherRangedP1Ongoing);
			weatherParent.addChild(weatherRangedP2Ongoing);
			weatherParent.addChild(weatherSeigeP1Ongoing);
			weatherParent.addChild(weatherSeigeP2Ongoing);
		}
		
		public function ShowWeatherOngoing(slotID:int, value:Boolean):void
		{
			trace("GFX -------------------------------------------------------===================================");
			trace("GFX - ShowWeatherOngoing called for slot: " + slotID + ", with value: " + value);
			
			
			if (slotID == CardManager.CARD_LIST_LOC_MELEE)
			{
				if (value)
				{
					if (hidingWeatherMeleeTimer)
					{
						hidingWeatherMeleeTimer.stop();
						hidingWeatherMeleeTimer = null;
					}
					
					if (!weatherMeleeOngoing_Active)
					{
						trace("GFX - calling gotoAndPlay(start)");
						weatherMeleeOngoing_Active = true;
						weatherMeleeP1Ongoing.gotoAndPlay("start");
						weatherMeleeP2Ongoing.gotoAndPlay("start");
					}
				}
				else
				{
					if (!hidingWeatherMeleeTimer && weatherMeleeOngoing_Active)
					{
						trace("GFX - starting stop timer");
						hidingWeatherMeleeTimer = new Timer(300, 1);
						hidingWeatherMeleeTimer.addEventListener( TimerEvent.TIMER, hiddingMeleeWeatherTimerEnded, false, 0, true );
						hidingWeatherMeleeTimer.start();
					}
				}
			}
			else if (slotID == CardManager.CARD_LIST_LOC_RANGED)
			{
				if (value)
				{
					if (hidingWeatherRangedTimer)
					{
						hidingWeatherRangedTimer.stop();
						hidingWeatherRangedTimer = null;
					}
					
					if (!weatherRangedOngoing_Active)
					{
						weatherRangedOngoing_Active = true;
						trace("GFX - calling gotoAndPlay(start)");
						weatherRangedP1Ongoing.gotoAndPlay("start");
						weatherRangedP2Ongoing.gotoAndPlay("start");
					}
				}
				else
				{
					if (!hidingWeatherRangedTimer && weatherRangedOngoing_Active)
					{
						trace("GFX - starting stop timer");
						hidingWeatherRangedTimer = new Timer(300, 1);
						hidingWeatherRangedTimer.addEventListener( TimerEvent.TIMER, hiddingRangeWeatherTimerEnded, false, 0, true );
						hidingWeatherRangedTimer.start();
					}
				}
			}
			else if (slotID == CardManager.CARD_LIST_LOC_SEIGE)
			{
				if (value)
				{
					if (hidingWeatherSiegeTimer)
					{
						hidingWeatherSiegeTimer.stop();
						hidingWeatherSiegeTimer = null;
					}
					
					if (!weatherSeigeOngoing_Active)
					{
						weatherSeigeOngoing_Active = true;
						trace("GFX - calling gotoAndPlay(start)");
						weatherSeigeP1Ongoing.gotoAndPlay("start");
						weatherSeigeP2Ongoing.gotoAndPlay("start");
					}
				}
				else
				{
					if (!hidingWeatherSiegeTimer && weatherSeigeOngoing_Active)
					{
						trace("GFX - starting stop timer");
						hidingWeatherSiegeTimer = new Timer(300, 1);
						hidingWeatherSiegeTimer.addEventListener( TimerEvent.TIMER, hiddingSiegeWeatherTimerEnded, false, 0, true );
						hidingWeatherSiegeTimer.start();
					}
				}
			}
			
			trace("GFX ===================================-------------------------------------------------------");
		}
		
		public function hiddingMeleeWeatherTimerEnded( event : TimerEvent )
		{
			if (weatherMeleeOngoing_Active)
			{
				weatherMeleeOngoing_Active = false;
				weatherMeleeP1Ongoing.gotoAndPlay("ending");
				weatherMeleeP2Ongoing.gotoAndPlay("ending");
				trace("GFX - calling gotoAndPlay(ending) - Melee");
				
				hidingWeatherMeleeTimer.stop();
				hidingWeatherMeleeTimer = null;
			}
		}
		
		public function hiddingRangeWeatherTimerEnded( event : TimerEvent )
		{
			if (weatherRangedOngoing_Active)
			{
				weatherRangedOngoing_Active = false;
				weatherRangedP1Ongoing.gotoAndPlay("ending");
				weatherRangedP2Ongoing.gotoAndPlay("ending");
				trace("GFX - calling gotoAndPlay(ending) - Ranged");
				
				hidingWeatherRangedTimer.stop();
				hidingWeatherRangedTimer = null;
			}
		}
		
		public function hiddingSiegeWeatherTimerEnded( event : TimerEvent )
		{
			if (weatherSeigeOngoing_Active)
			{
				weatherSeigeOngoing_Active = false;
				weatherSeigeP1Ongoing.gotoAndPlay("ending");
				weatherSeigeP2Ongoing.gotoAndPlay("ending");
				trace("GFX - calling gotoAndPlay(ending) - Siege");
				
				hidingWeatherSiegeTimer.stop();
				hidingWeatherSiegeTimer = null;
			}
		}
		
		protected var _frostFXName:String;
		public var _frostFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get frostFXName() : String	{ return _frostFXName }
		public function set frostFXName( value : String ) : void
		{
			if (_frostFXName != value)
			{
				_frostFXName = value;
				try
				{
					_frostFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _fogFXName:String;
		public var _fogFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get fogFXName() : String	{ return _fogFXName }
		public function set fogFXName( value : String ) : void
		{
			if (_fogFXName != value)
			{
				_fogFXName = value;
				try
				{
					_fogFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _rainFXName:String;
		public var _rainFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get rainFXName() : String	{ return _rainFXName }
		public function set rainFXName( value : String ) : void
		{
			if (_rainFXName != value)
			{
				_rainFXName = value;
				try
				{
					_rainFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _clearWeatherFXName:String;
		public var _clearWeatherFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get clearWeatherFXName() : String	{ return _clearWeatherFXName }
		public function set clearWeatherFXName( value : String ) : void
		{
			if (_clearWeatherFXName != value)
			{
				_clearWeatherFXName = value;
				try
				{
					_clearWeatherFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _hornFXName:String;
		public var _hornFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get hornFXName() : String	{ return _hornFXName }
		public function set hornFXName( value : String ) : void
		{
			if (_hornFXName != value)
			{
				_hornFXName = value;
				try
				{
					_hornFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _scorchFXName:String;
		public var _scorchFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get scorchFXName() : String	{ return _scorchFXName }
		public function set scorchFXName( value : String ) : void
		{
			if (_scorchFXName != value)
			{
				_scorchFXName = value;
				try
				{
					_scorchFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _dummyFXName:String;
		public var _dummyFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get dummyFXName() : String	{ return _dummyFXName }
		public function set dummyFXName( value : String ) : void
		{
			if (_dummyFXName != value)
			{
				_dummyFXName = value;
				try
				{
					_dummyFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _placeMeleeFXName:String;
		public var _placeMeleeFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get placeMeleeFXName() : String	{ return _placeMeleeFXName }
		public function set placeMeleeFXName( value : String ) : void
		{
			if (_placeMeleeFXName != value)
			{
				_placeMeleeFXName = value;
				try
				{
					_placeMeleeFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _placeRangedFXName:String;
		public var _placeRangedFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get placeRangedFXName() : String	{ return _placeRangedFXName }
		public function set placeRangedFXName( value : String ) : void
		{
			if (_placeRangedFXName != value)
			{
				_placeRangedFXName = value;
				try
				{
					_placeRangedFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _placeSeigeFXName:String;
		public var _placeSeigeFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get placeSeigeFXName() : String	{ return _placeSeigeFXName }
		public function set placeSeigeFXName( value : String ) : void
		{
			if (_placeSeigeFXName != value)
			{
				_placeSeigeFXName = value;
				try
				{
					_placeSeigeFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _placeSpyFXName:String;
		public var _placeSpyFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get placeSpyFXName() : String	{ return _placeSpyFXName }
		public function set placeSpyFXName( value : String ) : void
		{
			if (_placeSpyFXName != value)
			{
				_placeSpyFXName = value;
				try
				{
					_placeSpyFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}

		protected var _placeFiendFXName:String;
		public var _placeFiendFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get placeFiendFXName() : String	{ return _placeFiendFXName }
		public function set placeFiendFXName( value : String ) : void
		{
			if (_placeFiendFXName != value)
			{
				_placeFiendFXName = value;
				try
				{
					_placeFiendFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _placeHeroFXName:String;
		public var _placeHeroFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get placeHeroFXName() : String	{ return _placeHeroFXName }
		public function set placeHeroFXName( value : String ) : void
		{
			if (_placeHeroFXName != value)
			{
				_placeHeroFXName = value;
				try
				{
					_placeHeroFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _resurrectFXName:String;
		public var _resurrectFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get resurrectFXName() : String	{ return _resurrectFXName }
		public function set resurrectFXName( value : String ) : void
		{
			if (_resurrectFXName != value)
			{
				_resurrectFXName = value;
				try
				{
					_resurrectFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _summonClonesFXName:String;
		public var _summonClonesFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get summonClonesFXName() : String	{ return _summonClonesFXName }
		public function set summonClonesFXName( value : String ) : void
		{
			if (_summonClonesFXName != value)
			{
				_summonClonesFXName = value;
				try
				{
					_summonClonesFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _moraleBoostFXName:String;
		public var _moraleBoostFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get moraleBoostFXName() : String	{ return _moraleBoostFXName }
		public function set moraleBoostFXName( value : String ) : void
		{
			if (_moraleBoostFXName != value)
			{
				_moraleBoostFXName = value;
				try
				{
					_moraleBoostFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _tightBondsFXName:String;
		public var _tightBondsFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get tightBondsFXName() : String	{ return _tightBondsFXName }
		public function set tightBondsFXName( value : String ) : void
		{
			if (_tightBondsFXName != value)
			{
				_tightBondsFXName = value;
				try
				{
					_tightBondsFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _summonClonesArriveFX:String;
		public var _summonClonesArriveFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get summonClonesArriveFXName() : String	{ return _summonClonesArriveFX }
		public function set summonClonesArriveFXName( value : String ) : void
		{
			if (_summonClonesArriveFX != value)
			{
				_summonClonesArriveFX = value;
				try
				{
					_summonClonesArriveFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _hornRowFXName:String;
		public var _hornRowFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get hornRowFXName() : String	{ return _hornRowFXName }
		public function set hornRowFXName( value : String ) : void
		{
			if (_hornRowFXName != value)
			{
				_hornRowFXName = value;
				try
				{
					_hornRowFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _mushroomRowFXName:String;
		public var _mushroomFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get mushroomFXName() : String	{ return _mushroomRowFXName }
		public function set mushroomFXName( value : String ) : void
		{
			if (_mushroomRowFXName != value)
			{
				_mushroomRowFXName = value;
				try
				{
					_mushroomFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _morphRowFXName:String;
		public var _morphFXClassRef:Class;
		[Inspectable(defaultValue="")]
		public function get morphFXName() : String	{ return _morphRowFXName }
		public function set morphFXName( value : String ) : void
		{
			if (_morphRowFXName != value)
			{
				_morphRowFXName = value;
				try
				{
					_morphFXClassRef = getDefinitionByName( value ) as Class;
				}
				catch (er:Error)
				{
					trace("GFX Can't find class definition in your library for " + value );
				}
			}
		}
		
		protected var _rowEffectX:Number;
		[Inspectable(defaultValue = 0)]
		public function get rowEffectX() : Number	{ return _rowEffectX; }
		public function set rowEffectX( value : Number ) : void
		{
			_rowEffectX = value;
		}
		
		protected var _seigeEnemyRowEffectY:Number;
		[Inspectable(defaultValue = 0)]
		public function get seigeEnemyRowEffectY() : Number	{ return _seigeEnemyRowEffectY; }
		public function set seigeEnemyRowEffectY( value : Number ) : void
		{
			_seigeEnemyRowEffectY = value;
		}
		
		protected var _rangedEnemyRowEffectY:Number;
		[Inspectable(defaultValue = 0)]
		public function get rangedEnemyRowEffectY() : Number	{ return _rangedEnemyRowEffectY; }
		public function set rangedEnemyRowEffectY( value : Number ) : void
		{
			_rangedEnemyRowEffectY = value;
		}
		
		protected var _meleeEnemyRowEffectY:Number;
		[Inspectable(defaultValue = 0)]
		public function get meleeEnemyRowEffectY() : Number	{ return _meleeEnemyRowEffectY; }
		public function set meleeEnemyRowEffectY( value : Number ) : void
		{
			_meleeEnemyRowEffectY = value;
		}
		
		protected var _meleePlayerRowEffectY:Number;
		[Inspectable(defaultValue = 0)]
		public function get meleePlayerRowEffectY() : Number	{ return _meleePlayerRowEffectY; }
		public function set meleePlayerRowEffectY( value : Number ) : void
		{
			_meleePlayerRowEffectY = value;
		}
		
		protected var _rangedPlayerRowEffectY:Number;
		[Inspectable(defaultValue = 0)]
		public function get rangedPlayerRowEffectY() : Number	{ return _rangedPlayerRowEffectY; }
		public function set rangedPlayerRowEffectY( value : Number ) : void
		{
			_rangedPlayerRowEffectY = value;
		}
		
		protected var _seigePlayerRowEffectY:Number;
		[Inspectable(defaultValue = 0)]
		public function get seigePlayerRowEffectY() : Number	{ return _seigePlayerRowEffectY; }
		public function set seigePlayerRowEffectY( value : Number ) : void
		{
			_seigePlayerRowEffectY = value;
		}
		
		protected function getDeployFX(cardInstance:CardInstance) : Class
		{
			var templateRef:CardTemplate = cardInstance.templateRef;
			if (templateRef.isType(CardTemplate.CardType_Hero))
			{
				GwintGameMenu.mSingleton.playSound("gui_gwint_hero");
				return _placeHeroFXClassRef;
			}
			else if (templateRef.isType(CardTemplate.CardType_Spy))
			{
				GwintGameMenu.mSingleton.playSound("gui_gwint_spy");
				return _placeSpyFXClassRef;
			}
			else if (templateRef.isType(CardTemplate.CardType_RangedMelee))
			{
				switch (cardInstance.inList)
				{
					case CardManager.CARD_LIST_LOC_MELEE:
						GwintGameMenu.mSingleton.playSound("gui_gwint_close_combat");
						break;
					case CardManager.CARD_LIST_LOC_RANGED:
						GwintGameMenu.mSingleton.playSound("gui_gwint_long_range");
						break;
				}
				
				// #J currently assuming melee and ranged sfx are the same. if that changes, might have to change this
				return _placeRangedFXClassRef; 
			}
			else if (templateRef.isType(CardTemplate.CardType_Siege))
			{
				GwintGameMenu.mSingleton.playSound("gui_gwint_siege_weapon");
				return _placeSeigeFXClassRef;
			}
			else if (templateRef.isType(CardTemplate.CardType_Ranged))
			{
				GwintGameMenu.mSingleton.playSound("gui_gwint_long_range");
				return _placeRangedFXClassRef;
			}
			else if (templateRef.isType(CardTemplate.CardType_Melee))
			{
				GwintGameMenu.mSingleton.playSound("gui_gwint_close_combat");
				return _placeMeleeFXClassRef;
			}
			else if (templateRef.isType(CardTemplate.CardType_Weather))
			{
				if (templateRef.hasEffect(CardTemplate.CardEffect_Ranged) && templateRef.hasEffect(CardTemplate.CardEffect_Siege))
				{
					GwintGameMenu.mSingleton.playSound("gui_gwint_ske_tidal_wave");
					return _fogFXClassRef;
				}
				else if (templateRef.hasEffect(CardTemplate.CardEffect_Melee))
				{
					GwintGameMenu.mSingleton.playSound("gui_gwint_frost");
					return _frostFXClassRef;
				}
				else if (templateRef.hasEffect(CardTemplate.CardEffect_Ranged))
				{
					GwintGameMenu.mSingleton.playSound("gui_gwint_fog");
					return _fogFXClassRef;
				}
				else if (templateRef.hasEffect(CardTemplate.CardEffect_Siege))
				{
					GwintGameMenu.mSingleton.playSound("gui_gwint_rain");
					return _rainFXClassRef;
				}
				else if (templateRef.hasEffect(CardTemplate.CardEffect_ClearSky))
				{
					GwintGameMenu.mSingleton.playSound("gui_gwint_clear_weather");
					return _clearWeatherFXClassRef;
				}
			}
			else if (templateRef.isType(CardTemplate.CardType_Friendly_Effect))
			{
				if (templateRef.hasEffect(CardTemplate.CardEffect_UnsummonDummy))
				{
					GwintGameMenu.mSingleton.playSound("gui_gwint_draw_card");
					return _dummyFXClassRef;
				}
			}
			
			return null;
		}
		
		protected function getEffectFX(cardTemplate:CardTemplate) : Class
		{
			if (cardTemplate.hasEffect(CardTemplate.CardEffect_Horn))
			{
				GwintGameMenu.mSingleton.playSound("gui_gwint_horn");
				return _hornFXClassRef;
			}
			else if (cardTemplate.hasEffect(CardTemplate.CardEffect_Nurse))
			{
				GwintGameMenu.mSingleton.playSound("gui_gwint_resurrect");
				return _resurrectFXClassRef;
			}
			else if (cardTemplate.hasEffect(CardTemplate.CardEffect_SummonClones))
			{
				GwintGameMenu.mSingleton.playSound("gui_gwint_summon_clones");
				return _summonClonesFXClassRef;
			}
			else if (cardTemplate.hasEffect(CardTemplate.CardEffect_SameTypeMorale))
			{
				GwintGameMenu.mSingleton.playSound("gui_gwint_morale_boost");
				return _tightBondsFXClassRef;
			}
			else if (cardTemplate.hasEffect(CardTemplate.CardEffect_ImproveNeighbours))
			{
				GwintGameMenu.mSingleton.playSound("gui_gwint_morale_boost");
				return _moraleBoostFXClassRef;
			}
			else if (cardTemplate.hasEffect(CardTemplate.CardEffect_Morph))
			{
				if (cardTemplate.factionIdx == CardTemplate.FactionId_Skellige)
				{
					GwintGameMenu.mSingleton.playSound("gui_gwint_ske_berserker");
				}
				else
				{
					GwintGameMenu.mSingleton.playSound("gui_gwint_beserker");
				}
				return _morphFXClassRef;
			}
			
			return null;
		}
	}
}