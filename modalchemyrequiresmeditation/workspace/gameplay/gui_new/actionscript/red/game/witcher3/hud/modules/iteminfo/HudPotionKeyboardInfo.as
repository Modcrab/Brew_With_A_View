package red.game.witcher3.hud.modules.iteminfo 
{
	import scaleform.clik.managers.InputDelegate;
	/**
	 * red.game.witcher3.hud.modules.iteminfo.HudPotionKeyboardInfo
	 * @author Getsevich Yaroslav
	 */
	public class HudPotionKeyboardInfo extends HudItemInfo
	{		
		override public function setItemButtons( btn : int, pcBtn ) : void
		{
			var inputDelegate : InputDelegate;
			var keyName 	  : String;
			
			inputDelegate = InputDelegate.getInstance();
			switch( btn )
			{
				case -10 : // #B double dpad hax
					keyName = "double_dpad_up";
					break;
				case 0 :
					mcButton.visible = false;
					return;
				default :
					keyName = inputDelegate.inputToNav( "key", btn );
			}
			
			mcButton.visible = showButtonHint;
			mcButton.clickable = false;
			mcButton.setDataFromStage(keyName, pcBtn);
			mcButton.validateNow();
			
			if (!mcIconLoader.source)
			{
				mcButton.visible = false;
			}
			else
			{
				mcButton.visible = showButtonHint;
			}
		}
		
		override public function set IconName(value:String):void 
		{
			super.IconName = value;
			
			mcButton.visible = mcIconLoader.source && showButtonHint;
		}
		
	}

}
