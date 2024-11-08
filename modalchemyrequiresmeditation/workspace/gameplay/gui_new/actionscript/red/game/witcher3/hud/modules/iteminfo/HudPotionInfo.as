package red.game.witcher3.hud.modules.iteminfo 
{
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTweener;
	import red.game.witcher3.controls.W3UILoader;
	import scaleform.clik.managers.InputDelegate;
	
	/**
	 * red.game.witcher3.hud.modules.iteminfo.HudPotionInfo
	 * @author Getsevich Yaroslav
	 */
	public class HudPotionInfo extends HudItemInfo
	{
		public var mcAlterIconLoader:W3UILoader;
		
		protected var _alterIconPath:String = "";
		public function get alterIconPath():String { return _alterIconPath }
		public function set alterIconPath(value:String ):void
		{
			_alterIconPath = value;
			updateAlterIcon();
		}
		
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
		}
		
		public function animateSwitching():void
		{
			if (mcAlterIconLoader && mcIconLoader && mcAlterIconLoader.source && mcIconLoader.source)
			{
				const alterScale:Number = 1.2;
				const alterAlpha:Number = .6;
				const alterX:Number = 38;
				const alterY:Number = 46;
				
				const defaultScale:Number = 1.78;
				const defaultAlpha:Number = 1;
				const defaultX:Number = 70;
				const defaultY:Number = 38;
				
				GTweener.removeTweens(mcAlterIconLoader);
				GTweener.removeTweens(mcIconLoader);
				
				mcAlterIconLoader.x = defaultX;
				mcAlterIconLoader.y = defaultY;
				mcAlterIconLoader.alpha = defaultAlpha;
				//mcAlterIconLoader.scaleX = mcAlterIconLoader.scaleY = defaultScale;
				
				mcIconLoader.x = alterX;
				mcIconLoader.y = alterY;
				mcIconLoader.alpha = alterAlpha;
				
				GTweener.to(mcAlterIconLoader, .25, { x:alterX, y:alterY, alpha:alterAlpha/*, scaleX:alterScale, scaleY:alterScale*/ }, { ease:Sine.easeIn } );
				GTweener.to(mcIconLoader, .25, { x:defaultX, y:defaultY, alpha:defaultAlpha/*, scaleX:defaultScale, scaleY:defaultScale*/ }, { ease:Sine.easeIn } );
			}
		}
		
		protected function updateAlterIcon():void
		{
			if (mcAlterIconLoader)
			{
				if (_alterIconPath)
				{
					mcAlterIconLoader.visible = true;
					mcAlterIconLoader.source = "img://" + _alterIconPath;
				}
				else
				{
					mcAlterIconLoader.unload();
					mcAlterIconLoader.source = "";
					mcAlterIconLoader.visible = false;
				}
			}
		}
		
	}

}
