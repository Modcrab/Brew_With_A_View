package red.game.witcher3.hud.modules
{
	import flash.display.MovieClip;
	import red.core.events.GameEvent;
	import red.game.witcher3.hud.modules.HudModuleBase;
	import red.game.witcher3.constants.InventorySlotType;

	public class HudModuleDamagedItems extends HudModuleBase
	{
		public var mcSilver			:		MovieClip;
		public var mcSteel			:		MovieClip;
		public var mcArmor			:		MovieClip;
		public var mcBoots			:		MovieClip;
		public var mcTrousers		:		MovieClip;
		public var mcGloves			:		MovieClip;

		public function HudModuleDamagedItems()
		{
			super();
		}

		override public function get moduleName():String
		{
			return "DamagedItemsModule";
		}

		override protected function configUI():void
		{
			super.configUI();

			alpha = 0;
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}

		public function setItemDamaged( slot : int, damaged : Boolean )
		{
			switch ( slot )
			{
				case InventorySlotType.SilverSword:
					mcSilver.gotoAndStop( damaged +1 );
					break;
				case InventorySlotType.SteelSword:
					mcSteel.gotoAndStop( damaged +1 );
					break;
				case InventorySlotType.Armor:
					mcArmor.gotoAndStop( damaged +1 );
					break;
				case InventorySlotType.Boots:
					mcBoots.gotoAndStop( damaged +1 );
					break;
				case InventorySlotType.Pants:
					mcTrousers.gotoAndStop( damaged +1 );
					break;
				case InventorySlotType.Gloves:
					mcGloves.gotoAndStop( damaged +1 );
					break;
			}
		}
	}

}