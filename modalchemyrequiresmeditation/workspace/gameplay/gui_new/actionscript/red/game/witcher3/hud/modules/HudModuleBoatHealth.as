package red.game.witcher3.hud.modules
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import red.game.witcher3.hud.modules.HudModuleBase;
	import scaleform.clik.controls.StatusIndicator;
	
	public class HudModuleBoatHealth extends HudModuleBase 
	{
		public var mcBoat			:		MovieClip;
		
		public function HudModuleBoatHealth() 
		{			
			super();
		}

		override public function get moduleName():String
		{
			return "BoatHealthModule";
		}

		override protected function configUI():void
		{			
			super.configUI();
	
			alpha = 0;
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}
		
		public function setVolumeHealth( i : int, health : Number )
		{
			switch ( i )
			{
				case 0:
					mcBoat.mcBackLeft.gotoAndStop( health +1 );
					break;
				case 1:
					mcBoat.mcMiddleLeft.gotoAndStop( health +1 );
					break;
				case 2:
					mcBoat.mcFrontLeft.gotoAndStop( health +1 );
					break;
				case 3:
					mcBoat.mcBackRight.gotoAndStop( health +1 );
					break;
				case 4:
					mcBoat.mcMiddleRight.gotoAndStop( health +1 );
					break;
				case 5:
					mcBoat.mcFrontRight.gotoAndStop( health +1 );
					break;
			}
		}

	}

}