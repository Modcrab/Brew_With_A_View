/***********************************************************************
/** PANEL glossary main class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/
package red.game.witcher3.menus.glossary
{
	import flash.display.MovieClip;
	import red.core.events.GameEvent;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ListEvent;

	import red.core.CoreMenu;
	import scaleform.gfx.Extensions;

	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;

	//import red.game.witcher3.managers.PanelModuleManager;
	import red.game.witcher3.menus.common.TextAreaModule;

	import red.game.witcher3.menus.common.ItemDataStub;

	import flash.display.Sprite;
	import flash.external.ExternalInterface;

	import red.game.witcher3.menus.common.ListModuleBase;
	//import red.game.witcher3.menus.common.W3VideoObject;

	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import red.game.witcher3.utils.motion.TweenEx;
	import fl.transitions.easing.Strong;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.managers.InputFeedbackManager;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;

	public class GlossaryStorybookMenu extends CoreMenu
	{
		/********************************************************************************************************************
				ART CLIPS
		/ ******************************************************************************************************************/
		//public var mcPanelModuleManager : PanelModuleManager;

		public var 		mcMainListModule					: ListModuleBase;
		//public var 		mcStoryBookVideo					: W3VideoObject;
		//public var 		mcGlossarySubModule					: GlossaryTextureSubListModule;
		public var 		mcTextAreaModule					: TextAreaModule;

		public var btnSkip:InputFeedbackButton;
		public var mcSkipIndicator:MovieClip;
		private var _fadeTimer:Timer;
		private var _skipButtonShown : Boolean;
		protected var targetTweens:Vector.<TweenEx> = new Vector.<TweenEx>();
		protected static const FADE_DURATION : Number = 1000;

		/********************************************************************************************************************
				INTERNAL PROPERTIES
		/ ******************************************************************************************************************/

		public function GlossaryStorybookMenu()
		{
			super();
			mcMainListModule.menuName = menuName;
			mcMainListModule.itemInputFeedbackLabel = "panel_button_common_play";
			mcTextAreaModule.dataBindingKey = "glossary.description";
		}

		override protected function get menuName():String
		{
			return "GlossaryStorybookMenu";
		}

		override protected function configUI():void
		{
			super.configUI();
			//trace("DROPDOWN QuestJournalMenu# configUI start");

			_fadeTimer = new Timer( 3300 );
			_fadeTimer.addEventListener( TimerEvent.TIMER, OnFadeTimer, false, 0, true );
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			stage.invalidate();
			validateNow();

			focused = 1;

			btnSkip = mcSkipIndicator.btnSkip;

			btnSkip.clickable = false;
			btnSkip.label = "[[panel_button_dialogue_skip]]";
			mcSkipIndicator.alpha = 0;
			btnSkip.setDataFromStage(NavigationCode.GAMEPAD_X, KeyCode.ESCAPE);
			btnSkip.validateNow();
		}

		override public function ShowSecondaryModules( value : Boolean )
		{
			super.ShowSecondaryModules( value );
			mcTextAreaModule.visible = value;
			mcTextAreaModule.enabled = value;
		}

		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled )
			{
				return;
			}

			var details:InputDetails = event.details;
            var keyUp:Boolean = (details.value == InputValue.KEY_UP);

			if ( mcMainListModule.GetMovieIsPlaying() )
			{
				if (!event.handled && keyUp)
				{
					switch(details.navEquivalent)
					{
						case NavigationCode.GAMEPAD_B :
						case NavigationCode.GAMEPAD_X :
							if ( mcSkipIndicator.alpha > 0.1 )
							{
								SkipConfirmHide();
								closeMenu();
								return;
							}
							break;
					}
					SkipConfirmShow();
				}

				if (keyUp && !event.handled )
				{
					switch(details.code)
					{
						case KeyCode.SPACE :
						case KeyCode.ESCAPE :
							if ( mcSkipIndicator.alpha > 0.1 )
							{
								SkipConfirmHide();
								closeMenu();
								return;
							}
							break;
					}
					SkipConfirmShow();
				}
			}
			else
			{
				for each ( var handler:UIComponent in actualModules )
				{
					if ( event.handled )
					{
						event.stopImmediatePropagation();
						return;
					}
					handler.handleInput( event );
				}
			}
		}

		public function setTitle( value : String ) : void
		{
			if (mcTextAreaModule)
			{
				mcTextAreaModule.SetTitle(value);
			}
		}

		public function setText( value : String  ) : void
		{
			if (mcTextAreaModule)
			{
				mcTextAreaModule.SetText(value);
			}
		}

		public function showModules( value : Boolean  ) : void
		{
			var l_alpha : Number = 0;
			if ( value )
			{
				l_alpha = 1;
				visible = true;
				y = 0;
				alpha = 1;
				mcMainListModule.SetMovieIsPlaying( false );
				SkipConfirmHide();
			}
			if (mcTextAreaModule)
			{
				mcTextAreaModule.alpha = l_alpha + 0.001;
			}
			if (mcMainListModule)
			{
				mcMainListModule.alpha = l_alpha;
			}
		}

		public function SkipConfirmShow():void
		{
			_skipButtonShown = true;
			_fadeTimer.stop();
			effectFade( mcSkipIndicator, 1, 300 );
			_fadeTimer.reset();
			_fadeTimer.start();
		}

		public function SkipConfirmHide():void
		{
			_skipButtonShown = false;
			_fadeTimer.stop();
			effectFade( mcSkipIndicator, 0, 300 );
		}

		private function OnFadeTimer( event:TimerEvent ):void
		{
			SkipConfirmHide();
		}

		protected function effectFade( target:Object , value : Number, time : int = FADE_DURATION ):void
		{
			var tweenEx : TweenEx;
			pauseTweenOn(target);
			tweenEx = TweenEx.to( time, target, { alpha:value }, { paused:false, ease:Strong.easeOut, onComplete:handleTweenComplete } );
			targetTweens.push(tweenEx);
		}

		protected function handleTweenComplete( tween : TweenEx ) : void
		{
			pauseTweenOn(tween.target);
		}

		protected function pauseTweenOn( target : Object )
		{
			for (var i : int = targetTweens.length -1; i > -1 ; i-- )
			{
				if ( target == targetTweens[i].target )
				{
					targetTweens[i].paused = true;
					targetTweens.splice(i, 1);
				}
			}
		}

		/********************************************************************************************************************
			UPDATES
		/ ******************************************************************************************************************/
		protected function Update() : void
		{

		}
	}
}
