package red.game.witcher3.utils.mydragmanager 
{
	
	
	
	import flash.display.MovieClip;
	import flash.geom.Point;
	/**
	 * ...
	 * @author @ Paweł
	 */
	public class SlotVO 
	{
		
		static public const STATE_NORMAL:String = "normal";
		static public const STATE_AVAILABLE:String = "available";
		static public const STATE_DISABLED:String = "disabled";
		
		private static var idCounter:uint=0;
		private var _id:uint;
		
		private var _isEmpty:Boolean;
		private var _item:DraggedItemVO;
		public var slotType:String;
		
		public var position:Point;
		public var view:MovieClip;
		
		public var superSlot:SlotVO;
		public var extendedSlots:Vector.<SlotVO> = new Vector.<SlotVO>();
		
		public var isPaperDollSlot:Boolean = false;
		
		public function SlotVO() 
		{
			_id = idCounter++;
		}
		
		public function get id():uint 
		{
			return _id;
		}
		
		public function get isEmpty():Boolean 
		{
			if (item==null && superSlot==null) 
			{
				return true;
			}
			return false;
		}
		
		public function get item():DraggedItemVO 
		{
			return _item;
		}
		
		public function set item(value:DraggedItemVO):void 
		{
			_item = value;
		}
		
		public function clearSlot():void 
		{
			for (var i:int = 0; i < extendedSlots.length; i++) 
			{
				clearSlotVO(extendedSlots[i]);	
			}
			clearSlotVO(this);
		}
		
		private function clearSlotVO(vo:SlotVO):void 
		{
			vo.extendedSlots = new Vector.<SlotVO>();
			vo.superSlot = null;
			vo.item = null;
		}
		
	
		
		
		
	}

}