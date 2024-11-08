package red.game.witcher3.managers
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import red.core.events.GameEvent;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.tooltips.TooltipBase;

	/**
	 * Context tooltip data
	 * @author Yaroslav Getsevich
	 */
	public class ContextTooltipData extends EventDispatcher
	{
		protected var _dataBinding:String;
		protected var _hideBinding:String;
		protected var _contentReference:String;
		protected var _anchor:DisplayObject;
		protected var _canvas:Sprite;
		protected var _tooltipInstance:TooltipBase;
		protected var _gamepadOnly:Boolean;

		public function ContextTooltipData(dataBinding:String, hideBinding:String)
		{
			_dataBinding = dataBinding;
			_hideBinding = hideBinding;
		}
		
		public function get gamepadOnly():Boolean { return _gamepadOnly }
		public function set gamepadOnly(value:Boolean):void
		{
			_gamepadOnly = value;
		}

		public function setContentRefs(contentRef:String, anchor:DisplayObject, canvas:Sprite):void
		{
			_contentReference = contentRef;
			_anchor = anchor;
			_canvas = canvas;
			
			_canvas.dispatchEvent( new GameEvent( GameEvent.REGISTER, _dataBinding, [handleSetData]));
			_canvas.dispatchEvent( new GameEvent( GameEvent.REGISTER, _hideBinding, [handleHideRequest]));
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged);					
		}

		// #Y Warning: GameEvent.UNREGISTER doesn't work, missing C++ implementation
		public function destroyTooltip():void
		{
			_canvas.dispatchEvent( new GameEvent( GameEvent.UNREGISTER, _dataBinding, [handleSetData]));
			_canvas.dispatchEvent( new GameEvent( GameEvent.UNREGISTER, _hideBinding, [handleHideRequest]));
			removeInstance();
		}

		public function removeInstance():void
		{
			if (_tooltipInstance)
			{
				_canvas.removeChild(_tooltipInstance);
				_tooltipInstance = null;
			}
		}

		public function getAnchor():DisplayObject
		{
			return _anchor;
		}

		public function getDataBinding():String
		{
			return _dataBinding;
		}

		protected function handleSetData(data:Object):void
		{
			//trace("GFX ContextTooltipData [", _contentReference, "][", _tooltipInstance, "], handleSetData ");
			if (!InputManager.getInstance().isGamepad() && gamepadOnly)
			{
				return;
			}
			
			if (_contentReference)
			{
				if (!_tooltipInstance)
				{
					dispatchEvent(new Event(Event.ACTIVATE)); // del
					createInstance(data.ContentRef);
				}
				if (_tooltipInstance)
				{
					_tooltipInstance.data = data;
				}
			}
		}

		protected function handleHideRequest(value:Boolean):void
		{
			if (!InputManager.getInstance().isGamepad() && gamepadOnly)
			{
				return;
			}
			dispatchEvent(new Event(Event.DEACTIVATE));
		}

		protected function createInstance(redefinedContext:String = ""):void
		{
			if (!_tooltipInstance)
			{
				if (redefinedContext)
				{
					_tooltipInstance = getDefinition(redefinedContext) as TooltipBase;
				}
				else
				{
					_tooltipInstance = getDefinition(_contentReference) as TooltipBase;
				}
				_tooltipInstance.anchorRect = new Rectangle(_anchor.x, _anchor.y, 0, 0);
				_tooltipInstance.lockFixedPosition = true;
				_canvas.addChild(_tooltipInstance);
				_tooltipInstance.validateNow();
			}
		}

		protected function getDefinition(assetName:String):DisplayObject
		{
			var assetsMgr:RuntimeAssetsManager = RuntimeAssetsManager.getInstanse();
			return assetsMgr.getAsset(assetName);
		}
		
		protected function handleControllerChanged(event:ControllerChangeEvent):void
		{
			if (_tooltipInstance && gamepadOnly)
			{
				_tooltipInstance.visible = event.isGamepad;
			}
		}
		
		override public function toString():String 
		{
			return "ContextTooltipData ref: " + _contentReference;
		}
		
	}
}
