package red.game.witcher3.menus.common 
{	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import red.core.CoreComponent;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.slots.SlotInventoryGrid;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * red.game.witcher3.menus.common.InventoryListItemRenderer
	 * Item renderer for EnchantingMenu
	 * @author Getsevich Yaroslav
	 */
	public class InventoryListItemRenderer extends IconItemRenderer
	{
		public static const SOUND_TRIGGER_EVENT:String = "sound_trigger_event";
		
		private const TEXT_CENTER:Number = 49;
		private const TEXT_PADDING:Number = 5;
		private const SLOT_SCALING:Number = .78;		
		private const STATIC_HEIGHT:Number = 100;
		
		public var mcProgressRemoveEnchantment:MovieClip;
		public var mcProgressEnchantment:MovieClip;
		public var mcItemSlot:SlotInventoryGrid;
		public var mcShowAllIcon:MovieClip;
		
		protected var _currentProgressBar:MovieClip;
		protected var _progressCallback:Function;
		protected var _soundCallback:Function;
		protected var _tooltipRequested:Boolean;
		protected var _isInProgress:Boolean;
		protected var _isRemoving:Boolean;
		
		public function InventoryListItemRenderer() 
		{
			mcProgressRemoveEnchantment.visible = false;
			mcProgressEnchantment.visible = false;
			visible = false;
			
			mcProgressRemoveEnchantment.addEventListener(Event.COMPLETE, onProgressComplete, false, 0, true);
			mcProgressEnchantment.addEventListener(Event.COMPLETE, onProgressComplete, false, 0, true);
			
			mcProgressRemoveEnchantment.addEventListener(SOUND_TRIGGER_EVENT, onSoundTrigger, false, 0, true);
			mcProgressEnchantment.addEventListener(SOUND_TRIGGER_EVENT, onSoundTrigger, false, 0, true);
			
			_isInProgress = false;
		}
		
		public function showProgress(removing:Boolean = false, callback:Function = null, soundCallback:Function = null):void
		{
			resetProgress();
			
			_isRemoving = removing;
			_isInProgress = true;
			_currentProgressBar = _isRemoving ? mcProgressRemoveEnchantment : mcProgressEnchantment;
			_currentProgressBar.visible = true;
			_currentProgressBar.gotoAndPlay(2);
			_progressCallback = callback;
			_soundCallback = soundCallback;
		}
		
		public function resetProgress():void
		{
			if (_currentProgressBar)
			{
				_currentProgressBar.gotoAndStop(1);
				_currentProgressBar.visible = false;
				_currentProgressBar = null;
			}
			_isInProgress = false;
		}
		
		private function onProgressComplete(event:Event):void
		{
			if (_isInProgress)
			{
				resetProgress();
				
				if (_progressCallback != null)
				{
					_progressCallback();
				}
			}
		}
		
		private function onSoundTrigger(event:Event):void
		{
			if (_soundCallback != null)
			{
				_soundCallback(_isRemoving);
			}
		}
		
		override protected function configUI():void 
		{
			super.configUI();
			
			addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut, false, 0, true);
		}
		
		override public function setData( data:Object ):void
		{
			super.setData( data );
			
			if (!data)
			{
				return;
			}
			
			visible = true;
			
			if (data.userData as String == "ShowAll")
			{
				mcItemSlot.cleanup();
				mcItemSlot.visible = false;
				if (mcShowAllIcon) mcShowAllIcon.visible = true;
			}
			else
			{
				mcItemSlot.visible = true;
				mcItemSlot.data = data;
				mcItemSlot.validateNow();
				mcItemSlot.y = TEXT_CENTER - mcItemSlot.getSlotRect().height * SLOT_SCALING / 2;
				if (mcShowAllIcon) mcShowAllIcon.visible = false;
			}
			
			
			if ( selected)
			{
				fireTooltipShowEvent(false);
			}
			else
			{
				fireTooltipHideEvent();
			}
		}
		
		override protected function updateText():void
		{
			if (_data)
			{
				var itemNameStr:String = _data.itemName;
				var isEquipped:Boolean = false;
				var isNotEnoughSockets:Boolean = false;
				var textValueSecondLine:String;
				
				if (CoreComponent.isArabicAligmentMode)
				{
					itemNameStr = "<p align=\"right\">" + itemNameStr + "</p>";
				}
				
				isEquipped = _data.isEquipped;
				isNotEnoughSockets = _data.isNotEnoughSockets;
				
				tfSecondLine.textColor = 0x999999;
				
				if (isNotEnoughSockets)
				{
					textValueSecondLine =  _data.description;
					tfSecondLine.htmlText = textValueSecondLine;
					tfSecondLine.textColor = 0xc90202;
					tfSecondLine.visible = true;
					
					if (CoreComponent.isArabicAligmentMode)
					{
						tfSecondLine.htmlText = "<p align=\"right\">" + textValueSecondLine + "</p>";
						tfSecondLine.textColor = 0xc90202;
					}
				}
				else
				if (isEquipped)
				{
					textValueSecondLine =  "[[panel_blacksmith_equipped]]";
					tfSecondLine.htmlText = textValueSecondLine;
					if (CoreComponent.isArabicAligmentMode)
					{
						tfSecondLine.htmlText = "<p align=\"right\">" + textValueSecondLine + "</p>";
					}
					tfSecondLine.visible = true;
				}
				else
				{
					tfSecondLine.visible = false;
				}
				
				
				textField.htmlText = itemNameStr;
				textField.height = textField.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				
				if (isEquipped || isNotEnoughSockets)
				{
					var textHeight:Number = textField.textHeight + tfSecondLine.textHeight + TEXT_PADDING;
					
					textField.y = TEXT_CENTER - textHeight / 2;
					tfSecondLine.y = textField.y + textField.textHeight + TEXT_PADDING;
				}
				else
				{
					textField.y = TEXT_CENTER - textField.textHeight / 2;
				}
			}
		}
		
		override public function toString() : String
		{
			return "[W3 IconItemRenderer] " + name + "[" + index + "]";
		}
		
		override public function get height():Number 
		{
			return STATIC_HEIGHT; // ignore selection MC
		}
		
		// ---  for tooltip
		
		private function handleMouseMove(event:MouseEvent):void
		{
			/*
			if (mcItemSlot.visible)
			{
				if (mcItemSlot.hitTestPoint(event.stageX, event.stageY))
				{
					fireTooltipShowEvent(true);
				}
				else
				{
					fireTooltipHideEvent();
				}
			}
			*/
		}
		
		private function handleMouseOut(event:MouseEvent):void
		{
			/*
			if (mcItemSlot.visible)
			{
				if (!mcItemSlot.hitTestPoint(event.stageX, event.stageY))
				{
					fireTooltipHideEvent();
				}
			}
			*/
		}
		
		override public function set selected(value:Boolean):void 
		{
			super.selected = value;
			
			if ( mcItemSlot.visible)
			{
				if (value && _activeSelectionEnabled)
				{
					fireTooltipShowEvent(false);
				}
				else
				{
					fireTooltipHideEvent();
				}
			}
		}
		
		override public function set activeSelectionEnabled(value:Boolean):void
		{
			var ownerList:UIComponent = owner as UIComponent;
			var ownerListEnabled:Boolean = ownerList ? ownerList.enabled : true;
			
			super.activeSelectionEnabled = value;
			
			if (value && selected && ownerListEnabled && mcItemSlot.visible)
			{
				fireTooltipShowEvent(false);
			}
			else
			{
				//fireTooltipHideEvent(false)
			}
		}
		
		private function fireTooltipShowEvent(isMouseTooltip:Boolean):void
		{
			var displayEvent:GridEvent = new GridEvent(GridEvent.DISPLAY_TOOLTIP, true, false, 0, -1, -1, null, data);
			
			//displayEvent.isMouseTooltip = isMouseTooltip;
			//displayEvent.tooltipMouseContentRef = "ItemTooltipRef_mouse"; 
			
			displayEvent.isMouseTooltip = false;
			
			if (!mcItemSlot.visible)
			{
				return;
			}
			
			if (isMouseTooltip)
			{
				// var globalPosition:Point = localToGlobal(new Point(mcItemSlot.x, mcItemSlot.y));
				// var targetRect:Rectangle = new Rectangle(globalPosition.x, globalPosition.y, mcItemSlot.width, mcItemSlot.height);
				
				const tooltip_x = 90;
				const tooltip_y = 15;
				var globalPosition:Point = localToGlobal(new Point(tooltip_x, tooltip_y));
				
				displayEvent.anchorRect = new Rectangle(globalPosition.x, globalPosition.y);
			}
			
			dispatchEvent(displayEvent);
			_tooltipRequested = true;
		}
		
		private function fireTooltipHideEvent():void
		{
			if (_tooltipRequested)
			{
				var hideEvent:GridEvent = new GridEvent(GridEvent.HIDE_TOOLTIP, true, false, 0, -1, -1, null, null);
				
				dispatchEvent(hideEvent);
				_tooltipRequested = false;
			}
		}
		
		
	}

}

