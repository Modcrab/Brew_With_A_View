package red.game.witcher3.events
{
    import flash.events.Event;
	import flash.geom.Rectangle;
	import scaleform.clik.events.ListEvent;
    import scaleform.clik.interfaces.IListItemRenderer;

    public class GridEvent extends ListEvent
	{
    	/********************************************************************************************************************
			CONSTANTS
		/ ******************************************************************************************************************/

        public static const ITEM_CHANGE:String = "gridItemChange";
        public static const DISPLAY_TOOLTIP:String = "gridDisplayTooltip";
        public static const HIDE_TOOLTIP:String = "gridHideTooltip";
        public static const DISPLAY_OPTIONSMENU:String = "gridDisplayOptionsMenu";
        public static const HIDE_OPTIONSMENU:String = "gridHideOptionsMenu";
        public static const HILIGHTSLOT:String = "paperdollHilightSlot";

    	/********************************************************************************************************************
			TOOLTIP EXTENDS
		/ ******************************************************************************************************************/

		public var tooltipContentRef:String;
		public var tooltipMouseContentRef:String;
		public var tooltipDataSource:String;
		public var tooltipCustomArgs:Array;
		public var tooltipForceSetDataSource:Boolean = false; // #Y2 Hack for empty slots in the paperdoll;
		public var directData : Boolean;

		public var tooltipAlignment:String = "Right";
		public var anchorRect:Rectangle;
		public var defaultAnchor:String;
		public var isMouseTooltip:Boolean;

    	/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/

        public function GridEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = true,
                                  index:int = -1, columnIndex:int = -1, rowIndex:int = -1,
                                  itemRenderer:IListItemRenderer = null, itemData:Object = null,
                                  controllerIdx:uint = 0, buttonIdx:uint = 0, isKeyboard:Boolean = false)
        {
            super(type, bubbles, cancelable, index, columnIndex, rowIndex, itemRenderer, itemData, controllerIdx, buttonIdx, isKeyboard );
        }

       	/********************************************************************************************************************
			PUBLIC METHODS
		/ ******************************************************************************************************************/

        override public function clone() : Event {
            return new GridEvent(type, bubbles, cancelable, index, columnIndex, rowIndex, itemRenderer, itemData, controllerIdx, buttonIdx, isKeyboard);
        }

        override public function toString() : String {
            return formatToString("GridEvent", "type", "bubbles", "cancelable", "index", "columnIndex", "rowIndex", "itemRenderer", "itemData", "controllerIdx", "buttonIdx", "isKeyboard");
        }
    }
}
