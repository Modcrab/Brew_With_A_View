package red.game.witcher3.menus.photomode 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import red.core.constants.KeyCode;
	import scaleform.clik.constants.NavigationCode;
	import flash.events.KeyboardEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.ui.InputDetails;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.constants.PlatformType;
	import red.game.witcher3.utils.CommonUtils;
	import flash.utils.getDefinitionByName;
	import red.game.witcher3.events.ControllerChangeEvent;
	
	public class PhotomodeMenu extends CoreMenu
	{
		public var m_notification : PhotomodeNotification;
		public var m_tabbedMenu : PhotomodeTabbedMenu;
		public var m_bottomAnchor : MovieClip;
		public var m_leftAnchor : MovieClip;
		
		private var m_bottomHints : Vector.<InputFeedbackButton>;
		private var m_leftHints : Vector.<InputFeedbackButton>;
		
		public function PhotomodeMenu() 
		{			
			_enableMouse = false;
			_disableShowAnimation = true;
			m_bottomHints = new Vector.<InputFeedbackButton>;
			m_leftHints = new Vector.<InputFeedbackButton>; 
			
			super();

			///////
			/*
			var testData = {};
			testData.tabs = [{label:"Some text", data:[]}, {label:"Test"}, {label:"Yes this is some"}, {label:"The last"}];
			fillTabbedMenu(testData);
			*/
			///////
		}
		
		override protected function get menuName():String
		{
			return "PhotomodeMenu";
		}
		
		override protected function configUI():void
		{
			super.configUI();	
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "photomode.tabs", [fillTabbedMenu] ) );
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			
			this.visible = true;
			m_notification.visible = false;
			m_leftAnchor.visible = false;
			m_bottomAnchor.visible = false;
			
			initHints();
			
			_inputMgr.addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, onControllerChange);
		}
		
		// created for calling from .ws scripts
		public function fillTabbedMenu(obj : Object) : void
		{
			var rootDataProvider : DataProvider = new DataProvider();
			var idx : int = 1;

			for each( var tab : Object in obj.tabs )
			{
				var tabModel : Object = new Object();
				tabModel.label = tab.label;
				tabModel.data = toDataProvider(tab.data);
				tabModel.index = idx;
				idx++;
				
				rootDataProvider.push(tabModel);
			}
			
			m_tabbedMenu.setTabs(rootDataProvider);
		}
		
		public function onScreenshotSaved():void 
		{
			m_notification.m_text.text = "[[photomode_screenshot_saved]]";
			m_notification.visible = true;
			m_notification.gotoAndPlay("start");
		}
		
		public function setCurrentFrameScale(vScale : Number , hScale : Number):void 
		{
			var screenCenterX = stage.width / 2;
			var screenCenterY = stage.height / 2;
			
			m_leftAnchor.x = screenCenterX - hScale * (screenCenterX - m_leftAnchor.x);
			m_leftAnchor.y = screenCenterY - vScale * (screenCenterY - m_leftAnchor.y);
			
			m_bottomAnchor.x = screenCenterX - hScale * (screenCenterX - m_bottomAnchor.x);
			m_bottomAnchor.y = screenCenterY - vScale * (screenCenterY - m_bottomAnchor.y);
			
			m_tabbedMenu.x = screenCenterX - hScale * (screenCenterX - m_tabbedMenu.x - m_tabbedMenu.width) - m_tabbedMenu.width;
			m_tabbedMenu.y = screenCenterY - hScale * (screenCenterY - m_tabbedMenu.y - m_tabbedMenu.height) - m_tabbedMenu.height;
			
			m_tabbedMenu.invalidate();
			initHints();
		}
		
		protected override function handleInputNavigate(event:InputEvent):void 
		{
			var details:InputDetails = event.details;
			
			var keyDown:Boolean = details.value == InputValue.KEY_DOWN; //#B should be also hold here
			if (!keyDown)
				return;
			
			switch (details.code) 
			{
			case KeyCode.SPACE:
				if( InputManager.getInstance().getPlatform() == PlatformType.PLATFORM_PC)
					dispatchEvent(new GameEvent(GameEvent.CALL, 'OnScreenShotRequested'));
				return;
			case KeyCode.TAB:
			case KeyCode.PAD_RIGHT_THUMB:
				this.visible = !this.visible;
				return;
			default:
				break;
			}
			
			switch (details.navEquivalent) 
			{
				case NavigationCode.GAMEPAD_START:
					if( InputManager.getInstance().getPlatform() == PlatformType.PLATFORM_PC)
						dispatchEvent(new GameEvent(GameEvent.CALL, 'OnScreenShotRequested'));
					return;
				default:
					break;
			}
		}
		
		private function toDataProvider(tabData:Array):DataProvider 
		{
			var dataProvider : DataProvider = new DataProvider;
			var sliderModel : PhotomodeSliderDataModel;
			
			for each(var item : Object in tabData)
			{
				sliderModel = new PhotomodeSliderDataModel();
				sliderModel.setDataModel.apply(sliderModel, item.args);
				
				dataProvider.push({ data: sliderModel });
			}
			
			return dataProvider;
		}
		
		private function initHints():void 
		{
			var ClassRef:Class = getDefinitionByName("HintButtonRef") as Class;
			
			var bottomHintsModels : Array = [
				{ txt: "[[photomode_navigation_previous_tab]]", gpCode: NavigationCode.GAMEPAD_L1, kbCode:  KeyCode.Q },
				{ txt: "[[photomode_navigation_next_tab]]", gpCode: NavigationCode.GAMEPAD_R1, kbCode:  KeyCode.E },
				{ txt: "[[photomode_navigation_take_screenshot]]", gpCode: _inputMgr.getPlatform() == PlatformType.PLATFORM_PC ? NavigationCode.GAMEPAD_START : NavigationCode.GAMEPAD_SHARE, kbCode:  KeyCode.SPACE },
				{ txt: "[[photomode_navigation_toggle_ui]]", gpCode: NavigationCode.GAMEPAD_RSTICK_HOLD, kbCode:  KeyCode.TAB },
				{ txt: "[[photomode_navigation_exit]]", gpCode: NavigationCode.GAMEPAD_B, kbCode:  KeyCode.ESCAPE } ];
			
			m_bottomHints.length = bottomHintsModels.length;
			
			var padding : uint = 10;
			var xOffset : int = 0;
			bottomHintsModels.reverse();
			for (var i:int = 0; i < bottomHintsModels.length; i++)
			{
				var model : Object =  bottomHintsModels[i];
				var hint : InputFeedbackButton = m_bottomHints[i];
				
				if (hint == null)	
				{
					hint = m_bottomHints[i] = new ClassRef() as InputFeedbackButton;
					this.addChild(hint);
				}
					
				hint.label = model.txt;
				hint.setDataFromStage(model.gpCode, model.kbCode);
				hint.clickable = false;
				
				xOffset += hint.getOccupiedWidth() + padding * i;
				hint.x = m_bottomAnchor.x - xOffset;
				hint.y = m_bottomAnchor.y - hint.height / 2;
			}
			
			var leftHintsModels : Array = [
				[ 
					{ txt: "", gpCode: NavigationCode.GAMEPAD_L3, kbCode: KeyCode.LEFT_MOUSE },
					{ txt: "", gpCode: NavigationCode.INVALID, kbCode: KeyCode.W },  
					{ txt: "", gpCode: NavigationCode.INVALID, kbCode: KeyCode.A },
					{ txt: "", gpCode: NavigationCode.INVALID, kbCode: KeyCode.S },
					{ txt: "[[photomode_hints_move_camera]]", gpCode: NavigationCode.INVALID, kbCode: KeyCode.D } 
				],			
				[ 
					{ txt: "[[photomode_hints_rotate_camera]]", gpCode: NavigationCode.GAMEPAD_R3, kbCode: KeyCode.RIGHT_MOUSE } 
				],		
				[
					{ txt: "[[photomode_hints_camera_distance]]", gpCode: NavigationCode.INVALID, kbCode: KeyCode.MOUSE_SCROLL }
				],
				[
					{ txt: "", gpCode: NavigationCode.GAMEPAD_L2, kbCode: KeyCode.INVALID },
					{ txt: "[[photomode_hints_camera_up_down]]", gpCode: NavigationCode.GAMEPAD_R2, kbCode: KeyCode.INVALID }
				],
				[ 
					{ txt: "", gpCode: NavigationCode.DPAD_UP_DOWN, kbCode: KeyCode.UP },
					{ txt: "[[photomode_hints_select_option]]", gpCode: NavigationCode.INVALID, kbCode: KeyCode.DOWN } 
				],
				[ 
					{ txt: "", gpCode: NavigationCode.GAMEPAD_DPAD_LR, kbCode: KeyCode.LEFT },
					{ txt: "[[photomode_hints_change_value]]", gpCode: NavigationCode.INVALID, kbCode: KeyCode.RIGHT } 
				]
			];
			
			var leftHintsButtonCount : uint = 0
			var predicate = function (obj:Object) 
			{
				return (_inputMgr.isGamepad() && obj.gpCode != NavigationCode.INVALID) 
					|| (!_inputMgr.isGamepad() && obj.kbCode != KeyCode.INVALID); 
			};
			
			for (i = 0; i < leftHintsModels.length; i++)
			{
				var filteredArray : Array = leftHintsModels[i].filter(predicate);
				
				
				if (filteredArray.length == 0)
				{
					leftHintsModels[i] = filteredArray;
					continue;
				}
				
				leftHintsButtonCount += filteredArray.length;
				filteredArray[filteredArray.length - 1].txt = leftHintsModels[i][leftHintsModels[i].length - 1].txt;
				leftHintsModels[i] = filteredArray;
			}
			
			if(m_leftHints.length < leftHintsButtonCount)
				m_leftHints.length = leftHintsButtonCount;
			
			leftHintsModels.reverse();
					
			var yOffset : uint = 0;
			var hintMaxHeight : uint = 0;
			var cur : uint = 0;
			for (i = 0; i < leftHintsModels.length; i++)
			{
				xOffset = 0;
				hintMaxHeight = 0;
				for (var j:int = 0; j < leftHintsModels[i].length; j++)
				{
					model = leftHintsModels[i][j];
					hint = m_leftHints[cur];
									
					if (hint == null)	
					{
						hint = m_leftHints[cur] = new ClassRef() as InputFeedbackButton;
						this.addChild(hint);
					}
									
					hint.label = model.txt;
					hint.clickable = false;
					hint.visible = true;
					hint.setDataFromStage(model.gpCode, model.kbCode);
					hint.validateNow();
					
					if (hintMaxHeight < hint.height)
						hintMaxHeight = hint.height;
					
					hint.x = m_leftAnchor.x + xOffset;
					hint.y = m_leftAnchor.y - yOffset - hint.height / 2;
					
					xOffset += hint.getOccupiedWidth();
					
					cur++;
				}
				
				yOffset += hintMaxHeight * 0.75;	
			}
			
			for (; cur < m_leftHints.length; cur++)
			{
				hint = m_leftHints[cur];
				
				if (hint)
					hint.visible = false;
			}
		}
		
		private function onControllerChange(event:ControllerChangeEvent):void 
		{
			initHints();
		}
	}
}