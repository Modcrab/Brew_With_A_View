package red.game.witcher3.menus.poster
{
	import red.core.CoreMenu;
	import red.game.witcher3.managers.InputFeedbackManager;

	import red.core.events.GameEvent;
	import flash.events.MouseEvent;
	import scaleform.gfx.MouseEventEx;

	import flash.text.TextField;

	import flash.display.MovieClip;
	import scaleform.clik.core.UIComponent;

	import scaleform.gfx.Extensions;
	import red.core.constants.KeyCode;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
	import scaleform.clik.constants.NavigationCode;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.core.CoreComponent;
	import red.game.witcher3.constants.CommonConstants;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;

	public class PosterMenu extends CoreMenu
	{
		public var tfSubtitles : TextField;
		public var tfSubtitlesHack : TextField;
		public var fontSize : int;
		
		public function PosterMenu()
		{
			_disableShowAnimation = true;
			super();
			_enableInputValidation = true;
		}

		override protected function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			
			InputFeedbackManager.useOverlayPopup = true;
			InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_B, KeyCode.ESCAPE, "[[panel_button_common_exit]]");
		}

		override protected function get menuName():String
		{
			return "PosterMenu";
		}

		public function CloseMenu() : void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseMenu' ) );
		}

		public function SetFontScale( fontScale : int )
		{
			fontSize = fontScale;
		}

		public function SetDescription( htmlText : String, alignLeft : Boolean )
		{
			var fontOpenTag : String;
			var fontCloseTag : String;

            fontOpenTag = "<font size = \"" + ( 27 + fontSize) + "\" >";
			fontCloseTag = "</font>";
			if ( alignLeft )
			{
				if ( CoreComponent.isArabicAligmentMode )
				{
					tfSubtitles.htmlText = "<p align=\"right\">" + fontOpenTag + htmlText + fontCloseTag + "</p>";
				}
				else
				{
					tfSubtitles.htmlText = "<p align=\"left\">" + fontOpenTag + htmlText + fontCloseTag + "</p>";
				}
			}
			else
			{
				tfSubtitles.htmlText = fontOpenTag + htmlText + fontCloseTag;
			}
			if ( tfSubtitles.textHeight + tfSubtitles.y > 1025 )
			{
				tfSubtitles.y = 1025 - tfSubtitles.textHeight;
			}
			else
			{
				tfSubtitles.y  = 758;
			}
		}
		
		private static const BLOCK_PADDING:Number = 160;
		public function SetSubtitlesHack( speakerNameDisplayText : String, dialogLineDisplayHtmlText : String )
		{
			// to prevent any unforseen consequences, do not allow to show subtitles if there's a description
			if ( tfSubtitles.htmlText && tfSubtitles.htmlText.length > 0 )
			{
				return;
			}
			
			////////////
			//
			// taken from HudModuleSubtitles::addSubtitle, if you change something here make sure to change also out there
			//
			tfSubtitlesHack.htmlText =  "<b><font color='#FFFFFF'>" + speakerNameDisplayText + "</font>" + dialogLineDisplayHtmlText;
			tfSubtitlesHack.height = tfSubtitlesHack.textHeight + CommonConstants.SAFE_TEXT_PADDING+12;
			
			var safePadding:Number = 1080 * .95;
			tfSubtitlesHack.y = safePadding - tfSubtitlesHack.height - BLOCK_PADDING;			
			//
			////////////
		}
		
		override protected function hideAnimation():void
		{
			closeMenu();
		}
	}
}
