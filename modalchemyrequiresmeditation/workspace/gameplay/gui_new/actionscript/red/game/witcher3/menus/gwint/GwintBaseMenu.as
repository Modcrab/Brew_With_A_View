package red.game.witcher3.menus.gwint
{
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	
	/**
	 * ...
	 * @author Jason Slama sept 2014
	 */
	public class GwintBaseMenu extends CoreMenu
	{
		public var _cardManager:CardManager;
		
		override protected function configUI():void
		{
			super.configUI();
			_restrictDirectClosing = false;
			
			_cardManager = CardManager.getInstance();
			
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "gwint.card.templates", [onGetCardTemplates]));
		}
		
		protected function onGetCardTemplates( gameData:Object, index:int ):void
		{
			_cardManager.onGetCardTemplates(gameData, index);
		}
	}
	
}