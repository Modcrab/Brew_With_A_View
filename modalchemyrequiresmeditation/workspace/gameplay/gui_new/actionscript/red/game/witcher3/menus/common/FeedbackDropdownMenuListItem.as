package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.EInputDeviceType;
	import red.game.witcher3.constants.PlatformType;
	import red.game.witcher3.controls.W3DropdownMenuListItem;
	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.events.ListEvent;
	import red.game.witcher3.controls.W3DropDownItemRenderer;

	public class FeedbackDropdownMenuListItem extends W3DropdownMenuListItem
	{
		public var mcFeedbackIcon : MovieClip;
		public var mcNewOverlay : MovieClip;
		public var mcSelectionHighlight : MovieClip;
		public var mcCollapseBtnIcon : MovieClip;
		protected var _isNew : Boolean = false;

		public function FeedbackDropdownMenuListItem()
		{
			super();
			
			if (mcFeedbackIcon)
			{
				mcFeedbackIcon.visible = false;
			}
			
			if (mcNewOverlay)
			{
				mcNewOverlay.visible = false;
			}
			
			if (mcCollapseBtnIcon)
			{
				var inputMgr:InputManager = InputManager.getInstance();
				
				mcCollapseBtnIcon.visible = false;
				
				if (inputMgr.gamepadType == EInputDeviceType.IDT_Steam)
				{
					mcCollapseBtnIcon.gotoAndStop( 3 );
				}
				else
				{
					mcCollapseBtnIcon.gotoAndStop( (inputMgr.isPsGamepad()) ? 2 : 1 );
				}
				
				inputMgr.addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged, false, 0, true);
			}
		}
		
		private function handleControllerChanged( event : ControllerChangeEvent ):void
		{
			mcCollapseBtnIcon.visible = event.isGamepad && isOpen() && selected;
		}
		
		override public function open(allowSound : Boolean = true):void
		{
			super.open( allowSound );
			
			if ( mcCollapseBtnIcon )
			{
				mcCollapseBtnIcon.visible = InputManager.getInstance().isGamepad() && selected;
			}
		}
		
		override public function close():void
		{
			super.close();
			
			if ( mcCollapseBtnIcon )
			{
				mcCollapseBtnIcon.visible = false;
			}
		}
		
		override public function set selected(value:Boolean):void
		{
			super.selected = value;
			
			mcCollapseBtnIcon.visible = InputManager.getInstance().isGamepad() && isOpen() && selected;
		}

		override protected function configUI():void
		{
			super.configUI();
			
			if (mcSelectionHighlight)
			{
				mcSelectionHighlight.visible = false;
			}
		}

		override public function setDropdownData( dropdownDataIn : Object ) : void
		{
            super.setDropdownData(dropdownDataIn);
			CheckDropDownRefNewState();
        }

		protected function SetReadState( movie : MovieClip )
		{
			if ( _isNew )
			{
				movie.visible = true;
			}
			else
			{
				movie.visible = false;
			}
		}
		
		private var selectedByTag:Boolean;
		override protected function handleSelectChange( e : ListEvent ) // #B move from here - to kill
		{
			if (mcSelectionHighlight)
			{
				mcSelectionHighlight.visible = true;
			}
				
			if ( e.index > -1 )
			{
				if ( _dropdownRef )
				{
					var renderer : BaseListItem = _dropdownRef.getRendererAt(e.index) as BaseListItem;
					//dropDownData[e.index].isNew = false;
					CheckDropDownRefNewState();
					if (renderer)
					{
						if (renderer.data)
						{
							if(renderer.data.id)
							{
								dispatchEvent(new GameEvent(GameEvent.CALL, selectionEventName, [renderer.data.id]));
								selectedByTag = false;
							}
							else if(renderer.data.tag)
							{
								dispatchEvent(new GameEvent(GameEvent.CALL, selectionEventName, [renderer.data.tag]));
								selectedByTag = true;
							}
							
							if (renderer is RecipeIconItemRenderer)
							{
								(renderer as RecipeIconItemRenderer).fireShowTooltipEvent();
							}
						}
					}
					else
					{
						dispatchEvent(new GameEvent(GameEvent.CALL, selectionEventName, [uint(0)]));
					}
					
					if (mcSelectionHighlight)
					{
						mcSelectionHighlight.visible = false;
					}
				}
			}
			else
			{
				dispatchEvent(new GameEvent(GameEvent.CALL, selectionEventName, [uint(0)]));
			}
		}

		protected function CheckDropDownRefNewState()
		{
			var i : int;
			_isNew = false;
			for ( i = 0; i < dropDownData.length; i++ )
			{
				if( dropDownData[i].isNew )
				{
					_isNew = true;
					break;
				}
			}
			SetReadState(mcNewOverlay);
		}

		override protected function handleMenuItemDoubleClick(e:ListEvent):void
		{
			var renderer : W3DropDownItemRenderer = _dropdownRef.getRendererAt(e.index) as W3DropDownItemRenderer;
			renderer.handleEntryPress();
        }

		override protected function handleMenuItemPress(e:ListEvent):void
		{
			if( e.isKeyboard )
			{
				var renderer : W3DropDownItemRenderer = _dropdownRef.getRendererAt(e.index) as W3DropDownItemRenderer;
				renderer.handleEntryPress();
			}
        }
	}

}
