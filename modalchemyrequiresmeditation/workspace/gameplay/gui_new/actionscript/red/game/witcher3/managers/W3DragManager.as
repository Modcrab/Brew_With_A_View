package red.game.witcher3.managers
{  
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.Stage;
	
	import flash.geom.Point;
	
    import flash.events.MouseEvent;

    import scaleform.clik.events.DragEvent;
    import scaleform.clik.interfaces.IDragSlot;
	import scaleform.clik.managers.DragManager;
	
	import red.game.witcher3.controls.W3UILoader;
		
	import flash.utils.getDefinitionByName;
    
    public class W3DragManager {
        
    	/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		public static var  _dragedLoader : W3UILoader;
		public static var  _dragedSlot : W3DragSlot;
		
    	/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/
		
        /** Reference to the Stage. */
        protected static var _stage:Stage;
		
        /** TRUE if the DragManager has been initialized using init(). FALSE if not. */
        protected static var _initialized:Boolean = false;
		
        /** TRUE if the DragManager is currently dragging. FALSE if not. */
        protected static var _inDrag:Boolean = false;
        
        /** The data behind the Sprite that is currently being dragged. */
        protected static var _dragData:Object;
		
        /** Reference to the MovieClip being dragged by the DragManager. */
        protected static var _dragTarget:MovieClip;
		
        /** Reference to the original DragSlot that initiated the current drag. */
        protected static var _origDragSlot:IDragSlot;

    	/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
        public static function init( stage : Stage )  :void 
		{
            if( _initialized )
			{ 
				return;
			}
            _initialized = true;
            
            W3DragManager._stage = stage;
            _stage.addEventListener( DragEvent.DRAG_START, DragManager.handleStartDragEvent, false, 0, true );
        }
        
        /********************************************************************************************************************
			PUBLIC METHODS
		/ ******************************************************************************************************************/
        public static function inDrag() : Boolean 
		{ 
			return _inDrag;
		}
        
        public static function handleStartDragEvent( event : DragEvent ) : void
		{
            if( event.dragTarget == null || event.dragData == null ) 
			{ 
				return; 
			}
            
			var ref:Class = getDefinitionByName( 'DragInventorySlot' ) as Class; // could be done better
			_dragedSlot = new ref();
			
			_dragedSlot.IconPath = event.dragData.iconPath;
			
			_dragedSlot.scaleX = (2.0 / 3.0); // still needed ?
			_dragedSlot.scaleY = (2.0 / 3.0); // still needed ?
			
			_stage.addChild(_dragedSlot);
			
            _dragData = event.dragData;
            
            // Store a reference to the original DragSlot so it can handle a failed Drag however it wants.
            _origDragSlot = event.dragTarget;
			
			if( event.dragData.dragTarget == null )
			{
				return;
			}
			
            var origin:Point = new Point(0,0);
            var dest:Point = MovieClip(event.dragData.dragTarget).localToGlobal(origin);
			
			_dragedSlot.x = dest.x;
			_dragedSlot.y = dest.y;			
            _inDrag = true;

			var dragMC : MovieClip = _dragedSlot as MovieClip;
            dragMC.mouseEnabled = dragMC.mouseChildren = false;
            dragMC.trackAsMenu = true;
			_dragedSlot.startDrag(false);
            _stage.addEventListener(MouseEvent.MOUSE_UP, handleEndDragEvent, false, 0, true);
        }
        
        public static function handleEndDragEvent( event : MouseEvent ) : void 
		{
			
            _stage.removeEventListener(MouseEvent.MOUSE_UP, handleEndDragEvent, false);
            _inDrag = false;
            
            var isValidDrop:Boolean = false;
            var dropTarget:IDragSlot = findSpriteAncestorOf(_dragedSlot.dropTarget) as IDragSlot;
			
            // Give the original DragSlot a chance to handle the DRAG_END.
            var dragEndEvent:DragEvent = new DragEvent( DragEvent.DRAG_END, _dragData, _origDragSlot, dropTarget, null);//_dragTarget); //here
            _origDragSlot.handleDragEndEvent(dragEndEvent, isValidDrop); // NFM: This event isn't being dispatched for perf (reduces the number of IDragSlots who will receive / process the event).
            
            // Have to dispatch the event from one of the dragTargets since this class is static.
            _origDragSlot.dispatchEvent(dragEndEvent); 
				
            if (dropTarget != null && dropTarget is IDragSlot && dropTarget != _origDragSlot) 
			{
               var dropEvent:DragEvent = new DragEvent(DragEvent.DROP, _dragData, _origDragSlot, dropTarget, null); // here
                isValidDrop = dropTarget.handleDropEvent(dropEvent);
            }
            
            // Reset the drag references.
            _origDragSlot = null;
			_dragedSlot.stopDrag();
			_stage.removeChild(_dragedSlot);
			_dragedSlot = null;
        }
        
        // Finds a IDragSlot ancestor in the display list of the target DisplayObject.
        protected static function findSpriteAncestorOf( obj:DisplayObject ) : IDragSlot {
            while( obj && !(obj is IDragSlot) ) 
			{
                obj = obj.parent;
            }
            return obj as IDragSlot;
        }
		
		public static function GetDragedSlotGridSize() : int 
		{
			if ( _origDragSlot != null )
			{
				return InventorySlot(_origDragSlot).gridSize; // @FIXME BIDON should be killed (*1)
			}
			return 1;
		}
    }
}