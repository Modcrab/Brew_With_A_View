 package red.game.witcher3.menus.uirescale
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
	import red.game.witcher3.menus.mainmenu.UIRescaleModule;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import red.core.data.InputAxisData;
	import red.core.constants.KeyCode;
	import red.core.utils.InputUtils;
	import scaleform.gfx.Extensions;
	import scaleform.clik.controls.Slider;
	import scaleform.clik.events.SliderEvent;
	
	public class UIRescaleMenu extends CoreMenu
	{
		public var mcUIRescaleModule : UIRescaleModule;
		
		protected var initialH:Number = -1;
		protected var initialV:Number = -1;
		
		public var txtUserName:TextField;
		public var mcInputFeedbackModule:ModuleInputFeedback;
		
		//private var currentScale : Number;
		//private var currentOpacity : Number;
		
		public function UIRescaleMenu():void
		{
			super();
		}
		
		override protected function get menuName():String
		{
			return "RescaleMenu";
		}
		
		public function setCurrentUsername(name:String):void
		{
			if (txtUserName)
			{
				txtUserName.text = name;
			}
		}

		override protected function configUI():void
		{
			super.configUI();
			
			setCurrentUsername("");
			
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 100, true );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "uirescale.initial.horizontal",[SetInitialScaleHorizontal] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "uirescale.initial.vertical",[SetInitialScaleVertical] ) );
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
			
			mcInputFeedbackModule.appendButton(0, NavigationCode.GAMEPAD_L3, -1, "[[panel_button_common_navigation]]", false);
			mcInputFeedbackModule.appendButton(1, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_continue]]", true);
		}
		
		public function SetInitialScaleHorizontal( value : Number )
		{
			initialH = value;
			
			if (initialV != -1)
			{
				mcUIRescaleModule.showWithScale(initialH, initialV);
			}
		}
		
		public function SetInitialScaleVertical( value : Number )
		{
			initialV = value;
			
			if (initialH != -1)
			{
				mcUIRescaleModule.showWithScale(initialH, initialV);
			}
		}
		
		override public function handleInput(event:InputEvent):void
		{
            var details:InputDetails = event.details;
			
			CommonUtils.convertWASDCodeToNavEquivalent(details);
			
			if (details.navEquivalent == NavigationCode.GAMEPAD_A && details.value == InputValue.KEY_UP )
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfirmRescale' , [mcUIRescaleModule._lastSentHValue, mcUIRescaleModule._lastSentVValue]) );
				closeMenu();
				event.handled = true;
			}
			else
			{
				mcUIRescaleModule.handleInputNavigate(event);
			}
			
			if ( details.value == InputValue.KEY_UP &&
				(details.code == KeyCode.SPACE || details.code == KeyCode.ENTER || details.code == KeyCode.E))
			{
				closeMenu();
				event.handled = true;
			}
		}
	}
}
