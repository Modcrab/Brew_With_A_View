package red.game.witcher3.menus.worldmap
{
	import flash.display.MovieClip;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.core.UIComponent;
	import red.game.witcher3.controls.W3ScrollingList;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.data.DataProvider;
	import red.game.witcher3.controls.InputFeedbackButton;
	import scaleform.clik.events.InputEvent;
	import red.core.constants.KeyCode;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.ui.InputDetails;
		
	public class UserPinPanel extends UIComponent
	{
		public var mcUserPin1:UserPinItemRenderer;
		public var mcUserPin2:UserPinItemRenderer;
		public var mcUserPin3:UserPinItemRenderer;
		public var mcUserPin4:UserPinItemRenderer;
		public var mcUserPinsList:W3ScrollingList;
		public var btnClose:InputFeedbackButton;
		
		public var enableUserPinPanel:Function;
		public var setUserMapPin:Function;

		public function UserPinPanel()
		{
		}
		
		override protected function configUI():void
		{
			super.configUI();

			mcUserPinsList.focusable = true;
			mcUserPinsList.dataProvider = new DataProvider([ { pinId:"User2" }, { pinId:"User3" }, { pinId:"User4" } ]);	
			mcUserPinsList.validateNow();
			mcUserPinsList.addEventListener(ListEvent.ITEM_PRESS, handleUserPinsPress, false, 0, true);
			//mcUserPinsList.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, handleUserPinDoubleClick, false, 0, true);
			//mcUserPinsList.addEventListener( ListEvent.INDEX_CHANGE, handleUserPinsSelected, false, 0, true );
			
			btnClose.clickable = true;
			btnClose.label = "[[panel_common_cancel]]";
			btnClose.setDataFromStage( "", KeyCode.ESCAPE );				
			btnClose.visible = true;
			btnClose.addEventListener( ButtonEvent.CLICK, handleCloseButtonClicked, false, 0, true );
			btnClose.validateNow();
			
			mcUserPinsList.focusable = false;
			mcUserPinsList.bSkipFocusCheck = true;
			
			mcUserPinsList.selectOnOver = true;
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			super.handleInput( event );
			
			if (event.handled)
			{
				return;
			}

			var details:InputDetails = event.details;
			var keyUp : Boolean = ( details.value == InputValue.KEY_UP );
			
			if (details.navEquivalent == NavigationCode.GAMEPAD_X )
			{
				if ( keyUp )
				{
					closePanelAndSetUserPin();
					event.handled = true;
				}
			}
			/*
			else if (details.navEquivalent == NavigationCode.GAMEPAD_A )
			{
				if ( keyUp )
				{
					closePanelAndSetUserPin();
					event.handled = true;
				}
			}
			*/
			else if (details.navEquivalent == NavigationCode.GAMEPAD_B ) 
			{
				if ( keyUp )
				{
					enableUserPinPanel( false );
					event.handled = true;
				}
			}
			else
			{
				mcUserPinsList.handleInput(event);	
			}
		}
		
		private function handleUserPinsPress(event:ListEvent):void
		{
			closePanelAndSetUserPin();
		}
		
		public function handleCloseButtonClicked( event : ButtonEvent )
		{
			enableUserPinPanel( false );
		}

		/*
		private function handleUserPinsSelected(event:ListEvent):void
		{
			trace("Minimap handleUserPinsSelected ");
			
			if (event.itemData)
			{
				trace("Minimap - ", event.itemData.pinId );
			}
		}
		*/

		/*
		private function handleUserPinDoubleClick(event:ListEvent):void
		{
			trace("Minimap handleUserPinDoubleClick ");
			
			if (event.itemData)
			{
				trace("Minimap - ", event.itemData.pinId );
			}
		}
		*/
		
		private function closePanelAndSetUserPin()
		{
			var index : int = mcUserPinsList.selectedIndex;
			enableUserPinPanel( false );
			setUserMapPin( index, true );
		}
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if ( value )
			{
				mcUserPinsList.selectedIndex = 0;
			}
		}
		
	}
	
}
