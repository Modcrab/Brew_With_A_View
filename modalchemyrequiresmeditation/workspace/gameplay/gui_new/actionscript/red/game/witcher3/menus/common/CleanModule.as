/***********************************************************************
/** Clean module
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
		
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;
	
	public class CleanModule extends UIComponent //#B it should inherit after CoreMenuModule - currently need update !!!
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/
		
		public var dataBindingKey : String = "character.tree.perks";
		protected var _inputHandlers:Vector.<UIComponent>;
		
		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/
				
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function CleanModule()
		{
			super();
			_inputHandlers = new Vector.<UIComponent>;
		}
		
		protected override function configUI():void
		{
			super.configUI();
			//dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey, [handleDataSet]));
			//dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey+".name", [handleGridNameSet]));
		}

		protected function handleDataSet( gameData:Object, index:int ):void
		{
			var dataArray:Array = gameData as Array;
			
			if ( index > 0 )
			{
				//@FIXME BIDON update only one index here
				if (gameData)
				{
					mcPerkTree.populateData(dataArray);
				}
			}
			else if (gameData)
			{
				mcPerkTree.populateData(dataArray);
			}
		}
		
		protected function handleGridNameSet(  name : String ):void
		{
			if (mcPerkTree.tfCurrentState)
			{
				mcPerkTree.tfCurrentState.htmlText = name;
			}
		}
				
		override public function toString() : String
		{
			return "[W3 PlayerGridModule]"
		}
		
		/********************************************************************************************************************
			PRIVATE FUNCTIONS
		/ ******************************************************************************************************************/
		public function GetDataBindingKey() : String
		{
			return dataBindingKey;
		}
		/*
		override public function handleInput( event:InputEvent ):void
		{
			if ( _focused )
			{
				var details:InputDetails = event.details;
				var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
				
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
		}*/
	}
}
