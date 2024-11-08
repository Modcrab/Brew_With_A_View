package red.game.witcher3.hud.modules
{
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.filters.*;
	import red.core.CoreHudModule;
	import red.core.events.GameEvent;
	
	//>------------------------------------------------------------------------------------------------------------------
	// Display player's health and injuries as a paperdoll
	//-------------------------------------------------------------------------------------------------------------------
	public class HudModuleBioMonitor extends CoreHudModule 
	{
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function HudModuleBioMonitor() 
		{
			super();			
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function get moduleName():String
		{
			return "BioMonitorModule";
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function configUI():void
		{
			super.configUI();	
			
 			x = 440;
			y = -75;
			z = 100;
			
			ResetHealth();
			visible = false;
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function Show():void
		{	
			visible = true;
			gotoAndPlay("open");
		}		
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function Hide():void
		{
			gotoAndPlay("close");
		}		
		private function ResetHealth():void
		{
			for (var i:int = 0; i < 10; i++) 
			{
				SetHealthValue( 1, i );
			}
			
			SetGeneralHealthValue(1);
		}
		//>------------------------------------------------------------------------------------------------------------------
		// _healthPercentageN should be between 0 and 1
		//-------------------------------------------------------------------------------------------------------------------
		public function SetGeneralHealthValue( _HealthPercentageN:Number ):void
		{
			mcGeneralHealth.tfHealth.text = Math.round( _HealthPercentageN * 100 ) + "% HP";
		}
		public function SetHealthValue( _HealthPercentageN:Number, _BodyPartI:int ):void
		{			
			mcPaperDoll[ "mcBodyPart" + _BodyPartI ].tfHealth.visible = (_HealthPercentageN != 1);			
			mcPaperDoll[ "mcBodyPart" + _BodyPartI ].tfHealth.text = Math.round( _HealthPercentageN * 100 ) + "%";
			mcPaperDoll[ "mcBodyPart" + _BodyPartI ].gotoAndStop( Math.round(_HealthPercentageN * mcPaperDoll[ "mcBodyPart" + _BodyPartI ].totalFrames));			
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function AddCriticalEffect( _EffectI:int, _BodyPartI:int ):void
		{
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function RemoveCriticalEffect( _EffectI:int, _BodyPartI:int ):void
		{
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function RemoveCriticalEffects( _BodyPartI:int):void
		{
		}
		
	}

}