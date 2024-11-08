/***********************************************************************
/** PANEL glossary places main class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/
package red.game.witcher3.menus.glossary
{
	import flash.display.MovieClip;
	import red.core.events.GameEvent;
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

	//import red.game.witcher3.managers.PanelModuleManager;
	import red.game.witcher3.menus.common.TextAreaModule;

	import red.game.witcher3.menus.common.ItemDataStub;

	import flash.display.Sprite;
	import flash.external.ExternalInterface;

	import red.game.witcher3.menus.common.DropdownListModuleBase;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;

	public class GlossaryPlacesMenu extends CoreMenu
	{
		/********************************************************************************************************************
				ART CLIPS
		/ ******************************************************************************************************************/
		//public var mcPanelModuleManager : PanelModuleManager;

		public var 		mcMainListModule					: DropdownListModuleBase;
		public var 		mcGlossarySubModule					: GlossaryTextureSubListModule;
		public var 		mcTextAreaModule					: TextAreaModule;

		/********************************************************************************************************************
				INTERNAL PROPERTIES
		/ ******************************************************************************************************************/

		public function GlossaryPlacesMenu()
		{
			super();
			mcMainListModule.menuName = menuName;
			mcTextAreaModule.dataBindingKey = "glossary.places.description";
			mcGlossarySubModule.dataBindingKey = "glossary.places.sublist";
			mcGlossarySubModule.imagePathPrefix = "img://textures/journal/places/";
		}

		override protected function get menuName():String
		{
			return "GlossaryPlacesMenu";
		}

		override protected function configUI():void
		{
			super.configUI();
			//trace("DROPDOWN QuestJournalMenu# configUI start");
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			stage.invalidate();
			validateNow();

			focused = 1;
		}

		override public function ShowSecondaryModules( value : Boolean )
		{
			super.ShowSecondaryModules( value );
			mcGlossarySubModule.visible = value;
			mcGlossarySubModule.enabled = value;

			mcTextAreaModule.visible = value;
			mcTextAreaModule.enabled = value;
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
				handler.handleInput( event );
			}

			var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);

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

		/********************************************************************************************************************
			UPDATES
		/ ******************************************************************************************************************/
		protected function Update() : void
		{

		}
	}

}