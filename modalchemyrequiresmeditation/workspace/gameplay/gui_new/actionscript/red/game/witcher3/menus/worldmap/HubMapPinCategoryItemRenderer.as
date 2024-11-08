package red.game.witcher3.menus.worldmap {
	
	import flash.display.MovieClip;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.BaseListItem;
	import scaleform.clik.controls.ListItemRenderer;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import red.core.constants.KeyCode;
	import scaleform.gfx.MouseEventEx;
	
	import red.game.witcher3.menus.worldmap.data.CategoryData;
	import red.game.witcher3.menus.worldmap.data.CategoryPinData;
	import red.game.witcher3.menus.worldmap.data.CategoryPinInstanceData;
	
	public class HubMapPinCategoryItemRenderer extends BaseListItem
	{
		public var tfPinType : TextField;
		public var mcIconContainer : MovieClip;
		public var mcArrowsContainer : MovieClip;
		public var funcChangePinIndex : Function;
		public var funcTogglePin : Function;
		public var funcIsPinDisabled : Function;

		public var mcBackground:MovieClip;
		public var mcSelectionAnim:MovieClip;
		private const TEXT_PADDING = 10;
		
		private var txtCounter: TextField;
		private var otherTextFormat: TextFormat;
		private var lTextFormat : TextFormat;
		private var currTextFormat : TextFormat;
		
		public function HubMapPinCategoryItemRenderer()
		{

		}
		
		override public function set enabled(value:Boolean):void 
		{
			super.enabled = value;
			mouseEnabled = true;
			mouseChildren  = true;			
		}
		
		protected override function configUI():void
		{
			super.configUI();
			
			mouseEnabled = true;
			mouseChildren  = true;
		
			mcArrowsContainer.mcHubMapPinCategoryArrowLeft.addEventListener(  MouseEvent.MOUSE_DOWN, handleArrowLeft,	false, 0, true );
			mcArrowsContainer.mcHubMapPinCategoryArrowRight.addEventListener( MouseEvent.MOUSE_DOWN, handleArrowRight,	false, 0, true );
			mcIconContainer.addEventListener( MouseEvent.MOUSE_DOWN, handleToggleVisibilityLMB, false, 0, true );
			addEventListener( MouseEvent.MOUSE_DOWN, handleToggleVisibilityRMB, false, 0, true );
		}

		public function handleArrowLeft( event : MouseEventEx )
		{
			if ( event.buttonIdx == MouseEventEx.LEFT_BUTTON )
			{
				if ( funcChangePinIndex != null )
				{
					funcChangePinIndex( this, -1 );
				}
			}
		}

		public function handleArrowRight( event : MouseEventEx )
		{
			if ( event.buttonIdx == MouseEventEx.LEFT_BUTTON )
			{
				if ( funcChangePinIndex != null )
				{
					funcChangePinIndex( this, 1 );
				}
			}
		}
		
		public function handleToggleVisibilityLMB( event : MouseEventEx )
		{
			if ( event.buttonIdx == MouseEventEx.LEFT_BUTTON )
			{
				toggleVisibility();
			}
		}

		public function handleToggleVisibilityRMB( event : MouseEventEx )
		{
			if ( event.buttonIdx == MouseEventEx.RIGHT_BUTTON )
			{
				toggleVisibility();
			}
		}
		
		private function toggleVisibility()
		{
			if ( funcTogglePin != null )
			{
				funcTogglePin( data._name );
			}

			updateVisibility();
		}
		
		override public function handleInput( event : InputEvent ) : void
		{
            var details : InputDetails = event.details;
            var keyPress : Boolean = ( details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD );
            var keyUp : Boolean = ( details.value == InputValue.KEY_UP );
			
			if ( details.code == KeyCode.PAD_LEFT_TRIGGER )
			{
				if ( keyUp )
				{
					toggleVisibility();
					return;
				}
			}
			
			super.handleInput( event );
		}
		
		public function updateVisibility()
		{
			var disabled : Boolean = false;
			if ( funcIsPinDisabled != null )
			{
				disabled = funcIsPinDisabled( data._name );
			}
			mcIconContainer.mcDisabled.visible = disabled;
			setColoredText( data.translation, disabled );
		}
		
		override public function set selected(value:Boolean):void
		{
			super.selected = value;
			
			if (mcSelectionAnim)
			{
				mcSelectionAnim.visible = selected;
			}
		}

		override public function setData( data : Object ):void
		{
			super.setData(data);

			var pinData : CategoryPinData = data as CategoryPinData;
			if ( pinData )
			{
				mcIconContainer.mcIcon.gotoAndStop( pinData._name );
				updateVisibility();
				tfPinType.width = tfPinType.textWidth + CommonConstants.SAFE_TEXT_PADDING;
				setCounter( pinData._index, pinData._instances.length );
				mcBackground.width = tfPinType.x -mcBackground.x + tfPinType.textWidth + TEXT_PADDING;
				if (mcSelectionAnim)
				{
					mcSelectionAnim.width = mcBackground.width;
				}
			}
		}
		
		private function setColoredText( text : String, disabled : Boolean )
		{
			if ( disabled )
			{
				tfPinType.htmlText = "<font color='#bf1f1f'>" + data._translation + "</font>";
			}
			else
			{
				tfPinType.htmlText = "<font color='#dfdede'>" + data._translation + "</font>";
			}
		}
		
		public function setCounter( index, count : int )
		{
			var shift : int = 1;
			if ( count == 0 )
			{
				shift = 0;
			}
			
			lTextFormat = new TextFormat("$NormalFont", 20);
			lTextFormat.font = "$NormalFont";
			lTextFormat.align = TextFormatAlign.CENTER;
			otherTextFormat = new TextFormat("$NormalFont", 17);
			otherTextFormat.font = "$NormalFont";
			otherTextFormat.align = TextFormatAlign.CENTER;
			txtCounter = mcArrowsContainer.getChildByName("tfCounter") as TextField;
			
			if (txtCounter)		
			{
				txtCounter.defaultTextFormat = lTextFormat;
				txtCounter.setTextFormat(lTextFormat);
				
				txtCounter.text = ( index + shift ) + "/" + count;
				
				if (txtCounter.textWidth > txtCounter.width )
				{
					currTextFormat = otherTextFormat;
				}
				else
				{
					currTextFormat = lTextFormat;
				}
				
				formatText();
			}
		}
		
		override protected function updateText():void 
		{
			super.updateText();
			
			formatText();
		}
		
		private function formatText():void
		{
			if (txtCounter && currTextFormat)
			{
				txtCounter.defaultTextFormat = currTextFormat;	
				txtCounter.setTextFormat(currTextFormat);
			}
		}

	}
	
}
