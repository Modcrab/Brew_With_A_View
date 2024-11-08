package red.game.witcher3.data 
{
	/**
	 * SysMesssages init data (TCR, etc)
	 * @author Getsevich Yaroslav
	 */
	public class SysMessageData 
	{
		public var id:int;
		public var messageText:String;
		public var titleText:String;
		public var priority:uint;
		public var type:uint;
		public var userData:Object;
		public var buttonList:Array; // map [id: <MessageButton id>, label : String ] label is optional
		
		public function toString():String
		{
			return "<SysMessageData> [id: " + id +  "; priority: " + priority + "; messageText: " + messageText + " ]";
		}
	}
}
