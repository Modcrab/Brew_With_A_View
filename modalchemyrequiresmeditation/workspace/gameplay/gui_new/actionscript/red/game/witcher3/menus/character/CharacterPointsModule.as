/***********************************************************************
/** Clean module
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.character
{
	import flash.text.TextField;
	import scaleform.clik.core.UIComponent;
	import red.core.events.GameEvent;
	
	public class CharacterPointsModule extends UIComponent
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		public var tfSkillPointsDescription : TextField;
		public var tfSkillPoints : TextField;
		
		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/
		
		public var dataBindingKey : String = "character.points.";
		
		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/
				
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function CharacterPointsModule()
		{
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
			focusable = false;
			mouseChildren = mouseEnabled = false;
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey+"description", [handleDescriptionSet]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey+"value", [handleValueSet]));
		}
		
		protected function handleDescriptionSet( name : String ):void
		{
			if (tfSkillPointsDescription)
			{
				tfSkillPointsDescription.htmlText = name;
			}
		}
		
		protected function handleValueSet( value : int ):void
		{
			if (tfSkillPoints)
			{
				tfSkillPoints.htmlText = value.toString();
			}
		}
				
		override public function toString() : String
		{
			return "[W3 CharacterPointsModule]"
		}
		
		/********************************************************************************************************************
			PRIVATE FUNCTIONS
		/ ******************************************************************************************************************/
		public function GetDataBindingKey() : String
		{
			return dataBindingKey;
		}
	}
}
