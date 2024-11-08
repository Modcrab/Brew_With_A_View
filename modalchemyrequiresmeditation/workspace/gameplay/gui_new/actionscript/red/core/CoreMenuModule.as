package red.core
{
	import com.gskinner.motion.GTween;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import red.game.witcher3.controls.ModuleHighlighting;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.core.events.GameEvent;
	import scaleform.clik.events.ListEvent;

	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Exponential;

	import scaleform.clik.core.UIComponent;
	import scaleform.gfx.Extensions;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;

	public class CoreMenuModule extends UIComponent
	{
		public static const EVENT_MOUSE_FOCUSE:String = "EVENT_MOUSE_FOCUSE";
		protected static const INVALIDATE_CONTEXT:String  = "invalidate_context";
		protected var _inputHandlers:Vector.<UIComponent>;
		public var mcHighlight:ModuleHighlighting;
		public var dataBindingKey : String = "core.menu.module.base";
		protected var DATA_UPDATE_ALPHA_ANIMATION_TIME : Number = 3;
		
		protected var _active:Boolean;
		public function get active():Boolean { return _active }
		public function set active(value:Boolean):void
		{
			_active = value;
			if (visible != _active)
			{
				visible = _active;
				if (visible)
				{
					alpha = 0;
					GTweener.removeTweens(this);
					GTweener.to(this, 2, { alpha:1 }, { ease:Exponential.easeOut } );
				}
			}
			if (enabled != _active)
			{
				enabled = _active;
			}
		}

		public function CoreMenuModule()
		{
			super();
			_inputHandlers = new Vector.<UIComponent>;

			// Instead of in "configUI" so can initialize things before it tries to call game events
			// and rely on somebody overriding it to call super.
			if ( stage )
			{
				init();
			}
			else
			{
				addEventListener( Event.ADDED_TO_STAGE, init, false, int.MAX_VALUE, true );
			}
		}
		
		public function hasSelectableItems():Boolean
		{
			return visible;
		}

		private function init( e:Event = null ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, init, false );
			addEventListener( Event.REMOVED_FROM_STAGE, handleRemovedFromStage, false, int.MIN_VALUE, true );
			addEventListener(ListEvent.ITEM_CLICK, handleSlotClick, false, 0 , true);
			onCoreInit();
			tabEnabled = false;
			tabChildren = false;
		}
		
		protected function handleSlotClick(event:ListEvent):void
		{
			if (focused < 1)
			{
				dispatchEvent(new Event(EVENT_MOUSE_FOCUSE));
			}
		}

		protected function onCoreInit():void { } // for override
		protected function onCoreCleanup():void{ } // for override

		override protected function configUI():void
		{
			super.configUI();
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged, false, 0, true);
		}
		
		override public function set enabled(value:Boolean):void
		{
			//trace("GFX enabled [", this, "] enabled: ", enabled, "value -> ", value, "; initialized: ", initialized);
			if ((value != enabled) && initialized)
			{
				if (value)
				{
					dispatchEvent(new Event(Event.ACTIVATE));
				}
				else
				{
					dispatchEvent(new Event(Event.DEACTIVATE));
				}
			}
			super.enabled = value;
		}
		
		private function handleRemovedFromStage( e:Event ):void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, handleRemovedFromStage, false );
		}
		
		/*
		 * 	Dealing with focus
		 */
		
		override public function set focused(value:Number):void
		{
			var err:Error = new Error();
			
			if (_focused != value)
			{
				//trace("GFX Module [", this, "] set focus ", value);
				_focused = value;
				changeFocus();
			}
		}
		
		override protected function changeFocus():void
		{
			super.changeFocus();
			handleFocusChanged();
		}

		protected function handleControllerChanged(event:Event):void
		{
			handleFocusChanged();
		}

		protected function handleFocusChanged():void
		{
			if (_focused > 0)
			{
				if (mcHighlight && InputManager.getInstance().isGamepad())
				{
					//mcHighlight.highlighted = true;
				}
				handleModuleSelected();
				// Deal with selection
			}
			else
			{
				if (mcHighlight && InputManager.getInstance().isGamepad()) mcHighlight.highlighted = false;
			}
		}

		protected function handleModuleSelected():void
		{
			//dispatchEvent(new GameEvent(GameEvent.CALL, "OnModuleSelected", [dataBindingKey]));
		}

		public function handleDataChanged():void
		{
			if ( alpha == 0 )
			{
				GTweener.removeTweens(this);
				GTweener.to( this, DATA_UPDATE_ALPHA_ANIMATION_TIME, { alpha:1 },  { ease: Exponential.easeOut } );
			}
		}

		protected var _isVisible:Boolean = true;
		public function set backgroundVisible(value:Boolean):void
		{
			if (value != _isVisible)
			{
				_isVisible = value;
				
				GTweener.removeTweens(this);
				
				if (value)
				{
					visible = true;
					GTweener.to(this, 0.2, { alpha:1.0 }, { } );
				}
				else
				{
					GTweener.to(this, 0.2, { alpha:0.0 }, { onComplete:handleHideComplete } );
				}
			}
		}
		
		protected function handleHideComplete(curTween:GTween):void
		{
			visible = false;
		}
	}
}
