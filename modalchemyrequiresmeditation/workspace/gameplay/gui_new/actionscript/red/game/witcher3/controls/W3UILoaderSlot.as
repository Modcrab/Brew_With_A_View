package red.game.witcher3.controls
{
	import flash.events.Event;
	import flash.net.URLRequest;
	import red.game.witcher3.constants.InventorySlotType;
	import scaleform.clik.controls.UILoader;
	
	/**
	 * Custome UILoader	for invenory slots
	 * 
	 */
	public class W3UILoaderSlot extends UILoader
	{
		protected static const DEFAULT_ICON:String = "icons/inventory/raspberryjuice_64x64.dds";
		protected var tryLoadDefault:Boolean;
		protected var _slotType:int;
		
		public function get slotType():int { return _slotType; }
		public function set slotType(value:int):void
		{
			_slotType = value;
		}
		
		// Hmm..
		public function setOriginSource(value:String):void
		{
			super.source = value;
		}
		
		override public function set source(value:String):void 
		{
			//trace("GFX core load source ", value);
			if (value && value != "")
			{
				super.source = "img://" + value;
			}
			else
			{
				super.source = "img://" + getDefaultImage();
			}
		}
		
		override protected function handleLoadIOError(ioe:Event):void 
		{
			if (!tryLoadDefault)
			{
				loader.load( new URLRequest(DEFAULT_ICON) );
				tryLoadDefault = true;
			}
			else
			{
				super.handleLoadIOError(ioe);
			}			
		}
		
		override protected function handleLoadComplete(e:Event):void 
		{
			super.handleLoadComplete(e);
			tryLoadDefault = false;
		}
		
		protected function getDefaultImage():String
		{
			switch(_slotType)
			{
				case InventorySlotType.SteelSword:
					return "icons/inventory/sword-01-A.png";
					break;
				case InventorySlotType.SilverSword:
					return "icons/inventory/sword-02-A.png";
					break;
				case InventorySlotType.Armor:
					return "icons/inventory/armor-00.png";
					break;
				case InventorySlotType.Trophy:
					return "icons/inventory/hardenedleather-00.png";
					break;
				case InventorySlotType.Gloves:
					return "icons/inventory/gauntlet-00.png";
					break;
				case InventorySlotType.Pants:
					return "icons/inventory/trousers-00.png";
					break;
				case InventorySlotType.Boots:
					return "icons/inventory/boots-00.png";
					break;
				case InventorySlotType.Trophy:
					return "icons/inventory/trophy-00.png";
					break;
				case InventorySlotType.Potion2:
				case InventorySlotType.Potion1:
					return "icons/inventory/trophy-00.png";
					break;
				default:
					return "";
					break;
			}
			return "";
		}
		
	}
}