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
	
	import scaleform.gfx.MouseEventEx;
	import flash.events.MouseEvent;
	
	import red.game.witcher3.menus.common.ItemDataStub;
	
	import red.game.witcher3.managers.PanelModuleManager;
	import red.game.witcher3.menus.common.PlayerDetails;
	import red.game.witcher3.menus.common.NavigationModule;
	import red.game.witcher3.menus.common.MessageModule;
	
	import red.game.witcher3.menus.character.CharacterTabsModule; // @FIXME BIDON - add another later
	
	import flash.display.Sprite;
	import flash.external.ExternalInterface;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;
	
	public class PreparationMainMenu extends CoreMenu
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		public var mcPlayerDetailsModule : PlayerDetails;
		public var mcNavigationModule : NavigationModule;
		public var mcTabsModule : CharacterTabsModule;
		public var mcMessageModule : MessageModule;
		
		public var mcPanelModuleManager : PanelModuleManager;
		public var mcAnchor_Module_NavigationContent : MovieClip;
		public var mcAnchor_MODULE_TopStatsContent : MovieClip;
		public var mcAnchor_Module_Tabs : MovieClip;
		public var mcAnchor_Module_Message : MovieClip;
		
		/********************************************************************************************************************
			INTERNAL PROPERTIES
		/ ******************************************************************************************************************/
		
		protected var _inputHandlers:Vector.<UIComponent>;
		private	var	m_bUsingGamepad	: Boolean = true;
		
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function PreparationMainMenu()
		{
			super();
			_inputHandlers = new Vector.<UIComponent>;
		}

		override protected function get menuName():String
		{
			return "PreparationMainMenu";
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			focused = 1;
			
			LoadModules();
			_inputHandlers.push(mcTabsModule);
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			stage.invalidate();
			validateNow();
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
		
		/********************************************************************************************************************
			RIGHT CLICK MENU
		/ ******************************************************************************************************************/
		
		public function IsUsingGamepad() : Boolean
		{
			m_bUsingGamepad =  ExternalInterface.call( "isUsingPad" );
			return m_bUsingGamepad;
		}
	}
}
