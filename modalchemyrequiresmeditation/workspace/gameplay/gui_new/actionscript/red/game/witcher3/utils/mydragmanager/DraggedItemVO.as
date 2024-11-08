package red.game.witcher3.utils.mydragmanager 
{
	
	import flash.display.Sprite;
	
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author @ Paweł
	 */
	public class DraggedItemVO 
	{
		private static var idCounter:uint=0;
		private var _id:String;
		public var slotType:String;
		public var name:String;
		public var thumb:String;
		public var view:MovieClip;
		public var currentSlot:SlotVO;
		public var isDragged:Boolean = false;
		
		
		public function DraggedItemVO(customID:String="") 
		{
			if (customID!="") 
			{
				_id = customID;
			}
			else 
			{
				_id = "item"+ (idCounter++);
			}
			
			
		}
		
		public function get id():String
		{
			return _id;
		}
		
	}

}