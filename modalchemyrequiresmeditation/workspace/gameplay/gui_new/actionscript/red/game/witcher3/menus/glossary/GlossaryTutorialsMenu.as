/***********************************************************************
/** PANEL glossary tutorial main class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/
package red.game.witcher3.menus.glossary
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import red.core.CoreComponent;
	import red.core.events.GameEvent;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.TextAreaModuleCustomInput;
	import red.game.witcher3.utils.CommonUtils;
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

	public class GlossaryTutorialsMenu extends CoreMenu
	{
		/********************************************************************************************************************
				ART CLIPS
		/ ******************************************************************************************************************/
		//public var mcPanelModuleManager : PanelModuleManager;

		public var 		mcMainListModule					: DropdownListModuleBase; 
		public var 		mcGlossarySubModule					: GlossaryTextureSubListModule;
		public var 		mcTextAreaModule					: TextAreaModuleCustomInput;

		/********************************************************************************************************************
				INTERNAL PROPERTIES
		/ ******************************************************************************************************************/

		public function GlossaryTutorialsMenu()
		{
			super();
			mcMainListModule.menuName = menuName;
			mcGlossarySubModule.dataBindingKey = "glossary.tutorials";
		}

		override protected function get menuName():String
		{
			return "GlossaryTutorialsMenu";
		}

		override protected function configUI():void
		{
			super.configUI();
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerUpdate, false, 0, true);
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );	
			focused = 1;
		}
		
		private function handleControllerUpdate(event:Event):void
		{
			mcMainListModule.mcDropDownList.clearRenderers();			
			mcMainListModule.validateNow();
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnUpdateTutorials" ) );
			
			mcMainListModule.removeEventListener(Event.CHANGE, handleDataChanged);
			mcMainListModule.addEventListener(Event.CHANGE, handleDataChanged, false, 0, true);
		}
		
		private function handleDataChanged(event:Event):void
		{
			mcMainListModule.removeEventListener(Event.CHANGE, handleDataChanged);
			mcMainListModule.mcDropDownList.selectedIndex = 0;
			mcMainListModule.mcDropDownList.validateNow();
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
		
		/*
		 * Update selected tutorial data
		 * 
		 * */
		
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
				value = CommonUtils.fixFontStyleTags(value);
				
				// #Y hack for arabic
				if ( CoreComponent.isArabicAligmentMode && value.charAt(1) == "." )
				{
					var txtValue:String = value;
					
					mcTextAreaModule.SetText( "." + value.charAt(1) + value.slice(2) );
				}
				else
				{
					mcTextAreaModule.SetText(value);
				}
				
				mcTextAreaModule.mcSeparator.visible = value != "";
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
	}

}
