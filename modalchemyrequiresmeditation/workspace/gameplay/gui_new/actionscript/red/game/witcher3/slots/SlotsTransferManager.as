package red.game.witcher3.slots
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import red.game.witcher3.events.ItemDragEvent;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.interfaces.IDragTarget;
	import red.game.witcher3.interfaces.IDropTarget;
	import red.game.witcher3.interfaces.IInventorySlot;
	import red.game.witcher3.utils.Math2;
	import scaleform.clik.core.UIComponent;
	import scaleform.gfx.Extensions;
	import scaleform.gfx.MouseEventEx;
	
	/**
	 * Drag manager for slots
	 * @author Yaroslav Getsevich
	 */
	public class SlotsTransferManager extends EventDispatcher
	{
		protected static const DRAG_START_OFFSET:Number = 10;
		protected static var _instance:SlotsTransferManager;
		protected var _dragTargets:Vector.<IDragTarget>;
		protected var _dropTargets:Vector.<IDropTarget>;
		protected var _actualDropTargets:Vector.<IDropTarget>;
		
		protected var _downPoint:Point;
		protected var _dragging:Boolean;
		protected var _canvas:Sprite;
		protected var _avatar:SlotDragAvatar;
		
		protected var _disabled:Boolean;
		
		protected var _currentStage:Stage;
		protected var _currentDragItem:IDragTarget;
		protected var _currentRecepient:IDropTarget;
		
		public static function getInstance():SlotsTransferManager
		{
			if (!_instance) _instance = new SlotsTransferManager();
			return _instance;
		}
		
		public function SlotsTransferManager()
		{
			_dragTargets = new Vector.<IDragTarget>;
			_dropTargets = new Vector.<IDropTarget>;
			_actualDropTargets = new Vector.<IDropTarget>;
		}
		
		public function get disabled():Boolean { return _disabled }
		public function set disabled(value:Boolean):void
		{
			_disabled = value;
			
			if (_disabled && _dragging)
			{
				stopDrag();
			}
		}
		
		public function init(targetCanvas:Sprite):void
		{
			_canvas = targetCanvas;
		}
		
		public function isDragging():Boolean
		{
			return _dragging;
		}
		
		public function addDragTarget(target:IDragTarget):void
		{
			_dragTargets.push(target);
			target.addEventListener(Event.REMOVED_FROM_STAGE, handleDragRemovedFromStage, false, 0, true);
			target.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
			target.addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver, false, 0, true);
			target.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut, false, 0, true);
		}
		
		public function addDropTarget(target:IDropTarget):void
		{
			_dropTargets.push(target);
			target.addEventListener(Event.REMOVED_FROM_STAGE, handleDropRemovedFromStage, false, 0, true);
		}
		
		public function removeDragTarget(target:IDragTarget):void
		{
			var idx:int = _dragTargets.indexOf(target);
			if (idx > -1) _dragTargets.splice(idx, 1);
		}
		
		public function removeDropTarget(target:IDropTarget):void
		{
			var idx:int = _dropTargets.indexOf(target);
			if (idx > -1) _dropTargets.splice(idx, 1);
		}
		
		public function showDropTargets(target:IDragTarget):void
		{
			if (!_dragging)
			{
				removeDropHighlighting();
				if (target.canDrag())
				{
					highlightDropTargets(target);
				}
			}
		}
		
		public function hideDropTargets():void
		{
			if (!_dragging)
			{
				removeDropHighlighting();
			}
		}
		
		/*
		 * 				- Handlers -
		 */
		
		private function handleMouseOver(event:MouseEvent):void
		{
			if (!_dragging)
			{
				var target:IDragTarget = event.currentTarget as IDragTarget;
				
				removeDropHighlighting();
				if (target && target.canDrag())
				{
					highlightDropTargets(event.currentTarget as IDragTarget);
				}
			}
		}
		
		private function handleMouseOut(event:MouseEvent):void
		{
			var target:IDragTarget = event.currentTarget as IDragTarget;
			
			if (target && !_dragging)
			{
				removeDropHighlighting();
			}
		}
		
		private function handleMouseDown(event:MouseEvent):void
		{
			if (_disabled)
			{
				return;
			}
			
			var eventEx:MouseEventEx = event as MouseEventEx;
			if (eventEx && eventEx.buttonIdx != MouseEventEx.LEFT_BUTTON)
			{
				// ignor all buttons except LEFT_BUTTON
				return;
			}
			
			var target:IDragTarget = event.currentTarget as IDragTarget;
			
			if (target.canDrag())
			{
				_downPoint = new Point(event.stageX, event.stageY);
				waitForDragging(target);
			}
		}
		
		private function handleDragRemovedFromStage(event:Event):void
		{
			removeDragTarget(event.currentTarget as IDragTarget);
		}
		
		private function handleDropRemovedFromStage(event:Event):void
		{
			removeDropTarget(event.currentTarget as IDropTarget);
		}
		
		protected function waitForDragging(target:IDragTarget):void
		{
			var targetComponent:UIComponent = target as UIComponent;
			var targetStage:Stage = targetComponent.stage;
			
			_currentStage = targetStage;
			_currentDragItem = target;
			
			targetStage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false, 0, true);
			targetStage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false, 0, true);
		}
		
		protected function handleMouseMove(event:MouseEvent):void
		{
			if (!_dragging)
			{
				tryStartDrag(event.stageX, event.stageY);
			}
			else if (_dragging)
			{
				// check for recepient
				var overObject:DisplayObject = Extensions.getMouseTopMostEntity(true);
				var overDropTarget:IDropTarget;
				
				var lastEnabledDropTarget:IDropTarget;
				while (overObject && !overDropTarget && overObject.parent)
				{
					overDropTarget = overObject as IDropTarget;
					overObject = overObject.parent;
					
					if (overDropTarget && overDropTarget.dropEnabled)
					{
						lastEnabledDropTarget = overDropTarget
					}
					else
					{
						overDropTarget = null;
					}
				}
				if (!overDropTarget && lastEnabledDropTarget)
				{
					overDropTarget = lastEnabledDropTarget;
				}
				
				var canDropNow:Boolean = overDropTarget && overDropTarget.canDrop(_currentDragItem);
				
				if (overDropTarget && canDropNow)
				{
					if (_currentRecepient && _currentRecepient != overDropTarget)
					{
						_currentRecepient.processOver(null);
					}
					
					_currentRecepient = overDropTarget;
					_currentRecepient.dropSelection = true;
					
					var actionId:int = _currentRecepient.processOver(_avatar);
					if (_avatar)
					{
						_avatar.setActionIcon(actionId);
					}
				}
				else
				{
					if (_currentRecepient)
					{
						_currentRecepient.processOver(null);
					}
					_currentRecepient = null;
					
					if (_avatar)
					{
						if (!canDropNow && overDropTarget && overDropTarget != _currentDragItem)
						{
							_avatar.setActionIcon(SlotDragAvatar.ACTION_ERROR);
						}
						else
						{
							_avatar.setActionIcon(SlotDragAvatar.ACTION_NONE);
						}
					}
				}
			}
		}
		
		protected function handleMouseUp(event:MouseEvent):void
		{
			stopDrag();
		}
		
		/*
		 * 				- Core -
		 */
		
		protected function tryStartDrag(curX:Number, curY:Number):void
		{
			if (!_currentDragItem || !_downPoint || !_canvas)
			{
				return;
			}
			var currentDeviation:Number = Math2.getSegmentLength(_downPoint, new Point(curX, curY));
			_dragging = currentDeviation > DRAG_START_OFFSET;
			if (_dragging && !_avatar)
			{
				_avatar = new SlotDragAvatar(_currentDragItem.getAvatar(), _currentDragItem.getDragData(), _currentDragItem);
				if (_avatar)
				{
					_canvas.addChild(_avatar);
					_avatar.x = curX;
					_avatar.y = curY;
					_avatar.startDrag(true);
					_avatar.mouseChildren = false;
					_avatar.mouseEnabled = false;
					_currentDragItem.dragSelection = true;
					
					var startEvent:ItemDragEvent = new ItemDragEvent(ItemDragEvent.START_DRAG);
					startEvent.targetItem = _currentDragItem;
					dispatchEvent(startEvent);
					highlightDropTargets(_currentDragItem);
				}
				else
				{
					_dragging = false;
					throw new Error("Can't get dragging view avatar from object ", _currentDragItem);
				}
			}
		}
		
		protected function stopDrag():void
		{
			var stopEvent:ItemDragEvent = new ItemDragEvent(ItemDragEvent.STOP_DRAG);
			if (_dragging)
			{
				if (_currentRecepient)
				{
					_currentRecepient.processOver(null);
					_currentRecepient.applyDrop(_currentDragItem);
					stopEvent.targetRecepient = _currentRecepient;
				}
				if (_avatar)
				{
					_avatar.stopDrag();
					_canvas.removeChild(_avatar);
					_avatar = null;
				}
				_dragging = false;
				_currentDragItem.dragSelection = false;
				removeDropHighlighting();
			}
			if (_currentStage)
			{
				_currentStage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
				_currentStage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
				_currentDragItem = null;
			}
			dispatchEvent(stopEvent);
		}
		
		protected function highlightDropTargets(keyTarget:IDragTarget):void
		{
			var len:int = _dropTargets.length;
			
			for (var i:int = 0; i < len; i++ )
			{
				var curTarget:IDropTarget = _dropTargets[i];
				var isSameSlot:Boolean = keyTarget == curTarget;
				
				if (curTarget.canDrop(keyTarget) && !isSameSlot)
				{
					curTarget.dropSelection = true;
					_actualDropTargets.push(curTarget);
				}
			}
		}
		
		protected function removeDropHighlighting():void
		{
			while (_actualDropTargets.length)
			{
				_actualDropTargets.pop().dropSelection = false;
			}
		}
	}
	
}
