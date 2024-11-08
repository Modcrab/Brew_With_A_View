/***********************************************************************
/** PANELS button container module
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.events.Event;
	import red.core.events.GameEvent;
	import red.core.CoreComponent;
	import red.game.witcher3.controls.W3GamepadButton;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.constants.NavigationCode;
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.constants.InventoryActionType;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.core.UIComponent;
	import red.game.witcher3.events.GridEvent;
	import flash.utils.getDefinitionByName;
	//import scaleform.clik.constants.NavigationCode;
	
	public class ButtonContainerModule extends CoreComponent
	{
		var mcButtons : Vector.<W3GamepadButton>;
		var _LongestLabelWidth : Number = 0;
		var _gap : Number = 10;
		protected var _handleKeyUp:Boolean;
		
		public function ButtonContainerModule()
		{
			super();
			mcButtons = new Vector.<W3GamepadButton>;
		}

		override protected function configUI():void
		{
			super.configUI();
			//dispatchEvent( new GameEvent( GameEvent.REGISTER, 'common.buttons.setup', [handleSetupButtons]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'common.button.setup', [handleSetupButton]));
		}
		
		public function get handleKeyUp():Boolean { return _handleKeyUp }
		public function set handleKeyUp(value:Boolean):void
		{
			_handleKeyUp = value;
		}

		// temporary public
		public function handleSetupButtons( gameData:Object, index:int ) : void //#B from left to right
		{
			var i : int;
			this.visible = false;
			if (gameData)
			{
				if ( index < 0 )
				{
					for( i = mcButtons.length -1; i >= 0; i-- )
					{
						removeChild(mcButtons[i]);
					}
					_LongestLabelWidth = 0;
					mcButtons.length = 0;
					var dataArray:Array = gameData as Array;
					for( i = 0; i < dataArray.length; i++ )
					{
						var mcButton : W3GamepadButton;
						var classRef:Class = getDefinitionByName("StandardGamepadButtonRef") as Class;
						if (classRef != null) { mcButton = new classRef() as W3GamepadButton; }
						mcButton.addEventListener( ButtonEvent.CLICK, handleButtonPress, false, 10, true );
						mcButton.navigationCode = dataArray[i].navigationCode;
						mcButton.label = dataArray[i].label;
						mcButton.enabled = dataArray[i].enabled;
						mcButton.index = i;
						
						
						_inputHandlers.push( mcButton );
						addChild(mcButton);
						mcButton.visible = true;

						mcButton.validateNow();
						mcButtons.push(mcButton);
						this.visible = true;
					}
				}
				else
				{
					return;
				}
				RepositionButtons();
				validateNow();
			}
		}

		protected function handleSetupButton( gameData:Object) : void //#B from left to right
		{
			var i : int;
			var mcButton : W3GamepadButton;
			if (gameData)
			{
				if ( gameData.index < mcButtons.length )
				{
					mcButton = mcButtons[gameData.index];
					mcButton.removeEventListener( ButtonEvent.CLICK, handleButtonPress );
					mcButton.addEventListener( ButtonEvent.CLICK, handleButtonPress, false, 10, true );
					mcButton.navigationCode = gameData.navigationCode;
					mcButton.label = gameData.label;
					mcButton.enabled = gameData.enabled;
					mcButton.index = gameData.index;
					mcButton.visible = true;
					mcButton.validateNow();
				}
				else
				{
					return;
				}
				RepositionButtons();
				validateNow();
			}
		}

		protected function RepositionButtons() : void
		{
			var i : int;
			var tempX : Number = 0;
			
			for( i = 0; i < mcButtons.length; i++ )
			{
				//tempX = -( _LongestLabelWidth + 32 ) * ( i + 1 ) - ( _gap +32) * i;
				tempX += - mcButtons[i].textField.textWidth - 32;
				mcButtons[i].x = tempX;
				tempX += -32 -_gap;
			}
			
		}
		
		protected function handleButtonPress( event : ButtonEvent )
		{
			var mcButton : W3GamepadButton = event.target as W3GamepadButton;
			dispatchEvent( new GameEvent(GameEvent.CALL, 'OnButtonPress', [mcButton.index]));
		}
		
		override public function toString():String
		{
			return "[W3 ButtonContainerModule: ]";
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled )
			{
				//trace( " IV event.handled " + event.handled+ " ");
				return;
			}
			
			var details:InputDetails = event.details;
            var keyPress:Boolean;
			if (!_handleKeyUp)
			{
				keyPress = details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD;
			}
			else
			{
				keyPress = details.value == InputValue.KEY_UP;
			}
			if (!keyPress) return;
			
			for each ( var handler:UIComponent in _inputHandlers )
			{
				if ( event.handled )
				{
					event.stopImmediatePropagation();
					return;
				}
				handler.handleInput( event );
			}
		}
	}
}