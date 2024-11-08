package red.game.witcher3.hud.modules
{
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.core.CoreHudModule;
	import red.core.events.GameEvent;
	import red.core.constants.KeyCode;
	import red.game.witcher3.controls.InputFeedbackButton;
	//import red.game.witcher3.controls.Button;

	import scaleform.clik.events.ListEvent;
	import scaleform.clik.events.InputEvent;
	import flash.events.FocusEvent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import flash.events.MouseEvent;

	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;

	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.controls.W3ScrollingList;
	import scaleform.clik.data.DataProvider;

	import scaleform.clik.managers.FocusHandler;

	public dynamic class HudModuleDeathScreen extends HudModuleBase
	{
		private var bHandleInput : Boolean = false;

		public var btnNavigation : InputFeedbackButton;
		public var btnSelect : InputFeedbackButton;

		public var mcDeathScreenGraphics : MovieClip;
		public var mcFakeBlackScreen : MovieClip;

		public var mcList : W3ScrollingList;
		public var mcListItem1 : BaseListItem;
		public var mcListItem2 : BaseListItem;
		public var mcListItem3 : BaseListItem;

		private var _focusHandler : FocusHandler;

		public function HudModuleDeathScreen()
		{
			super();

		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function get moduleName():String
		{
			return "DeathScreenModule";
		}

		override protected function configUI():void
		{
			super.configUI();

			FocusHandler.init(stage, this);
			_focusHandler = FocusHandler.getInstance();
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "hud.deathscreen.list", [handleDataSet]));

			_inputHandlers = new Vector.<UIComponent>;
			visible = true;
			alpha = 0;
			tabEnabled = false;
			mcDeathScreenGraphics.textField.htmlText = "[[panel_death_screen_title]]";

			stage.addEventListener( InputEvent.INPUT, handleInputNavigate, false, 0, true );
			stage.addEventListener( MouseEvent.CLICK, restoreFocus );
			mcList.addEventListener( ListEvent.ITEM_CLICK, SendPressEvent );

			_inputHandlers.push(mcList);

			btnSelect.label = "[[panel_button_common_select]]";
			btnSelect.setDataFromStage( NavigationCode.GAMEPAD_A, KeyCode.ENTER);

			btnNavigation.label = "[[panel_button_common_navigation]]";
			btnNavigation.setDataFromStage(NavigationCode.GAMEPAD_L3, KeyCode.UP);

			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}

		public function handleDataSet( gameData:Object, index:int ):void
		{
			var dataList:Array = gameData as Array;
			mcList.dataProvider = new DataProvider(dataList);
			mcList.validateNow();
			mcList.focused = 1;
		}

		override public function ShowElementFromState( bShow : Boolean, bImmeditely : Boolean = false ):void
		{
			mcList.selectedIndex = 0;
			bHandleInput = bShow;
			visible = bShow;
			alpha = bShow ? OPACITY_MAX : 0;
			desiredAlpha = alpha;
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnOpened', [ bShow ] ) );
			if ( !bShow )
			{
				setShowBlackscreen( false );
			}
			else
			{
				focused = 1;
				mcList.focused = 1;
			}
		}

		public function SendPressEvent( event : ListEvent ):void
		{
			if( !bHandleInput )
			{
				return;
			}
			var listItem : BaseListItem;
			listItem = mcList.getRendererAt( mcList.selectedIndex ) as BaseListItem;
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnPress', [listItem.data.tag] ) );
		}

		public function handleInputNavigate( event:InputEvent ):void // #B tweak
		{
			if ( event.handled || !bHandleInput )
			{
				return;
			}

			var details:InputDetails = event.details;
            var keyUp:Boolean = (details.value == InputValue.KEY_UP );
			_focusHandler.setFocus(this, 0);
			for each ( var handler:UIComponent in _inputHandlers )
			{
				if ( event.handled )
				{
					event.stopImmediatePropagation();
					return;
				}
				handler.handleInput( event );
			}
		}

		private function restoreFocus( event : MouseEvent )
		{
			if (bHandleInput)
			{
				focused = 1;
				mcList.focused = 1;
			}
		}

		override public function set focused(value:Number):void
		{
			super.focused = value;
			_focusHandler.setFocus(this, 0);
			mcList.focused = 1;
		}

		public function setShowBlackscreen( value : Boolean )
		{
			if (mcFakeBlackScreen)
			{
				mcFakeBlackScreen.visible = value;
			}
		}

		override public function SetScaleFromWS( scale : Number ) : void
		{
		}
	}
}
