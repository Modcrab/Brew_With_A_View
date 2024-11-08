/***********************************/
/** Copyright © 2022 CDProjektRed
/***********************************/

package red.game.witcher3.menus.mainmenu
{
	import red.game.witcher3.constants.PlatformType;
	import red.game.witcher3.menus.mainmenu.PatchNotesInfoBlock;
	import scaleform.clik.core.UIComponent;
	import flash.display.MovieClip;
	import flash.text.TextField;

	public class PatchNotesPopup extends UIComponent
	{
		public var mcInfoModule1 : PatchNotesInfoBlock;
		public var mcInfoModule2 : PatchNotesInfoBlock;
		public var mcInfoModule3 : PatchNotesInfoBlock;
		public var mcInfoModule4 : PatchNotesInfoBlock;
		public var mcInfoModule5 : PatchNotesInfoBlock;
		public var mcInfoModule6 : PatchNotesInfoBlock;
		
		public function PatchNotesPopup()
		{
			super();
		}
		
		override protected function configUI():void
		{
			super.configUI();
			//SetupData();
		}

		public function SetupData()
		{
			trace(" mcInfoModule1   ", mcInfoModule1);
			trace(" mcInfoModule2   ", mcInfoModule2);

			
			if(mcInfoModule1)
			{
				mcInfoModule1.setData( "graphical_modes_xss" );
			}
			
			mcInfoModule2.setData( "new_content" );
			mcInfoModule3.setData( "photo_mode" );
			mcInfoModule4.setData( "cross_progression" );
			mcInfoModule5.setData( "mods" );
			mcInfoModule6.setData( "controls" );			
		}

	}
}
