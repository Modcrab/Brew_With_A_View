/***********************************/
/** Copyright © 2022 CDProjektRed
/***********************************/

package red.game.witcher3.menus.mainmenu
{
	import red.game.witcher3.constants.PlatformType;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.core.UIComponent;
	import flash.display.MovieClip;
	import flash.text.TextField;

	public class PatchNotesInfoBlock extends UIComponent
	{
		public var mcTitle : TextField;
		public var mcDescription : TextField;		
		public var mcIcon : MovieClip;
		public var mcBackground : MovieClip;
		
		public function PatchNotesInfoBlock()
		{
			super();
		}
		
		override protected function configUI():void
		{
			super.configUI();
		}

		public function setData( dataLabel : String )
		{
			mcIcon.gotoAndStop( dataLabel );

			switch( dataLabel )
			{
				case "graphical_modes_xss":
					mcTitle.text = "[[nge_info_title_graphical_modes]]";
					mcDescription.text = "[[nge_info_description_graphical_modes_xss]]";
				case "graphical_modes":
					mcTitle.text = "[[nge_info_title_graphical_modes]]";					
					mcDescription.text = "[[nge_info_description_graphical_modes_xss]]";
					break;
				case "new_content":
					mcTitle.text = "[[nge_info_title_new_content]]";
					mcDescription.text = "[[nge_info_description_new_content]]";
					break;
				case "photo_mode":
					mcTitle.text = "[[nge_info_title_photo_mode]]";
					mcDescription.text = "[[nge_info_description_photo_mode]]";
					break;
				case "cross_progression":
					mcTitle.text = "[[nge_info_title_cross_progression]]";
					mcDescription.text = "[[nge_info_description_cross_progression]]";
					break;
				case "mods":
					mcTitle.text = "[[nge_info_title_mods]]";
					mcDescription.text = "[[nge_info_description_mods]]";
					break;
				case "controls":
					mcTitle.text = "[[nge_info_title_controls]]";
					mcDescription.text = "[[nge_info_description_controls]]";
					break;
			}

			/*
				case "graphical_modes":
					mcTitle.text = "Graphical Modes";
					mcDescription.text = "Explore the Continent using two graphical rendering options! Switch between Quality Mode’s top visual fidelity with ray tracing elements, and the butter-smooth 60FPS of Performance Mode.";
					break;
				case "new_content":
					mcTitle.text = "New Content";
					mcDescription.text = "Discover a new quest, armor, weapons, & alternate outfits inspired by The Witcher Netflix series, plus extra in-game goodies with My Rewards — a thank you for supporting our work!";
					break;
				case "photo_mode":
					mcTitle.text = "Photo Mode";
					mcDescription.text = "Make your adventure one you’ll never forget thanks to Photo Mode. Take stunning landscape shots, artsy character portraits, pulsating action shots, and more — unleash your creativity.";
					break;
				case "cross_progression":
					mcTitle.text = "Cross Progression";
					mcDescription.text = "Start your journey in one place, then transport it to another — no portals needed! Upload your save to the cloud using your GOG.COM account, then pick it up seamlessly on another platform.";
					break;
				case "mods":
					mcTitle.text = "Mods Integrated";
					mcDescription.text = "Some fantastic community-made mods have been integrated into the game as standard, including 4K textures and models, more detailed monsters, and more!";
					break;
				case "controls":
					mcTitle.text = "New Camera, UI, Controls";
					mcDescription.text = "Quality of life improvements! Including dynamic UI customization, faster Sign casting, an alternate default camera, and other tweaks to provide a smoother, modernized gameplay experience.";
					break;
			}
			*/
			realignControls();
		}

		private function realignControls()
		{
			var ICON_PADDING : Number = 10;				
			var offset : Number = ( mcBackground.width - ( mcIcon.width + mcTitle.textWidth + ICON_PADDING) ) / 2;

			mcIcon.x = offset;
			mcTitle.x = mcIcon.x + mcIcon.width + ICON_PADDING;
		}
		
	}
}
