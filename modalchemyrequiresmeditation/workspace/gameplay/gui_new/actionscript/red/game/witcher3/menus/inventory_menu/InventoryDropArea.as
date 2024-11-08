package red.game.witcher3.menus.inventory_menu 
{
	import flash.display.MovieClip;
	import flash.events.DataEvent;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.interfaces.IDragTarget;
	import red.game.witcher3.interfaces.IDropTarget;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.slots.SlotDragAvatar;
	import red.game.witcher3.slots.SlotsTransferManager;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * D&D drop area, visible only for mouse ctrl
	 * @author Getsevich Yaroslav
	 */
	public class InventoryDropArea extends UIComponent implements IDropTarget
	{
		public var mcBorder:MovieClip;
		public var mcIconGlow:MovieClip;
		public var txtLabel:TextField;
		
		private var _isGamepad:Boolean;
		private var _dropSelection:Boolean;
		private var _inputManager:InputManager;
		
		public function InventoryDropArea() 
		{
			txtLabel.text = "[[panel_button_common_drop]]";
			mcIconGlow.visible = false;
			SlotsTransferManager.getInstance().addDropTarget(this);
			visible = false;
		}
		
		protected var _disabled:Boolean = false;
		public function get disabled():Boolean { return _disabled }
		public function set disabled(value:Boolean):void
		{
			_disabled = value;
			updateVisibility();
		}
		
		override protected function configUI():void 
		{
			super.configUI();
			
			_inputManager = InputManager.getInstance();
			_inputManager.addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange, false, 0, true);
			
			_isGamepad = _inputManager.isGamepad();
			updateVisibility();
		}
		
		private function handleControllerChange(event : ControllerChangeEvent):void
		{
			_isGamepad = event.isGamepad;
			updateVisibility();
		}
		
		private function updateVisibility():void
		{
			visible = !_isGamepad && !_disabled;
		}
		
		private var _dropEnabled:Boolean = true;
		public function get dropEnabled():Boolean { return _dropEnabled }
        public function set dropEnabled(value:Boolean):void
		{
			_dropEnabled = value;
		}
		
		public function get dropSelection():Boolean { return _dropSelection }
        public function set dropSelection(value:Boolean):void
		{
			_dropSelection = value;
		}
		
		public function processOver(avatar:SlotDragAvatar):int
		{
			mcIconGlow.visible = avatar != null;
			return SlotDragAvatar.ACTION_DROP;
		}
		
		public function canDrop(sourceObject:IDragTarget):Boolean
		{
			var draggingData:ItemDataStub = sourceObject.getDragData() as ItemDataStub;
			return draggingData && draggingData.canDrop && !_inputManager.isGamepad() && visible;
		}
		
		public function applyDrop(sourceObject:IDragTarget):void
		{
			var draggingData:ItemDataStub = sourceObject.getDragData() as ItemDataStub;
			if (draggingData && draggingData.canDrop)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnDropItem', [draggingData.id, draggingData.quantity ] ));
				mcBorder.gotoAndPlay(2);
			}
		}
		
	}
}
