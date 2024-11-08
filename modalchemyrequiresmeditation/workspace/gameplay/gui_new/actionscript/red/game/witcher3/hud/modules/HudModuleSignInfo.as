package red.game.witcher3.hud.modules
{
	import red.core.events.GameEvent;
	import red.game.witcher3.hud.modules.HudModuleBase;
	import red.game.witcher3.hud.modules.signinfo.HudItemInfo;
	
	public class HudModuleSignInfo extends HudModuleBase
	{
		public var mcSlot 	 : HudItemInfo;

		public function HudModuleSignInfo() 
		{
			super();
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function get moduleName():String
		{
			return "SignInfoModule";
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function configUI():void
		{
			super.configUI();	
			
			//x = 470.55;
			//y = 255.05;
			//z = 100;
			//scaleX = 1;
			//scaleY = 1;
			visible = true;
			
			registerDataBinding( 'signinfo.iconname', UpdateIcon );

			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}
	
		public function ShowBckArrow( bShow : Boolean ):void
		{
			if( mcSlot.mcBckArrow )
			{
				mcSlot.mcBckArrow.visible = bShow;
			}
		}
		
		private function UpdateIcon( value : String ) : void
		{
			mcSlot.IconName = value;
		}
		
		public function EnableElement( enable : Boolean ):void
		{
			if ( enable )
			{
				mcSlot.mcError.gotoAndStop(1);
			}
			else
			{
				mcSlot.mcError.gotoAndPlay("play");
			}
		}
		
		

	}
}
