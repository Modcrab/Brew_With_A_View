/***********************************************************************/
/** Action Script file - Meditation Clock Menu Base Class
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.meditation {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.menus.meditation.Clock;
	import red.game.witcher3.menus.meditation_menu.MeditationClock;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;
	
	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;
	
	public class MeditationClockMenu extends CoreMenu
	{
		public var mcMeditationBonuses:MeditationBonusPanel;
		public var meditationClock:MeditationClock;
		public var mcGeraltImage:MovieClip;

        private var _navBlocked:Boolean;
		private var _bonusMeditationTime:int;

		// modcrab
		private var _modcrabConfirmIntentMode:Boolean = false;
		public var mcModConfirmIntentPanel:ModConfirmIntentPanel;
		// -----
		
		public function MeditationClockMenu()
		{
			_disableShowAnimation = true;
			upToCloseEnabled = false;

			
			super();
		}
		
		override protected function configUI():void
		{
			// modcrab
			if (mcGeraltImage)
			{
				mcGeraltImage.visible = false;
			}
			// -----

			super.configUI();
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
            dispatchEvent( new GameEvent(GameEvent.REGISTER, 'meditation.clock.blocked', [blockClock] ) );
			dispatchEvent( new GameEvent(GameEvent.REGISTER, 'meditation.bonus', [setMeditationBonus] ) );
			
			meditationClock.timeChangeCallback = timeChangedCallback;
			
			focused = 1;
            _navBlocked = false;
		}

        protected function blockClock(value:Boolean):void
		{
            _navBlocked = value;
		}
		
		public function setBonusMeditationTime(value:int):void
		{
			_bonusMeditationTime = value;
			
			var modDelta : Number = Math.abs( meditationClock.selectedTime - meditationClock.currentTime );
			
			mcMeditationBonuses.active = modDelta >= _bonusMeditationTime;
		}
		
		protected function setMeditationBonus(value:Array):void
		{
			trace("GFX -- setMeditationBonus ", value);
			mcMeditationBonuses.data = value;
			
			meditationClock.setLabels("[[panel_name_sleep]]", "[[panel_meditationclock_sleep_hours]]");
			//meditationClock.setLabels("sleep", "sleep until");
		}
		
		protected function timeChangedCallback( value : uint ):void
		{
			trace("GFX meditationClock.currentTime ", meditationClock.selectedTime, _bonusMeditationTime);
			
			var modDelta : Number = Math.abs( meditationClock.selectedTime - meditationClock.currentTime );
			
			mcMeditationBonuses.active = modDelta >= _bonusMeditationTime;
		}
		
        override protected function handleInputNavigate(event:InputEvent):void
        {
            if (!_navBlocked && !(meditationClock.isMeditating))
            {
                super.handleInputNavigate(event);
            }
        }
		
		public function setGeraltBackgroundVisible(value:Boolean):void
		{
			if (mcGeraltImage)
			{
				//mcGeraltImage.visible = value;
			}
		}
		
		override protected function get menuName():String
		{
			return "MeditationClockMenu";
		}
		
		public function SetBlockMeditation( value : Boolean )
		{
			meditationClock.SetBlockMeditation( value );
		}
		
		public function Set24HRFormat( value : Boolean )
		{
			meditationClock.Set24HRFormat( value );
		}

		// modcrab
		public function ModcrabOnMeditationHotkeyPressed():void
		{
			if (_modcrabConfirmIntentMode)
			{
				mcModConfirmIntentPanel.ConfirmedIntent();
			}
			else if (meditationClock.isMeditating)
			{
				meditationClock.ModcrabStopMeditation();
			}
			else
			{
			 	hideAnimation();
			}
		}

		public function ModcrabSetIsInConfirmIntentMode(value:Boolean, panelText:String, buttonPromptLabel:String)
		{
			_modcrabConfirmIntentMode = value;
			//if (mcGeraltImage)
			//{
			//	mcGeraltImage.visible = value;
			//}
			meditationClock.ModcrabSetIsInConfirmIntentMode(value);
			mcModConfirmIntentPanel.ModcrabSetIsInConfirmIntentMode(value, panelText, buttonPromptLabel);
		}
		public function ModcrabCleanup()
		{
			meditationClock.ModcrabCleanup();
			mcModConfirmIntentPanel.ModcrabCleanup();
		}
		// -----
	}
}
