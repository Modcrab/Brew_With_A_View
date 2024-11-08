package red.game.cyberpunk.events {
    
    import flash.events.Event;
    
    public class TooltipEvent extends Event {
        
    // Constants:
		public static const SHOW:String = "tooltipShow";
		public static const HIDE:String = "tooltipHide";
		
	// Data:
        public var tooltipData:Object; // TBD
                
    // Initialization:
        public function TooltipEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = true, tooltipData:Object = null ) 
        {
            super(type, bubbles, cancelable);
            
            this.tooltipData = tooltipData;
        }
        
    // Public getter / setters:
        
    // Public Methods:
        override public function clone():Event {
            return new TooltipEvent(type, bubbles, cancelable, tooltipData);
        }
        
        override public function toString():String {
            return formatToString("Cyberpunk TooltipEvent", "type", "bubbles", "cancelable", "tooltipData");
        }
        
    // Protected Methods:
        
    }
    
}