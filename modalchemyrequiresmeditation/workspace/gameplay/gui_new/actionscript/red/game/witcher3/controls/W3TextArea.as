package red.game.witcher3.controls
{
	import com.gskinner.motion.plugins.CurrentFramePlugin;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import red.core.CoreComponent;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.controls.TextArea;
    import flash.text.TextField;

    import scaleform.gfx.Extensions;
    import scaleform.clik.utils.ConstrainedElement;
	
	import scaleform.clik.controls.ScrollIndicator;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import red.core.events.GameEvent;
	
	public class W3TextArea extends TextArea
	{
		//public var bBlockSound : Boolean = false;
		
		protected var _scrollSpeed 		: Number;
		protected var _baseTextColor 	: uint
		protected var _uppercase 		: Boolean;
		protected var _alignArabicText  : Boolean;
		
		// hack to arabic alignment
		protected var txtInitPosition	: Number; 
		
		public function W3TextArea()
		{
			super();
			txtInitPosition = textField.x;
		}
		
		public function get uppercase():Boolean { return _uppercase };
		public function set uppercase(value:Boolean):void
		{
			_uppercase = value;
		}
		
		[Inspectable(defaultValue="false")]
		public function get alignArabicText():Boolean { return _alignArabicText };
		public function set alignArabicText(value:Boolean):void
		{
			_alignArabicText = value;
		}
		
		override public function set text(value:String):void 
		{
			if (value == null) value = "";
			super.text = value;
        }

		protected override function configUI():void
		{
			super.configUI();
			addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheelScroll, false, 0, true);
			_baseTextColor = textField.textColor;
			_textColorChange = _baseTextColor;
		}
		
		override public function set position(value:int):void
		{
			super.position = value;
			//updateScrollBar();
			scrollBar.position = value;
			if ( _maxScroll > 1 )
			{
				if ( position != value )
				{
					dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_scroll_description"]));
				}
				else
				{
					dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_scroll_description_failed"]));
				}
			}
        }
		
		[Inspectable(defaultValue = 40)]
		public function get scrollSpeed( ) : Number
		{
			return _scrollSpeed;
		}
		public function set scrollSpeed( value : Number ) : void
		{
			_scrollSpeed = value;
		}
		
		// #J possible values: "on", "off", "auto"
		public function changeScrollBarPolicy( policy : String ) : void
		{
			_scrollPolicy = policy;
			updateScrollBar();
		}
		
		 override protected function updateText():void 
		 {
            super.updateText();
			
			if (_baseTextColor != _textColorChange || textField.textColor != _baseTextColor)
			{
				textField.textColor = _textColorChange;
			}
						
			if (_uppercase)
			{
				textField.htmlText = CommonUtils.toUpperCaseSafe(textField.htmlText);
			}
			
			if (_alignArabicText && CoreComponent.isArabicAligmentMode)
			{
				var curTF:TextFormat = textField.getTextFormat();
				curTF.align = TextFormatAlign.RIGHT;
				textField.setTextFormat(curTF);
				textField.x = txtInitPosition - (textField.width - textField.textWidth);
			}
			else
			{
				textField.x = txtInitPosition;
			}
        }
		
        /** Updates the scroll position and thumb size of the ScrollBar. */ //#B fix for hide scrool bar when no neeeded
       override protected function updateScrollBar():void
	   {
            _maxScroll = textField.maxScrollV;
            var sb:ScrollIndicator = _scrollBar as ScrollIndicator;
            if ( sb == null )
			{
				return;
			}
            var element:ConstrainedElement = constraints.getElement("textField");
            if (_scrollPolicy == "on" || (_scrollPolicy == "auto" && textField.maxScrollV > 1))
			{
                if (_autoScrollBar && !sb.visible)  // Add some space on the right for the scrollBar
                {
					if (element != null)
                    {
						constraints.update(_width, _height);
                        invalidate();
                    }
                    _maxScroll = textField.maxScrollV; // Set this again, in case adding a scrollBar made the maxScroll larger.
                }
                sb.visible = true;
            }

            // If no ScrollIndicator is needed, hide it.
            if (_scrollPolicy == "off" || (_scrollPolicy == "auto" && textField.maxScrollV < 2))
			{
				if( sb.visible ) // #B this is fix
				{
					sb.visible = false; // Hide the ScrollBar before calling availableWidth to remove it from the calculation.
				}
                if (_autoScrollBar) // Remove any added space.
				{
                    if (element != null)
					{
                        constraints.update(availableWidth, _height);
                        invalidate();
                    }
                }
            }

            if (sb.enabled != enabled)
			{
				sb.enabled = enabled;
			}
        }
		
		public function CanBeFocused() : Boolean
		{
			return (textField.maxScrollV > 1 );
		}
		
		protected var _textColorChange:uint;
		public function setTextColor(color:uint):void
		{
			_textColorChange = color;
			textField.textColor = _textColorChange;
		}
		
		public function resetTextColor():void
		{
			_textColorChange = _baseTextColor;
			textField.textColor = _textColorChange;
		}
		
		override protected function blockMouseWheel(event:MouseEvent):void
		{
		}
		
		protected function onMouseWheelScroll(event:MouseEvent):void
		{
			position = textField.scrollV;
		}
		
		override protected function onScroller(event:Event):void {
			super.onScroller(event);
			updateScrollBar();
        }
	}
}
