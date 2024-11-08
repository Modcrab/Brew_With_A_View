/***********************************************************************
/** Inventory Player details module
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import red.game.witcher3.managers.InputFeedbackManager;
	import scaleform.clik.core.UIComponent;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3TextArea;
	import red.core.CoreMenuModule;
	import red.core.CoreComponent;
	import scaleform.clik.controls.ScrollBar;

	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.game.witcher3.utils.CommonUtils;

	public class TextAreaModule extends CoreMenuModule
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/

		public var tfTitle 		: TextField;
		public var tfDifficulty : TextField;
		public var tfLocation	: TextField;
		public var headerColor	: MovieClip;
		public var crests		: MovieClip;
		public var skullIcon	: MovieClip;
		public var mcTextArea 	: W3TextArea;
		public var mcScrollbar 	: ScrollBar;
		public var mcSeparator 	: Sprite;
		public var mcFrameDescr	: MovieClip;
		
		protected var _inputSymbolScroll				:int = -1;
		public static const TEXT_HEIGHT_PADDING 		: int = 0.5;
		public static const TEXT_HEADER_PADDING_BOTTOM 	: int = 18;
		
		

		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/

		protected var _moduleDisplayName : String = "";

		/********************************************************************************************************************
			INIT
		/ ******************************************************************************************************************/

		public function TextAreaModule()
		{
			super();
		
			/// TODO: Move to separate class
			
			if (skullIcon)
			{
				skullIcon.visible = false;
			}
			
			if (crests)
			{
				crests.visible = false;
			}
			
			if (headerColor)
			{
				headerColor.visible = false;
			}
		}

		protected override function configUI():void
		{
			super.configUI();
			mouseEnabled = false;

			//mcScrollbar.alpha = 0.4;

			_inputHandlers.push(mcTextArea);

			SetTitle(_lastTitle);
			SetText(_lastText);
		}

		override public function hasSelectableItems():Boolean
		{
			trace("GFX TextAreaModule ", mcScrollbar.visible, mcScrollbar.enabled);
			
			if (mcScrollbar.visible && mcScrollbar.enabled)
			{
				return true;
			}

			return false;
		}

		/********************************************************************************************************************
			DATA
		/ ******************************************************************************************************************/
		protected var _lastTitle:String = "";
		public function SetTitle( value : String ) : void
		{
			_lastTitle = value;
			if (tfTitle)
			{
				_moduleDisplayName = value;
				if ( CoreComponent.isArabicAligmentMode )
				{
					value = "<p align=\"right\">" + value+"</p>";
				}
				tfTitle.htmlText = value;
				tfTitle.htmlText = CommonUtils.toUpperCaseSafe(tfTitle.htmlText);
				
			}
			handleDataChanged();
			updateTextPositions();
		}
		
		public function setDifficulty( value : String ) :void
		{
			if ( value == "" )
			{
				tfDifficulty.visible = false;
			}
			else
			{
				tfDifficulty.visible = true;
				var textValue : String = CommonUtils.toUpperCaseSafe( value );
				if ( CoreComponent.isArabicAligmentMode )
				{
					textValue = "<p align=\"right\">" + textValue +"</p>";
				}
				tfDifficulty.htmlText = textValue;
			}
			
			updateTextPositions();
		}
		
		public function ShowSkullIcon( value : Boolean ) :void
		{
			if (skullIcon)
			{
				skullIcon.visible = value;
			}
		}
		
		public function setLocation( value : String ) :void
		{
			
			var textValue : String = CommonUtils.toUpperCaseSafe( value );
			if ( CoreComponent.isArabicAligmentMode )
			{
				textValue = "<p align=\"right\">" + textValue +"</p>";
			}
			
			tfLocation.htmlText = textValue;
			updateTextPositions();
		}
		
		public function setCrest( value : String ) :void
		{
			if (crests)
			{
				crests.gotoAndStop(value);
				crests.visible = true;
			}
		}
		
		public function updateTextPositions()
		{
			if (tfLocation && tfDifficulty && headerColor && crests && skullIcon)
			{
				if ( tfDifficulty.visible == true )
				{
					tfLocation.y = tfTitle.y + tfTitle.textHeight + TEXT_HEIGHT_PADDING;
					tfDifficulty.y = tfLocation.y + tfLocation.textHeight + TEXT_HEIGHT_PADDING;
					headerColor.height = tfTitle.textHeight + tfLocation.textHeight + tfDifficulty.textHeight + TEXT_HEADER_PADDING_BOTTOM;
					crests.y =  headerColor.y + headerColor.height / 2 - crests.height / 2;
					skullIcon.y = tfDifficulty.y + tfDifficulty.textHeight / 2 - skullIcon.height / 2;
				}
				else
				{
					tfLocation.y = tfTitle.y + tfTitle.textHeight + TEXT_HEIGHT_PADDING;
					headerColor.height = tfTitle.textHeight + tfLocation.textHeight +  TEXT_HEADER_PADDING_BOTTOM;
					crests.y =  headerColor.y + headerColor.height / 2 - crests.height / 2;
					skullIcon.visible = false;
				}
				
			}
		}
		public function setHeaderColor( value : Number):void
		{
			if (headerColor)
			{
				headerColor.visible = true;
				headerColor.gotoAndStop( 1 );
				
				switch(value)
				{
					case 0://Main Story Quests
						headerColor.gotoAndStop( "main" );
						break;
					case 1: //Main Quests
						headerColor.gotoAndStop( "main" );;
						break;
					case 2://Secondary Quests
						headerColor.gotoAndStop( "secondary" );
						break;
					case 3://Witcher Contracts
						headerColor.gotoAndStop( "contract" );
						break;
					case 4://Treasure Hunts
						headerColor.gotoAndStop( "treasurehunt" );
						break;
				}
			}
		}

		protected var _lastText:String = "";
		public function SetText( value : String  ) : void
		{
			_lastText = value;
			if ( CoreComponent.isArabicAligmentMode )
			{
				value = "<p align=\"right\">" + value+"</p>";
			}
			mcTextArea.htmlText = value;
			
			if ( mcFrameDescr )
			{
				if( value == "")
				{
					mcFrameDescr.visible = false;
				}
				else
				{
					mcFrameDescr.visible = true;
				}
			}
			handleDataChanged();
			
			validateNow();
			updateInputFeedback();
		}


		override public function set focused(value:Number):void
		{
            super.focused = value;
			
			trace("GFX TextAreaModule; focused ", _focused);
			
			if ( _focused )
			{
				SetAsActiveContainer(true);
				//mcScrollbar.alpha = 1.0;
			}
			else
			{
				//mcScrollbar.alpha = 0.4;
				SetAsActiveContainer(false);
			}
			
			updateInputFeedback();
		}

		public function SetAsActiveContainer( value : Boolean )
		{
			if (tfTitle)
			{
				tfTitle.htmlText = _moduleDisplayName;
				tfTitle.htmlText = CommonUtils.toUpperCaseSafe(tfTitle.htmlText);
				tfTitle.height = tfTitle.textHeight;
			}
		}

		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled || !focused )
			{
				return;
			}

			var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);

			for each ( var handler:UIComponent in _inputHandlers )
			{
				if ( event.handled )
				{
					event.stopImmediatePropagation();
					return;
				}
				handler.handleInput( event );
			}
			if (keyPress)
			{
				switch(details.navEquivalent)
				{
					case NavigationCode.DOWN:
					case NavigationCode.UP:
						event.handled  = true;
						return;
				}
			}
		}
		
		protected function scrollFocusCheck():Boolean
		{
			return focused == 1;
		}
		
		protected function updateInputFeedback():void
		{
			var canScroll:Boolean;
			
			if ( scrollFocusCheck() )
			{
				canScroll = mcScrollbar.visible;
			}
			else
			{
				canScroll = false;
			}
			
			if (canScroll && _inputSymbolScroll == -1)
			{
				_inputSymbolScroll = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_RSTICK_SCROLL, -1, "input_feedback_scroll_text");
			}
			else if (!canScroll && _inputSymbolScroll != -1)
			{
				InputFeedbackManager.removeButton(this, _inputSymbolScroll);
				_inputSymbolScroll = -1;
			}
			
			InputFeedbackManager.updateButtons(this);
		}
	}
}
