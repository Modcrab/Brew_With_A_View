package red.game.witcher3.menus.inventory_menu 
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import red.core.constants.KeyCode;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3GamepadButton;
	import red.game.witcher3.events.SlotActionEvent;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.slots.SlotInventoryGrid;
	import red.game.witcher3.slots.SlotsListGrid;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.events.InputEvent;
	
	/**
	 * Menu for equipping / unequipping items slots
	 * @author Getsevich Yaroslav
	 */
	public class MenuSocketsManagment extends CoreMenu
	{
		public var mcScrollBar:ScrollBar;
		public var mcPlayerGrid:SlotsListGrid;
		public var btnAccept:InputFeedbackButton;
		public var btnClose:InputFeedbackButton;
		public var mcGridMask:MovieClip;
		
		override protected function get menuName():String { return "InventorySocketsMenu" }
		override protected function configUI():void
		{
			super.configUI();
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "menu.inventory.sockets.items", [handleDataSet]));
			
			btnAccept.label = "[[panel_common_accept]]";
			btnAccept.setDataFromStage(NavigationCode.GAMEPAD_A, KeyCode.ENTER);
			btnClose.label = "[[panel_common_cancel]]";
			btnClose.setDataFromStage(NavigationCode.GAMEPAD_B, KeyCode.ESCAPE);
			
			focused = 1;
			mcPlayerGrid.ignoreGridPosition = true;
			mcPlayerGrid.focused = 1;			
			mcPlayerGrid.focusable = false;
			
			addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			mcPlayerGrid.addEventListener(SlotActionEvent.EVENT_ACTIVATE, handleItemSelect, false, 0, true);
		}
		
		protected function handleItemSelect(event:SlotActionEvent):void
		{
			var targetSlot:IBaseSlot = event.targetSlot as IBaseSlot;
			if (!targetSlot.isEmpty())
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnEquipItem", [targetSlot.data.id] ) );
			}
		}
		
		override public function handleInput(event:InputEvent):void
		{
			super.handleInput(event);
			if (!event.handled)
			{
				mcPlayerGrid.handleInputNavSimple(event);
			}
		}
		
		override protected function showAnimation():void
		{
			visible = true;
			alpha = .1;
			GTweener.to(this, 1, { x:0, alpha:1 },  { ease: Exponential.easeOut } );
		}
		
		protected function handleDataSet(value:Array):void
		{
			mcPlayerGrid.data = value;
			mcPlayerGrid.selectedIndex = 0;
			mcPlayerGrid.validateNow();
			
			var currentSlot:SlotInventoryGrid;
			for (var i:int = 0; i < mcPlayerGrid.getRenderersCount(); ++i)
			{
				currentSlot = mcPlayerGrid.getRendererAt(i) as SlotInventoryGrid;
				if (currentSlot)
				{
					currentSlot.useContextMgr = false;
				}
			}
		}
	}

}
