package red.game.witcher3.controls
{
	import flash.display.MovieClip;
	/**
	 * Simple class for anchors and other stuff which we needs only in the authortime
	 * @author Yaroslav Getsevich
	 * red.game.witcher3.controls.InvisibleComponent
	 */
	public class InvisibleComponent extends MovieClip
	{
		public function InvisibleComponent()
		{
			visible = mouseChildren = mouseEnabled = false;
		}
	}
}
