package red.game.witcher3.utils.mydragmanager 
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author @ Paweł
	 */
	public class MyDragManager extends EventDispatcher
	{
		public var slots:Vector.<SlotVO> = new Vector.<SlotVO>;
		protected var stage:Stage;
		protected var draggedItemsContainer:Sprite;
		
		protected var draggedItem:DraggedItemVO = null;
		public var itemClicked:DraggedItemVO = null;
		
		
		public function MyDragManager(stage:Stage,draggedItemsContainer:Sprite) 
		{
			this.draggedItemsContainer = draggedItemsContainer;
			this.stage = stage;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, hMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, hMouseUp);
			
		}
		
		private function hMouseUp(e:MouseEvent):void
		{
			if (draggedItem) 
			{
				var slotAccepted:Boolean = dropItem();
				
				if (slotAccepted==false) 
				{
					
					dropOutside(draggedItem);
					draggedItem = null;
				}
				else 
				{
					
					//var ev:MyDragManagerEvent = new MyDragManagerEvent(MyDragManagerEvent.ITEM_DROPPED_IN_SLOT);
					//dispatchEvent(ev);
				}
				
				
			}
			
		}
		
		private function dropOutside(item:DraggedItemVO):void 
		{
			item.currentSlot = null;
			var ev:MyDragManagerEvent = new MyDragManagerEvent(MyDragManagerEvent.ITEM_DROPPED_OUTSIDE);
			ev.item = item;
			dispatchEvent(ev);
			
		}
		
		private function dropItem():Boolean
		{
				if (draggedItem) 
				{
					var p1:Point = new Point(draggedItem.view.x, draggedItem.view.y);
						
					for (var i:int = 0; i < slots.length; i++) 
					{
						var vo:SlotVO = slots[i];
						if (draggedItem.slotType == slots[i].slotType) 
						{
							var p2:Point = vo.view.localToGlobal(new Point(0, 0));
							if (Math.abs(p2.x-p1.x)< (vo.view.width)/2 && Math.abs(p2.y-p1.y)< (vo.view.height)/2) 
							{
								insertItemToSlot(draggedItem, vo);
								return true;
							}
						}
						
					}
				}
				return false;
			
		}
		
		public function insertItemToSlot(item:DraggedItemVO, slot:SlotVO):void 
		{
			if (slot.slotType == item.slotType) 
			{
				
			
				if (slot.item!=null) 
				{
				
					dropOutside(slot.item);
					
				}
				item.view.x = 0;
				item.view.y = 0;
				slot.item = item;
				slot.view.addChild(item.view);
				item.currentSlot = slot;
				
				
				var ev:MyDragManagerEvent = new MyDragManagerEvent(MyDragManagerEvent.ITEM_DROPPED_IN_SLOT);
				ev.item = item;
				dispatchEvent(ev);
				
				draggedItem = null;
				
				itemClicked = null;
				
				
			}
			
		}
		
		
		public function destroy():void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, hMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, hMouseUp);
		}
		
		protected function hMouseMove(e:MouseEvent):void 
		{
			if (draggedItem) 
			{
				updatePosition();
				
				//e.updateAfterEvent();
			}
		}
		
		private function updatePosition():void 
		{
			draggedItem.view.x = stage.mouseX;
				draggedItem.view.y = stage.mouseY;
		}
		public function addSlot(vo:SlotVO):void 
		{
			slots.push(vo);
		}
		
		public function dragItem(vo:DraggedItemVO):void 
		{
			
			if (vo.currentSlot ) 
			{
			
				vo.currentSlot.item = null;
			}
			
			draggedItem  = vo;
			draggedItemsContainer.addChild(draggedItem.view);
			updatePosition();
			
			dispatchEvent(new MyDragManagerEvent(MyDragManagerEvent.ITEM_START_DRAG));
		}
		
	}

}