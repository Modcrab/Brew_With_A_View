package red.core.events {

    import flash.events.Event;

    public class GameEvent extends Event {

    // Constants:
		public static const CALL:String = "callGameEvent";
		public static const REGISTER:String = "registerDataBinding";
		public static const UNREGISTER:String = "unregisterDataBinding";
		public static const PASSINPUT:String = "passInput";
		public static const UPDATE:String = "update";
	// Data:
		public var eventName:String;
        public var eventArgs:Array;

    // Initialization:
        public function GameEvent(type:String, eventName:String, eventArgs:Array = null, bubbles:Boolean = true, cancelable:Boolean = true )
        {
            super(type, bubbles, cancelable);

			this.eventName = eventName;
			this.eventArgs = eventArgs;
        }

    // Public getter / setters:

    // Public Methods:
        override public function clone():Event {
            return new GameEvent( type, eventName, eventArgs, bubbles, cancelable );
        }

        override public function toString():String {
            return formatToString("Red GameEvent", "type", "eventName", "eventArgs", "bubbles", "cancelable" );
        }

    // Protected Methods:

    }

}