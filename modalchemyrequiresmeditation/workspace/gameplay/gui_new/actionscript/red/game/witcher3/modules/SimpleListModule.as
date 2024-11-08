/***********************************************************************
/** PANEL glossary characters main class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.modules
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.core.CoreMenuModule;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.mainmenu.IngameMenu;
	import red.game.witcher3.menus.mainmenu.W3MenuListItemRenderer;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ListEvent;
	import scaleform.gfx.MouseEventEx;

	public class SimpleListModule extends CoreMenuModule
	{
		public var mcList : W3ScrollingList;
		public var mcListItem1 : W3MenuListItemRenderer;
		public var mcListItem2 : W3MenuListItemRenderer;
		public var mcListItem3 : W3MenuListItemRenderer;
		public var mcListItem4 : W3MenuListItemRenderer;
		public var mcListItem5 : W3MenuListItemRenderer;
		public var mcListItem6 : W3MenuListItemRenderer;
		public var mcListItem7 : W3MenuListItemRenderer;
		public var mcListItem8 : W3MenuListItemRenderer;
		public var mcListItem9 : W3MenuListItemRenderer;
		public var mcListItem10 : W3MenuListItemRenderer;

		public var txtMenuListDescripion : TextField;
		public var txtMenuListTitle : TextField;
		public var mcMenuTitleUnderline : MovieClip;
		public var mcGameLogo : MovieClip;
		
		protected var _lastMoveWasMouse:Boolean = false;

		override protected function configUI():void
		{
			super.configUI();
			
			if (txtMenuListDescripion)
			{
				txtMenuListDescripion.visible = false;
			}
			
			registerMouseEvents();
			
			if (mcList)
			{
				mcList.focusable = false;
				mcList.addEventListener(ListEvent.INDEX_CHANGE, handleIndexChanged, false, 0, true);
			}
		}
		
		public function onLastMoveStatusChanged(lastMoveWasMouse:Boolean):void
		{
			_lastMoveWasMouse = lastMoveWasMouse;
			
			if (!lastMoveWasMouse)
			{
				if (_lockedSelectionIndex != -1)
				{
					//trace("GFX ------------------ 555 ---- Setting selected index to: " + _lockedSelectionIndex);
					//trace("GFX ---------- lastMoveWasMouse is false so we are hiding the selection");
					hideSelection = true;
					mcList.selectedIndex = _lockedSelectionIndex;
				}
				else
				{
					hideSelection = false;
					//trace("GFX ------------------ 777 ---- Setting selected index to: 0");
					if (mcList.selectedIndex == -1)
					{
						mcList.selectedIndex = 0;
					}
				}
			}
			else
			{
				//trace("GFX ------------ lastMoveWasMouse is true so we are showing the selection");
				if (_lastMouseOveredItem != -1)
				{
					hideSelection = false;
					//trace("GFX ------------------ 666 ---- Setting selected index to: " + _lastMouseOveredItem);
					mcList.selectedIndex = _lastMouseOveredItem;
				}
			}
		}
		
		protected var _lockedSelectionIndex:int = -1;
		public function get lockSelectionIndex() : int
		{
			return _lockedSelectionIndex;
		}
		public function set lockSelection(value:Boolean):void
		{
			if (value)
			{
				_lockedSelectionIndex = mcList.selectedIndex;
				if (_lockedSelectionIndex != -1)
				{
					(mcList.getRendererAt(_lockedSelectionIndex) as W3MenuListItemRenderer).showOpen = true;
				}
				
				if ((_lastMoveWasMouse && _lastMouseOveredItem == -1) || !_lastMoveWasMouse)
				{
					hideSelection = true;
				}
			}
			else
			{
				if (_lockedSelectionIndex != -1)
				{
					(mcList.getRendererAt(_lockedSelectionIndex) as W3MenuListItemRenderer).showOpen = false;
				}
				_lockedSelectionIndex = -1;
				hideSelection = false;
			}
		}
		
		public function registerMouseEvents():void
		{
			registerMouseEventsForItem(mcListItem1);
			registerMouseEventsForItem(mcListItem2);
			registerMouseEventsForItem(mcListItem3);
			registerMouseEventsForItem(mcListItem4);
			registerMouseEventsForItem(mcListItem5);
			registerMouseEventsForItem(mcListItem6);
			registerMouseEventsForItem(mcListItem7);
			registerMouseEventsForItem(mcListItem8);
			registerMouseEventsForItem(mcListItem9);
			registerMouseEventsForItem(mcListItem10);
		}
		
		protected function registerMouseEventsForItem(item:W3MenuListItemRenderer):void
		{
			item.addEventListener(MouseEvent.CLICK, onItemClicked, false, 1, true);
			item.addEventListener(MouseEvent.MOUSE_OVER, onItemMouseOver, false, 1, true);
			item.addEventListener(MouseEvent.MOUSE_OUT, onItemMouseOut, false, 1, true);
		}
		
		protected function onItemClicked(event:MouseEvent):void
		{
			onItemMouseOver(event);
			
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			if (superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
			{
				var ingameMenu:IngameMenu = parent as IngameMenu;
				if (ingameMenu)
				{
					ingameMenu.activateMenuListItem();
					event.stopImmediatePropagation();
				}
			}
		}
		
		protected var _lastMouseOveredItem:int = -1;
		protected function onItemMouseOver(event:MouseEvent):void
		{
			var currentTarget:W3MenuListItemRenderer = event.currentTarget as W3MenuListItemRenderer;
			
			_lastMouseOveredItem = mcList.getRenderers().indexOf(currentTarget);
			
			if (_lastMoveWasMouse)
			{
				//trace("GFX ------------- onItemMouseOver changed selection and unhid to index: " + currentTarget.index);
				hideSelection = false;
				mcList.selectedIndex = currentTarget.index;
			}
		}
		
		protected function onItemMouseOut(event:MouseEvent):void
		{
			_lastMouseOveredItem = -1;
			
			if (_lastMoveWasMouse)
			{
				//trace("GFX ---------------- Simple list changed index to: " + _lockedSelectionIndex + " from a MouseOut event");
				hideSelection = true;
				mcList.selectedIndex = _lockedSelectionIndex;
			}
		}
		
		protected function handleIndexChanged(event:ListEvent):void
		{
			updateSelectedItemDescriptionText();
		}
		
		protected function updateSelectedItemDescriptionText():void
		{
			if (txtMenuListDescripion)
			{
				var selectedItem:W3MenuListItemRenderer = mcList.getSelectedRenderer() as W3MenuListItemRenderer;
				if (selectedItem)
				{
					var itemData:Object = selectedItem.data;
					if (itemData && itemData.description)
					{
						txtMenuListDescripion.htmlText = CommonUtils.fixFontStyleTags(itemData.description);
						txtMenuListDescripion.visible = true;
					}
					else
					{
						txtMenuListDescripion.visible = false;
					}
				}
				else
				{
					txtMenuListDescripion.visible = false;
				}
			}
		}
		
		public function updateSelectedItemText(value:String):void
		{
			var selectedItem:W3MenuListItemRenderer = mcList.getSelectedRenderer() as W3MenuListItemRenderer;
			if (selectedItem)
			{
				selectedItem.label = value;
			}
		}
		
		private var _hideSelection:Boolean = false;
		public function get hideSelection():Boolean { return _hideSelection; }
		public function set hideSelection(value:Boolean):void
		{
			if (_hideSelection == value)
			{
				return;
			}
			
			_hideSelection = value
			
			if (mcListItem1) { mcListItem1.hideSelection = value; }
			if (mcListItem2) { mcListItem2.hideSelection = value; }
			if (mcListItem3) { mcListItem3.hideSelection = value; }
			if (mcListItem4) { mcListItem4.hideSelection = value; }
			if (mcListItem5) { mcListItem5.hideSelection = value; }
			if (mcListItem6) { mcListItem6.hideSelection = value; }
			if (mcListItem7) { mcListItem7.hideSelection = value; }
			if (mcListItem8) { mcListItem8.hideSelection = value; }
			if (mcListItem9) { mcListItem9.hideSelection = value; }
			if (mcListItem10) { mcListItem10.hideSelection = value; }
			
			//mouseEnabled = !value;
			//mouseChildren = !value;
		}
		
		public function set titleText(value:String):void
		{
			if (value == "")
			{
				txtMenuListTitle.visible = false;
				if (mcMenuTitleUnderline)
				{
					mcMenuTitleUnderline.visible = false;
				}
			}
			else
			{
				txtMenuListTitle.visible = true;
				txtMenuListTitle.htmlText = CommonUtils.fixFontStyleTags(value);
				txtMenuListTitle.htmlText = CommonUtils.toUpperCaseSafe( txtMenuListTitle.htmlText );
				

				if (mcMenuTitleUnderline)
				{
					mcMenuTitleUnderline.visible = true;
					mcMenuTitleUnderline.y = txtMenuListTitle.y + txtMenuListTitle.textHeight;
				}
			}
		}

		public function setGameLogoLanguage(  language : String ) : void
		{
			if ( mcGameLogo )
			{
				mcGameLogo.gotoAndStop(language);
			}
		}

		public function setListData( data : DataProvider, selectionIndex:int = 0 ) : void
		{
			var i:int;
			
			// #J Following block is not ideal but simpler and safer than trying to inject back buttons all over the data
			// Also this forces the back to the last element which is not easy to do when these lists are so dynamic
			var ingameMenu:IngameMenu = parent as IngameMenu;
			if (ingameMenu)
			{
				var hasBackButton:Boolean = false;
				// Check if Data should have back button
				for (i = 0; i < data.length; ++i)
				{
					if (data[i].type == IngameMenu.IGMActionType_Back)
					{
						hasBackButton = true;
						break;
					}
				}
				
				if (ingameMenu.previousEntries.length > 0 && !hasBackButton)
				{
					var subElementsAry:Array = new Array();
					var backData:Object = { id:"credits", tag:666, label:"[[panel_mainmenu_back]]", type:IngameMenu.IGMActionType_Back, subElements:subElementsAry };
					data.push(backData);
				}
			}
			
			mcList.dataProvider = data;
			mcList.validateNow();
			if (_lastMoveWasMouse && _lastMouseOveredItem != -1)
			{
				mcList.selectedIndex = _lastMouseOveredItem;
			}
			else
			{
				mcList.selectedIndex = selectionIndex;
			}
			repositionRenderers();
			updateSelectedItemDescriptionText();
		}

		public function repositionRenderers():void
		{
			var i :int;
			var curRenderer : W3MenuListItemRenderer;
			var NextPosY : Number = 0;

			for ( i = 0; i < mcList.numRenderers; i++)
			{
				curRenderer = mcList.getRendererAt(i) as W3MenuListItemRenderer;

				if (curRenderer)
				{
					curRenderer.y = NextPosY;
					NextPosY += curRenderer.textField.textHeight + 17;
				}
			}
		}
	}
}
