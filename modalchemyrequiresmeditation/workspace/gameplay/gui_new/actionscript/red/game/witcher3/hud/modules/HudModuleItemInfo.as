package red.game.witcher3.hud.modules
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.hud.modules.iteminfo.HudItemInfo;
	import red.game.witcher3.hud.modules.iteminfo.HudPotionInfo;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;

	public class HudModuleItemInfo extends HudModuleBase
	{
		// Should always match up with witcherscript
		public static const HudItemInfoBinding_item1   : uint = 0;
		public static const HudItemInfoBinding_potion1 : uint = 1;
		public static const HudItemInfoBinding_potion2 : uint = 2;
		public static const HudItemInfoBinding_potion3 : uint = 3;
		public static const HudItemInfoBinding_potion4 : uint = 4;
		
		public var mcKbPotion1 	  : HudItemInfo;
		public var mcKbPotion2 	  : HudItemInfo;
		public var mcKbPotion3 	  : HudItemInfo;
		public var mcKbPotion4 	  : HudItemInfo;
		
		public var mcItemSlot 	  : HudItemInfo;
		public var mcPotionSlot1  : HudPotionInfo;
		public var mcPotionSlot2  : HudPotionInfo;
		
		private var isAlwaysDisplayed : Boolean = false;
		private var _showHint:Boolean = false;
		
		public var btnSwitchHint:InputFeedbackButton;
		public var btnSwitchHintBackground:MovieClip;
		
		// NGE
		public static const HudItemInfoBinding_steelsword : uint = 5;
		public static const HudItemInfoBinding_silversword : uint = 6;
		
		public var mcKbOilSteel 	  : HudItemInfo;
		public var mcKbOilSilver 	  : HudItemInfo;
		
		public var btnSwitchHintDoubleTap:InputFeedbackButton;
		public var btnSwitchHintBackgroundDoubleTap:MovieClip;
		
		public var btnSwitchHintOils:InputFeedbackButton;
		public var btnSwitchHintBackgroundOils:MovieClip;
		public var btnSwitchHintOilsKB:InputFeedbackButton;
		public var btnSwitchHintBackgroundOilsKB:MovieClip;
		
		public var cachedY: int;
		
		private var _radialMenuOn:Boolean = false;
		public function setRadialMenuOn(radialOn:Boolean):void		
		{
			var isGamepad:Boolean = InputManager.getInstance().isGamepad();
			
			_radialMenuOn = radialOn;
			
			mcKbOilSteel.visible = _radialMenuOn && !isGamepad;
			mcKbOilSilver.visible = _radialMenuOn && !isGamepad;
			
			btnSwitchHintOilsKB.visible = !isGamepad && _radialMenuOn;
			btnSwitchHintBackgroundOilsKB.visible = !isGamepad && _radialMenuOn;
			
			btnSwitchHintDoubleTap.visible = isGamepad && _radialMenuOn;
			btnSwitchHintBackgroundDoubleTap.visible = isGamepad && _radialMenuOn;
			
			btnSwitchHintOils.visible = isGamepad && _radialMenuOn;
			btnSwitchHintBackgroundOils.visible = isGamepad && _radialMenuOn;
		}
		// NGE

		public function HudModuleItemInfo()
		{
			super();
			
			mcItemSlot.defaultIconName = "quick1";
			mcKbPotion1.showButtonHint = true;
			mcKbPotion2.showButtonHint = true;
			mcKbPotion3.showButtonHint = true;
			mcKbPotion4.showButtonHint = true;
			
			mcKbOilSteel.showButtonHint = true; 	// NGE
			mcKbOilSilver.showButtonHint = true; 	// NGE
		}
		
		override public function get moduleName():String
		{
			return "ItemInfoModule";
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			btnSwitchHint.label = "[[hud_item_info_switch_potions]]";
			btnSwitchHint.setDataFromStage(NavigationCode.DPAD_UP_DOWN, -1, -1, 300);
			
			// NGE
			btnSwitchHintOils.label = "[[panel_button_inventory_upgrade]]";
			btnSwitchHintOils.setDataFromStage(NavigationCode.GAMEPAD_DPAD_LR, -1, -1, 300);
			
			btnSwitchHintOilsKB.label = "[[hud_equip_oils_and_potion]]";
			btnSwitchHintOilsKB.setDataFromStage("", KeyCode.SHIFT_LEFT, -1, 300, true);			
			
			btnSwitchHintDoubleTap.label = "[[hud_equip_potions]]";
			btnSwitchHintDoubleTap.setDataFromStage(NavigationCode.DPAD_UP_DOWN, -1, -1, 300, false, true);
			
			cachedY = btnSwitchHint.y;
			// NGE
			
			visible = true;
			alpha = 0;
			
			updateHints();
			
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, updateHints, false, 0, true);
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}
		
		protected function updateHints(event:Event = null):void
		{
			var isGamepad:Boolean = InputManager.getInstance().isGamepad();
			
			btnSwitchHint.visible = isGamepad && _showHint;
			btnSwitchHintBackground.visible = isGamepad && _showHint;
			
			// NGE
			btnSwitchHintDoubleTap. visible = isGamepad && _showHint;
			btnSwitchHintBackgroundDoubleTap. visible = isGamepad && _showHint;
			
			btnSwitchHintOilsKB.visible = !isGamepad && _radialMenuOn;
			btnSwitchHintBackgroundOilsKB.visible = !isGamepad && _radialMenuOn; 
			
			btnSwitchHintOils.visible = isGamepad && _radialMenuOn;
			btnSwitchHintBackgroundOils.visible = isGamepad && _radialMenuOn;

			btnSwitchHintOils.y = cachedY;
			btnSwitchHintBackgroundOils.y = cachedY;
			btnSwitchHintDoubleTap.y = btnSwitchHintOils.y - btnSwitchHintOils.height * 0.65;
			btnSwitchHintBackgroundDoubleTap.y = btnSwitchHintDoubleTap.y;
				
			btnSwitchHint.y = btnSwitchHintDoubleTap.y - btnSwitchHintOils.height * 0.65;
			btnSwitchHintBackground.y = btnSwitchHint.y;
			// NGE
			
			mcPotionSlot1.visible = isGamepad;
			mcPotionSlot2.visible = isGamepad;
			
			mcKbPotion1.visible = !isGamepad;
			mcKbPotion2.visible = !isGamepad;
			mcKbPotion3.visible = !isGamepad;
			mcKbPotion4.visible = !isGamepad;
			
			mcKbOilSteel.visible = _radialMenuOn && !isGamepad; 	// NGE
			mcKbOilSilver.visible = _radialMenuOn && !isGamepad; // NGE
		}
		
		public function showButtonHints(showHint:Boolean):void
		{
			var isGamepad:Boolean = InputManager.getInstance().isGamepad();
			
			_showHint = _radialMenuOn;
			btnSwitchHint.visible = _showHint && isGamepad; // && ((mcPotionSlot1.alterIconPath && mcPotionSlot1.IconName) || (mcPotionSlot2.alterIconPath && mcPotionSlot2.IconName));
			btnSwitchHintDoubleTap.visible = _showHint && isGamepad;// NGE
			
			mcItemSlot.showButtonHint = showHint;
			mcPotionSlot1.showButtonHint = showHint;
			mcPotionSlot2.showButtonHint = showHint;
		}
		
		public function HideSlots( value : Boolean ):void
		{
			var isGamepad:Boolean = InputManager.getInstance().isGamepad();
			
			if (value)
			{
				updateHints();
			}
			else
			{
				mcPotionSlot1.visible = false;
				mcPotionSlot2.visible = false;
				
				mcKbPotion1.visible = false;
				mcKbPotion2.visible = false;
				mcKbPotion3.visible = false;
				mcKbPotion4.visible = false;
				
				mcKbOilSteel.visible = false;  // NGE
				mcKbOilSilver.visible = false; // NGE
			}
		}
		
		public function animatePotionSwitch(bindingID:int):void
		{
			var targetSlot : HudPotionInfo;
			
			switch (bindingID)
			{
				case HudItemInfoBinding_potion1:
					targetSlot = mcPotionSlot1;
					break;
					
				case HudItemInfoBinding_potion2:
					targetSlot = mcPotionSlot2;
					break;
			}
			
			if (targetSlot)
			{
				targetSlot.animateSwitching();
			}
		}
		
		public function setItemInfo(bindingID:int, icon:String, category:String, name:String, ammo:String, button:int, pcButton:int):void
		{
			var targetKeyboardSlot 	  : HudItemInfo;
			var targetGamepadSlot 	  : HudItemInfo;
			var targetAlterPotionSlot : HudPotionInfo;
			
			switch (bindingID)
			{
				case HudItemInfoBinding_item1:
					targetGamepadSlot = mcItemSlot;
					break;
					
				case HudItemInfoBinding_potion1:
					targetGamepadSlot = mcPotionSlot1;
					targetKeyboardSlot = mcKbPotion1;
					break;
					
				case HudItemInfoBinding_potion2:
					targetGamepadSlot = mcPotionSlot2;
					targetKeyboardSlot = mcKbPotion2;
					break;
				
				case HudItemInfoBinding_potion3:
					targetGamepadSlot = null;
					targetAlterPotionSlot = mcPotionSlot1 as HudPotionInfo;
					targetKeyboardSlot = mcKbPotion3;
					break;
					
				case HudItemInfoBinding_potion4:
					targetGamepadSlot = null;
					targetAlterPotionSlot = mcPotionSlot2 as HudPotionInfo;
					targetKeyboardSlot = mcKbPotion4;
					break;
					
				// NGE
				case HudItemInfoBinding_steelsword:
					targetGamepadSlot = null;
					targetAlterPotionSlot = null;
					targetKeyboardSlot = mcKbOilSteel;
					break;
				case HudItemInfoBinding_silversword:
					targetGamepadSlot = null;
					targetAlterPotionSlot = null;
					targetKeyboardSlot = mcKbOilSilver;
					break;
				// NGE
			}
			
			if (targetGamepadSlot)
			{
				targetGamepadSlot.IconName = icon;
				targetGamepadSlot.ItemCategory = category;
				targetGamepadSlot.ItemName = name;
				targetGamepadSlot.ItemAmmo = ammo;
				targetGamepadSlot.setItemButtons(button, pcButton);
			}
			
			if (targetKeyboardSlot)
			{
				targetKeyboardSlot.IconName = icon;
				targetKeyboardSlot.ItemCategory = category;
				targetKeyboardSlot.ItemName = name;
				targetKeyboardSlot.ItemAmmo = ammo;
				targetKeyboardSlot.setItemButtons(button, pcButton);
			}
			
			if (targetGamepadSlot || targetKeyboardSlot)
			{
				dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
			}
			
			if (targetAlterPotionSlot)
			{
				targetAlterPotionSlot.alterIconPath = icon;
			}
			
			if (_showHint && btnSwitchHint && InputManager.getInstance().isGamepad())
			{
				//btnSwitchHint.visible = (mcPotionSlot1.alterIconPath && mcPotionSlot1.IconName) || (mcPotionSlot2.alterIconPath && mcPotionSlot2.IconName);
			}
		}

		public function EnableElement( enable : Boolean ):void
		{
			/*if ( enable )
			{
				mcItemSlot.mcError.gotoAndStop(1);
			}
			else
			{
				mcItemSlot.mcError.gotoAndPlay("play");
			}*/
		}

		override public function SetEnabled( value : Boolean )
		{
			isEnabled = value;
			if ( !isEnabled )
			{
				SetState("Hide");
				this.alpha = 0;
				this.desiredAlpha = 0;
			}
			else if ( isAlwaysDisplayed )
			{
				SetState("OnUpdate");
				setAlwaysDisplayed(isAlwaysDisplayed);
			}
		}
		
		public function UpdateElement():void
		{
			dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
		}
		
		public function setAlwaysDisplayed( value : Boolean )
		{
			isAlwaysDisplayed = value;
			if ( value )
			{
				RemoveUpdateTimer();
				dispatchEvent( new GameEvent( GameEvent.UPDATE, moduleName ) );
			}
		}

		override public function ShowElement( bShow : Boolean, bImmediately : Boolean = false, bIgnoreState : Boolean = false ):void
		{
			if ( bIgnoreState )
			{
				if ( !isAlwaysDisplayed )
				{
					ShowElementFromState(bShow, bImmediately);
				}
			}
			else
			{
				stateMachine.ShowElement(bShow, bImmediately);
			}
		}

		override function UpdateTimerFinishedCounting( event : TimerEvent ) : void
		{
			if ( isAlwaysDisplayed )
			{
				RemoveUpdateTimer();
				return;
			}
			else
			{
				super.UpdateTimerFinishedCounting( event );
			}
		}
	}
}
