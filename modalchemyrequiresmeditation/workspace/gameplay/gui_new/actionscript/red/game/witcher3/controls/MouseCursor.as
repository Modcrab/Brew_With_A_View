package red.game.witcher3.controls 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.managers.RuntimeAssetsManager;
	import scaleform.gfx.Extensions;
	import scaleform.gfx.InteractiveObjectEx;
	
	/**
	 * MouseCursor controller
	 * 
	 * WARNING: Deprecated, remove it
	 * 
	 * @author Yaroslav Getsevich
	 */	
	public class MouseCursor
	{
		protected static const CURSOR_CONTENT_REF:String = "MouseCursorRef";
		protected var _canvas:DisplayObjectContainer;
		protected var _cursorInstance:Sprite;
		protected var _visible:Boolean = true;
		protected var _autoHide:Boolean = true;
		
		protected var _assetsMgr:RuntimeAssetsManager;
		protected var _inputMgr:InputManager;
		
		public function MouseCursor(target:DisplayObjectContainer)
		{
			_assetsMgr = RuntimeAssetsManager.getInstanse();
			_inputMgr = InputManager.getInstance();
			_canvas = target;
			
			if (_assetsMgr.isLoaded)
			{
				loadCursorAsset()
			}
			else
			{
				_assetsMgr.addEventListener(Event.COMPLETE, loadCursorAsset, false, 0, true);
			}
		}
		
		public function get visible():Boolean { return _visible }
		public function set visible(value:Boolean)
		{
			_visible = value;
			updateVisibility();
		}
		
		public function get autoHide():Boolean { return _autoHide }
		public function set autoHide(value:Boolean)
		{
			_autoHide = value;
			updateVisibility();
		}
		
		public function handleControllerChanged(event:ControllerChangeEvent):void
		{
			updateVisibility();
		}
		
		protected function loadCursorAsset(event:Event = null):void
		{
			_cursorInstance = _assetsMgr.getAsset(CURSOR_CONTENT_REF) as Sprite;
			_canvas.addChild(_cursorInstance);
			
			_cursorInstance.x = _canvas.mouseX;
			_cursorInstance.y = _canvas.mouseY;
			
			InteractiveObjectEx.setHitTestDisable(_cursorInstance, true);
			InteractiveObjectEx.setTopmostLevel(_cursorInstance, true);
			
			_canvas.stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false, 0, true);
			_inputMgr.addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged, false, 0, true);
			
			updateVisibility();
		}
		
		protected function updateVisibility():void
		{
			if (!Extensions.isScaleform) 
				return;
				
			if (_cursorInstance)
			{
				if (_autoHide)
				{
					_cursorInstance.visible = !_inputMgr.isGamepad() && _visible;
				}
				else
				{
					_cursorInstance.visible = _visible;
				}
			}
		}
		
		protected function handleMouseMove(event:MouseEvent):void
		{
			_cursorInstance.x = event.stageX;
			_cursorInstance.y = event.stageY;
		}
	}

}
