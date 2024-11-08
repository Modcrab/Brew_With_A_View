package red.game.witcher3.slots
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.DisplayObject;
	import red.core.constants.KeyCode;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.gwint.CardInstance;
	import red.game.witcher3.menus.gwint.CardSlot;
	import red.game.witcher3.menus.gwint.GwintTutorial;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	
	/**
	 * [GWINT] Carousel control; Warning: Cards only
	 * @author Getsevich Yaroslav
	 */
	public class SlotsListCarousel extends SlotsListBase
	{
		private static const ITEM_ROTATE_KOEFF:Number = 15;
		private static const ITEM_SCALE_KOEFF:Number = .3;
		private static const ITEM_PADDING:Number = 10;
		private static const ITEM_Y_OFFSET:Number = 70;
		private var _displayItemsCount:uint;
		private var baseComponentWidth:Number;
		private var baseComponentHeight:Number;
		
		public var inputEnabled:Boolean = true;
		
		public function SlotsListCarousel()
		{
			super();
			ignoreSelectable = true;
		}
		
		[Inspectable(defaultValue="5")]
		public function get displayItemsCount():uint {	return _displayItemsCount }
		public function set displayItemsCount(value:uint):void
		{
			_displayItemsCount = value;
		}
		
		public function replaceItem(sourceItem:*, newItem:*):void
		{
			trace("GFX [SlotsListCarousel][replaceItem] newItem: ", newItem);
			
			var len:int = _renderers.length;
			for (var i:int = 0; i < len; i++)
			{
				var curCard:CardSlot = _renderers[i] as CardSlot;
				var sourceInstance:CardInstance = sourceItem as CardInstance;
				var newInstance:CardInstance = newItem as CardInstance;
				if (curCard && curCard.instanceId == sourceInstance.instanceId)
				{
					curCard.setCardSource(newInstance);
				}
			}
		}
		
		private function spawnRenderer(index:uint):IBaseSlot
		{
			var newInstanse:IBaseSlot = new _slotRendererRef() as IBaseSlot;
			newInstanse.index = index;
			
			_canvas.addChild(newInstanse as DisplayObject);
			setupRenderer(newInstanse);
			return newInstanse;
		}
		
		private function shiftRenderers(direction:Boolean):void
		{
			
		}
		
		override protected function populateData():void 
		{
			trace("GFX [SlotsListCarousel] populateData ", _data);
			
			if (_renderers.length > 0)
			{
				clearRenderers();
			}
			
			super.populateData();
			if (_data)
			{
				var count:int = _data.length // count % 2 != 0
				var curPosition:Number = 0;
				
				for (var i:int = 0; i < count; i++)
				{
					var newInstance:SlotBase = spawnRenderer(i) as SlotBase;
					var cardSlot:CardSlot = newInstance as CardSlot;
					
					newInstance.useContextMgr = false;
					
					if (cardSlot)
					{
						cardSlot.cardState = CardSlot.STATE_CAROUSEL;
						if (_data[i] is CardInstance)
						{
							cardSlot.setCardSource(_data[i]);
						}
						else
						{
							cardSlot.cardIndex = _data[i];
						}
					}
					else
					{
						newInstance.setData(_data[i]);
					}
					
					_renderers.push(newInstance);
					
					var instanceComponent:UIComponent = newInstance as UIComponent;
				}
				
				// TODO: Shifting
				_canvas.x = 0;
				_canvas.y = ITEM_Y_OFFSET;
			}
			
			if (_renderers.length > 0)
			{
				baseComponentWidth = CardSlot.CARD_ORIGIN_WIDTH;
				baseComponentHeight = CardSlot.CARD_ORIGIN_HEIGHT;
			}
			
			if (InputManager.getInstance().isGamepad())
			{
				selectedIndex = 0;
			}
			
			if (_renderers.length > 0)
			{
				repositionCards(false);
			}
		}
		
		override public function set selectedIndex(value:int):void 
		{
			var scrollBackward:Boolean = _selectedIndex < value;
			
			super.selectedIndex = value;
			
			repositionCards(true);
		}
		
		override public function get itemClickEnabled():Boolean
		{
			if (GwintTutorial.mSingleton)
			{
				return !GwintTutorial.mSingleton.active;
			}
			return true;
		}
		
		protected function repositionCards(animated:Boolean):void
		{
			var i:int;
			var targetX:Number;
			var targetY:Number;
			var targetScale:Number;
			var targetRotation:Number;
			var middleIndex:int;
			var distanceFromMiddle:int;
			var maxOffset:Number = Math.floor(_displayItemsCount / 2);
			var currentComponent:UIComponent;
			var shouldBeVisible:Boolean;
			
			//validateNow(); // Make sure selectedIndex is validated before doing this logic
			
			if (_cachedSelection < 0)
			{
				middleIndex = 0;
			}
			else
			{
				middleIndex = _cachedSelection;
			}
			
			//trace("GFX ---------------------------------------------------------------------------------------");
			//trace("GFX - Repositioning Cards with width:" + baseComponentWidth + ", and height:" + baseComponentHeight + ", and maxOffset:" + maxOffset + ", and displayCount:" +  _displayItemsCount);
			//trace("GFX =========================================================================================================");
			
			for (i = 0; i < _renderers.length; ++i)
			{
				// Step 1 calculate position and scale and rotation base off
				// {
					distanceFromMiddle = i - middleIndex;
					
					if (distanceFromMiddle == 0)
					{
						targetX = 0;
						targetY = 0;
						targetScale = 1;
						targetRotation = 0;
						shouldBeVisible = true;
					}
					else if (Math.abs(distanceFromMiddle) <= maxOffset)
					{
						targetX = distanceFromMiddle * baseComponentWidth; // TODO
						targetScale = (1 - ITEM_SCALE_KOEFF * Math.abs(distanceFromMiddle) / maxOffset);
						targetY = -((baseComponentHeight - (baseComponentHeight * targetScale)) / 2); //Move up by half the height shrinkage
						targetRotation = ITEM_ROTATE_KOEFF * distanceFromMiddle / maxOffset;
						shouldBeVisible = true;
					}
					else
					{
						shouldBeVisible = false;
						if (distanceFromMiddle > 0)
						{
							targetX = 1920 + baseComponentWidth;
						}
						else
						{
							targetX = -1920 - baseComponentWidth;
						}
						
						targetY = (baseComponentHeight * ITEM_SCALE_KOEFF) / 2;
						
						targetScale = 1 - ITEM_SCALE_KOEFF;
						targetRotation = ITEM_ROTATE_KOEFF;
					}
				// }
				
				//trace("GFX - Repositioned card at Index: " + i + " to position: (" + targetX + "," + targetY + ") with scale: " + targetScale + ", and target Rotation: " + targetRotation + ", with visibility: " + shouldBeVisible);
				
				// Step 2 actually set card positions
				// {
					currentComponent = _renderers[i] as UIComponent;
					GTweener.removeTweens(currentComponent);
					
					if (!animated)
					{
						currentComponent.visible = shouldBeVisible;
						currentComponent.x = targetX;
						currentComponent.y = targetY;
						currentComponent.actualScaleX
						currentComponent.scaleX = currentComponent.scaleY = targetScale;
						//currentComponent.rotationY = targetRotation;
					}
					else
					{
						if (shouldBeVisible)
						{
							currentComponent.visible = true;
							GTweener.to(currentComponent, 0.2, { x:targetX, y:targetY, scaleX:targetScale, scaleY:targetScale }, { } );
						}
						else
						{
							if (targetX != currentComponent.x)
							{
								GTweener.to(currentComponent, 0.2, { x:targetX, y:targetY, scaleX:targetScale, scaleY:targetScale }, { onComplete:onHideComplete } );
							}
						}
					}
				//}
			}
			
			//trace("GFX =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");
		}
		
		protected function onHideComplete(curTween:GTween):void
		{
			var targetComponent:UIComponent = curTween.target as UIComponent;
			
			if (targetComponent)
			{
				targetComponent.visible = false;
			}
		}
		
		override public function handleInput(event:InputEvent):void 
		{
			if (!inputEnabled)
			{
				return;
			}
			
			super.handleInput(event);
			if (event.handled || !parent.visible) return;
			var details:InputDetails = event.details;
			var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			if (keyPress)
			{
				switch (details.code)
				{
					case KeyCode.LEFT:
						navigateLeft();
						break;
					case KeyCode.RIGHT:
						navigateRight();
						break;
				}
			}
		}
		
		public function navigateLeft():void
		{
			if (selectedIndex > 0)
			{
				selectedIndex--;
			}
		}
		
		public function navigateRight():void
		{
			if (selectedIndex < (_renderers.length - 1))
			{
				selectedIndex++;
			}
		}
	}

}
