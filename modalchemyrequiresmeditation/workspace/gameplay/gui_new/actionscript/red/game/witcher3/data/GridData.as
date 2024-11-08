package red.game.witcher3.data
{        
	import scaleform.clik.data.ListData;
	
    public class GridData extends ListData 
	{
    	/********************************************************************************************************************
			PUBLIC PROPERTIES
		/ ******************************************************************************************************************/
		
		public var iconPath:String;
		public var gridSize:int;

    	/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
        public function GridData(index:uint, label:String = "Empty", selected:Boolean = false, iconPath = "", gridSize = 1)
		{
			super( index, label, selected );
			this.iconPath = iconPath;
			this.gridSize = gridSize;
        }
        
		/********************************************************************************************************************
			OVERRIDES
		/ ******************************************************************************************************************/
        
        override public function toString():String {
            return "[W3 GridData " + index + ", " + label + ", " + selected + ", " + iconPath + ", " + gridSize + "]";
        }        
    }
    
}