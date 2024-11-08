package red.game.witcher3.hud.modules
{
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.HintButton;
	import red.game.witcher3.controls.W3Label;
	import red.game.witcher3.data.KeyBindingData;
	import scaleform.clik.constants.NavigationCode;

	public class HudModuleControlsFeedback extends HudModuleBase
	{
		public var mcBackground:MovieClip;
		public var mcSwordDisplay:MovieClip;
		public var mcLabel:W3Label;
		
		public var mcBtn1:HintButton;
		public var mcBtn2:HintButton;
		public var mcBtn3:HintButton;
		public var mcBtn4:HintButton;
		public var mcBtn5:HintButton;
		
		public function HudModuleControlsFeedback()
		{
			super();
			isAlwaysDynamic = true;
		}

		override public function get moduleName():String
		{
			return "ControlsFeedbackModule";
		}

		override protected function configUI():void
		{
			super.configUI();
			registerDataBinding( "hud.module.controlsfeedback", populateData );
			
			alpha = 0;
			mcSwordDisplay.visible = false;
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
			
			/*
			var testBd:KeyBindingData = new KeyBindingData();
			testBd.gamepad_navEquivalent = NavigationCode.GAMEPAD_A;
			testBd.keyboard_keyCode = KeyCode.ENTER;
			testBd.label = "ololo";
			populateData([testBd], 0);
			setSwordText("ololo");
			*/
		}

		public function populateData( gameData:Object, index:int ):void
		{
			var dataList:Array = gameData as Array;
			var keyBindingData:KeyBindingData;
			var buttonsCount:int = dataList ? dataList.length : 0;
			
			visible = true;
			
			if ( buttonsCount > 0 )
			{
				keyBindingData = dataList[0] as KeyBindingData;
				mcBtn1.label = keyBindingData.label;
				mcBtn1.keyBinding = keyBindingData;
			}
			else
			{
				mcBtn1.visible = false;
				mcBtn2.visible = false;
				mcBtn3.visible = false;
				mcBtn4.visible = false;
				mcBtn5.visible = false;
				return;
			}
			
			if ( buttonsCount > 1 )
			{
				keyBindingData = dataList[1] as KeyBindingData;
				mcBtn2.label = keyBindingData.label;
				mcBtn2.keyBinding = keyBindingData;
			}
			else
			{
				mcBtn2.visible = false;
				mcBtn3.visible = false;
				mcBtn4.visible = false;
				mcBtn5.visible = false;
				return;
			}
			
			if( buttonsCount > 2 )
			{
				keyBindingData = dataList[2] as KeyBindingData;
				mcBtn3.label = keyBindingData.label;
				mcBtn3.keyBinding = keyBindingData;
			}
			else
			{
				mcBtn3.visible = false;
				mcBtn4.visible = false;
				mcBtn5.visible = false;
				return;
			}
			
			if( buttonsCount > 3 )
			{
				keyBindingData = dataList[3] as KeyBindingData;
				mcBtn4.label = keyBindingData.label;
				mcBtn4.keyBinding = keyBindingData;
			}
			else
			{
				mcBtn4.visible = false;
				mcBtn5.visible = false;
				return;
			}
			
			// NGE - Alternate Sign Casting
			// Added one more button
			if( buttonsCount > 4 )
			{
				keyBindingData = dataList[4] as KeyBindingData;
				mcBtn5.label = keyBindingData.label;
				mcBtn5.keyBinding = keyBindingData;
			}
			else
			{
				mcBtn5.visible = false;
				return;
			}	
			// NGE - Alternate Sign Casting
		}

		public function setSwordText( value : String ):void
		{
			if ( mcSwordDisplay )
			{
				if ( value == "" )
				{
					mcSwordDisplay.visible = false;
				}
				else if ( mcSwordDisplay.textField )
				{
					if ( mcSwordDisplay.textField.htmlText != value )
					{
						mcSwordDisplay.textField.htmlText = value;
						mcSwordDisplay.visible = true;
					}
				}
			}
		}
		
	}
}
