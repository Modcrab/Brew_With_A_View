/***********************************************************************
/** Clean module
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.preparation
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import scaleform.clik.core.UIComponent;
	import red.core.events.GameEvent;
	
	public class PreparationToxicityBarModule extends UIComponent
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		public var tfDescription : TextField;
		public var tfMax : TextField;
		public var tfMin : TextField;
		public var mcDarkBar : MovieClip;
		public var mcLightBar : MovieClip;
		
		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/
		
		public var dataBindingKey : String = "preparation.toxicity.bar.";
		private var _maxValue : Number = 100;
		
		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/
				
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function PreparationToxicityBarModule()
		{
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
			focusable = false;
			mouseChildren = mouseEnabled = false;
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey+"description", [handleDescriptionSet]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey+"max", [handleMaxValueSet]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey+"value", [handleValueSet]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey+"locked", [handleLockedValueSet]));
		}
		
		protected function handleDescriptionSet( name : String ):void
		{
			if (tfDescription)
			{
				tfDescription.htmlText = name;
			}
		}
		
		protected function handleMaxValueSet( value : Number ):void
		{
			if (tfMax)
			{
				tfMax.htmlText = value.toString();
				_maxValue = value;
			}
		}
		
		protected function handleValueSet( value : Number ):void
		{
			if (mcDarkBar)
			{
				mcDarkBar.mcMask.x = -391 * ( 1 - value / _maxValue ) + 6;
			}
		}
		
		protected function handleLockedValueSet( value : Number ):void
		{
			if (mcLightBar)
			{
				mcLightBar.mcMask.x = -391 * ( 1 - value / _maxValue ) + 6;
			}
		}
				
		override public function toString() : String
		{
			return "[W3 PreparationToxicityBarModule]"
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
