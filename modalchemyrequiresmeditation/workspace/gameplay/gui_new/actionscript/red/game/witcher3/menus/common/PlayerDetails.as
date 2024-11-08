/***********************************************************************
/** Inventory Player details module
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import scaleform.clik.core.UIComponent;
	import red.core.events.GameEvent;
	
	public class PlayerDetails extends UIComponent
	{
		public var mcWeightStat : PlayerDetailsStatItem;
		public var mcMoneyStat : PlayerDetailsStatItem;
		public var mcLevelStat : PlayerDetailsStatItem;
		
		public function PlayerDetails()
		{
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
			focusable = false;
			mouseChildren = mouseEnabled = false;
			//enabled = false;
			
			//mcWeightStat.SetStatName("[[panel_inventory_weight]]");
			//mcMoneyStat.SetStatName("[[panel_inventory_money]]");
			mcLevelStat.SetStatName("[[panel_inventory_level]]");
			
			mcWeightStat.SetIcon("weight");
			mcMoneyStat.SetIcon("money");
			//mcLevelStat.SetIcon("level");
			
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "panel.main.playerdetails.level", [SetLevel]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "panel.main.playerdetails.money", [SetMoney]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "panel.main.playerdetails.weight", [SetWeight]));
		}
		
		public function SetLevel( value : int ) : void
		{
			mcLevelStat.SetValue(value.toString());
		}
		
		public function SetMoney( value : int ) : void
		{
			mcMoneyStat.SetValue(value.toString());
		}
		
		public function SetWeight( value : String ) : void
		{
			mcWeightStat.SetValue(value);
		}
	}
}
