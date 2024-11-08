/***********************************************************************
/** PANEL Character perks menu class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.character
{
	import flash.display.MovieClip;
	import red.core.events.GameEvent;
	import scaleform.clik.core.UIComponent;
	
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
	
	import scaleform.gfx.MouseEventEx;
	import flash.events.MouseEvent;

	import red.game.witcher3.managers.PanelModuleManager;
	import red.game.witcher3.menus.common.PlayerStatsModule;
	
	import flash.display.Sprite;
	import flash.external.ExternalInterface;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;
	
	public class CharacterPerksMenu extends CoreMenu
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		public var mcPlayerStatistics : PlayerStatsModule;
		public var mcButtonContainerModule : CharacterButtonContainerModule;
		public var mcPerkTreeModule : PerkTreeModule;
		public var mcBookPerkTreeModule : PerkTreeModule;
		public var mcSkillTooltipModule : CharacterFloatingTooltipModule;
		
		public var mcPanelModuleManager : PanelModuleManager;
		public var mcAnchor_MODULE_MiddleBottom : MovieClip;
		public var mcAnchor_MODULE_Right : MovieClip;
		public var mcAnchor_MODULE_BottomContextualContentCharacter : MovieClip;
		public var mcAnchor_Module_PerkTree : MovieClip;
		public var mcAnchor_Module_BooksPerkTree : MovieClip;
		public var mcAnchor_MODULE_SkillTooltip : MovieClip;
		
		/********************************************************************************************************************
			INTERNAL PROPERTIES
		/ ******************************************************************************************************************/
		
		protected var focusList	: Vector.<UIComponent> = new Vector.<UIComponent>();
		private var iCurrentFocused : int = -1;
		
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function CharacterPerksMenu()
		{
			super();
			mcBookPerkTreeModule.dataBindingKey = "character.tree.bookperks";
		}

		override protected function get menuName():String
		{
			return "CharacterPerksMenu";
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			addEventListener( GridEvent.ITEM_CHANGE, onGridItemChange, false, 0, true );
			focused = 1;
			
			LoadModules();
			
			//dispatchEvent( new GameEvent( GameEvent.REGISTER, "inventory.modules.selected",[SetChangeFocus] ) );
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );

			focusList.push(mcPerkTreeModule);
			focusList.push(mcBookPerkTreeModule);
			focusList.push(mcPlayerStatistics);
			
			SetChangeFocus(0);
			
			stage.invalidate();
			validateNow();
		}
		
		function LoadModules() : void
		{
			var modules : Vector.<MovieClip>  = mcPanelModuleManager.GetModules();
	
			mcButtonContainerModule = modules[4] as CharacterButtonContainerModule;
			mcButtonContainerModule.validateNow();
			_inputHandlers.push(mcButtonContainerModule);
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
			var skillDataStub : SkillDataStub = event.itemData as SkillDataStub;
			if ( skillDataStub.isSkill )
			{
				mcButtonContainerModule.SetActiveSkillDataStub(skillDataStub); // #B differ buttons later
			}
			else
			{
				mcButtonContainerModule.SetActiveSkillDataStub(null);
			}
			
			var displayEvent:GridEvent;
			if (skillDataStub)
			{
				if ( skillDataStub.abilityName != 0 ) //@FIXME BIDON - first skill coould have problem with tooltip
				{
					displayEvent = new GridEvent( GridEvent.DISPLAY_TOOLTIP, true, false, 0, -1, -1, null, skillDataStub );
				}
				else
				{
					displayEvent = new GridEvent( GridEvent.HIDE_TOOLTIP, true, false, 0, -1, -1, null, skillDataStub );
				}
			}
			else
			{
				displayEvent = new GridEvent( GridEvent.HIDE_TOOLTIP, true, false, 0, -1, -1, null, skillDataStub );
			}
			dispatchEvent(displayEvent);
		}
		
		private function ChangeFocus( dir : int , bCanPlaySound : Boolean )
		{
			var prevFocus : int = iCurrentFocused;
			var currentFocusedList : W3ScrollingList;

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
/*			if ( focusList[iCurrentFocused] is W3ScrollingList ) // #B ?
			{
				currentFocusedList = W3ScrollingList(focusList[iCurrentFocused]);
				if( currentFocusedList.dataProvider.length < 1 )
				{
					ChangeFocus( dir, false );
				}
			}*/
			
			//trace("INVENTORY midf iCurrentFocused "+iCurrentFocused+ " focusList[iCurrentFocused].focused "+focusList[iCurrentFocused].focused);

			if( prevFocus != iCurrentFocused && bCanPlaySound )
			{
				//GameInterface.playSound("gui_journal_change_selected_list"); //@FIXME BIDON - apply sound here
			}
			
			focusList[iCurrentFocused].focused = 1;
			//trace("INVENTORY iCurrentFocused " + iCurrentFocused + " focusList[iCurrentFocused].focused END " + focusList[iCurrentFocused].focused);
			
			var displayEvent:GridEvent;
			displayEvent = new GridEvent( GridEvent.HIDE_TOOLTIP, true, false, 0, -1, -1, null, null );
			dispatchEvent(displayEvent);
		}
		
		private function SetChangeFocus( ID : int )
		{
			//trace("INVENTORY SetChangeFocus " + ID);
			if( ID != iCurrentFocused )
			{
				if ( iCurrentFocused > -1 && focusList[iCurrentFocused] )
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
