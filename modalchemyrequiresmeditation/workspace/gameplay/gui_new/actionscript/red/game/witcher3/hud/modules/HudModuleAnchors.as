package  red.game.witcher3.hud.modules
{
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import red.core.events.GameEvent;
	import red.game.witcher3.hud.modules.HudModuleBase;
	import red.game.witcher3.managers.PanelModuleManager;
	import scaleform.clik.layout.LayoutData;
	import scaleform.gfx.Extensions;
	import red.game.witcher3.constants.AspectRatio;

	/**
	 * ...
	 * @author Ryan Pergent
	 */
	public class HudModuleAnchors extends HudModuleBase
	{
		//>------------------------------------------------------------------------------------------------------------------
		// VARIABLES
		//-------------------------------------------------------------------------------------------------------------------
		public var mcModuleManager 		: PanelModuleManager;
		public var mcAnchorWolfHead 	: MovieClip;
		public var mcAnchorHorseStaminaBar: MovieClip;
		public var mcAnchorHorsePanicBar: MovieClip;
		public var mcAnchorItemInfo		: MovieClip;
		public var mcAnchorLootPopup	: MovieClip;
		public var mcAnchorMiniMap		: MovieClip;
		public var mcAnchorOxygenBar	: MovieClip;
		public var mcAnchorQuest		: MovieClip;
		public var mcAnchorBuffs		: MovieClip;
		public var mcAnchorConsole		: MovieClip;
		public var mcAnchorBoatHealth	: MovieClip;
		public var mcAnchorBossFocus	: MovieClip;
		public var mcAnchorMessage		: MovieClip;
		public var mcAnchorWatermark	: MovieClip;
		public var mcAnchorTimelapse	: MovieClip;
		public var mcAnchorJournalUpdate: MovieClip;
		public var mcAnchorAreaInfo		: MovieClip;
		public var mcAnchorCrosshair	: MovieClip;
		public var mcAnchorCompanion	: MovieClip;
		public var mcAnchorDamagedItems	: MovieClip;
		public var mcAnchorControlsFeedback	: MovieClip;

		public function HudModuleAnchors()
		{
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function get moduleName():String
		{
			return "AnchorsModule";
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function configUI():void
		{
			visible = false;
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		
		protected var _currentAspectRatio : int;

		public function UpdateAnchorsAspectRatio( screenWidth : int, screenHeight : int ):void
		{
			_currentAspectRatio = AspectRatio.getCurrentAspectRatio( screenWidth, screenHeight );
			
			//////////////////
			//
			// uncomment to force 21:9 in editor
			//
			//_currentAspectRatio = AspectRatio.ASPECT_RATIO_21_9;
			//
			//////////////////
			
			switch ( _currentAspectRatio )
			{
				case AspectRatio.ASPECT_RATIO_DEFAULT:
				case AspectRatio.ASPECT_RATIO_4_3:
				case AspectRatio.ASPECT_RATIO_21_9:
					gotoAndStop( _currentAspectRatio );
					break;
				case AspectRatio.ASPECT_RATIO_UNDEFINED:
					break;
			}
		}
		
		public function isAspectRatio21_9() : Boolean
		{
			return _currentAspectRatio == AspectRatio.ASPECT_RATIO_21_9;
		}
		
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function UpdateAnchorsPositions() : void
		{
			mcModuleManager.UpdateAnchorsPositions();
		}
	}
}
