/***********************************************************************
/** PANEL glossary bestiary main class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/
package red.game.witcher3.menus.glossary
{
	import flash.display.MovieClip;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3RenderToTextureHolder;
	import red.game.witcher3.menus.common.TextAreaModuleCustomInput;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ListEvent;

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

	import red.game.witcher3.managers.PanelModuleManager;
	import red.game.witcher3.menus.common.PlayerDetails;
	import red.game.witcher3.menus.common.PlayerStatsModule;
	import red.game.witcher3.menus.common.TextAreaModule;

	import red.game.witcher3.menus.common.ItemDataStub;

	import flash.display.Sprite;
	import flash.external.ExternalInterface;

	import red.game.witcher3.menus.common.DropdownListModuleBase;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;

	public class GlossaryBestiaryMenu extends CoreMenu
	{
		/********************************************************************************************************************
				ART CLIPS
		/ ******************************************************************************************************************/
		public var mcPanelModuleManager : PanelModuleManager;

		public var 		mcMainListModule					: DropdownListModuleBase;
		public var 		mcGlossarySubModule					: GlossarySubListModule;
		public var 		mcTextAreaModule					: TextAreaModuleCustomInput;
		public var 		mcMonsterTexture 					: W3RenderToTextureHolder;

		/*public var 		mcAnchor_MODULE_QuestList			: MovieClip;
		public var 		mcAnchor_MODULE_TextArea			: MovieClip;
		public var 		mcAnchor_MODULE_SubList				: MovieClip;*/
		public var 		mcAnchor_MODULE_Tooltip				: MovieClip;

		/********************************************************************************************************************
				INTERNAL PROPERTIES
		/ ******************************************************************************************************************/

		private	var	m_bUsingGamepad	: Boolean = true;

		public function GlossaryBestiaryMenu()
		{
			super();
			mcMainListModule.menuName = menuName;
			mcMainListModule.selectModuleOnClick = true;
		}

		override protected function get menuName():String
		{
			return "GlossaryBestiaryMenu";
		}

		override protected function configUI():void
		{
			super.configUI();
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			addEventListener( GridEvent.ITEM_CHANGE, onGridItemChange, false, 0, true );

			_contextMgr.defaultAnchor = mcAnchor_MODULE_Tooltip;
			_contextMgr.addGridEventsTooltipHolder(stage);
			_contextMgr.enableInputFeedbackShowing(true);
			
			//_contextMgr.blockModeSwitching = true;
			
			registerRenderTarget( "test_nopack", 1024, 1024 );

			//stage.invalidate();
			//validateNow();

			focused = 1;
			_contextMgr.defaultAnchor = mcAnchor_MODULE_Tooltip;
			_contextMgr.addGridEventsTooltipHolder(stage);
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			
			mcGlossarySubModule.mcRewards.mcRewardGrid.initFindSelection = false;
			//mcGlossarySubModule.mcLoader.visible = false
		}

		override public function ShowSecondaryModules( value : Boolean )
		{
			super.ShowSecondaryModules( value );
			
			mcGlossarySubModule.active = value;
			mcTextAreaModule.active = value;
		}

		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled )
			{
				return;
			}

			for each ( var handler:UIComponent in actualModules )
			{
				if ( event.handled )
				{
					event.stopImmediatePropagation();
					return;
				}
				//trace("DROPDOWN inputHandler "+handler);
				handler.handleInput( event );
			}

			var details:InputDetails = event.details;
            var keyPress:Boolean = details.value == InputValue.KEY_UP;// (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);

			if (keyPress)
			{
				switch(details.navEquivalent)
				{
					case NavigationCode.GAMEPAD_B :
						hideAnimation();
						break;
				}
			}
		}
		
		public function hideContent(value:Boolean):void
		{
			mcGlossarySubModule.mcRewards.enabled = value;
			mcGlossarySubModule.mcRewards.mcRewardGrid.enabled = value;
			
			mcGlossarySubModule.active = value;
			mcTextAreaModule.active = value;
			//mcGlossarySubModule.visible = value;
			//mcTextAreaModule.visible = value;
			if (!value)
			{
				var hideEvent:GridEvent = new GridEvent(GridEvent.HIDE_TOOLTIP, true, false, -1, -1, -1, null, null);
				dispatchEvent(hideEvent);
			}
		}
		
		public function setTitle( value : String ) : void
		{
			if (mcTextAreaModule)
			{
				mcTextAreaModule.SetTitle(value);
			}
		}
		
		public function setText( value : String  ) : void
		{
			if (mcTextAreaModule)
			{
				mcTextAreaModule.SetText(value);
			}
		}
		
		public function setImage( value : String ) : void
		{
			if (mcGlossarySubModule)
			{
				mcGlossarySubModule.handleSetImage(value);
			}
		}

		/********************************************************************************************************************
			UPDATES
		/ ******************************************************************************************************************/
		protected function Update() : void
		{

		}

		/********************************************************************************************************************
			PRIVATE FUNCTIONS
		/ ******************************************************************************************************************/

		protected function onGridItemChange( event:GridEvent ) : void
		{
			var itemDataStub:ItemDataStub = event.itemData as ItemDataStub;
			var displayEvent:GridEvent;
			if (itemDataStub)
			{
				if (itemDataStub.id)
				{
					displayEvent = new GridEvent( GridEvent.DISPLAY_TOOLTIP, true, false, 0, -1, -1, null, itemDataStub );
				}
				else
				{
					displayEvent = new GridEvent( GridEvent.HIDE_TOOLTIP, true, false, 0, -1, -1, null, itemDataStub );
				}
			}
			else
			{
				displayEvent = new GridEvent( GridEvent.HIDE_TOOLTIP, true, false, 0, -1, -1, null, itemDataStub );
			}
			dispatchEvent(displayEvent);
		}

		/********************************************************************************************************************
			Move to common
		/ ******************************************************************************************************************/
		public function IsUsingGamepad() : Boolean
		{
			m_bUsingGamepad =  ExternalInterface.call( "isUsingPad" );
			return m_bUsingGamepad;
		}
	}

}
