package red.game.witcher3.hud.modules.wolfHead
{
	import flash.display.MovieClip;
	import flash.events.Event;

	public class WolfMedallion extends MovieClip
	{
		//>------------------------------------------------------------------------------------------------------------------
		// Variable
		//-------------------------------------------------------------------------------------------------------------------
		public var mcWolfGlow : MovieClip

		private var m_shouldStop:Boolean

		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function WolfMedallion()
		{
			mcWolfGlow.gotoAndStop(1);
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function StartGlow()
		{
			mcWolfGlow.gotoAndPlay("play");
			m_shouldStop = false;
			addEventListener( Event.ENTER_FRAME, Update );
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function StopGlow()
		{
			m_shouldStop = true;
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function Update( e:Event )
		{
			if ( m_shouldStop && mcWolfGlow.currentFrame == 1)
			{
				mcWolfGlow.gotoAndStop(1);
				removeEventListener( Event.ENTER_FRAME, Update );
			}
		}

		public function SetMedalionGraphic( value : String )
		{
			gotoAndStop(value);
			mcWolfGlow = getChildByName("mcWolfGlow") as MovieClip;
			mcWolfGlow.gotoAndStop(1);
		}
	}

}