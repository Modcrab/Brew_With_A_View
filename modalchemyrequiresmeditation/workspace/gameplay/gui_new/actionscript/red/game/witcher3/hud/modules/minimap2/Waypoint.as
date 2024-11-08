/***********************************************************************
/** Used for minimap
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/***********************************************************************/

package red.game.witcher3.hud.modules.minimap2
{
	import flash.display.MovieClip;
	import flash.geom.Vector3D;
	import flash.geom.Point;
	import red.game.witcher3.hud.modules.HudModuleMinimap2;
	import 	flash.geom.	ColorTransform;
	import red.game.witcher3.menus.overlay.BookPopup;

	public class Waypoint
	{		
		public var pinClip		: MovieClip;
		
		private var isVisible : Boolean = false;

		public function ForceShow( bShow : Boolean )
		{
			pinClip.visible = bShow;
			isVisible = bShow;
		}
		
		public function Show( bShow : Boolean )
		{
			if ( isVisible != bShow )
			{
				pinClip.visible = bShow;
				isVisible = bShow;
			}
		}

		public function SetScale( sc : Number )
		{
			if ( pinClip.mcWaypoint )
			{
				pinClip.mcWaypoint.scaleX = sc;
				pinClip.mcWaypoint.scaleY = sc;
			}
		}

		public function SetPosition( px : Number, py : Number )
		{
			pinClip.x = px;
			pinClip.y = py;
		}
	}
}
