package red.game.witcher3.menus.gwint
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.game.witcher3.controls.W3TextArea;
	import red.game.witcher3.controls.W3UILoaderSlot;
	import red.game.witcher3.interfaces.IInventorySlot;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.events.InputEvent;
	import scaleform.gfx.MouseEventEx;
	
	/**
	 * ...
	 * @author Jason Slama sept 2014
	 */

	public class CardSlot extends SlotBase implements IInventorySlot
	{
		// Events
		public static const CardMouseOver			:String = "CardMouseOver";
		public static const CardMouseOut			:String = "CardMouseOut";
		public static const CardMouseLeftClick		:String = "CardMouseLeftClick";
		public static const CardMouseRightClick		:String = "CardMouseRightClick";
		public static const CardMouseDoubleClick	:String = "CardMouseDoubleClick";
		
		// Card states
		public static const STATE_DECK:String = "deckBuilder";
		public static const STATE_BOARD:String = "Board";
		public static const STATE_CAROUSEL:String = "Carousel";
		
		public static const CARD_ORIGIN_HEIGHT:int = 584;
		public static const CARD_ORIGIN_WIDTH:int = 309;
		
		public static const CARD_BOARD_HEIGHT:int = 120;
		public static const CARD_BOARD_WIDTH:int = 90;
		
		public static const CARD_CAROUSEL_HEIGHT:int = 584;
		
		public static const TYPE_ICON_OFFSET_Y:int = 167.5;
		public static const TYPE_ICON_OFFSET_X:int = 68.5;
		public static const TYPE_ICON_BOARD_SCALE:Number = 0.36;
		public static const POWER_ICON_BOARD_SCALE:Number = 0.36;
		public static const FACTION_BANNER_OFFSET_X:int = 6;
		public static const FACTION_BANNER_OFFSET_Y:int = 17;
		public static const EFFECT_OFFSET_X:int = 43.5;
		public static const EFFECT_OFFSET_Y:int = 0;
		public static const BOARD_EFFECT_OFFSET_X:int = 0;
		public static const BOARD_EFFECT_OFFSET_Y:int = -18;
		public static const DESCRIPTION_WIDTH:int = 243;
		public static const DESCRIPTION_HEIGHT:int = 114;
		
		public static const BOARD_SELECTED_Y_OFFSET:int = -15;
		
		public static var g_neutral_cards:Vector.<CardSlot> = new Vector.<CardSlot>();
		public static var g_current_faction:int = CardTemplate.FactionId_Nilfgaard;
		
		protected function get adjCardHeight():int
		{
			if (_cardState == STATE_BOARD)
			{
				return CARD_BOARD_HEIGHT;
			}
			else if (_cardState == STATE_DECK)
			{
				return 355;
			}
			else if (_cardState == STATE_CAROUSEL)
			{
				return CARD_CAROUSEL_HEIGHT;
			}
			
			return CARD_ORIGIN_HEIGHT;
		}
		
		protected function get adjCardWidth():int
		{
			if (_cardState == STATE_BOARD)
			{
				return CARD_BOARD_WIDTH;
			}
			else if (_cardState == STATE_DECK)
			{
				return 188;
			}
			else if (_cardState == STATE_CAROUSEL)
			{
				return 309;
			}
			
			return CARD_ORIGIN_WIDTH;
		}
		
		public var mcHitBox:MovieClip; // used for mouse hit boxes as actual card movie clip size is not reliable
		public var mcCopyCount:MovieClip;
		public var mcLockedIcon:MovieClip;
		public var mcPowerIndicator:MovieClip;
		public var mcTypeIcon:MovieClip;
		// #J SORRY for confusion, partial refactor. mcTitle now contains the text and mcDesc contains the background
		// { --------------------------------------------------------------
		public var mcTitle:MovieClip;
		public var mcDesc:MovieClip;
		// } --------------------------------------------------------------
		public var mcFactionBanner:MovieClip;
		//public var mcCardBack:MovieClip;
		//public var mcRightShadow:MovieClip;
		//public var mcLeftShadow:MovieClip;
		
		public var mcEffectIcon1:MovieClip;
		
		public var mcSmallImageMask:MovieClip;
		public var mcSmallImageContainer:MovieClip;
		public var mcCardImageContainer:MovieClip;
		public var mcCardHighlight:MovieClip;
		
		protected var imageLoaded:Boolean = false;
		
		protected var cardElementHolder:MovieClip;
		
		private var _cardIndex:int;
		[Inspectable(defaultValue=-1)]
		public function get cardIndex():int { return _cardIndex; }
		public function set cardIndex(value:int):void
		{
			if (value != _cardIndex)
			{
				_cardIndex = value;
				
				if (_cardIndex != -1)
				{
					updateCardData();
				}
			}
		}
		
		private var _instanceId:int;
		[Inspectable(defaultValue=-1)]
		public function get instanceId():int { return _instanceId; }
		public function set instanceId(value:int):void
		{
			cardInstanceRef = null;
			_instanceId = value;
			if (_instanceId != -1)
			{
				_cardIndex = cardInstance.templateId;
				
				updateCardData();
			}
		}
		
		public function updateTemplate(cardTemplate:CardTemplate):void
		{
			setupCardWithTemplate(cardTemplate);
		}
		
		private var _cardState:String;
		[Inspectable(defaultValue="deckBuilder")]
		public function get cardState():String { return _cardState }
		public function set cardState(value:String):void
		{
			if (value && _cardState != value)
			{
				_cardState = value;
				updateCardSetup();
				updateSelectedVisual();
			}
		}
		
		// Buffered for optimization, makes changing the instance ID very problematic
		protected var cardInstanceRef:CardInstance = null;
		public function get cardInstance():CardInstance
		{
			if (_instanceId != -1 && cardInstanceRef == null)
			{
				cardInstanceRef = CardManager.getInstance().getCardInstance(instanceId);
			}
			
			return cardInstanceRef;
		}
		
		private var _activateEnabled:Boolean = true;
		public function get activateEnabled() : Boolean { return _activateEnabled; }
		public function set activateEnabled(value:Boolean):void
		{
			_activateEnabled = value;
			
			mcLockedIcon.visible = !_activateEnabled;
			
			// Costs too much
			/*if (_activateEnabled)
			{
				this.filters = [];
			}
			else
			{
				this.filters = [CommonUtils.generateGrayscaleFilter()];
			}*/
		}
		
		public function CardSlot()
		{
			super();
			_instanceId = -1;
			_cardIndex = -1;
			
			this.visible = false;
			
			_cardState = STATE_DECK;
			
			//if (mcRightShadow) { mcRightShadow.visible = false; }
			//if (mcLeftShadow) { mcLeftShadow.visible = false; }
			
			if (mcCardHighlight) 
			{
				mcCardHighlight.visible = false;
			}
			
			if (mcCopyCount)
			{
				mcCopyCount.visible = false;
			}
			
			if (mcLockedIcon)
			{
				mcLockedIcon.visible = false;
			}
		}
		
		override protected function configUI():void 
		{
			super.configUI();
			
			setupCardElementHolder();
			
			if (mcCardHighlight) 
			{
				_indicators.push(mcCardHighlight);
				mcCardHighlight.visible = false;				
				mcCardHighlight.mouseEnabled = false;
				mcCardHighlight.mouseChildren = false;
			}
			
			if (mcCopyCount)
			{
				var textField:TextField = mcCopyCount.getChildByName("mcCountText") as TextField;
					
				if (textField && data != null)
				{
					mcCopyCount.visible = true;
					textField.text = "x" + data.numCopies.toString();
				}
				else
				{
					mcCopyCount.visible = false;
				}
			}
			
			if (mcHitBox)
			{
				hitArea = mcHitBox; 
				mcHitBox.doubleClickEnabled = true;
				mcHitBox.addEventListener(MouseEvent.DOUBLE_CLICK, handleHitDoubleClick, false, 0, true);
				mcHitBox.addEventListener(MouseEvent.CLICK, handleHitClick, false, 0, true);
				mcHitBox.addEventListener(MouseEvent.MOUSE_OVER, handleHitMouseOver, false, 0, true);
				mcHitBox.addEventListener(MouseEvent.MOUSE_OUT, handleHitMouseOut, false, 0, true);
			}
		}
		
		override public function canDrag():Boolean
		{
			return false; // For now we don't have time to support card dragging
		}
		
		protected function setupCardElementHolder()
		{
			cardElementHolder = new MovieClip();
			this.addChild(cardElementHolder);
			if (mcHitBox)
			{
				this.addChild(mcHitBox);
				mcHitBox.x = 0;
				mcHitBox.y = 0;
			}
			
			cardElementHolder.x = 0;
			cardElementHolder.y = 0;
			
			//if (mcCardImageContainer) { cardElementHolder.addChild(mcCardImageContainer); }
			if (mcSmallImageContainer) { cardElementHolder.addChild(mcSmallImageContainer); }
			if (mcSmallImageMask) { cardElementHolder.addChild(mcSmallImageMask); }
			if (mcDesc) { cardElementHolder.addChild(mcDesc); }
			if (mcTitle) { cardElementHolder.addChild(mcTitle); }
			if (mcFactionBanner) { cardElementHolder.addChild(mcFactionBanner); }
			if (mcEffectIcon1) { cardElementHolder.addChild(mcEffectIcon1); }
			if (mcPowerIndicator) { cardElementHolder.addChild(mcPowerIndicator); }
			if (mcTypeIcon) { cardElementHolder.addChild(mcTypeIcon); }
			if (mcCopyCount) { cardElementHolder.addChild(mcCopyCount); }
			if (mcSlotOverlays) { cardElementHolder.addChild(mcSlotOverlays); }
			if (mcCardHighlight) { cardElementHolder.addChild(mcCardHighlight); }
			
			if ( mcSmallImageContainer && mcSmallImageMask)
			{
				mcSmallImageContainer.mask = mcSmallImageMask;
			}
		}
		
		override protected function updateData() 
		{
			//super.updateData();
			
			if (data)
			{
				cardIndex = data.cardID;
			}
		}
		
		override public function setData(value:Object):void 
		{ 
			super.setData(value);
			
			if (data != null)
			{
				trace("GFX - CardSlot setData called with cardID: " + data.cardID + ", and copy count: " + data.numCopies);
				cardIndex = data.cardID;
				
				if (mcCopyCount)
				{
					var textField:TextField = mcCopyCount.getChildByName("mcCountText") as TextField;
					
					if (textField)
					{
						mcCopyCount.visible = true;
						textField.text = "x" + data.numCopies.toString();
					}
				}
				else
				{
					mcCopyCount.visible = false;
				}
			}
		}
		
		public function setCardSource(instance:CardInstance)
		{
			instanceId = instance.instanceId;
		}
		
		protected function updateCardData():void
		{
			var cardManager:CardManager = CardManager.getInstance();
			
			if (_instanceId != -1)
			{
				var cardInstance:CardInstance = cardManager.getCardInstance(_instanceId);
				
				if (cardInstance)
				{
					// #J For now assumes the card template values are ok when first created
					setupCardWithTemplate(cardInstance.templateRef);
				}
				else
				{
					trace("GFX ---- [ERROR ] ---- tried to get card instance for id: " + _instanceId + ", but could not find it?!");
				}
			}
			else if (_cardIndex != -1)
			{
				if (cardManager.getCardTemplate(_cardIndex) != null)
				{
					setupCardWithTemplate(cardManager.getCardTemplate(_cardIndex));
				}
				else
				{
					cardManager.addEventListener(CardManager.cardTemplatesLoaded, onCardTemplatesLoaded, false, 0, true);
				}
			}
		}
		
		public function setCallbacksToCardInstance(cardInstance:CardInstance):void
		{
			cardInstance.powerChangeCallback = onCardPowerChanged;
		}
		
		public static function updateDefaultFaction(factionIdx:int):void
		{
			g_current_faction = factionIdx;
			
			var factionFrameName:String = CardTemplate.getFactionStringFromId(g_current_faction);
			
			for each (var curSlot:CardSlot in g_neutral_cards)
			{
				if (curSlot.mcFactionBanner)
				{
					curSlot.mcFactionBanner.gotoAndStop(factionFrameName);
				}
			}
		}
		
		protected function setupCardWithTemplate(cardTemplate:CardTemplate):void
		{
			trace("GFX - CardSlot setting card up with cardID: " + cardIndex + ", and template: " + cardTemplate);
			if (cardTemplate)
			{
				var typeString = cardTemplate.getTypeString();
				var childTextField:W3TextArea;
				
				loadIcon("icons/gwint/" + cardTemplate.imageLoc + ".png");
				
				if (mcPowerIndicator)
				{
					if (cardTemplate.index >= 1000) // leader
					{
						mcPowerIndicator.visible = false;
					}
					else
					{
						mcPowerIndicator.visible = true;
						if (!CommonUtils.hasFrameLabel(mcPowerIndicator, typeString))
						{
							mcPowerIndicator.gotoAndStop("Default");
						}
						else
						{
							mcPowerIndicator.gotoAndStop(typeString);
						}
						mcPowerIndicator.addEventListener(Event.ENTER_FRAME, onPowerEnteredFrame, false, 0, true);
						updateCardPowerText();
					}
				}
				
				if (mcTypeIcon)
				{
					var placementTypeString:String = cardTemplate.getPlacementTypeString();
					if (!CommonUtils.hasFrameLabel(mcTypeIcon, placementTypeString))
					{
						mcTypeIcon.gotoAndStop("None");
					}
					else
					{
						mcTypeIcon.gotoAndStop(placementTypeString);
					}
				}
				
				// #J SORRY for confusion, partial refactor. mcTitle now contains the text and mcDesc contains the background
				// { --------------------------------------------------------------
				if (mcTitle)
				{	
					var childTF:TextField;
					childTF = mcTitle.getChildByName("txtTitle") as TextField;
					if (childTF)
					{
						childTF.htmlText = cardTemplate.title;
					}
					
					childTF = mcTitle.getChildByName("txtDesc") as TextField;
					if (childTF)
					{
						childTF.htmlText = cardTemplate.description;
					}
				}
				
				if (mcDesc)
				{
					if (!CommonUtils.hasFrameLabel(mcDesc, typeString))
					{
						mcDesc.gotoAndStop("Default");
					}
					else
					{
						mcDesc.gotoAndStop(typeString);
					}
				}
				// } --------------------------------------------------------------
				
				if (mcFactionBanner)
				{
					if (cardTemplate.factionIdx == CardTemplate.FactionId_Neutral)
					{
						g_neutral_cards.push(this);
						
						if (_instanceId != -1)
						{
							var cardManager:CardManager = CardManager.getInstance();
							var cardInstance:CardInstance = cardManager.getCardInstance(_instanceId);
							
							if (cardInstance && cardManager)
							{
								mcFactionBanner.gotoAndStop(CardTemplate.getFactionStringFromId(cardManager.getSpawnedFaction(cardInstance)));
							}
						}
						else
						{
							mcFactionBanner.gotoAndStop(CardTemplate.getFactionStringFromId(g_current_faction));
						}
					}
					else
					{
						if (!CommonUtils.hasFrameLabel(mcFactionBanner, cardTemplate.getFactionString()))
						{
							mcFactionBanner.gotoAndStop("None");
						}
						else
						{
							mcFactionBanner.gotoAndStop(cardTemplate.getFactionString());
						}
					}
				}
				
				trace("GFX --- setting up card with effect: " + cardTemplate.getEffectString());
				
				if (mcEffectIcon1)
				{
					mcEffectIcon1.gotoAndStop(cardTemplate.getEffectString());
				}
				
				updateCardSetup();
			}
			else
			{
				throw new Error("GFX -- Tried to setup a card with an unknown template! --- ");
			}
		}
		
		protected function onPowerEnteredFrame(event:Event):void
		{
			updateCardPowerText();
			mcPowerIndicator.removeEventListener(Event.ENTER_FRAME, onPowerEnteredFrame);
		}
		
		protected function updateCardPowerText():void
		{
			var cardTemplate:CardTemplate = CardManager.getInstance().getCardTemplate(_cardIndex);
			var txtPowerValue:W3TextArea = mcPowerIndicator.getChildByName("txtPower") as W3TextArea;
							
			if (txtPowerValue)
			{
				if (instanceId != -1)
				{
					var cardInstance:CardInstance = CardManager.getInstance().getCardInstance(instanceId);
					var totalPower:int = cardInstance.getTotalPower();
					txtPowerValue.text = totalPower.toString();
				}
				else
				{
					txtPowerValue.text = cardTemplate.power.toString();
				}
				
				if (!cardTemplate.isType(CardTemplate.CardType_Creature))
				{
					txtPowerValue.visible = false;
				}
				else
				{
					txtPowerValue.visible = true;
					if (instanceId != -1 && cardInstance.templateRef.power < totalPower)
					{
						txtPowerValue.setTextColor(0X218013);
					}
					else if (instanceId != -1 && cardInstance.templateRef.power > totalPower)
					{
						txtPowerValue.setTextColor(0XC10000);
					}
					else
					{
						if(cardTemplate.isType(CardTemplate.CardType_Hero))
						{
							txtPowerValue.setTextColor(0xFFFFFF);
						}
						else
						{
							txtPowerValue.setTextColor(0x000000);
						}
					}
				}
			}
		}
		
		protected function onCardPowerChanged():void
		{
			if (mcPowerIndicator)
			{
				updateCardPowerText();
			}
		}
		
		protected function onCardTemplatesLoaded(event:Event):void
		{
			CardManager.getInstance().removeEventListener(CardManager.cardTemplatesLoaded, onCardTemplatesLoaded, false);
			setupCardWithTemplate(CardManager.getInstance().getCardTemplate(cardIndex));
		}
		
		override protected function handleIconLoaded(event:Event):void
		{
			var image:Bitmap = Bitmap(event.target.content);
			if (image)
			{
				image.smoothing = true;
				image.pixelSnapping = PixelSnapping.NEVER;
			}
			
			this.visible = true;
			
			imageLoaded = true;
			
			updateCardSetup();
		}
		
		protected function updateCardSetup():void
		{
			if (!imageLoaded)
			{
				return;
			}
			
			// Keep in mind all positiong is done relatively to a centered card
			
			var templateCard:CardTemplate = CardManager.getInstance().getCardTemplate(_cardIndex);
			
			var adjustedCardHeight:int = adjCardHeight;
			var adjustedCardWidth:int = adjCardWidth;
			
			var halfAdjHeight:int = adjustedCardHeight / 2;
			var halfAdjWidth:int = adjustedCardWidth / 2;
			
			var relativeScale = adjustedCardHeight / CARD_CAROUSEL_HEIGHT;
			
			if (mcCopyCount)
			{
				mcCopyCount.x = 0;
				mcCopyCount.y = halfAdjHeight;
			}
			
			if (mcHitBox)
			{
				if (_cardState == STATE_BOARD)
				{
					mcHitBox.width = CARD_BOARD_WIDTH;
					mcHitBox.height = CARD_BOARD_HEIGHT;
				}
				else
				{
					mcHitBox.width = adjustedCardWidth;
					mcHitBox.height = adjustedCardHeight;
				}
			}
			
			if (mcPowerIndicator)
			{
				if (_cardState == STATE_BOARD)
				{
					mcPowerIndicator.scaleX = mcPowerIndicator.scaleY = POWER_ICON_BOARD_SCALE;
				}
				else
				{
					mcPowerIndicator.scaleX = mcPowerIndicator.scaleY = relativeScale;
				}
				
				mcPowerIndicator.x = -halfAdjWidth;
				mcPowerIndicator.y = -halfAdjHeight;
			}
			
			if (mcTypeIcon)
			{
				if (_cardState == STATE_BOARD)
				{
					mcTypeIcon.x = 40;
					mcTypeIcon.y = 32 ;
					mcTypeIcon.scaleX = mcTypeIcon.scaleY = TYPE_ICON_BOARD_SCALE;
				}
				else
				{
					mcTypeIcon.x = -halfAdjWidth + TYPE_ICON_OFFSET_X * relativeScale;
					mcTypeIcon.y = -halfAdjHeight + TYPE_ICON_OFFSET_Y * relativeScale;
					mcTypeIcon.scaleX = mcTypeIcon.scaleY = relativeScale;
				}
			}
			
			if (mcFactionBanner)
			{
				if (_cardState == STATE_BOARD || !mcPowerIndicator.visible)
				{
					mcFactionBanner.visible = false;
				}
				else
				{
					mcFactionBanner.visible = true;
					mcFactionBanner.scaleY = mcFactionBanner.scaleX = relativeScale; 
					
					mcFactionBanner.x = -halfAdjWidth;
					mcFactionBanner.y = -halfAdjHeight;
				}
			}
			
			if (mcEffectIcon1)
			{
				if (_cardState == STATE_BOARD)
				{
					mcEffectIcon1.scaleX = mcEffectIcon1.scaleY = TYPE_ICON_BOARD_SCALE;
					mcEffectIcon1.x = BOARD_EFFECT_OFFSET_X;
					mcEffectIcon1.y = halfAdjHeight + BOARD_EFFECT_OFFSET_Y;
				}
				else
				{
					mcEffectIcon1.scaleX = mcEffectIcon1.scaleY = relativeScale;
					
					mcEffectIcon1.x = -halfAdjWidth + EFFECT_OFFSET_X * relativeScale;
					mcEffectIcon1.y = EFFECT_OFFSET_Y * relativeScale;
				}
			}
			
			// #J SORRY for confusion, partial refactor. mcTitle now contains the text and mcDesc contains the background
			// { --------------------------------------------------------------
			if (mcDesc && mcTitle)
			{
				var curTextField:TextField;
				
				if (_cardState == STATE_BOARD)
				{
					mcTitle.visible = false;
					mcDesc.visible = false;
				}
				else
				{
					mcTitle.visible = true;
					mcDesc.visible = true;
					
					curTextField = mcTitle.getChildByName("txtTitle") as TextField;
					if (curTextField)
					{
						if (_cardState == STATE_CAROUSEL)
						{
							if (templateCard && templateCard.typeArray == CardTemplate.CardType_None) // NO banner, center text properly
							{
								curTextField.x = -149;
								curTextField.y = -137;
								curTextField.width = 287;
								curTextField.height = 79;
							}
							else
							{
								curTextField.x = -83;
								curTextField.y = -137;
								curTextField.width = 223;
								curTextField.height = 79;
							}
						}
						else if (_cardState == STATE_DECK)
						{
							if (templateCard && templateCard.typeArray == CardTemplate.CardType_None)
							{
								curTextField.x = -96;
								curTextField.y = -83;
								curTextField.width = 178;
								curTextField.height = 100;
							}
							else
							{
								curTextField.x = -53;
								curTextField.y = -83;
								curTextField.width = 140;
								curTextField.height = 100;
							}
						}
					}
					
					curTextField = mcTitle.getChildByName("txtDesc") as TextField;
					if (curTextField)
					{
						if (_cardState == STATE_CAROUSEL)
						{
							curTextField.visible = true;
							curTextField.x = -156;
							curTextField.y = -65;
							curTextField.width = 304;
							curTextField.height = 70;
						}
						else if (_cardState == STATE_DECK)
						{
							curTextField.visible = false;
						}
					}
					
					mcDesc.scaleX = mcDesc.scaleY = relativeScale;
					
					mcDesc.x = 0;
					mcDesc.y = halfAdjHeight;
					
					mcTitle.x = 0;
					mcTitle.y = halfAdjHeight;
				}
			}
			// } --------------------------------------------------------------
			
			if (mcCardHighlight)
			{
				mcCardHighlight.scaleX = adjustedCardWidth / 238;
				mcCardHighlight.scaleY = adjustedCardHeight / 450;
			}
			
			updateImagePosAndSize();
		}
		
		protected function updateImagePosAndSize():void
		{
			if (!_imageLoader)
			{
				return;
			}
			
			var targetHeight:Number = adjCardHeight;
			var targetWidth:Number = adjCardWidth;
			
			if (_cardState == STATE_BOARD)
			{
				targetHeight = 170; // Need it bigger, mask will clip it properly to the adjCardHeight
				if(mcSmallImageContainer) { mcSmallImageContainer.addChild(_imageLoader); }
			}
			else if (mcCardImageContainer)
			{
				mcCardImageContainer.addChild(_imageLoader);
			}
			
			_imageLoader.scaleX = _imageLoader.scaleY = targetWidth / CARD_ORIGIN_WIDTH;
			
			_imageLoader.x = -(_imageLoader.width / 2);
			_imageLoader.y = -(targetHeight / 2);
		}
		
		override public function set selected(value:Boolean):void
		{
			super.selected = value;
			
			updateSelectedVisual();
		}
		
		override protected function updateState():void
		{
			super.updateState();
			updateSelectedVisual();
		}
		
		public function updateSelectedVisual()
		{
			if (mcCardHighlight)
			{
				if (selected && activeSelectionEnabled)
				{
					mcCardHighlight.visible = true;
				}
				else
				{
					mcCardHighlight.visible = false;
				}
			}
			
			if (cardElementHolder)
			{
				if (_cardState == STATE_BOARD && selected && activeSelectionEnabled && cardInstance != null && cardInstance.inList != CardManager.CARD_LIST_LOC_GRAVEYARD)
				{
					//this.parent.addChild(this); // Move to front in render queue
					cardElementHolder.y = BOARD_SELECTED_Y_OFFSET;
					mcHitBox.y = BOARD_SELECTED_Y_OFFSET;
					
					if (_cardState == STATE_BOARD)
					{
						mcHitBox.height = CARD_BOARD_HEIGHT + Math.abs(BOARD_SELECTED_Y_OFFSET);
					}
					else
					{
						mcHitBox.height = adjCardHeight + Math.abs(BOARD_SELECTED_Y_OFFSET);
					}
				}
				else
				{
					cardElementHolder.y = 0;
					mcHitBox.y = 0;
					if (_cardState == STATE_BOARD)
					{
						mcHitBox.height = CARD_BOARD_HEIGHT;
					}
					else
					{
						mcHitBox.height = adjCardHeight;
					}
				}
			}
		}
		
		override public function set activeSelectionEnabled(value:Boolean):void
		{
			super.activeSelectionEnabled = value;
			
			updateSelectedVisual();
		}
		
		override protected function getTargetIndicator():MovieClip
		{
			if (!_activeSelectionEnabled)
			{
				return null;
			}
			
			if (_selected)
			{
				return null;
			}
			return null;
		}
		
		private const shadowMax:Number = 90;
		private const shadowDelta:Number = 4;
		private var _lastShadowRotation:Number = 0;
		override public function set rotationY(value:Number):void 
		{
			super.rotationY = value;
			if (Math.abs(_lastShadowRotation - value) > shadowDelta)
			{
				
				_lastShadowRotation = value;
				var curRotation:Number = value;
				if (value > shadowMax)
				{
					curRotation -= shadowMax;
				}
				else if (value < -shadowMax)
				{
					curRotation += shadowMax;
				}
				/*if (curRotation > 0)
				{
					mcRightShadow.visible = false;
					mcLeftShadow.visible = true;
					mcLeftShadow.alpha = curRotation / shadowMax;
				}
				else
				{
					mcRightShadow.visible = true;
					mcLeftShadow.visible = false;
					mcRightShadow.alpha = Math.abs( curRotation / shadowMax );
				}*/
			}
		}
		
		public function get uplink():IInventorySlot
		{
			return null;
		}
		public function set uplink(value:IInventorySlot):void {}
		
		public function get highlight():Boolean
		{
			return false;
		}
        public function set highlight(value:Boolean):void {}
		
		override public function toString():String 
		{
			var cardInstance:CardInstance = CardManager.getInstance().getCardInstance(_instanceId);
			var addInfo:String = "";
			if (cardInstance)
			{
				addInfo = cardInstance.templateRef.getTypeString() + " <" + cardInstance.templateRef.title + ">";
			}
			return "CardSlot [" +this.name + "]  " + addInfo;
		}
		
		// Need custom events due to not being able to process the mouse events directly on the card movieclip
		protected function handleHitDoubleClick(event:MouseEvent):void
		{
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			if (superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
			{
				dispatchEvent(new Event(CardMouseDoubleClick, true, false));
			}
		}
		
		protected function handleHitClick(event:MouseEvent):void
		{
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			if (superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
			{
				dispatchEvent(new Event(CardMouseLeftClick, true, false));
			}
			else if (superMouseEvent.buttonIdx == MouseEventEx.RIGHT_BUTTON)
			{
				dispatchEvent(new Event(CardMouseRightClick, true, false));
			}
		}
		
		override protected function executeDefaultAction(keyCode:Number, event:InputEvent):void
		{
			if (keyCode == KeyCode.ENTER)
			{
				return;
			}
			
			super.executeDefaultAction(keyCode, event);
		}
		
		protected function handleHitMouseOver(event:MouseEvent):void
		{
			dispatchEvent(new Event(CardMouseOver, true, false));
		}
		
		protected function handleHitMouseOut(event:MouseEvent):void
		{
			dispatchEvent(new Event(CardMouseOut, true, false));
		}
	}
	
}
