package red.game.witcher3.popups.test
{
	import red.core.CorePopup;

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

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;

	public class TestPopup extends CorePopup
	{
		override protected function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
		}

		override protected function get popupName():String
		{
			return "TestPopup";
		}

		public function CloseMenu() : void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnClosePopup' ) );
		}
	}
}
