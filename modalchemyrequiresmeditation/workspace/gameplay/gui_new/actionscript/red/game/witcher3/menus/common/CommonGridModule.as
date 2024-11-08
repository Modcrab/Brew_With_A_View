/***********************************************************************
/** Common Player grid module : Base Version
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import scaleform.clik.core.UIComponent;
	import red.core.events.GameEvent;
	import red.game.witcher3.events.GridEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.data.DataProvider;
	import red.game.witcher3.constants.InventoryFilterType;

	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;

	import red.game.witcher3.menus.inventory.InventoryGrid; // @FIXME BIDON - move it to common or something like that

	public class CommonGridModule extends UIComponent
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/

		public var mcGrid : InventoryGrid;

		public var tfCurrentState : TextField;

		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/

		protected var _currentInventoryFilterIndex:int = -1;
		protected var dataBindingKey : String = "common.grid";
		protected var _inputHandlers:Vector.<UIComponent>;
		protected var _moduleDisplayName : String = "";

		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/

		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/

		public function CommonGridModule()
		{
			super();
			_inputHandlers = new Vector.<UIComponent>;
		}

		protected override function configUI():void
		{
			super.configUI();

			var indexNavigation:Boolean = true;
			mcGrid.indexNavigation = indexNavigation;

			//mcGrid.selectedIndex = -1;
			//mcGrid.focused = 1;
			mouseEnabled = false;

			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey, [handleDataSet]));
			mcGrid.resetRenderers();
			mcGrid.addEventListener( GridEvent.ITEM_CHANGE, onGridItemChange, false, 0, true );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey+".name", [handleGridNameSet]));

			Init();
		}

		protected function Init() : void
		{
			_inputHandlers.push(mcGrid);
			mcGrid.focused = 1;
			focused = 1;
		}

		protected function handleDataSet( gameData:Object, index:int ):void
		{
			var dataArray:Array = gameData as Array;
			trace("MEDITATION dataArray.length "+dataArray.length);
			if ( index > 0 )
			{
				//@FIXME BIDON update only one index here
				if (gameData)
				{
					mcGrid.populateData(dataArray);
				}
			}
			else if (gameData)
			{
				mcGrid.populateData(dataArray);
			}
			// #B ugly hax
			//InventoryMenu(parent).SetActiveItem(""); // @FIXME BIDON - change to event
		}

		protected function handleGridNameSet(  name : String ):void
		{
			if (tfCurrentState)
			{
				_moduleDisplayName = name;
				tfCurrentState.htmlText = name;
			}
		}

		protected function onGridItemChange( event : GridEvent ):void
		{
			dispatchEvent(event);
		}

		public function SetAsActiveContainer( value : Boolean )
		{
			if ( value )
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSetCurrentPlayerGrid', [dataBindingKey] ) );
			}
			else
			{
				mcGrid.selectedIndex = -1;
			}
		}

		override public function toString() : String
		{
			return "[W3 PlayerGridModule]"
		}

		/********************************************************************************************************************
			PRIVATE FUNCTIONS
		/ ******************************************************************************************************************/

		override public function set focused(value:Number):void
		{
            if (value == _focused || !_focusable)
			{
				return;
			}
            _focused = value;

			mcGrid.focused = value;
			if ( _focused )
			{
				gotoAndStop('focused');
				SetAsActiveContainer(true);
				//dispatchEvent(new GameEvent(GameEvent.CALL, "OnModuleSelected", [dataBindingKey]));
			}
			else
			{
				gotoAndStop('normal');
				SetAsActiveContainer(false);
			}
			if (tfCurrentState)
			{
				tfCurrentState.htmlText = _moduleDisplayName;
			}
		}

		public function GetDataBindingKey() : String
		{
			return dataBindingKey;
		}

		public function SetDataBindingKey( bindingName : String ) : void // ?
		{
			dataBindingKey = bindingName;
		}

		override public function handleInput( event:InputEvent ):void
		{
			if ( _focused )
			{
				var details:InputDetails = event.details;
				var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
	/*
				if ( details.code > 500 )
				{
					return;
				}*/
				switch( details.code )
				{
					case KeyCode.PAD_DIGIT_DOWN:
					case KeyCode.PAD_DIGIT_UP:
					case KeyCode.PAD_DIGIT_LEFT:
					case KeyCode.PAD_DIGIT_RIGHT:
						event.handled = true;
						return;
				}

				for each ( var handler:UIComponent in _inputHandlers )
				{
					//trace("INVENTORY CHECK handler "+handler+"  event.handled "+ event.handled);
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
}
