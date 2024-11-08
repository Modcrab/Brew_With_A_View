package red.game.witcher3.menus.journal
{
	import flash.events.Event;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.controls.W3DropDownList;
	import red.game.witcher3.controls.W3DropdownMenuListItem;
	
	/**
	 * red.game.witcher3.menus.journal.QuestDropDownList
	 * @author Getsevich Yaroslav
	 */
	public class QuestDropDownList extends W3DropDownList
	{
		// #Y Hack *autoselect tracked quest*;
		override public function SetInitialSelection()
		{
			var i : int;
			var j : int;
			var foundInitialSelection : Boolean;
			var tempRenderer : W3DropdownMenuListItem;
			var tempBaseRenderer : BaseListItem;

			foundInitialSelection = false;
			for ( i = 0; i < dataProvider.length; i++ )
			{
				tempRenderer = getRendererAt(i) as W3DropdownMenuListItem;
				if ( tempRenderer )
				{
					if( tempRenderer.HasInitialSelection() && !foundInitialSelection )
					{
						tempRenderer.open(false);
						selectedIndex = i;
						foundInitialSelection = true;
						tempRenderer.SelectSubListItem(0);
					}
					else if( tempRenderer.IsOpenedByDefault() )
					{
						tempRenderer.open(false);
					}
				}
			}
		}
		
	}

}
