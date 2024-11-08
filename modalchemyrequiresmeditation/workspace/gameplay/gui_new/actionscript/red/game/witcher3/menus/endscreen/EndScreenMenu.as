package red.game.witcher3.menus.endscreen
{
	import scaleform.clik.events.InputEvent;
	import red.game.witcher3.menus.startscreen.StartScreenMenu;

	public class EndScreenMenu extends StartScreenMenu
	{

		public function EndScreenMenu()
		{
			super();
		}

		override protected function get menuName():String
		{
			return "EndScreenMenu";
		}

		protected override function configUI():void
		{
			super.configUI();
		}

		override public function handleInput( event:InputEvent ):void
		{
		}
	}
}
