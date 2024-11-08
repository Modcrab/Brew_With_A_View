/***********************************************************************
/** Loading Screen - Fast Travel
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.loading
{
	import red.core.overlay.LoadingScreen;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Quadratic;

	public class LoadingMenu extends LoadingScreen
	{
		private static const SLIDE_ANIM_TIME				: Number = 30;

		public function LoadingMenu()
		{
			super();
		}

		override protected function registerLoadingScreen(): void
		{
			super.registerLoadingScreen();
			
			if ( mcImage )
			{
				onStartRightTween();
			}
		}
		
		protected function onStartRightTween(e:GTween = null):void
		{
			GTweener.removeTweens(mcImage);
			mcImage.x = -740;
			GTweener.to(mcImage, SLIDE_ANIM_TIME, { x:-320 },  { ease: Quadratic.easeInOut, onComplete:onStartLeftTween } );
		}
		
		private function onStartLeftTween(e:GTween):void
		{
			GTweener.removeTweens(mcImage);
			mcImage.x = -320;
			GTweener.to(mcImage, SLIDE_ANIM_TIME, { x:-740 },  { ease: Quadratic.easeInOut, onComplete:onStartRightTween  } );
		}
	}
}
