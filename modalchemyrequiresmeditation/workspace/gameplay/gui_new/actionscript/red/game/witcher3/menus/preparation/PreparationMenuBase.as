/***********************************************************************
/** PANEL Inventory main class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.preparation
{
	import flash.display.MovieClip;
	import red.core.events.GameEvent;
	import red.game.witcher3.menus.common.CommonGridModule;
	import red.game.witcher3.menus.common.NavigationModule;
	import red.game.witcher3.menus.common.QuantityPopup;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ListEvent; // kill ?
	
	import red.core.CoreMenu;
	import scaleform.gfx.Extensions;
	
	import scaleform.clik.constants.InvalidationType;
	
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	
	import flash.events.FocusEvent;
	import red.game.witcher3.interfaces.IGridItemRenderer;
	
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.menus.common.SkillDataStub;
	
	import red.game.witcher3.menus.common.FloatingTooltip;
	import red.game.witcher3.menus.common.RightClickMenu;
	
	import scaleform.gfx.MouseEventEx;
	import flash.events.MouseEvent;
	
	import red.game.witcher3.menus.common.ItemDataStub;
	
	import red.game.witcher3.managers.PanelModuleManager;
	import red.game.witcher3.menus.common.PlayerDetails;
	import red.game.witcher3.menus.common.PlayerStatsModule;
	
	import red.game.witcher3.menus.character.CharacterTabsModule;
	import red.game.witcher3.menus.inventory.ButtonContainerModule;
	import red.game.witcher3.menus.inventory.FloatingTooltipModule;
	
	import flash.display.Sprite;
	import flash.external.ExternalInterface;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;
	
	public class PreparationMenuBase extends CoreMenu
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		public var mcButtonContainerModule : ButtonContainerModule;
		public var mcGridModule : CommonGridModule;
		//public var mcMutagensSubList : PreparationMutagensSubListModule;
		public var mcFloatingTooltipsModule : FloatingTooltipModule;
		
		public var mcPanelModuleManager : PanelModuleManager;
		public var mcAnchor_MODULE_MiddleBottom : MovieClip;
		public var mcAnchor_MODULE_BottomContextualContentCharacter : MovieClip;
		public var mcAnchor_MODULE_GRID : MovieClip;
		public var mcAnchor_MODULE_FloatingTooltip : MovieClip;
		
		/********************************************************************************************************************
			INTERNAL PROPERTIES
		/ ******************************************************************************************************************/
		
		protected var _inputHandlers:Vector.<UIComponent>;
		private	var	m_bUsingGamepad	: Boolean = true;
		
		protected var focusList	: Vector.<UIComponent> = new Vector.<UIComponent>();
		protected var iCurrentFocused : int = 0;
		
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function PreparationMenuBase()
		{
			super();
			_inputHandlers = new Vector.<UIComponent>;
		}

		override protected function get menuName():String
		{
			return "PreparationMutagensMenu";
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			addEventListener( GridEvent.ITEM_CHANGE, onGridItemChange, false, 0, true );
			focused = 1;
			
			LoadModules();
			_inputHandlers.push(mcGridModule);
			focusList.push(mcGridModule);
			
			//dispatchEvent( new GameEvent( GameEvent.REGISTER, "inventory.modules.selected",[SetChangeFocus] ) );
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			//dispatchEvent( new GameEvent( GameEvent.REGISTER, "preparation.mutagens.tab.mode",[onSetCharacterPanelMode] ) );
			stage.invalidate();
			validateNow();
			//onSetCharacterPanelMode(0);
		}
		
		function LoadModules() : void
		{

		}
		
		/********************************************************************************************************************
			INPUT
		/ ******************************************************************************************************************/
		
		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled )
			{
				return;
			}
			
			var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
						
			if (keyPress)
			{
				switch(details.navEquivalent)
				{
					case NavigationCode.GAMEPAD_L1:
					case NavigationCode.PAGE_UP:
						ChangeFocus( -1 , true );
						return;
					case NavigationCode.GAMEPAD_R1:
					case NavigationCode.PAGE_DOWN:
						ChangeFocus( 1 , true );
						return;
						
					case NavigationCode.GAMEPAD_B:
						CloseMenu();
						return;
				}
			}
			
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
		
		/********************************************************************************************************************
			UPDATES
		/ ******************************************************************************************************************/
		protected function Update() : void
		{
			
		}
		
		/********************************************************************************************************************
			PUBLIC FUNCTIONS
		/ ******************************************************************************************************************/
		
		public function CloseMenu() : void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseMenu' ) );
		}
		
		/********************************************************************************************************************
			PRIVATE FUNCTIONS
		/ ******************************************************************************************************************/
		
		protected function onGridItemChange( event:GridEvent ) : void
		{
			var itemDataStub:ItemDataStub = event.itemData as ItemDataStub;
			mcButtonContainerModule.SetActiveItemDataStub(itemDataStub);
			var displayEvent:GridEvent;
						
			if (itemDataStub)
			{
				if (itemDataStub.id) // #B probably wrong check // renderer.IsEmpty() ?
				{
					displayEvent = new GridEvent( GridEvent.DISPLAY_TOOLTIP, true, false, 0, -1, -1, null, itemDataStub );
					trace("INVENTORY onGridItemChange  DISPLAY_TOOLTIP");
				}
				else
				{
					displayEvent = new GridEvent( GridEvent.HIDE_TOOLTIP, true, false, 0, -1, -1, null, itemDataStub );
					trace("INVENTORY onGridItemChange  HIDE_TOOLTIP");
				}
			}
			else
			{
				displayEvent = new GridEvent( GridEvent.HIDE_TOOLTIP, true, false, 0, -1, -1, null, null );
				trace("INVENTORY onGridItemChange  HIDE_TOOLTIP itemDataStub = null");
			}
			dispatchEvent(displayEvent);
		}
		
		/********************************************************************************************************************
			RIGHT CLICK MENU
		/ ******************************************************************************************************************/
		
		public function IsUsingGamepad() : Boolean
		{
			m_bUsingGamepad =  ExternalInterface.call( "isUsingPad" );
			return m_bUsingGamepad;
		}
		
		private function ChangeFocus( dir : int , bCanPlaySound : Boolean )
		{
			var prevFocus : int = iCurrentFocused;
			var currentFocusedList : W3ScrollingList;
			//trace("INVENTORY ChangeFocus iCurrentFocused "+iCurrentFocused);
			if (!focusList[iCurrentFocused])
			{
				return;
			}
			
			focusList[iCurrentFocused].focused = 0;
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnUpdateTooltipCompareData", [0, 0,""]) );
			iCurrentFocused += dir;
			
			if ( iCurrentFocused < 0 )
			{
				iCurrentFocused += focusList.length;
			}
			else if ( iCurrentFocused > focusList.length - 1 )
			{
				iCurrentFocused -= focusList.length;
			}

			if( prevFocus != iCurrentFocused && bCanPlaySound )
			{
				//GameInterface.playSound("gui_journal_change_selected_list"); //@FIXME BIDON - apply sound here
			}
			
			focusList[iCurrentFocused].focused = 1;
			//trace("INVENTORY iCurrentFocused " + iCurrentFocused + " focusList[iCurrentFocused].focused END " + focusList[iCurrentFocused].focused);
			
			var displayEvent:GridEvent;
			displayEvent = new GridEvent( GridEvent.HIDE_TOOLTIP, true, false, 0, -1, -1, null, null );
			dispatchEvent(displayEvent);
			//var itemDataStub : ItemDataStub;
			//mcButtonContainerModule.SetActiveItemDataStub(itemDataStub);  // #B differ buttons later
			
			//var tempGrid : PlayerGridModule;
			/*tempGrid = focusList[iCurrentFocused] as PlayerGridModule;
			if ( tempGrid )
			{
				mcRightClickMenu.gridBindingKey = tempGrid.GetDataBindingKey();
			}*/
		}
		
		private function SetChangeFocus( ID : int )
		{
			//trace("INVENTORY SetChangeFocus " + ID);
			if( ID != iCurrentFocused )
			{
				if ( focusList[iCurrentFocused] )
				{
					focusList[iCurrentFocused].focused = 0;
				}
				
				var displayEvent:GridEvent;
				displayEvent = new GridEvent( GridEvent.HIDE_TOOLTIP, true, false, 0, -1, -1, null, null );
				dispatchEvent(displayEvent);
				//var itemDataStub : ItemDataStub;
				//mcButtonContainerModule.SetActiveItemDataStub(itemDataStub); //  #B differ buttons later
				
/*				var tempGrid : PlayerGridModule;
				tempGrid = focusList[iCurrentFocused] as PlayerGridModule;
				if ( tempGrid )
				{
					mcRightClickMenu.gridBindingKey = tempGrid.GetDataBindingKey();
				}*/
				
				iCurrentFocused = ID;
				focusList[iCurrentFocused].focused = 1;
			}
			//OnSetCurrentItem(-1)
		}
	}
}
