/***********************************************************************
/** Inventory Player details stat item
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.core.CoreComponent;
	
	public class PlayerDetailsStatItem extends CoreComponent
	{				
		public var mcIcon : MovieClip;
		public var tfLabel : TextField;
		public var tfValue : TextField;
		
		public function PlayerDetailsStatItem() 
		{
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
		}
		
		public function SetStatName( value : String ) : void
		{
			tfLabel.htmlText = value;
		}
		
		public function SetValue( value : String ) : void
		{
			tfValue.htmlText = value; 
		}
		
		public function SetIcon( value : String ) : void
		{
			mcIcon.gotoAndStop(value);
		}
	}
}
