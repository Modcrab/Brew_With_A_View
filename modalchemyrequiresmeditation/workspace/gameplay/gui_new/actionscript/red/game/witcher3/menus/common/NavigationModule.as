/***********************************************************************
/** Navigation Module
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.core.CoreComponent;
	import scaleform.clik.data.DataProvider;
	import red.core.events.GameEvent;
	import scaleform.clik.events.ListEvent;
	
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;
	import red.game.witcher3.controls.TabListItem;
	import red.game.witcher3.controls.BaseListItem;
	
	import scaleform.clik.core.UIComponent;
	import flash.events.Event;
	
	import red.game.witcher3.controls.W3GamepadButton;
	
	public class NavigationModule extends CoreComponent
	{
		public var mcNavButtonRight : W3GamepadButton;
		public var mcNavButtonLeft : W3GamepadButton;
		
		public var mcTabList : W3ScrollingList;
		public var mcTabListItem1 : TabListItem;
		public var mcTabListItem2 : TabListItem;
		public var mcTabListItem3 : TabListItem;
		public var mcTabListItem4 : TabListItem;
		public var mcTabListItem5 : TabListItem;
		public var mcTabListItem6 : TabListItem;
		
		public var mcTabsBackground : MovieClip;
		
		private var _selectedTab : int = -1;
		
		/********************************************************************************************************************
			INIT & DATA SET
		/ ******************************************************************************************************************/
		
		public function NavigationModule()
		{
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.main.navigationtabs', [handleTabsData]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.main.navigationtabs.selected', [handleForceSelectTab]));
			/*mcTabList.dataProvider = new DataProvider( [ { icon:"InventoryMenu" },
			{ icon:"InventoryMenu" },
			{ icon:"InventoryMenu" },
			{ icon:"InventoryMenu" },
			{ icon:"InventoryMenu" },
			{ icon:"InventoryMenu" }] );*/
			
			mcTabList.addEventListener( ListEvent.INDEX_CHANGE, OnTabListItemClick, false, 0, true );

			_inputHandlers.push(mcTabList);
			
			mcNavButtonLeft.navigationCode = NavigationCode.GAMEPAD_L2;
			_inputHandlers.push( mcNavButtonLeft );
			mcNavButtonLeft.label = "";
			
			mcNavButtonRight.navigationCode = NavigationCode.GAMEPAD_R2;
			_inputHandlers.push( mcNavButtonRight );
			mcNavButtonRight.label = "";
			
			/*
				if (details.navEquivalent == NavigationCode.GAMEPAD_L2)
				{
					parent.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnPrevSubMenu' ) );
				}
				else if (details.navEquivalent == NavigationCode.GAMEPAD_R2)
				{
					parent.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnNextSubMenu' ) );*/
		}
		
		
		public function handleTabsData( gameData : Object, index : int ):void
		{
			var l_dataArray = gameData as Array;
			if( l_dataArray )
			{
				if( index > -1 )
				{
					//mcDropDownList.updateItemData(gameData);
				}
				else
				{
					mcTabList..dataProvider = new DataProvider( l_dataArray );
					mcTabList.ShowRenderers(true);
					if (_selectedTab > -1 )
					{
						mcTabList.selectedIndex = _selectedTab;
					}
				}
			}
		}
		
		/********************************************************************************************************************
			INPUT & EVENTS
		/ ******************************************************************************************************************/
		
		protected function OnTabListItemClick( event:ListEvent ):void
		{
			mcTabList.selectedIndex = event.index;
			if ( _selectedTab != mcTabList.selectedIndex )
			{
				//var renderer : BaseListItem = mcTabList.getRendererAt(mcTabList.selectedIndex) as BaseListItem;
				//mcTabList.invalidate();
				_selectedTab = mcTabList.selectedIndex;
				OnRepositionItems(null);
				parent.dispatchEvent( new GameEvent( GameEvent.CALL, 'OnOpenSubMenu', [event.index]) ); // @FIXME BIDON - why it could not send event from module ?
			}
		}
		
		protected function handleForceSelectTab( filterIndex : int ):void
		{
			_selectedTab = filterIndex;
			mcTabList.selectedIndex = filterIndex;
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
		
		public function OnRepositionItems( event : Event ) : void
		{
			var tempX : Number;
			var renderer : TabListItem;
			tempX = mcTabList.x;
			
			for ( var i : int = 0; i < mcTabList.dataProvider.length; i++ )
			{
				renderer = mcTabList.getRendererAt(i) as TabListItem;
				renderer.x = tempX;
				tempX += renderer.width;
				if ( i == mcTabList.selectedIndex )
				{
					tempX += 355; // #B hax
				}
				mcTabsBackground.gotoAndStop(mcTabList.selectedIndex+1);
			}
		}
	}
}
