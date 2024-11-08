/***********************************************************************
/** Inventory Player grid module : Base Version
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.character
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
	
	public class SkillTreeModule extends UIComponent
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
				
		public var mcSkillTree : SkillTreeGrid;
		
		public var tfCurrentState : TextField;
		
		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/
		
		public var dataBindingKey : String = "character.tree.skills.";
		protected var _inputHandlers:Vector.<UIComponent>;
		
		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/
				
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function SkillTreeModule()
		{
			super();
			_inputHandlers = new Vector.<UIComponent>;
		}
		
		protected override function configUI():void
		{
			super.configUI();
			
			var indexNavigation:Boolean = true;
			mcSkillTree.indexNavigation = indexNavigation;
			
			//mcPlayerGrid.selectedIndex = -1;
			//mcPlayerGrid.focused = 1;
			mouseEnabled = false;
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey, [handleDataSet]));
			mcSkillTree.resetRenderers();
			mcSkillTree.addEventListener( GridEvent.ITEM_CHANGE, onGridItemChange, false, 0, true );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey+".name", [handleGridNameSet]));
			
			Init();
		}
		
		protected function Init() : void
		{
			_inputHandlers.push(mcSkillTree);
			//mcPerkTree.focused = 1;
			//focused = 1;
		}
		
		protected function handleDataSet( gameData:Object, index:int ):void
		{
			var dataArray:Array = gameData as Array;
			
			if ( index > 0 )
			{
				//@FIXME BIDON update only one index here
				if (gameData)
				{
					mcSkillTree.populateData(dataArray);
				}
			}
			else if (gameData)
			{
				mcSkillTree.populateData(dataArray);
			}
		}
		
		protected function handleGridNameSet(  name : String ):void
		{
			if (mcSkillTree)
			{
				mcSkillTree.handleGridNameSet(name);
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
				//dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSetCurrentPlayerGrid', [dataBindingKey] ) );
				mcSkillTree.selectedIndex = 0;
			}
			else
			{
				mcSkillTree.selectedIndex = -1;
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
/*            if (value == _focused || !_focusable)
			{
				return;
			}*/
            _focused = value;

			mcSkillTree.focused = value;
			if ( _focused )
			{
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnModuleSelected", [dataBindingKey]));
				mcSkillTree.changeState('focused');
				SetAsActiveContainer(true);
			}
			else
			{
				mcSkillTree.changeState('normal');
				SetAsActiveContainer(false);
			}
		}
		
		public function GetDataBindingKey() : String
		{
			return dataBindingKey;
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
						event.stopImmediatePropagation();
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
