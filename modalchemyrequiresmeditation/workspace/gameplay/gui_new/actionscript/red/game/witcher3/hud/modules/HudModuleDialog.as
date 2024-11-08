package red.game.witcher3.hud.modules
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import red.core.CoreHudModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.hud.modules.dialog.OptionContainer;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.gfx.MouseEventEx;

	import scaleform.clik.core.UIComponent;
	import flash.text.TextField;
	import flash.display.MovieClip;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.events.ButtonEvent;
	import flash.events.MouseEvent;

	import red.game.witcher3.utils.motion.TweenEx;
	import fl.transitions.easing.Strong;

	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.hud.modules.dialog.Option;
	import red.game.witcher3.hud.modules.dialog.SkipIndicator;
	import scaleform.clik.controls.StatusIndicator;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	import  scaleform.clik.managers.FocusHandler;

	import red.core.CoreMenu;

	import scaleform.gfx.Extensions;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;

	public class HudModuleDialog extends HudModuleBase
	{
		public var mcSkipIndicator:SkipIndicator;

		public var tfSubtitles:TextField;
		public var tfPreviousSubtitles:TextField;
		public var mcSubtitlesContainer:MovieClip;

		public var mcOptionContainer:OptionContainer;

		public var mcDialogueBar:StatusIndicator;
		public var mcAngerBar:StatusIndicator;
		private var _fadeTimer:Timer;
		
		public var canBeSkipped:Boolean = true;

		private var _skipButtonShown : Boolean;
		private var _focusHandler : FocusHandler;

	//{region Private constants
	// ------------------------------------------------
		public function HudModuleDialog()
		{
			super();
			_fadeTimer = new Timer( 3300 );
			_fadeTimer.addEventListener( TimerEvent.TIMER, OnFadeTimer, false, 0, true );
		}

		override public function get moduleName():String
		{
			return "DialogModule";
		}
		
		override public function ShowElementFromState( bShow : Boolean, bImmediately : Boolean = false ):void
		{			
			super.ShowElementFromState(bShow, bImmediately);
			
			if (_shown)
			{
				_inputMgr.addInputBlocker(false, "HUD_DIALOG");
			}
			else
			{
				_inputMgr.removeInputBlocker("HUD_DIALOG");
			}
		}
		
		protected override function configUI():void
		{
			super.configUI();

			FocusHandler.init(stage, this);
			_focusHandler = FocusHandler.getInstance();

			tabEnabled = tabChildren = false;
			mouseEnabled = false;
			visible = false;
			alpha = 0;

			mcOptionContainer.visible = false;
			mcOptionContainer.alpha = 1;

			tfSubtitles = mcSubtitlesContainer.tfSubtitles;
			tfPreviousSubtitles = mcSubtitlesContainer.tfPreviousSubtitles;
			
			tfSubtitles.autoSize = TextFieldAutoSize.CENTER;
			tfSubtitles.multiline = true;
			tfSubtitles.wordWrap = true;
			tfPreviousSubtitles.autoSize = TextFieldAutoSize.CENTER;
			tfPreviousSubtitles.multiline = true;
			tfPreviousSubtitles.wordWrap = true;

			tfSubtitles.text = "";
			tfPreviousSubtitles.text = "";
			mcDialogueBar["tfBarLabel"].htmlText = "[[panel_hud_dialogue_bar_label_timeleft]]";
			mcAngerBar["tfBarLabel"].htmlText = "[[panel_hud_dialogue_bar_label_anger]]";
			mcAngerBar.visible = false;
			mcDialogueBar.visible = false;
			
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			
			registerDataBinding( 'hud.dialog.choices', onChoicesSet );
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
			
			stage.addEventListener(MouseEvent.CLICK, handleStageClick, false, 0, true);
			
			_inputHandlers.push(mcOptionContainer);
			
			mcSkipIndicator.setupData();
			updateSlipPosition();
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, updateSlipPosition, false, 0, true);
		}
		
		private function updateSlipPosition(event:Event = null):void
		{
			mcSkipIndicator.x =  Math.round((1920 - mcSkipIndicator.btnSkip.getViewWidth()) / 2);
		}
		
		public function setAlternativeDialogOptionView(value:Boolean):void
		{
			Option.ALTERNATIVE_ARROW_SKIN = value;
		}
		
		public function setCanBeSkipped(value:Boolean):void
		{
			canBeSkipped = value;
			
			if (value == false && mcSkipIndicator.alpha > 0.1)
			{
				SkipConfirmHide();
			}
		}

		public function SentenceSet(htmlText:String ):void
		{
			tfSubtitles.htmlText = htmlText; //#B cont
			mcOptionContainer.DataReset();
			alignControls();
		}

		public function SentenceHide():void
		{
			tfSubtitles.htmlText = "";
			alignControls();
		}

		public function PreviousSentenceSet(htmlText:String ):void
		{
			tfPreviousSubtitles.htmlText = htmlText; //#B cont
			alignControls();
		}

		public function PreviousSentenceHide():void
		{
			tfPreviousSubtitles.htmlText = ""; //#B cont
			alignControls();
		}

		private function onChoicesSet( gameData:Object, index:int ):void
		{
			var dataArray:Array = gameData as Array;

			if ( index > 0 )
			{
			}
			else if (dataArray)
			{
				ChoicesSet( dataArray );
				_focusHandler.setFocus(this, 0);
			}
		}

		public function ChoicesSet( choices:Array ):void
		{
			if ( choices.length > 0 )
			{
				mcOptionContainer.alpha = 1;
				mcOptionContainer.visible = true;
			}
			else
			{
				mcOptionContainer.alpha = 0;
				mcOptionContainer.visible = false;
			}
			mcOptionContainer.ChoicesSet( choices );
			SkipConfirmHide();
		}

		public function ChoiceSelectionSet( index:int ):void
		{
			mcOptionContainer.ChoiceSelectionSet(index);
		}

		public function ChoiceTimeoutSet( timeout: Number ):void
		{
			mcDialogueBar.value = timeout;
			mcDialogueBar.visible = true;
		}

		public function ChoiceTimeoutHide():void
		{
			mcDialogueBar.visible = false;
		}
		
		public function SkipConfirmShow():void
		{
			if (canBeSkipped)
			{
				_skipButtonShown = true;
				_fadeTimer.stop();
				effectFade( mcSkipIndicator, 1, 300 );
				_fadeTimer.reset();
				_fadeTimer.start();
			}
		}

		public function SkipConfirmHide():void
		{
			_skipButtonShown = false;
			_fadeTimer.stop();
			effectFade( mcSkipIndicator, 0, 300 );
		}

		override public function handleInput( event:InputEvent ) : void
		{
			if( event.handled || alpha == 0 )
			{
				return;
			}

			var details:InputDetails = event.details;
			var sendValue : int = 0;
			_focusHandler.setFocus(this, 0);
			for each ( var handler:UIComponent in _inputHandlers )
			{
				if ( event.handled )
				{
					event.stopImmediatePropagation();
					return;
				}
				handler.handleInput( event );
			}

			if ( event.handled )
			{
				event.stopImmediatePropagation();
				return;
			}

			if ( details.value == InputValue.KEY_DOWN && canBeSkipped )
			{
				switch( details.code )
				{
					case KeyCode.SPACE:
					//case KeyCode.ESCAPE:
					case KeyCode.PAD_X_SQUARE:
						if ( mcSkipIndicator.alpha > 0.1 )
						{
							event.handled = true;
							SkipConfirmHide();
							sendValue = 1;
							dispatchEvent( new GameEvent( GameEvent.CALL, 'OnDialogSkipped', [sendValue] ) );
							break;
						}
						
					default:
///////////////////////////////////////////
//
//
//
						if ( (details.code < KeyCode.F1 || details.code > KeyCode.F24) && details.code != KeyCode.PRINTSCREEN && mcOptionContainer.GetOptionsListLength() == 0 )
//
//
//
///////////////////////////////////////////
						{
							SkipConfirmShow();
						}
						break;
				}
			}
		}
		
		private function handleStageClick(event:MouseEvent):void
		{
			trace("GFX handleStageClick ", canBeSkipped, mcSkipIndicator.alpha);
			
			var eventEx:MouseEventEx = event as MouseEventEx;
			if (eventEx && eventEx.buttonIdx == MouseEventEx.RIGHT_BUTTON)
			{
				if (!canBeSkipped)
				{
					return;
				}
				
				if ( mcSkipIndicator.alpha > 0.1 )
				{
					SkipConfirmHide();
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnDialogSkipped', [1] ) );
				}
				else
/////////////////////////////////////////////////////////////////////////////////////////
//
//
//
				if ( mcOptionContainer.GetOptionsListLength() == 0 )
//
//
//
/////////////////////////////////////////////////////////////////////////////////////////
				{
					SkipConfirmShow();
				}
			}
		}

		override public function set focused(value:Number):void
		{
			super.focused = value;
			_focusHandler.setFocus(this, 0);
/////////////////////////////////////////////////////////
//
//
//
			mcOptionContainer.focused = 1;
//
//
//
/////////////////////////////////////////////////////////
		}

		public function setBarValue( _Percentage : Number ):void
		{
			mcAngerBar.value = _Percentage;
			if ( _Percentage == 0 )
			{
				mcAngerBar.visible = false;
			}
			else
			{
				mcAngerBar.visible = true;
			}
		}

		override public function SetScaleFromWS( scale : Number ) : void
		{
		}

		override protected function effectFade( target:Object , value : Number, time : int = FADE_DURATION ):void
		{
			var tweenEx : TweenEx;
			pauseTweenOn(target);
			desiredAlpha = value;
			tweenEx = TweenEx.to( time, target, { alpha:value }, { paused:false, ease:Strong.easeOut, onComplete:handleTweenComplete } );
			targetTweens.push(tweenEx);
		}

		override protected function SetScaleAnimation( target:Object , value : Number, time : int = FADE_DURATION ):void
		{
			var tweenEx : TweenEx;
			pauseTweenOn(target);
			desiredScale = value;
			tweenEx = TweenEx.to( time, target, { scaleX:value, scaleY:value }, {  paused:false, ease:Strong.easeOut, onComplete:handleTweenComplete  } );
			targetTweens.push(tweenEx);
		}
		
		private static const BLOCK_PADDING:Number = 44;
		private static const SKIP_HEIGHT:Number = 45;
		private function alignControls():void
		{
			//var safeRect:Rectangle = CommonUtils.getScreenRect();
			var safePadding:Number = 1080 * .95;
			
			tfPreviousSubtitles.height = tfPreviousSubtitles.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			tfSubtitles.height = tfSubtitles.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			
			if (mcSkipIndicator.visible)
			{
				mcSkipIndicator.y = safePadding - BLOCK_PADDING;
				mcSubtitlesContainer.y = mcSkipIndicator.y - SKIP_HEIGHT - BLOCK_PADDING;
			}
			else
			{
				mcSubtitlesContainer.y = safePadding - SKIP_HEIGHT - BLOCK_PADDING;
			}
		}

		private function OnFadeTimer( event:TimerEvent ):void
		{
			SkipConfirmHide();
		}
	}
}
