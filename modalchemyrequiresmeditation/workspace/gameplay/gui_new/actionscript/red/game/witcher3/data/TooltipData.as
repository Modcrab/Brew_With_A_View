package red.game.witcher3.data
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Tooltip component wrapper
	 * @author Yaroslav Getsevich
	 */
	public class TooltipData
	{
		public var viewerClass:String;
		public var dataSource:String;
		public var anchor:DisplayObject;
		public var anchorRect:Rectangle;
		public var alignment:String = "Right";
		public var isMouseTooltip:Boolean;
		public var directData : Boolean;		
		public var defaultAnchorName : String;
		
		public var description : String;
		public var label : String;
		
		public var isComparisonMode : Boolean;
		
		/**
		 * Tooltip data wrapper
		 * @param	viewerClass	ActionScript's class of the tooltip which will be created
		 * @param	dataSource	WitcherScript function name whitch will return tooltip's data
		 * @param 	anchor	For fixed position
		 */
		public function TooltipData(viewerClass:String = "", dataSource:String = ""):void
		{
			this.viewerClass = viewerClass;
			this.dataSource = dataSource;
		}
	}

}
