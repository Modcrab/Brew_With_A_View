/***********************************************************************
/** Tooltip module : Base Version
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.character
{
	import red.game.witcher3.menus.common.SkillDataStub;
	import red.game.witcher3.menus.common.StatsTooltip;
	import scaleform.clik.core.UIComponent;
	import red.game.witcher3.events.GridEvent;
	import red.core.events.GameEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class CharacterFloatingTooltipModule extends UIComponent
	{
		public var mcFloatingTooltip : StatsTooltip; // stats
				
		private var tooltipTimer : Timer;
		private static const TIMER_DELAY = 300; // [ms]
		
		public function CharacterFloatingTooltipModule()
		{
			super();
			mcFloatingTooltip.dataBindingKey = "character.tooltip";
		}
		
		protected override function configUI():void
		{
			super.configUI();
			tooltipTimer = new Timer(TIMER_DELAY, 1);
			//dispatchEvent( new GameEvent(GameEvent.REGISTER, "inventory.tooltip_compare.display", [DisplayCompareTooltip]));
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "character.tooltip.display", [ShowTooltip]));
			mcFloatingTooltip.visible = false;
			mcFloatingTooltip.mouseEnabled = false;
			mouseEnabled = false;

			stage.addEventListener(GridEvent.DISPLAY_TOOLTIP, onDisplayTooltip, false, 0, true);
			stage.addEventListener(GridEvent.HIDE_TOOLTIP, onHideTooltip, false, 0, true);
			
			trace("CHARACTER ##########################");
			trace("CHARACTER configUI character floating module");
			trace("CHARACTER ##########################");
		}
		
		public function onDisplayTooltip( event : GridEvent )
		{
			trace("CHARACTER ##########################");
			trace("CHARACTER onDisplayTooltip character floating module");
			trace("CHARACTER ##########################");
			var tooltipData : SkillDataStub = event.itemData as SkillDataStub;

			if ( !tooltipTimer.running )
			{
				tooltipTimer.reset();
				tooltipTimer.addEventListener(TimerEvent.TIMER, TimerShowTooltip);
				tooltipTimer.start();
			}
						
			event.stopImmediatePropagation();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnUpdateSkillTooltip", [tooltipData.abilityName]) );
		}

		protected function ShowTooltip( bShow : Boolean ) : void
		{
			trace("CHARACTER ##########################");
			trace("CHARACTER ShowTooltip character floating module");
			trace("CHARACTER ##########################");
			if ( bShow )
			{
				mcFloatingTooltip.visible = true;
			}
			else
			{
				onHideTooltip(null);
			}
		}

		public function onHideTooltip( event : GridEvent )
		{
			trace("CHARACTER ##########################");
			trace("CHARACTER onHideTooltip character floating module");
			trace("CHARACTER ##########################");
			if ( tooltipTimer.running )
			{
				tooltipTimer.stop();
			}
			mcFloatingTooltip.visible = false;
		}
				
		function TimerShowTooltip( event : TimerEvent ) : void
		{
			ShowTooltip(true);
		}
	}
}
