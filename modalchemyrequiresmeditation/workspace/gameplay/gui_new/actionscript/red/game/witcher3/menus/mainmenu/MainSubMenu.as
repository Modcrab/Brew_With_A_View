/***********************************************************************
/** Main Sub Menu class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import flash.display.MovieClip;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;

	import red.core.CoreMenu;
	import red.core.events.GameEvent;

	import red.game.witcher3.menus.common.W3SubMenuListItemRenderer;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.controls.BaseListItem;

	import scaleform.clik.events.ListEvent;
	import scaleform.clik.data.DataProvider;

	import scaleform.clik.events.InputEvent;
	import red.core.constants.KeyCode;
	//import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.controls.ScrollBar;

	import red.game.witcher3.managers.InputManager;

	public class MainSubMenu extends CoreMenu
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/

		public var mcMenuList : W3ScrollingList;
		public var mcMenuListItem1 : BaseListItem;
		public var mcMenuListItem2 : BaseListItem;
		public var mcMenuListItem3 : BaseListItem;
		public var mcMenuListItem4 : BaseListItem;
		public var mcMenuListItem5 : BaseListItem;
		public var mcScrollbar 	   : ScrollBar;

		public var mcAnchor_MODULE_Tooltip 	   : MovieClip;

		public var dataBindingKey : String = "mainmenu.main.entries";

		public function MainSubMenu()
		{
			super();
			_enableMouse = true;
		}

		override protected function get menuName():String
		{
			return "not important";
		}

		override protected function configUI():void
		{
			super.configUI();
			_contextMgr.defaultAnchor = mcAnchor_MODULE_Tooltip;
			_contextMgr.addGridEventsTooltipHolder(stage);

			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			//dispatchEvent( new GameEvent( GameEvent.REGISTER, "mainmenu.savegames", [handleSavegameList] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey, [handleOptionsList] ) );
			focused = 1;

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			mcMenuList.addEventListener( ListEvent.ITEM_CLICK, onItemClicked, false, 0, true );  // #B couldn't be used because of
			//mcMenuList.addEventListener( ListEvent.INDEX_CHANGE, onItemSelected, false, 0, true );
			mcMenuList.ShowRenderers(true);
			mcMenuList.selectedIndex = 0;
			mcMenuList.focused = 1;
			mcMenuList.focusable = false;
		}

		private function onItemClicked( event : ListEvent ):void
		{
			var renderer : BaseListItem =  mcMenuList.getRendererAt( event.index, mcMenuList.scrollPosition ) as BaseListItem;
			if(renderer)
			{
				trace("HUD onItemClicked renderer.data.tag " + renderer.data.tag);
				var _inputMgr:InputManager;
				_inputMgr = InputManager.getInstance();
				_inputMgr.reset();
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnItemChosen', [ renderer.data.tag ] ) );
			}
			else
			{
				trace("MainMenu renderer is fucked "+event.target);
			}
		}

/*		private function onItemSelected( event : ListEvent ):void
		{
			/*var renderer : BaseListItem =  mcMenuList.getRendererAt( event.index, mcMenuList.scrollPosition ) as BaseListItem;
			if(renderer)
			{
				renderer.focused = 1;
			}* /
		}*/

		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled )
			{
				return;
			}

			var details:InputDetails = event.details;
            var keyUp:Boolean = (details.value == InputValue.KEY_UP);

			if ( !keyUp && !event.handled ) // #B for debug only
			{
				switch(details.navEquivalent)
				{
					case NavigationCode.GAMEPAD_A :
						event.handled = true;
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfirm' ) );
						break;
				}
			}

			mcMenuList.handleInput(event);
		}

		protected function handleOptionsList( gameData : Object, index : int ) : void
		{
			var dataArray : Array = gameData as Array;

			if ( index > 0 )
			{
				// nvm
				mcMenuList.dataProvider = new DataProvider(dataArray);
			}
			else if ( dataArray )
			{
				mcMenuList.dataProvider = new DataProvider(dataArray);
			}

			trace("HUD dataArray.length "+dataArray.length + " mcMenuList.dataProvider "+mcMenuList.dataProvider.length );
			mcMenuList.ShowRenderers(true);
		}

		override protected function closeMenu() :void
		{
			var _inputMgr:InputManager;
			_inputMgr = InputManager.getInstance();
			_inputMgr.reset();
			super.closeMenu();
		}
	}
}
