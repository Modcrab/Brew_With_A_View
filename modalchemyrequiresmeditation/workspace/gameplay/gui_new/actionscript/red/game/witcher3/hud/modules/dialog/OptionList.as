package red.game.witcher3.hud.modules.dialog 
{
	import red.game.witcher3.controls.W3ScrollingList;
	import scaleform.clik.controls.ScrollingList;
	import red.game.witcher3.managers.InputManager;
	
	public class OptionList extends W3ScrollingList 
	{
		override public function trySelectingIndex( index : int )
		{
			if ( !InputManager.getInstance().isGamepad() )
			{
				selectedIndex = index;
			}
		}


	}

}