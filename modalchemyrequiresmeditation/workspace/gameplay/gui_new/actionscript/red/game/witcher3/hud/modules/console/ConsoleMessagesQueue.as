package red.game.witcher3.hud.modules.console
{
	import fl.transitions.easing.Strong;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.core.UIComponent;
	import com.gskinner.motion.GTweener;
	import red.core.events.GameEvent;
	
	/**
	 * List of the console messages
	 * @author Yaroslav Getsevich
	 */
	public class ConsoleMessagesQueue extends UIComponent
	{
		protected static const RENDERER_CONTENT_REF:String = "mcConsoleMessageItem";
		protected static const ANIM_DIRECTION_UP:String = "up";
		protected static const ANIM_DIRECTION_DOWN:String = "down";
		protected static const ANIM_REARRANGE_DURATION:Number = .1;
		
		private var _direction:String;
		private var _msgVisibilityDuration:Number;
		private var _padding:Number;
		private var _cachedHeight:Number;
		
		private var _messageRenderers:Vector.<ConsoleMessageItem> = new Vector.<ConsoleMessageItem>;
		private var _canvas:Sprite;
		
		private var _rendererClassRef:Class;
		
		public function ConsoleMessagesQueue()
		{
			_canvas = new Sprite(); // #B  what for ?
			addChild(_canvas);
			_cachedHeight = height;
		}
		
		override protected function configUI():void
		{
			super.configUI();
			_rendererClassRef = getDefinitionByName(RENDERER_CONTENT_REF) as Class;
		}
		
		[Inspectable(defaultValue="down", type="list", enumeration="up,down", name="Animation direction")]
        public function get direction():String { return _direction; }
        public function set direction(value:String):void
		{
            _direction = value;
        }
		
		[Inspectable(defaultValue="2000", name="Message visibility (ms)")]
		public function get msgVisibilityDuration():Number { return _msgVisibilityDuration }
		public function set msgVisibilityDuration(value:Number):void
		{
			_msgVisibilityDuration = value;
		}
		
		[Inspectable(defaultValue="2", name="Lines spacing")]
		public function get padding():Number { return _padding }
		public function set padding(value:Number):void
		{
			_padding = value;
		}
		
		public function pushMessage(value:String):void
		{
			var instRenderer:ConsoleMessageItem = createMessage(value, _msgVisibilityDuration);
			rearrangeMessages(instRenderer);
		}
		
		public function cleanup():void
		{
			var len:uint = _messageRenderers.length;
			
			for (var i:int = 0; i < len; i++)
			{
				_canvas.removeChild(_messageRenderers.pop());
			}
		}
		
		protected function createMessage(value:String, lifetime:Number):ConsoleMessageItem
		{
			var newRenderer:ConsoleMessageItem = new _rendererClassRef() as ConsoleMessageItem;
			
			newRenderer.init(value, lifetime, this.width);
			_canvas.addChild(newRenderer);
			newRenderer.addEventListener(Event.COMPLETE, handleItemHidden, false, 0, true);
			_messageRenderers.push(newRenderer);
			return newRenderer;
		}
		
		/*protected function handleLifeTimer(event:TimerEvent = null):void
		{
			if (_messageRenderers.length)
			{
				removeLastItem();
				rearrangeMessages();
				
				_lifeTimer.reset();
				_lifeTimer.start();
			}
		}*/
		
		protected function removeLastItem():void
		{
			if ( _messageRenderers )
			{
				if ( _messageRenderers[0] )
				{
					var lastItem:ConsoleMessageItem = _messageRenderers[0];
					
					var targetPos:Number = _direction == ANIM_DIRECTION_UP ? - lastItem.actualHeight : (_cachedHeight + lastItem.actualHeight);
					
					
					lastItem.forceRemove();
					//GTweener.pauseTweens(lastItem);
					//GTweener.to(lastItem, ANIM_REARRANGE_DURATION, { y: targetPos, alpha:0 } );
					lastItem.y = targetPos;
					lastItem.alpha = 0;

					removeItemFromQueue(lastItem);
				}
			}
		}
		
		protected function removeDepricatedItems():void
		{
			var len:uint = _messageRenderers.length;
			
			for (var i:int = 0; i < len; i++)
			{
				var curItem:ConsoleMessageItem = _messageRenderers[i];
				if (curItem.isVanishing())
				{
					curItem.destroy();
					_canvas.removeChild(curItem);
					curItem = null;
				}
			}
		}
		
		protected function rearrangeMessages(newItem:ConsoleMessageItem = null, pushAnimation:Boolean = false):void
		{
			var len:uint = _messageRenderers.length;
			var posY:Number;
			var curHeight:Number = 0;
			var newPosMap:Dictionary = new Dictionary(true);
			
			for (var i:int = 0; i < len; i++)
			{
				var curIdx:uint = _direction == ANIM_DIRECTION_UP ? i : (len - i -1);
				var leadIdx:uint = _direction == ANIM_DIRECTION_UP ? 0 : len - 1;
				var curItem:ConsoleMessageItem = _messageRenderers[curIdx];
				var actualPadding:Number = curIdx == leadIdx ? 0 : _padding;
				var curItemHeight:Number = curItem.actualHeight + actualPadding;
				
				/*
				 * Looks bad, maybe we can tweak it a little and use
				 *
				var scaleRat:Number = (1 - ((len - curIdx + 1) / len));
				var scaleValue:Number = 1 - .4 * scaleRat;
				curItem.scaleX = curItem.scaleY = scaleValue;
				*/
				
				//GTweener.pauseTweens(curItem);
				posY = curHeight + actualPadding;
				newPosMap[curItem] = posY;
				
				curHeight += curItemHeight;
				
				/*trace("HUD ");
				trace("HUD i "+i);
				//trace("HUD curItem "+curItem.textField.htmlText);
				trace("HUD curHeight "+curHeight);
				trace("HUD _cachedHeight "+_cachedHeight);
				trace("HUD curItemHeight "+curItemHeight);
				trace("HUD curHeight "+curHeight);*/
				
				if (curHeight > _cachedHeight && curItemHeight < _cachedHeight)
				{
					// if we have not enough space
					//removeDepricatedItems();
					//removeLastItem();
					rearrangeMessages(newItem, true);
					//_lifeTimer.reset();
					//_lifeTimer.start();
					return;
				}
				
				if (newItem == curItem && !pushAnimation)
				{
					curItem.y = posY;
				}
				else
				{
					if (newItem == curItem)
					{
						curItem.y = _direction == ANIM_DIRECTION_UP ? (_cachedHeight + curItem.height) : -curItem.height;
						curItem.alpha = 0;
					}
					if(curItem)
					{
						//GTweener.removeTweens(curItem);
						//GTweener.to(curItem, ANIM_REARRANGE_DURATION, { y:posY, alpha:1 } );
						curItem.y = posY
						curItem.alpha = 1;
					}
				}
				
				/*else
				{
					//removeDepricatedItems();
					//removeLastItem();
					_lifeTimer.reset();
					_lifeTimer.start();
				}*/
			}
			
			/*var scaleIdx:uint = 1;
			for (var keyItem:Object in newPosMap)
			{
				var posValue:Number = newPosMap[keyItem];
				var iterItem:ConsoleMessageItem = keyItem as ConsoleMessageItem;
				
				if (newItem == iterItem && !pushAnimation)
				{
					iterItem.y = posValue;
				}
				else
				{
					if (newItem == iterItem)
					{
						iterItem.y = _direction == ANIM_DIRECTION_UP ? (_cachedHeight + iterItem.height) : -iterItem.height;
						iterItem.alpha = 0;
					}
					if(iterItem)
					{
						GTweener.pauseTweens(iterItem);
						GTweener.to(iterItem, ANIM_REARRANGE_DURATION, { y:posValue, alpha:1 } );
					}
				}
				scaleIdx++;
			}*/
		}
		
		protected function handleItemHidden(event:Event):void
		{
			var targetItem:ConsoleMessageItem = event.currentTarget as ConsoleMessageItem;
			if (targetItem)
			{
				targetItem.removeEventListener(Event.COMPLETE, handleItemHidden);
				//GTweener.removeTweens(targetItem);
				_canvas.removeChild(targetItem);
				removeItemFromQueue(targetItem);
				targetItem = null;
				rearrangeMessages(null, false);
				dispatchEvent( new GameEvent(GameEvent.CALL, "OnMessageHidden", ["" + _messageRenderers.length]));
			}
		}
		
		protected function removeItemFromQueue(item:ConsoleMessageItem):void
		{
			var idx:int = _messageRenderers.indexOf(item)
			
			if (idx != -1)
			{
				_messageRenderers.splice(idx, 1);
			}
		}
	}

}
