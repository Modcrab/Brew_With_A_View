package red.game.witcher3.menus.overlay
{
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.easing.Linear;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.managers.InputManager;
	import red.core.constants.KeyCode;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.data.KeyBindingData;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import red.game.witcher3.utils.CommonUtils;
	import red.core.CoreComponent;

	/**
	 * Tempory tutorial popup
	 * @author Yaroslav Getsevich
	 *
	 * TODO: move to the popups package
	 *
	 */
	public class TutorialPopup extends UIComponent
	{
		protected static const MIN_WIDTH:Number = 480;
		protected static const MAX_WIDTH:Number = 600;
		protected static const EDGE_PADDING:Number = 5;
		protected static const UI_EDGE_PADDING:Number = 40;
		protected static const GRADIENT_PADDING:Number = 115;
		protected static const TOP_BORDER_POS:Number = -7;		
		protected static const BUTTONS_PADDING:Number = 15;
		protected static const BUTTONS_OFFSET:Number = 10;

		protected static const TOP_OFFSET_FOR_TITLE:Number = 90;
		protected static const SAFE_TEXTFIELD_OFFSET:Number = 5;
		protected static const BLOCK_PADDING:Number = 2;
		protected static const GLOSSARY_RIGHT_PADDING:Number = 60;
		protected static const GLOSSARY_PADDING:Number = 10;
		protected static const GLOSSARY_HEIGHT:Number = 70;
		protected static const BOTTOM_PADDING:Number = 10;

		public var btnAccept:InputFeedbackButton;
		public var btnGlossary:InputFeedbackButton;
		public var txtTitle:TextField;
		public var txtDescription:TextField;
		public var topDelemiter:Sprite;
		public var background:MovieClip;
		public var titleModule:TutorialPopupTitle;
		public var mcErrorFeedback:MovieClip;
		public var mcCorrectFeedback:MovieClip;
		public var contentMask:Sprite;
		
		public var borderLineTop:Sprite;
		public var borderLineBottom:Sprite;
		
		protected var _autosize:Boolean;
		protected var _data:Object;
		protected var _imageLoader:UILoader;
		
		public function TutorialPopup()
		{
			visible = false;
		}

		public function get data():Object { return _data }
		public function set data(value:Object):void
		{
			_data = value;
			if (_data)
			{
				_autosize = _data.autosize;
				visible = false;
				cleanup();
				populateData();
			}
			else
			{
				cleanup();
			}
		}

		public function playFeedbackAnimation(isCorrect:Boolean):void
		{
			if (isCorrect)
			{
				mcCorrectFeedback.gotoAndPlay(2);
			}
			else
			{
				mcErrorFeedback.gotoAndPlay(2);
			}
		}
		
		// shift hint if it is out of the safe rect
		public function getPositionShiftX():Number
		{
			var screenRect:Rectangle = CommonUtils.getScreenRect();
			var globalPosition:Point = this.localToGlobal(new Point(txtDescription.x, txtDescription.y));
			var safeScreenRectPading:Number = screenRect.width * .05;
						
			if (globalPosition.x < safeScreenRectPading)
			{
				return safeScreenRectPading - globalPosition.x;
			}
			else
			if ((globalPosition.x + txtDescription.textWidth) > (screenRect.x + screenRect.width - safeScreenRectPading))
			{
				return (screenRect.x + screenRect.width - safeScreenRectPading) - (globalPosition.x + txtDescription.textWidth);
			}
			return 0 ;
		}

		protected function populateData():void
		{
			var waitImageLoading:Boolean = false;
			
			if (_data.imagePath)
			{
				loadImage(_data.imagePath);
				waitImageLoading = true;
			}

			if (_data.messageTitle)
			{
				txtTitle.text = _data.messageTitle;
				txtTitle.text = CommonUtils.toUpperCaseSafe(txtTitle.text);
				//txtTitle.width = txtTitle.textWidth + CommonConstants.SAFE_TEXT_PADDING;
				txtTitle.height = txtTitle.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				txtTitle.textColor = (_data.isUiTutorial ? 0x0 : 0xAD8F51);
				topDelemiter.visible = true;
				
				var format:TextFormat = new TextFormat();
				if (CoreComponent.isArabicAligmentMode)
				{
					format.font = "$NormalFont";
				}
				else
				{
					format.font = "$BoldFont";
				}
				
				txtTitle.setTextFormat(format);
			}
			if (_data.messageText)
			{
				txtDescription.width = MIN_WIDTH;
				txtDescription.multiline = true;
				txtDescription.wordWrap = true;
				
				var msgText:String = CommonUtils.fixFontStyleTags(_data.messageText);
				
				if (_data.isUiTutorial)
				{
					_data.messageText = "<font color = '#0'>" + msgText + "</font>";
				}
				
				if ( CoreComponent.isArabicAligmentMode )
				{
					txtDescription.htmlText = "<p align=\"right\">" + _data.messageText +"</p>";
				}
				else
				{
					txtDescription.htmlText = _data.messageText;
				}
				txtDescription.visible = true;
				
				/*
				 * don't used
				 * 
				if (_autosize)
				{
					if ( CoreComponent.isArabicAligmentMode )
					{
						txtDescription.autoSize = TextFieldAutoSize.RIGHT;
					}
					else
					{
						txtDescription.autoSize = TextFieldAutoSize.LEFT;
					}
					txtDescription.multiline = false;
					txtDescription.wordWrap = false;
				}
				*/
				
			}
			if (_data.enableGlossaryLink)
			{
				btnGlossary.clickable = false;
				btnGlossary.overrideTextColor = _data.isUiTutorial ? 0 : -1;
				btnGlossary.label = "[[panel_title_glossary]]";
				btnGlossary.setDataFromStage(NavigationCode.GAMEPAD_BACK, -1, KeyCode.PAD_PS4_OPTIONS, 1000);
				btnGlossary.visible = true;				
				btnGlossary.holdCallback = handleGlossaryLink;
				btnGlossary.validateNow();
			}
			else
			{
				btnGlossary.holdCallback = null;
			}
			if (_data.enableAcceptButton)
			{
				btnAccept.clickable = false;
				btnAccept.overrideTextColor = _data.isUiTutorial ? 0 : -1;
				btnAccept.label = "[[panel_continue]]";
				btnAccept.setDataFromStage(NavigationCode.GAMEPAD_A, KeyCode.SPACE);				
				btnAccept.visible = true;
				btnAccept.validateNow();
			}
			else
			{
				btnAccept.visible = false;
			}
			
			background.gotoAndStop(_data.isUiTutorial ? "ui" : "game");
			
			if (!waitImageLoading)
			{
				alignContent();
			}
		}

		private function alignContent():void
		{
			var currentHeight:Number = 0;
			var currentWidth:Number = 0;
			
			var screenRect:Rectangle = CommonUtils.getScreenRect();
			
			var safePadding:Number;
			
			if (topDelemiter.visible)
			{
				currentHeight += (TOP_OFFSET_FOR_TITLE + BLOCK_PADDING);
			}
			else
			{
				currentHeight += BLOCK_PADDING * 4;
			}
			if (txtDescription.visible)
			{
				txtDescription.y = currentHeight;
				var targetWidth:Number = Math.min(MAX_WIDTH, txtDescription.textWidth + CommonConstants.SAFE_TEXT_PADDING);
				txtDescription.width = targetWidth;
				txtDescription.height = txtDescription.textHeight + SAFE_TEXTFIELD_OFFSET;
				currentHeight += txtDescription.height + BLOCK_PADDING;
				currentWidth = txtDescription.width;
			}

			if (btnAccept.visible)
			{
				btnAccept.y = currentHeight + GLOSSARY_PADDING + GLOSSARY_HEIGHT / 2;
			}
			if (btnGlossary.visible)
			{
				btnGlossary.y = currentHeight + GLOSSARY_PADDING + GLOSSARY_HEIGHT / 2;
			}
			
			if (btnAccept.visible || btnGlossary.visible)
			{
				currentHeight += (GLOSSARY_HEIGHT + GLOSSARY_PADDING);
			}
			
			currentHeight += BOTTOM_PADDING;
			background.height = currentHeight + BLOCK_PADDING;
			
			// Width
			
			if (_data.isUiTutorial)
			{
				safePadding = 0;
			}
			else
			{
				safePadding = screenRect.width * .05 + BLOCK_PADDING;
			}
			
			if (_data.isUiTutorial)
			{
				currentWidth = Math.max(MIN_WIDTH, currentWidth) + UI_EDGE_PADDING;
				background.width = currentWidth;
			}
			else
			{
				currentWidth = Math.max(MIN_WIDTH, currentWidth) + EDGE_PADDING;
				background.width = currentWidth + GRADIENT_PADDING + safePadding;
			}
			
			mcCorrectFeedback.x = mcErrorFeedback.x = background.x;
			mcCorrectFeedback.y = mcErrorFeedback.y = background.y;
			mcCorrectFeedback.width = mcErrorFeedback.width = background.width;
			mcCorrectFeedback.height = mcErrorFeedback.height = background.height;
			
			var centerPointX:Number = Math.round(currentWidth / 2) + safePadding;
			var centerPointY:Number = Math.round(currentHeight / 2);
			
			txtDescription.x = centerPointX - txtDescription.width / 2;
			topDelemiter.x = centerPointX;
			topDelemiter.y =  txtTitle.y + txtTitle.height + BOTTOM_PADDING;
			txtTitle.x = centerPointX - txtTitle.width / 2;
			
			// controls
			
			if (btnAccept.visible && btnGlossary.visible)
			{
				btnGlossary.x = centerPointX + BUTTONS_PADDING - BUTTONS_OFFSET;
				btnAccept.x = centerPointX - btnAccept.getViewWidth() - BUTTONS_PADDING - BUTTONS_OFFSET;
			}
			else
			{
				btnGlossary.x = centerPointX - btnGlossary.getViewWidth() / 2;
				btnAccept.x = centerPointX - btnAccept.getViewWidth() / 2;
			}
			
			const OFFSET_FOR_WIDE_SCREEN = 0;
			
			if (_data.showAnimation)
			{
				contentMask.y = centerPointY;
				contentMask.width = background.width + OFFSET_FOR_WIDE_SCREEN;
				//contentMask.height = background.height + 200; // ??
				contentMask.height = 1;
				borderLineTop.y = centerPointY - 1;
				borderLineBottom.y = centerPointY + 1;
				
				GTweener.removeTweens(contentMask);
				GTweener.removeTweens(borderLineTop);
				GTweener.removeTweens(borderLineBottom);
				
				const animDuration = .4;
				GTweener.to(contentMask, animDuration, { height : (background.height) }, { ease:Sine.easeInOut, onComplete:handleShown } );
				GTweener.to(borderLineTop, animDuration, { y : 0 }, { ease:Sine.easeInOut } );
				GTweener.to(borderLineBottom, animDuration, { y : background.height - 1 }, { ease:Sine.easeInOut } );
			}
			else
			{
				contentMask.y = centerPointY;
				contentMask.width = background.width + OFFSET_FOR_WIDE_SCREEN;
				contentMask.height = background.height + 200;
				borderLineTop.y = 0;
				borderLineBottom.y = background.height - 1;
			}
			
			dispatchEvent(new Event(Event.RESIZE));
		}

		private const HOLD_CANVAS_OFFSET:Number = 200;
		private function handleShown(tweenInst:GTween):void
		{
			contentMask.height = background.height + HOLD_CANVAS_OFFSET; // hack to show hold animation
		}

		private function cleanup():void
		{
			txtDescription.visible = false;
			btnGlossary.visible = false;
			txtTitle.text = "";
			removeImageLoader();
		}

		private function loadImage(imagePath:String):void
		{
			if (_imageLoader)
			{
				_imageLoader.unload();
				removeChild(_imageLoader);
			}
			_imageLoader = new UILoader();
			_imageLoader.width = background.width;
			_imageLoader.maintainAspectRatio = true;
			_imageLoader.autoSize = false;
			_imageLoader.source = "img://" + imagePath;
			_imageLoader.addEventListener(Event.COMPLETE, handleImageLoaded, false, 0, true);
			_imageLoader.addEventListener(IOErrorEvent.IO_ERROR, handleImageLoadinfFailed, false, 0, true);
			addChild(_imageLoader);
		}

		private function removeImageLoader():void
		{
			if (_imageLoader)
			{
				_imageLoader.removeEventListener(Event.COMPLETE, handleImageLoaded);
				_imageLoader.unload();
				removeChild(_imageLoader);
			}
		}

		private function handleImageLoadinfFailed(event:IOErrorEvent):void
		{
			removeChild(_imageLoader);
			alignContent();
		}

		private function handleImageLoaded(event:Event):void
		{
			alignContent();
		}

		private function handleGlossaryLink():void
		{
			if (_data && visible && parent.visible)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnGotoGlossary' ) );
			}
		}
		
		public function proccedInput(event:InputEvent, useDownEvent:Boolean = false):void
		{
			var details    : InputDetails = event.details;
			var isEnable   : Boolean = _data && _data.enableAcceptButton && visible && parent.visible;
			var isKeyUp    : Boolean = details.value == (useDownEvent ? InputValue.KEY_DOWN : InputValue.KEY_UP);
			var iskeyValid : Boolean = details.code == KeyCode.ESCAPE || details.navEquivalent == NavigationCode.GAMEPAD_A;
			
			if ( isEnable && isKeyUp && iskeyValid )
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseByUser' ) );
			}
		}
	}
}
