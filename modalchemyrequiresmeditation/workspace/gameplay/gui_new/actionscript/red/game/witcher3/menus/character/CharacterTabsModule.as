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
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.controls.TabListItem;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.data.DataProvider;
		
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;
	
	public class CharacterTabsModule extends UIComponent
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		public var mcTabList : W3ScrollingList;
		public var mcTabListItem1 : TabListItem;
		public var mcTabListItem2 : TabListItem;
		
		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/
		
		protected var dataBindingKey : String = "inventory.grid.player";
		protected var filterEventName : String = "OnCharacterTabSelected";
		protected var _inputHandlers:Vector.<UIComponent>;
		
		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/
						
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function CharacterTabsModule()
		{
			super();
			_inputHandlers = new Vector.<UIComponent>;
		}
		
		protected override function configUI():void
		{
			super.configUI();
			mouseEnabled = false;
			
			Init();
		}
		
		protected function Init() : void
		{
			mcTabList.dataProvider = new DataProvider( [ { icon:"SKILLS" }, { icon:"PERKS" }] );
			mcTabList.ShowRenderers(true);
			mcTabList.addEventListener( ListEvent.INDEX_CHANGE, OnTabListItemClick, false, 0, true ); // #B maybe shuld be Event change ?
			mcTabList.selectedIndex = 0;
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey+".tab.selected", [handleForceSelectTab]));
			
			_inputHandlers.push(mcTabList);;
			focused = 1;
		}

		override public function toString() : String
		{
			return "[W3 CHaracterTabsModule]"
		}
		
		/********************************************************************************************************************
			PRIVATE FUNCTIONS
		/ ******************************************************************************************************************/
		
		protected function OnTabListItemClick( event:ListEvent ):void
		{
			mcTabList.selectedIndex = event.index;
			dispatchEvent( new GameEvent( GameEvent.CALL, filterEventName, [event.index]) );
		}
		
		protected function handleForceSelectTab( filterIndex : int ):void
		{
			mcTabList.selectedIndex = filterIndex;
		}
		
		public function GetDataBindingKey() : String
		{
			return dataBindingKey;
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			var details:InputDetails = event.details;
			var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
				
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
