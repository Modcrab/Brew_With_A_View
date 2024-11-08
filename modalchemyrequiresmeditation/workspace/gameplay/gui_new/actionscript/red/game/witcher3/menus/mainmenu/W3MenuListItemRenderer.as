/***********************************************************************
/** Menu list item renderer
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.managers.InputManager;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import red.game.witcher3.utils.CommonUtils;

	public class W3MenuListItemRenderer extends BaseListItem
	{
		public var _CapitalizeAll : Boolean = true;
		public var _IsBackButton : Boolean = false;
		public var mcFrame : MovieClip;

		public function W3MenuListItemRenderer()
		{
			super();
			canBePressed = false;
		}
		
		override protected function setState(state:String):void 
		{
			super.setState(state);			
			//trace("GFX [", this.name, "] _state: ", _state, "; _newFrame: ", _newFrame);
		}

		override public function setData( data:Object ):void
		{
			if (! data )
			{
				return;
			}
			if(data.isBackButton)
			{
				_IsBackButton = data.isBackButton;
			}
			super.setData( data );

		}
		
		protected var _showOpen:Boolean = false;
		public function set showOpen(value:Boolean):void
		{
			_showOpen = value;
			updateText();
		}

		//overriding this coz the base function doesn't use htmlText which doesn't allow us to employ colors
        override protected function updateText():void
		{
            if (_label != null && textField != null)
			{
				if ( data && data.unavailable )
				{
					textField.htmlText = "<font color=\"#555555\">"+_label+"</font>";
				}
				else 
				if ( _IsBackButton && !selected )
				{
					textField.htmlText = "<font color=\"#FFFFFF\">"+_label+"</font>";
				}
				else if (_showOpen)
				{
					textField.htmlText = "<font color=\"#FFFFFF\">"+_label+"</font>";
				}
				else
				{
					textField.htmlText = _label;
				}
				if ( _CapitalizeAll )
				{
					textField.htmlText = CommonUtils.toUpperCaseSafe(textField.htmlText);
				}
				mcFrame = getChildByName( "mcFrame" ) as MovieClip;
				if(mcFrame)
				{
					if (hideSelection)
					{
						if (mcFrame.visible) mcFrame.visible = false;
					}
					else
					{
						if (!mcFrame.visible) mcFrame.visible = true;
						mcFrame.height = textField.textHeight + 33;
					}
				}
            }
        }
		
		private var _hideSelection:Boolean = false;
		public function set hideSelection(value:Boolean):void
		{
			_hideSelection = value;
			
			mcFrame = getChildByName( "mcFrame" ) as MovieClip;
			if(mcFrame)
			{
				if (hideSelection)
				{
					if (mcFrame.visible) mcFrame.visible = false;
				}
				else
				{
					if (!mcFrame.visible) mcFrame.visible = true;
				}
			}
		}
		public function get hideSelection():Boolean { return _hideSelection; }

        //[Inspectable(defaultValue = "false")]
        public function get capitalizeAll():Boolean
		{
			return _CapitalizeAll;
		}
        public function set capitalizeAll(value:Boolean):void
		{
            _CapitalizeAll = value;
        }

		override public function set selected(value:Boolean):void
		{
			super.selected = value;
			trace("HUD W3MLIR selected "+value + " gamepad? "+InputManager.getInstance().isGamepad()+" stage "+stage);
			//if (InputManager.getInstance().isGamepad())
			//{
				/*if (_selected)
				{
					showTooltip();
				}
				else
				{
					hideTooltip();
				}*/
			//}
		}


		// We use pending because of problem with data transfering during one tick
		public function showTooltip():void
		{
			//trace("GFX [SlotBase][", this, "] showTooltip", InputManager.getInstance().isGamepad());
			//if (InputManager.getInstance().isGamepad())
			//{
				/*trace("HUD W3MLIR showTooltip " );
				removeEventListener(Event.ENTER_FRAME, pendedTooltipShow);
				removeEventListener(Event.ENTER_FRAME, pendedTooltipHide);
				addEventListener(Event.ENTER_FRAME, pendedTooltipShow, false, 0, true);

				if (InputManager.getInstance().isGamepad())
				{
					fireTooltipShowEvent();
				}*/
			//}
		}
		public function hideTooltip():void
		{
			//trace("GFX [SlotBase][", this, "] hideTooltip", InputManager.getInstance().isGamepad());
			//if (InputManager.getInstance().isGamepad())
			//{
				/*removeEventListener(Event.ENTER_FRAME, pendedTooltipShow);
				removeEventListener(Event.ENTER_FRAME, pendedTooltipHide);
				addEventListener(Event.ENTER_FRAME, pendedTooltipHide, false, 0, true);*/
			//}
		}

		protected function pendedTooltipShow(event:Event):void
		{
			//trace("GFX [SlotBase] pendedTooltipShow");
			//removeEventListener(Event.ENTER_FRAME, pendedTooltipShow);
			//trace("HUD W3MLIR pendedTooltipShow " );
			//fireTooltipShowEvent(false);
		}
		protected function pendedTooltipHide(event:Event):void
		{
			//trace("GFX [SlotBase] pendedTooltipHide");
			//removeEventListener(Event.ENTER_FRAME, pendedTooltipHide);
			//fireTooltipHideEvent(false);
		}

		protected function fireTooltipShowEvent(isMouseTooltip:Boolean = false):void
		{
			//trace("GFX [SlotBase] fireTooltipShowEvent ", isMouseTooltip);
			/*var displayEvent:GridEvent = new GridEvent(GridEvent.DISPLAY_TOOLTIP, true, false, index, -1, -1, null, _data as Object);
			trace("HUD W3MLIR fireTooltipShowEvent " );
			displayEvent.isMouseTooltip = isMouseTooltip;
			displayEvent.directData = true;
			displayEvent.tooltipContentRef = "InGameMenuTooltipRef";
			displayEvent.anchorRect = getGlobalRect();
			dispatchEvent(displayEvent);*/
		}
		protected function fireTooltipHideEvent(isMouseTooltip:Boolean = false):void
		{
			//trace("GFX [SlotBase] fireTooltipHideEvent ", isMouseTooltip);
			//var hideEvent:GridEvent = new GridEvent(GridEvent.HIDE_TOOLTIP, true, false, index, -1, -1, null, _data as Object);
			//dispatchEvent(hideEvent);
		}

		public function getGlobalRect():Rectangle
		{
			var targetRect:Rectangle = new Rectangle(x, y, width, height);
			var globalPoint:Point =	localToGlobal(new Point(targetRect.x, targetRect.y));
			targetRect.x = globalPoint.x;
			targetRect.y = globalPoint.y;
			return targetRect;
		}
	}
}
