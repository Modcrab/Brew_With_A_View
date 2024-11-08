/***********************************************************************
/** PANEL Character skills menu class
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
	import red.game.witcher3.menus.common.RightClickMenu;
	
	import scaleform.gfx.MouseEventEx;
	import flash.events.MouseEvent;

	import red.game.witcher3.managers.PanelModuleManager;
	import red.game.witcher3.menus.common.PlayerStatsModule;
	
	import flash.display.Sprite;
	import flash.external.ExternalInterface;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;
	
	public class CharacterSkillsMenu extends CoreMenu
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		public var mcPlayerStatistics : PlayerStatsModule;
		public var mcButtonContainerModule : CharacterButtonContainerModule;
		public var mcSkillTooltipModule : CharacterFloatingTooltipModule;
		public var mcSkillTreeSwordModule : SkillTreeModule;
		public var mcSkillTreeSignsModule : SkillTreeModule;
		public var mcSkillTreeAlchemyModule : SkillTreeModule;
		public var mcSkillPointsModule : CharacterPointsModule;
		public var mcFakeArrows : MovieClip;
		
		public var mcPanelModuleManager : PanelModuleManager;
		public var mcAnchor_MODULE_MiddleBottom : MovieClip;
		public var mcAnchor_MODULE_Right : MovieClip;
		public var mcAnchor_MODULE_BottomContextualContentCharacter : MovieClip;
		public var mcAnchor_MODULE_SkillTooltip : MovieClip;
		public var mcAnchor_Module_SkillTreeSword : MovieClip;
		public var mcAnchor_Module_SkillTreeSigns : MovieClip;
		public var mcAnchor_Module_SkillTreeAlchemy : MovieClip;
		public var mcAnchor_Module_SkillPoints : MovieClip;
		
		/********************************************************************************************************************
			INTERNAL PROPERTIES
		/ ******************************************************************************************************************/
		
		protected var focusList	: Vector.<UIComponent> = new Vector.<UIComponent>();
		private var iCurrentFocused : int = -1;
		
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function CharacterSkillsMenu()
		{
			super();
			mcSkillTreeSwordModule.dataBindingKey += "sword";
			mcSkillTreeSignsModule.dataBindingKey += "signs";
			mcSkillTreeAlchemyModule.dataBindingKey += "alchemy";
		}

		override protected function get menuName():String
		{
			return "CharacterSkillsMenu";
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
			
			focusList.push(mcSkillTreeSwordModule);
			focusList.push(mcSkillTreeSignsModule);
			focusList.push(mcSkillTreeAlchemyModule);
			focusList.push(mcPlayerStatistics);
			
			SetChangeFocus(0);
			
			stage.invalidate();
			validateNow();
		}
		
		function LoadModules() : void
		{
			var modules : Vector.<MovieClip>  = mcPanelModuleManager.GetModules();
	
			mcButtonContainerModule = modules[6] as CharacterButtonContainerModule;
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
				if ( skillDataStub.abilityName != 0 )
				{
					trace("CHARACTER onGridItemChange skillDataStub is ok, ablity is ok");
					displayEvent = new GridEvent( GridEvent.DISPLAY_TOOLTIP, true, false, 0, -1, -1, null, skillDataStub );
				}
				else
				{
					trace("CHARACTER onGridItemChange skillDataStub is ok, ablity is zero");
					displayEvent = new GridEvent( GridEvent.HIDE_TOOLTIP, true, false, 0, -1, -1, null, skillDataStub );
				}
			}
			else
			{
				trace("CHARACTER onGridItemChange skillDataStub error");
				displayEvent = new GridEvent( GridEvent.HIDE_TOOLTIP, true, false, 0, -1, -1, null, skillDataStub );
			}
			trace("CHARACTER ##########################");
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

			if( prevFocus != iCurrentFocused && bCanPlaySound )
			{
				//GameInterface.playSound("gui_journal_change_selected_list"); //@FIXME BIDON - apply sound here
			}
			
			focusList[iCurrentFocused].focused = 1;
			
			var displayEvent:GridEvent;
			displayEvent = new GridEvent( GridEvent.HIDE_TOOLTIP, true, false, 0, -1, -1, null, null );
			dispatchEvent(displayEvent);
		}
		
		private function SetChangeFocus( ID : int )
		{
			if( ID != iCurrentFocused )
			{
				if ( iCurrentFocused > -1 && focusList[iCurrentFocused] )
				{
					focusList[iCurrentFocused].focused = 0;
				}
				
				var displayEvent:GridEvent;
				displayEvent = new GridEvent( GridEvent.HIDE_TOOLTIP, true, false, 0, -1, -1, null, null );
				dispatchEvent(displayEvent);
				
				iCurrentFocused = ID;
				focusList[iCurrentFocused].focused = 1;
			}
		}
	}
}
