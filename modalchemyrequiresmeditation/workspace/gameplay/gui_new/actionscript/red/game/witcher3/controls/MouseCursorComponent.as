package red.game.witcher3.controls
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
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
	 * @author Yaroslav Getsevich
	 */
	public class MouseCursorComponent
	{
		protected static const CURSOR_CONTENT_REF:String = "MouseCursorRef";
		
		protected var _canvas:DisplayObjectContainer;
		protected var _cursorInstance:MovieClip;
		protected var _visible:Boolean = true;
		protected var _autoHide:Boolean = true;
		protected var _inputMgr:InputManager;
		protected var _cursorType:int = 1;
		
		public function MouseCursorComponent(target:DisplayObjectContainer)
		{
			try
			{
				_inputMgr = InputManager.getInstance();
				_canvas = target;
				loadCursorInstance();
			}
			catch (er:Error)
			{
				trace("GFX WARNING: Can't create mouse cursor; " + er.message);
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
		
		public function get cursorType():int { return _cursorType; }
		public function set cursorType(value:int):void
		{
			_cursorType = value;
			
			if (_cursorInstance && _cursorType > 0)
			{
				_cursorInstance.gotoAndStop(_cursorType);
			}
		}
		
		public function handleControllerChanged(event:ControllerChangeEvent):void
		{
			updateVisibility();
		}
		
		protected function loadCursorInstance():void
		{
			var cursorClassRef:Class = getDefinitionByName(CURSOR_CONTENT_REF) as Class;
			_cursorInstance = new cursorClassRef() as MovieClip;
			_canvas.addChild(_cursorInstance);
			
			if (_cursorType > 0)
			{
				_cursorInstance.gotoAndStop(_cursorType);
			}
			
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
