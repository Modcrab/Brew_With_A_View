package red.game.witcher3.controls
{
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.Elastic;
	import com.gskinner.motion.easing.Exponential;
	import flash.display.GraphicsPathCommand;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.game.witcher3.constants.GwintInputFeedback;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.menus.gwint.CardSlot;
	import red.game.witcher3.menus.gwint.CardTemplate;
	import red.game.witcher3.menus.gwint.GwintGameMenu;
	import red.game.witcher3.menus.gwint.GwintTutorial;
	import red.game.witcher3.slots.SlotsListCarousel;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import red.game.witcher3.menus.gwint.CardInstance;
	import red.game.witcher3.menus.gwint.CardManager;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.gfx.MouseEventEx;
	
	public class W3ChoiceDialog extends UIComponent
	{
		public var txtCarouselMessage:TextField;
		public var mcCarouselMsgBackground:MovieClip;
		public var cardsCarousel:SlotsListCarousel;
		public var mcTooltip:MovieClip;
		public var mcBackground:Sprite;
		
		private var _choices:Array;
		private var _sourceList:Array;
		private var _acceptCallback:Function;
		private var _declineCallback:Function;
		private var _shown:Boolean;
		public var ignoreNextRightClick:Boolean = false;
		
		override protected function configUI():void 
		{
			super.configUI();
			txtCarouselMessage.text = "";
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInputCustom, false, 0, true);
			
			cardsCarousel.addEventListener(ListEvent.INDEX_CHANGE, onCarouselSelectionChanged, false, 0, true);
			stage.addEventListener(MouseEvent.CLICK, handleStageClick, false, 1, true);
			stage.addEventListener( MouseEvent.MOUSE_WHEEL,	OnMouseWheel,	false, 0, true );
			
			cardsCarousel.addEventListener(CardSlot.CardMouseDoubleClick, 	OnCardMouseDoubleClick,	false, 0, true);
		}
		
		public function showDialogCardInstances(sourceList:Vector.<CardInstance>, acceptCallback:Function, declineCallback:Function, messageText:String):void
		{
			var convertedArray:Array = new Array();
			var i:int;
			
			for (i = 0; i < sourceList.length; ++i)
			{
				convertedArray.push(sourceList[i]);
			}
			
			showDialog(convertedArray, acceptCallback, declineCallback, messageText);
		}
		
		public function showDialogCardTemplates(sourceList:Vector.<int>, acceptCallback:Function, declineCallback:Function, messageText:String):void
		{
			var convertedArray:Array = new Array();
			var i:int;
			
			for (i = 0; i < sourceList.length; ++i)
			{
				convertedArray.push(sourceList[i]);
			}
			
			showDialog(convertedArray, acceptCallback, declineCallback, messageText);
		}
		
		public function showDialog(sourceList:Array, acceptCallback:Function, declineCallback:Function, messageText:String):void
		{
			if (!_shown)
			{
				_shown = true;
				enabled = visible = true;
				//alpha = 0;
				//GTweener.to(this, 1, { alpha:1 }, { onComplete:handleDialogShown } );				
			}
			
			// If one of the callbacks is null, it should not be added to the inputfeedback
			_acceptCallback = acceptCallback;
			_declineCallback = declineCallback;
			_sourceList = sourceList;
			cardsCarousel.data = _sourceList;
			cardsCarousel.focused = 1;
			cardsCarousel.validateNow();
			if (cardsCarousel.selectedIndex == -1)
			{
				cardsCarousel.selectedIndex = 0;
			}
			else if (cardsCarousel.selectedIndex > sourceList.length)
			{
				cardsCarousel.selectedIndex = sourceList.length - 1;
			}
			cardsCarousel.validateNow();
			updateTooltip(cardsCarousel.getSelectedRenderer() as CardSlot);
			
			updateDialogText(messageText);
			
			updateInputFeedback();
			
			inputEnabled = true;
		}
		
		protected var _inputEnabled:Boolean = true;
		public function set inputEnabled(value:Boolean):void
		{
			_inputEnabled = value;
			cardsCarousel.inputEnabled = value;
		}
		
		public function updateDialogText(messageText:String):void
		{
			if (txtCarouselMessage)
			{
				txtCarouselMessage.text = messageText;
			}
			
			if (txtCarouselMessage.text == "")
			{
				mcCarouselMsgBackground.visible = false;
			}
			else
			{
				mcCarouselMsgBackground.visible = true;
			}
		}
		
		public function appendDialogText(textToAppend:String):void
		{
			if (txtCarouselMessage)
			{
				txtCarouselMessage.appendText(textToAppend);
			}
			
			if (txtCarouselMessage.text == "")
			{
				mcCarouselMsgBackground.visible = false;
			}
			else
			{
				mcCarouselMsgBackground.visible = true;
			}
		}
		
		public function hideDialog():void
		{
			if (_shown)
			{
				_shown = false;
				cardsCarousel.focused = 0;
				//GTweener.to(this, 1, { alpha:0 }, { onComplete:handleDialogHidden } );
				enabled = visible = false;
				txtCarouselMessage.text = "";
			}
			InputFeedbackManager.removeButtonById(GwintInputFeedback.apply);
			InputFeedbackManager.removeButtonById(GwintInputFeedback.cancel);
		}
		
		override public function set visible(value:Boolean):void {
			super.visible = value;
			mouseEnabled = value;
			mouseChildren = value;
		}
		
		public function replaceCard(sourceInstance:CardInstance, newInstance:CardInstance):void
		{
			 cardsCarousel.replaceItem(sourceInstance, newInstance);
			 updateTooltip(cardsCarousel.getSelectedRenderer() as CardSlot);
		}
		
		private function handleDialogShown(tweenInstance:GTween):void
		{
			//
		}
		
		private function handleDialogHidden(tweenInstance:GTween):void
		{
			enabled = visible = false;
		}
		
		public function isShown():Boolean
		{
			return _shown;
		}
		
		private function handleInputCustom(event:InputEvent):void
		{
			if (!_inputEnabled)
			{
				return;
			}
			
			super.handleInput(event);
			if (event.handled || !_shown) return;
			var details:InputDetails = event.details;
			var keyPress:Boolean = details.value == InputValue.KEY_UP;
			if (keyPress)
			{
				switch (details.navEquivalent)
				{
					case NavigationCode.GAMEPAD_A:
						applyChoice();
						event.handled = true;
						break;
					case NavigationCode.GAMEPAD_B:
						cancelChoice();
						event.handled = true;
						break;
				}
			}
		}
		
		private function applyChoice():void
		{
			if (_shown && (_acceptCallback != null))
			{
				cardsCarousel.validateNow(); // Make sure the selection is properly updated
				var curRenderer:CardSlot = cardsCarousel.getRendererAt(cardsCarousel.selectedIndex) as CardSlot;
				if (curRenderer && curRenderer.activateEnabled)
				{
					if (curRenderer.instanceId != -1)
					{
						_acceptCallback(curRenderer.instanceId);
					}
					else
					{
						_acceptCallback(curRenderer.cardIndex);
					}
				}
			}
		}
		
		private function cancelChoice():void
		{
			if (_declineCallback != null)
			{
				_declineCallback();
			}
		}
		
		protected function onCarouselSelectionChanged( event:ListEvent ):void
		{
			var selectedItem:CardSlot = cardsCarousel.getRendererAt(event.index) as CardSlot;
			
			updateTooltip(selectedItem);
			updateInputFeedback();
		}
		
		protected function updateInputFeedback():void
		{
			var acceptAvailable:Boolean = _acceptCallback != null;
			var currentSelection:CardSlot = cardsCarousel.getSelectedRenderer() as CardSlot;
			
			if (currentSelection && acceptAvailable && !currentSelection.activateEnabled)
			{
				acceptAvailable = false;
			}
			
			if (acceptAvailable)
			{
				InputFeedbackManager.appendButtonById(GwintInputFeedback.apply, NavigationCode.GAMEPAD_A, KeyCode.ENTER, "panel_button_common_select");
			}
			else
			{
				InputFeedbackManager.removeButtonById(GwintInputFeedback.apply);
			}
			
			if (_declineCallback != null)
			{
				InputFeedbackManager.appendButtonById(GwintInputFeedback.cancel, NavigationCode.GAMEPAD_B, KeyCode.ESCAPE, "panel_common_cancel");
			}
			else
			{
				InputFeedbackManager.removeButtonById(GwintInputFeedback.cancel);
			}
		}
		
		protected function updateTooltip(selectedItem:CardSlot):void
		{
			var cardManager:CardManager = CardManager.getInstance();
			var cardTemplate:CardTemplate = null;
			
			if (selectedItem)
			{
				cardTemplate = cardManager.getCardTemplate(selectedItem.cardIndex);
			}
			else if (cardsCarousel.data.length > 0)
			{
				if (cardsCarousel.data[0] is CardInstance)
				{
					cardTemplate = (cardsCarousel.data[0] as CardInstance).templateRef;
				}
				else if (cardsCarousel.data[0] is int)
				{
					cardTemplate = cardManager.getCardTemplate(cardsCarousel.data[0]);
				}
			}
			
			if (cardTemplate)
			{
				// Tooltip update
				if (mcTooltip && cardManager)
				{
					var tooltipString:String = cardTemplate.tooltipString;
					
					var titleText:TextField = mcTooltip.getChildByName("txtTooltipTitle") as TextField;
					var descText:TextField = mcTooltip.getChildByName("txtTooltip") as TextField;
					
					if (tooltipString == "" || !titleText || !descText)
					{
						mcTooltip.visible = false;
					}
					else
					{
						mcTooltip.visible = true;
						
						if (cardTemplate.index >= 1000) // Leaders are special ;)
						{
							titleText.text = "[[gwint_leader_ability]]";
						}
						else
						{
							titleText.text = "[[" + tooltipString + "_title]]";
						}
						
						if (cardTemplate.index == 524)
						{
							descText.text = "[[gwint_card_tooltip_scorch_creature]]";
						}
						else
						{
							descText.text = "[[" + tooltipString + "]]";
						}
						
						var tooltipIcon:MovieClip = mcTooltip.getChildByName("mcTooltipIcon") as MovieClip;
						
						if (tooltipIcon)
						{
							tooltipIcon.gotoAndStop(cardTemplate.tooltipIcon);
						}
					}
				}
			}
			else
			{
				mcTooltip.visible = false;
			}
		}
		
		protected function handleStageClick(e:MouseEvent):void
		{
			if (!_shown)
			{
				return;
			}
			
			var superMouseEvent:MouseEventEx = e as MouseEventEx;
			if (superMouseEvent.buttonIdx == MouseEventEx.RIGHT_BUTTON && !GwintTutorial.mSingleton.active)
			{
				if (!ignoreNextRightClick)
				{
					cancelChoice();
				}
				else
				{
					ignoreNextRightClick = false;
				}
			}
		}
		
		public function OnMouseWheel( event : MouseEvent )
		{
			if (!_shown)
			{
				return;
			}
			
			if (event.delta > 0)
			{
				cardsCarousel.navigateLeft();
			}
			else
			{
				cardsCarousel.navigateRight();
			}
		}
		
		public function OnCardMouseDoubleClick( event : Event )
		{
			applyChoice();
		}
	}
}
