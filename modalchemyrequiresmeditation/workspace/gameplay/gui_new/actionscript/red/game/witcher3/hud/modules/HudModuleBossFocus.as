package red.game.witcher3.hud.modules
{
	import adobe.utils.CustomActions;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import red.game.witcher3.hud.modules.HudModuleBase;
	import scaleform.clik.controls.StatusIndicator;
	
	/**
	 * ...
	 * @author Shadi Dadenji
	 */
	public class HudModuleBossFocus extends HudModuleBase
	{
		//>------------------------------------------------------------------------------------------------------------------
		// VARIABLES
		//-------------------------------------------------------------------------------------------------------------------
		public var mcBossFocus		:		MovieClip;

		
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function HudModuleBossFocus()
		{
			super();
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function get moduleName():String
		{
			return "BossFocusModule";
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function configUI():void
		{
			super.configUI();
			alpha = 0;
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function setBossName( _Name:String )
		{
			mcBossFocus.tfBossName.text = _Name;
		}		
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function setBossHealth( _Percentage:int )
		{
			mcBossFocus.mcBossHealth.value = _Percentage;
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function setEssenceDamage( value : Boolean )
		{
			if ( value )
			{
				mcBossFocus.mcBossHealth.mcHealthBar.gotoAndStop("essence");
			}
			else
			{
				mcBossFocus.mcBossHealth.mcHealthBar.gotoAndStop("health");
			}
		}
	}
}