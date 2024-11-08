 package red.game.witcher3.menus.commonbkg
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import red.game.witcher3.managers.ControlContextManager;
	import red.game.witcher3.menus.common.NavigationModule;
	import red.game.witcher3.menus.common.PlayerDetails;
	import red.game.witcher3.menus.common.ButtonContainerModule;
	import flash.events.Event;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import red.game.witcher3.managers.PanelModuleManager;
	
	import red.game.witcher3.controls.W3ScrollingList;

	public class MainCommon extends CoreMenu
	{
		public var mcPanelModuleManager : PanelModuleManager;
		public var mcNavigationModule : NavigationModule;
		public var mcPlayerDetailsModule : PlayerDetails;
		public var mcButtons : ButtonContainerModule;
		
		public var mcAnchor_MODULE_Navigation : MovieClip;
		public var mcAnchor_MODULE_Buttons : MovieClip;
		public var mcAnchor_MODULE_PlayerDetails : MovieClip;
		//protected var _inputHandlers:Vector.<UIComponent>;
		
		public function MainCommon():void
		{
			//_inputHandlers = new Vector.<UIComponent>;
			super();
		}
		
		override protected function get menuName():String
		{
			return "CommonMenu";
		}
	
		override protected function configUI():void
		{
			super.configUI();
			
			//stage.addEventListener(KeyboardEvent.KEY_DOWN,hKeyboardDown);
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 100, true );
			stage.addEventListener( W3ScrollingList.REPOSITION, OnRepositionItems, false, 0, true );
			//	stage.addEventListener( InputEvent.INPUT, listModule.handleInput, false, 0, true );
			_inputHandlers.push(mcNavigationModule);
			_inputHandlers.push(mcButtons);
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}
		
		/*
		override protected function onCoreInit():void
		{
			super.onCoreInit();
		}
		*/
		
		override public function handleInput(event:InputEvent):void
		{
			var details		:InputDetails 	= event.details;
			var keyPress	:Boolean 		= (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
					
/*			//trace("JOURNAL handleInput "+details.code);
			mcNavigationModule.handleInput( event );
			
			if ( !event.handled )
			{
				super.handleInput( event );
			}*/
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
		
		public function OnRepositionItems( event : Event ) : void
		{
			mcNavigationModule.OnRepositionItems(event);
		}
	}
	
}