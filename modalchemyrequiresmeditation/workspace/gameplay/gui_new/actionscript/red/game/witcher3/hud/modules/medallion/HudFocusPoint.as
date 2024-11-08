package red.game.witcher3.hud.modules.medallion
{
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.core.UIComponent;
	import flash.events.Event;
	
	import red.game.witcher3.utils.motion.TweenEx;
	import fl.transitions.easing.Strong;
	
	public class HudFocusPoint extends UIComponent
	{

	//{region Art clips
	// ------------------------------------------------
	
	//{region Internal clips
	// ------------------------------------------------
	
	//{region Private constants
	// ------------------------------------------------
	
		private static const FADE_IN_DURATION : Number = 1000;
	
	//{region Internal properties
	// ------------------------------------------------
	
		static protected var statesDefault:Vector.<String> = Vector.<String>([""]);
		static protected var statesReserved:Vector.<String> = Vector.<String>(["reserved_", ""]);
		
		protected var _stateMap:Object = {
            up:["up"],
			over:["over", "up"],
			disabled:["disabled"]
        }
		
		protected var _newFrame:String;
		
	//{region Component properties
	// ------------------------------------------------
	
		protected var _reserved:Boolean = false;
		protected var _state:String;
	
	//{region Component setters/getters
	// ------------------------------------------------
	
		/**
         * Enable/disable this component. Focus (along with keyboard events) and mouse events will be suppressed if disabled.
         */
        [Inspectable(defaultValue="true")]
        override public function get enabled():Boolean
		{
			return super.enabled;
		}
        
		override public function set enabled(value:Boolean):void
		{
            super.enabled = value;
            mouseChildren = false; // Keep mouseChildren false for Button and its subclasses.
            
            var state:String;
            if ( super.enabled )
			{
                state = (_displayFocus || _focused ) ? "over" : "up";
            }
			else
			{
                state = "disabled";
            }
            setState( state );
        }
		
        [Inspectable(defaultValue="false")]
        public function get reserved():Boolean
		{
			return _reserved;
		}
		
		public function set reserved( value:Boolean ):void
		{
			if ( _reserved != value )
			{
				_reserved = value;
				setState( _state ); // same state but with or without reserved prefix
			}
		}
	
	//{region Initialization
	// ------------------------------------------------
	
		public function HudFocusPoint() 
		{
			super();
			addEventListener( Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true );
		}
		
		private function handleAddedToStage( event:Event ):void
		{
			effectFadeIn( this );
		}
	
	//{region Public functions
	// ------------------------------------------------
	
	//{region Overrides
	// ------------------------------------------------
		
		override protected function configUI():void
		{
			super.configUI();
		}
		
		override protected function draw():void
		{
			super.draw();
			
			 if ( isInvalid( InvalidationType.STATE ) )
			 {
                if ( _newFrame )
				{
					// FIXME: See later why it's still playing the next frame even with a stop();
                    gotoAndStop( _newFrame );
                    _newFrame = null;
                }
			 }
		}
	
		//{region Internal Updates
		// ------------------------------------------------
		
		protected function getStatePrefixes():Vector.<String>
		{
			return _reserved ? statesReserved : statesDefault;
		}
		
		protected function setState(state:String):void
		{
			_state = state;
	
			var prefixes:Vector.<String> = getStatePrefixes();
			
			var states:Array = _stateMap[ state ];
			
			if (states == null || states.length == 0)
			{
				return;
			}
			
			var l:uint = prefixes.length;
			
			for ( var i:uint = 0; i < l; ++i )
			{
				var prefix:String = prefixes[ i ];
				
				var sl:uint = states.length;
				
				for (var j:uint = 0; j < sl; j++)
				{
					var thisLabel:String = prefix + states[ j ];
					if ( _labelHash[thisLabel] )
					{
						_newFrame = thisLabel;
						invalidateState();
						return;
					}
				}
			}
		}
		
	//{region Effects
	// ------------------------------------------------
		
		private function effectFadeIn( target:Object ):void
		{
			target.alpha = 0;
			TweenEx.to( FADE_IN_DURATION, target, { alpha:1.0 }, { paused:false, ease:Strong.easeOut } );
		}
	}
}