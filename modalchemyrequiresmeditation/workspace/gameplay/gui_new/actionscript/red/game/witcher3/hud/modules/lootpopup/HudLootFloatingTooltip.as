package red.game.witcher3.hud.modules.lootpopup
{
	import flash.display.MovieClip;
	import red.game.witcher3.menus.common.FloatingTooltip;
	import scaleform.clik.data.DataProvider;
	
	//>------------------------------------------------------------------------------------------------------------------
	//-------------------------------------------------------------------------------------------------------------------
	public class HudLootFloatingTooltip extends FloatingTooltip //#B obsolete
	{
		//>------------------------------------------------------------------------------------------------------------------
		// VARIABLES
		//-------------------------------------------------------------------------------------------------------------------
		// On scene elements
		public var mcPointingArrow : MovieClip;
		
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function HudLootFloatingTooltip()
		{
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function setData( _Data:Object )
		{
			//Gives error when exporting swf
			//SetPriceText("[[panel_inventory_item_price]]");
			/////////////////////////////////
			SetPrice( _Data.price );
			SetTitle( String( _Data.label ) );
			
			if ( _Data.stats )
			{
				//mcStatsList.updateData( _Data.stats as Array);
				mcStatsList.dataProvider = new DataProvider( _Data.stats as Array );
			}
		}
		
	}

}