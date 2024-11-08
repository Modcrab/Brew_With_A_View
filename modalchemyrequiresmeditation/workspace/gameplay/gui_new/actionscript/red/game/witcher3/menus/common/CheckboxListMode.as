/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2015 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	
	public class CheckboxListMode extends UIComponent
	{
		public var mcTitle : TextField;
		public var mcBackground : MovieClip;
		
		public var mcList:W3ScrollingList;
		public var mcItemRenderer1  : CheckboxListItem;
		public var mcItemRenderer2  : CheckboxListItem;
		public var mcItemRenderer3  : CheckboxListItem;
		public var mcItemRenderer4  : CheckboxListItem;
		public var mcItemRenderer5  : CheckboxListItem;
		public var mcItemRenderer6  : CheckboxListItem;
		public var mcItemRenderer7  : CheckboxListItem;
		public var mcItemRenderer8  : CheckboxListItem;
		public var mcItemRenderer9  : CheckboxListItem;
		public var mcItemRenderer10 : CheckboxListItem;
		
		public var mcCloseButton : InputFeedbackButton;
		//public var mcToggleButton : InputFeedbackButton;
		
		public var disallowCloseOnNoCheck : Boolean = false;
		public var exclusiveCheckList : Boolean = false;
		
		public var hideCB  : Function;
		public var closeCB : Function; // #Y TODO: RENAME !!!
		public var allowUnchecking : Boolean = true;
		
		private var valuesOnShow : Array = new Array();
		public var extraCloseMode : Boolean = false;
		
		override protected function configUI():void
		{
			super.configUI();
			
			visible = false;
			
			mcCloseButton.clickable = true;
			mcCloseButton.label = "[[panel_button_common_close]]";
			mcCloseButton.addEventListener(ButtonEvent.PRESS, handleClosePressed, false, 0, true);
			mcCloseButton.setDataFromStage(NavigationCode.GAMEPAD_B, KeyCode.ESCAPE);
			mcCloseButton.validateNow();
			
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 10, true);
			/*
			mcToggleButton.clickable = false;
			mcToggleButton.label = "[[panel_common_toggle_filters]]";
			mcToggleButton.setDataFromStage(NavigationCode.GAMEPAD_A, KeyCode.E);
			mcToggleButton.validateNow();
			*/
			if (mcBackground)
			{
				mcBackground.addEventListener(MouseEvent.CLICK, handleBackgroundClick, false, 0, true);
			}
			
			//mcList.bSkipFocusCheck = true;
		}
		
		protected var _lastMoveWasMouse:Boolean = false;
		public function get lastMoveWasMouse():Boolean { return _lastMoveWasMouse; }
		public function set lastMoveWasMouse(value:Boolean):void
		{
			_lastMoveWasMouse = value;
			
			if (!_lastMoveWasMouse)
			{
				if (mcList.selectedIndex == -1)
				{
					mcList.selectedIndex = 0;
				}
			}
			else
			{
				mcList.selectedIndex = _lastMouseOveredItem;
			}
		}
		
		public function show():void
		{
			registerMouseEventsForItem(mcItemRenderer1);
			registerMouseEventsForItem(mcItemRenderer2);
			registerMouseEventsForItem(mcItemRenderer3);
			registerMouseEventsForItem(mcItemRenderer4);
			registerMouseEventsForItem(mcItemRenderer5);
			registerMouseEventsForItem(mcItemRenderer6);
			registerMouseEventsForItem(mcItemRenderer7);
			registerMouseEventsForItem(mcItemRenderer8);
			registerMouseEventsForItem(mcItemRenderer9);
			registerMouseEventsForItem(mcItemRenderer10);
			
			visible = true;
			if (mcList.selectedIndex == -1)
			{
				mcList.selectedIndex = 0;
			}
			
			valuesOnShow.length = 0;
			
			var currentRenderer : CheckboxListItem;
			var i:int;
			
			for (i = 0; i < mcList.numRenderers; ++i)
			{
				currentRenderer = mcList.getRendererAt(i) as CheckboxListItem;
				
				if (currentRenderer && currentRenderer.visible && currentRenderer.data != null)
				{
					valuesOnShow.push(currentRenderer.isChecked);
				}
			}
		}
		
		protected function registerMouseEventsForItem(item:CheckboxListItem):void
		{
			if (item)
			{
				item.addEventListener(MouseEvent.CLICK, onItemClicked, false, 1, true);
				item.addEventListener(MouseEvent.MOUSE_OVER, onItemMouseOver, false, 1, true);
				item.addEventListener(MouseEvent.MOUSE_OUT, onItemMouseOut, false, 1, true);
			}
		}
		
		protected function unregisterMouseEventsForItem(item:CheckboxListItem):void
		{
			if (item)
			{
				item.removeEventListener(MouseEvent.CLICK, onItemClicked);
				item.removeEventListener(MouseEvent.MOUSE_OVER, onItemMouseOver);
				item.removeEventListener(MouseEvent.MOUSE_OUT, onItemMouseOut);
			}
		}
		
		protected var _lastMouseOveredItem:int = -1;
		protected function onItemClicked(event:MouseEvent):void
		{
			if (mcList.selectedIndex != -1)
			{
				var selectedItem : CheckboxListItem = mcList.getSelectedRenderer() as CheckboxListItem;
					
				if (selectedItem)
				{
					toggleValue(selectedItem);
				}
			}
		}
		
		protected function onItemMouseOver(event:MouseEvent):void
		{
			var currentTarget:CheckboxListItem = event.currentTarget as CheckboxListItem;
			
			_lastMouseOveredItem = mcList.getRenderers().indexOf(currentTarget);
			
			if (_lastMoveWasMouse)
			{
				mcList.selectedIndex = _lastMouseOveredItem;
			}
		}
		
		protected function onItemMouseOut(event:MouseEvent):void
		{
			_lastMouseOveredItem = -1;
			
			if (_lastMoveWasMouse)
			{
				mcList.selectedIndex = -1;
			}
		}
		
		public function setData(data:Array):void
		{
			mcList.dataProvider = new DataProvider(data);
			mcList.validateNow();
		}
		
		override public function handleInput(event:InputEvent):void
		{
			if (!visible)
			{
				return;
			}
			
			var details:InputDetails = event.details;
			CommonUtils.convertWASDCodeToNavEquivalent(details);
			
			if (details.navEquivalent != NavigationCode.GAMEPAD_A) // List consumes A presses for some reason and we don't want this
			{
				mcList.handleInput(event);
			}
			
			var inputEnabled:Boolean = details.value == InputValue.KEY_UP && !event.handled;
			
			if (inputEnabled)
			{
				if (details.code == KeyCode.ESCAPE || details.navEquivalent == NavigationCode.GAMEPAD_B)
				{
					close();
					event.handled = true;
					event.stopImmediatePropagation();
					return;
				}
				else if (extraCloseMode && (details.code == KeyCode.F || details.navEquivalent == NavigationCode.GAMEPAD_R3))
				{
					close();
					event.handled = true;
					event.stopImmediatePropagation();
				}
				else if (details.code == KeyCode.E || details.navEquivalent == NavigationCode.GAMEPAD_A)
				{
					var selectedItem : CheckboxListItem = mcList.getSelectedRenderer() as CheckboxListItem;
					
					if (selectedItem)
					{
						toggleValue(selectedItem);
					}
				}
			}
			
			// Block input to rest of UI while this is visible
			event.handled = true;
			event.stopImmediatePropagation();
			
			super.handleInput(event);
		}
		
		private function handleBackgroundClick(event:MouseEvent):void
		{
			close();
		}
		
		protected function toggleValue(target:CheckboxListItem):void
		{
			if (target && (!target.isChecked || allowUnchecking))
			{
				target.isChecked = !target.isChecked;
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_switch"]));
				
				// #J this feature doesn't work right now and choosing simpler solution instead of this for now
				/*
				if (target.groupID != "")
				{
					var currentRenderer:CheckboxListItem;
					var i:int;
					
					for (i = 0; i < mcList.numRenderers; ++i)
					{
						currentRenderer = mcList.getRendererAt(i) as CheckboxListItem;
						if (currentRenderer != target && currentRenderer.groupID == target.groupID)
						{
							currentRenderer.isChecked = false;
						}
					}
				}*/
				
				if (exclusiveCheckList)
				{
					var currentRenderer:CheckboxListItem;
					var i:int;
					
					for (i = 0; i < mcList.numRenderers; ++i)
					{
						currentRenderer = mcList.getRendererAt(i) as CheckboxListItem;
						
						if (currentRenderer && currentRenderer != target)
						{
							currentRenderer.isChecked = false;
						}
					}
					
					if ( canApplyValue() )
					{
						applyValue();
					}
				}
			}
		}
		
		protected function handleClosePressed( event : ButtonEvent ) : void
		{
			close();
		}
		
		public function isBoxChecked(key:String):Boolean
		{
			var currentRenderer : CheckboxListItem;
			var i:int;
			
			for (i = 0; i < mcList.numRenderers; ++i)
			{
				currentRenderer = mcList.getRendererAt(i) as CheckboxListItem;
				
				if (currentRenderer.dataKey == key)
				{
					return currentRenderer.isChecked;
				}
			}
			
			throw new Error("GFX - tried to check if checkbox with key: \"" + key + "\" was checked but failed to find it");
			return false;
		}
		
		public function setBoxChecked(key:String, value:Boolean):void
		{
			var currentRenderer : CheckboxListItem;
			var i:int;
			
			for (i = 0; i < mcList.numRenderers; ++i)
			{
				currentRenderer = mcList.getRendererAt(i) as CheckboxListItem;
				
				if (currentRenderer.dataKey == key)
				{
					currentRenderer.isChecked = value;
					return;
				}
			}
			
			throw new Error("GFX - tried to set checkbox with key: \"" + key + "\" to isChecked value: \"" + value + "\" but failed to find it");
		}
		
		public function close():void
		{
			if ( canApplyValue() )
			{
				hide();
				applyValue();
			}
		}
		
		private function canApplyValue():Boolean
		{
			var currentRenderer : CheckboxListItem;
			var i:int;
			
			if (disallowCloseOnNoCheck)
			{
				var hasCheckSomewhere:Boolean = false;
				
				for (i = 0; i < mcList.numRenderers; ++i)
				{
					currentRenderer = mcList.getRendererAt(i) as CheckboxListItem;
					
					if (currentRenderer && currentRenderer.isChecked)
					{
						hasCheckSomewhere = true;
						break;
					}
				}
				
				if (!hasCheckSomewhere)
				{
					dispatchEvent(new GameEvent(GameEvent.CALL, "OnEmptyCheckListCloseFailed"));
					return false;
				}
			}
			
			return true;
		}
		
		private function applyValue():void
		{
			var currentRenderer : CheckboxListItem;
			var i:int;
			
			if (closeCB != null)
			{
				var valuesChanged:Boolean = false;
				
				for (i = 0; i < mcList.numRenderers; ++i)
				{
					currentRenderer = mcList.getRendererAt(i) as CheckboxListItem;
					
					if (currentRenderer && currentRenderer.visible && currentRenderer.data != null)
					{
						if (currentRenderer.isChecked != valuesOnShow[i])
						{
							valuesChanged = true;
							break;
						}
					}
				}
				
				closeCB(valuesChanged);
				hide();
			}
		}
		
		private function hide():void
		{
			unregisterMouseEventsForItem(mcItemRenderer1);
			unregisterMouseEventsForItem(mcItemRenderer2);
			unregisterMouseEventsForItem(mcItemRenderer3);
			unregisterMouseEventsForItem(mcItemRenderer4);
			unregisterMouseEventsForItem(mcItemRenderer5);
			unregisterMouseEventsForItem(mcItemRenderer6);
			unregisterMouseEventsForItem(mcItemRenderer7);
			unregisterMouseEventsForItem(mcItemRenderer8);
			unregisterMouseEventsForItem(mcItemRenderer9);
			unregisterMouseEventsForItem(mcItemRenderer10);
			visible = false;
			
			if (hideCB != null)
			{
				hideCB();
			}
		}
	}
}
