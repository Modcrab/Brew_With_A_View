/***********************************************************************
/** Common Main Menu class
/***********************************************************************
/** Copyright © 2015 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.death_screen
{
	import com.gskinner.motion.easing.Exponential;
	import flash.display.MovieClip;
	import red.game.witcher3.constants.GwintInputFeedback;
	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.managers.InputFeedbackManager;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.managers.FocusHandler;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;

	import red.core.CoreMenu;
	import red.core.events.GameEvent;

	public class DeathScreenMenu extends CoreMenu
	{
		public var mcDeathScreenGraphics : MovieClip;
		public var mcFakeBlackScreen : MovieClip;

		public var mcList : W3ScrollingList;
		public var mcListItem1 : BaseListItem;
		public var mcListItem2 : BaseListItem;
		public var mcListItem3 : BaseListItem;
		public var mcListItem4 : BaseListItem;

		private var _focusHandler : FocusHandler;
		private var _inputEnabled : Boolean = true;
		
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		public function DeathScreenMenu()
		{
			super();
			_enableMouse = false;
			InputFeedbackManager.useOverlayPopup = true;
			InputFeedbackManager.eventDispatcher = this;
			
			mcList.selectOnOver = true;
		}
		
		override protected function get menuName():String
		{
			return "DeathScreenMenu";
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			dispatchEvent( new GameEvent(GameEvent.REGISTER, "hud.deathscreen.list", [handleDataSet]));
			
			//InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInputNavigate, false, 0, true);
			mcList.addEventListener( ListEvent.ITEM_CLICK, SendPressEvent );
			
			mcList.focusable = false;
			
			showInputFeedback(true);
			
			visible = true;
			alpha = 1;
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
		}
		
		override protected function handleInputNavigate(event:InputEvent):void
		{
			if ( event.handled || !_inputEnabled )
			{
				return;
			}
			
			mcList.handleInput(event);
			
			if ( !event.handled )
			{
				var details:InputDetails = event.details;
				if (details.value == InputValue.KEY_UP && (details.navEquivalent == NavigationCode.ENTER || details.code == KeyCode.E || details.code == KeyCode.NUMPAD_ENTER))
				{
					SendPressEvent();
					event.handled = true;
				}
			}
		}
		
		override protected function showAnimation():void
		{
			handleShowAnimComplete(null);
			/*trace("HUD "+menuName+" showAnimation");
			visible = true;
			y = SHOW_ANIM_OFFSET;
			alpha = 0;
			GTweener.to(this, SHOW_ANIM_DURATION, { y:0, alpha:1 },  { ease: Exponential.easeOut, onComplete:handleShowAnimComplete } );*/
		}
		
		public function handleDataSet( gameData:Object, index:int ):void
		{
			var dataList:Array = gameData as Array;
			mcList.dataProvider = new DataProvider(dataList);
			mcList.validateNow();
			mcList.focused = 1;
			
			if (mcList.selectedIndex == -1)
			{
				mcList.selectedIndex = 0;
			}
			
			const itemsPadding:Number = 20;
			mcListItem1.validateNow();
			mcListItem2.validateNow();
			mcListItem3.validateNow();
			mcListItem4.validateNow();
			mcListItem2.y = mcListItem1.y + mcListItem1.textField.textHeight + itemsPadding;
			mcListItem3.y = mcListItem2.y + mcListItem2.textField.textHeight + itemsPadding;
			mcListItem4.y = mcListItem1.y - mcListItem1.textField.textHeight - itemsPadding; 
		}
		
		public function SendPressEvent( event : ListEvent = null ):void
		{			
			var listItem : BaseListItem;
			listItem = mcList.getRendererAt( mcList.selectedIndex ) as BaseListItem;					
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnPress', [listItem.data.tag] ) );
		}
		
		public function setShowBlackscreen( value : Boolean )
		{
			if (mcFakeBlackScreen)
			{
				mcFakeBlackScreen.visible = value;
			}
		}
		
		public function showInputFeedback( value : Boolean )
		{
			InputFeedbackManager.cleanupButtons(this);
			
			_inputEnabled = value;
			
			if ( value )
			{
				InputFeedbackManager.appendButtonById(GwintInputFeedback.apply, NavigationCode.GAMEPAD_A, KeyCode.ENTER, "panel_button_common_select");
				InputFeedbackManager.appendButtonById(GwintInputFeedback.navigate, NavigationCode.GAMEPAD_L3, -1, "panel_button_common_navigation");
			}
		}
	}
}
