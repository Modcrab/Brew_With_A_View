package red.game.witcher3.menus.overlay
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import red.core.CoreComponent;

	/**
	 * Full screen tutorial hint; used in popup_tutorial.fla
	 * @author Getsevich Yaroslav
	 */
	public class TutorialOverlay extends UIComponent
	{
		protected static const OVER_ANIM_OFFSET_X:Number = -50;
		protected static const OVER_ANIM_DURATION:Number = 0.5;
		
		protected static const BLOCK_PADDING:Number = 10;
		protected static const EDGE_PADDING:Number = 10;
		protected static const BUTTONS_TOP_PADDING:Number = 50;
		protected static const BUTTONS_PADDING:Number = 10;
		protected static const GRADIENT_PADDING:Number = 130;
		
		public var txtTitle:TextField;
		public var txtDescription:TextField;
		public var btnAccept:InputFeedbackButton;
		public var btnGlossary:InputFeedbackButton;
		public var topDelemiter:Sprite;
		public var mcBackground:Sprite;
		
		protected var _data:Object;
		protected var _imageLoader:UILoader;
		
		protected var _container:Sprite;

		public function TutorialOverlay()
		{
			_container = new Sprite();
			addChild(_container);
			_container.addChild(txtTitle);
			_container.addChild(topDelemiter);
			_container.addChild(txtDescription);
			_container.addChild(btnAccept);
			_container.addChild(btnGlossary);
			
			btnAccept.label = "[[panel_continue]]";
			btnAccept.clickable = false;
			btnAccept.setDataFromStage(NavigationCode.GAMEPAD_A, KeyCode.SPACE);			
			
			btnGlossary.label = "[[panel_title_glossary]]";
			btnGlossary.clickable = false;
			btnGlossary.setDataFromStage(NavigationCode.GAMEPAD_BACK, -1, -1, 1000);			
			cleanup();
		}

		public function get data():Object { return _data }
		public function set data(value:Object):void
		{
			var buttonsWidth:Number;
			
			cleanup();
			_data = value;			
			
			// buttons visibility
			
			if (_data.enableGlossaryLink)
			{
				btnGlossary.visible = true;
				btnGlossary.holdCallback = handleGlossaryLink;
			}
			else
			{
				btnGlossary.visible = false;
				btnGlossary.holdCallback = null;
			}
			if (btnAccept.visible && btnGlossary.visible)
			{
				buttonsWidth = btnAccept.getViewWidth() + btnGlossary.getViewWidth() + BUTTONS_PADDING;				
			}
			else
			{
				buttonsWidth = btnGlossary.getViewWidth();
			}
			
			// content 
			
			var safeRect:Rectangle = CommonUtils.getScreenRect();
			var safePadding:Number = safeRect.width * .05;
			
			var messageCenter:Number = Math.max(txtDescription.width / 2, buttonsWidth / 2);
			var centralLine:Number = safePadding + EDGE_PADDING + messageCenter;
			var backgroundWidth:Number = centralLine + messageCenter + GRADIENT_PADDING;
			
			mcBackground.width = backgroundWidth;
			
			txtTitle.htmlText = CommonUtils.toUpperCaseSafe(_data.messageTitle);
			txtTitle.width = txtTitle.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			
			txtDescription.htmlText =  CommonUtils.fixFontStyleTags(_data.messageText);
			txtDescription.height = txtDescription.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			
			topDelemiter.x = centralLine;
			txtTitle.x = centralLine - txtTitle.textWidth / 2;
			
			var format:TextFormat = new TextFormat();
			if ( CoreComponent.isArabicAligmentMode )
			{
				txtDescription.htmlText = "<p align=\"right\">" + _data.messageText + "</p>";
				txtDescription.x = centralLine - txtDescription.textWidth / 2 - (txtDescription.width - txtDescription.textWidth);
				
				format.font = "$NormalFont";
			}
			else
			{
				txtDescription.x = centralLine - txtDescription.textWidth / 2;
				
				format.font = "$BoldFont";
			}
			
			txtTitle.setTextFormat(format);
			
			// image
			if (_data.imagePath)
			{
				// #Y not sure that we need it, disabled for now
				// loadImage(_data.imagePath);
			}
			
			// buttons alignment
			
			btnAccept.y =  btnGlossary.y = (txtDescription.y + txtDescription.height + BUTTONS_TOP_PADDING);
			if (btnGlossary.visible)
			{
				btnAccept.x = centralLine - buttonsWidth / 2;
				btnGlossary.x = btnAccept.x + btnAccept.getViewWidth() + BUTTONS_PADDING;
			}
			else
			{
				btnAccept.x = centralLine - btnAccept.getViewWidth() / 2;
			}
			
			// container
			_container.y = safeRect.y + (safeRect.height - _container.height) / 2
		}

		private function cleanup():void
		{
			txtTitle.htmlText = "";
			txtDescription.htmlText = "";
			btnGlossary.visible = false;
			if (_imageLoader)
			{
				_imageLoader.unload();
				removeChild(_imageLoader);
			}
		}

		private function loadImage(imagePath:String):void
		{
			if (_imageLoader)
			{
				_imageLoader.unload();
				removeChild(_imageLoader);
			}
			_imageLoader = new UILoader();
			_imageLoader.maintainAspectRatio = true;
			_imageLoader.autoSize = true;
			_imageLoader.source = "img://" + imagePath;
			_imageLoader.x = txtDescription.x;
			_imageLoader.y = txtDescription.y + txtDescription.height
			addChild(_imageLoader);
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
			var isEnable   : Boolean = _data && visible && parent.visible;
			var isKeyUp    : Boolean = details.value == (useDownEvent ? InputValue.KEY_DOWN : InputValue.KEY_UP);
			var isKeyValid : Boolean = details.navEquivalent == NavigationCode.GAMEPAD_A || details.navEquivalent == NavigationCode.GAMEPAD_B;
			
			if (isEnable && isKeyUp && isKeyValid)
			{
				var animProps:Object = { ease:Exponential.easeOut, onComplete:handleOverlayHidden } ;
				var animValues:Object = { x: OVER_ANIM_OFFSET_X, alpha: 0 };
				GTweener.removeTweens(this);
				GTweener.to(this, OVER_ANIM_DURATION, animValues, animProps);
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnStartHiding' ) );
			}
		}
		
		protected function handleOverlayHidden(tweenInst:GTween):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnHideTimer' ) );
		}
		
	}
}
