package red.game.witcher3.menus.meditation_menu
{
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.menus.meditation.MeditationClockMenu;
	import red.game.witcher3.menus.meditation_menu.MeditationClock;
	/**
	 * JUST STUB
	 * @author Getsevich Yaroslav
	 */
	public class MenuMeditationClock extends CoreMenu
	{
		public var meditationClock : MeditationClock;

		override protected function get menuName():String { return "MeditationClockMenu" }
		override protected function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
		}

		public function SetBlockMeditation( value : Boolean )
		{
			meditationClock.SetBlockMeditation( value );
		}
	}
}