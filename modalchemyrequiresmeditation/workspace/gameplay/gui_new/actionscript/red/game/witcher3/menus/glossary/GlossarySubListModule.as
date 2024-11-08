/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.glossary
{
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.menus.common.JournalRewardModule;
	
	public class GlossarySubListModule extends JournalRewardModule
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		public var mcLoader : W3UILoader;
		
		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/
		
		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/
						
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function GlossarySubListModule()
		{
			super();
			mcRewards.titleString = "[[panel_glossary_recommended]]";
			dataBindingKey = "glossary.bestiary.sublist";
			mcRewards.dataBindingKeyReward = "glossary.bestiary.sublist.items";
			mcRewards.activeSelectionVisible = false;
		}
		
		protected override function configUI():void
		{
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey+'.image', [handleSetImage]));
			super.configUI();
			
			mcRewards.visible = true;
		}
		
		override public function set focused(value:Number):void 
		{
			super.focused = value;
			
			mcRewards.activeSelectionVisible = value;
			//mcRewards.mcRewardGrid.
		}

		override public function toString() : String
		{
			return "[W3 GlossarySubListModule]"
		}
		
		/********************************************************************************************************************
			PRIVATE FUNCTIONS
		/ ******************************************************************************************************************/
		
		public function handleSetImage( value : String ) : void
		{
			handleDataChanged();
			mcLoader.source = "img://textures/journal/bestiary/" + value;
		}
	}
}
