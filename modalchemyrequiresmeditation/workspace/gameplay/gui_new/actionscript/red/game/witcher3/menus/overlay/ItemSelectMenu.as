package red.game.witcher3.menus.overlay 
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTweener;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3GamepadButton;
	import red.game.witcher3.events.SlotActionEvent;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.slots.SlotInventoryGrid;
	import red.game.witcher3.slots.SlotsListGrid;
	import red.game.witcher3.utils.scrollbar.ScrollBar;
	import scaleform.clik.constants.NavigationCode;
	
	/**
	 * Select item dialog
	 * @author Yaroslav Getsevich
	 */
	public class ItemSelectMenu extends CoreMenu
	{
		public var mcPlayerGrid:SlotsListGrid;
		public var btnAccept:W3GamepadButton;
		public var btnClose:W3GamepadButton;
		
		public function ItemSelectMenu()
		{
			_enableMouse = true;
			super();
		}
		
		override protected function get menuName():String { return "SelectItemMenu" }
		override protected function configUI():void 
		{
			super.configUI();
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "items.list.data", [handleDataSet]));
			
			btnAccept.label = "Accept";
			btnAccept.navigationCode = NavigationCode.GAMEPAD_A;
			btnClose.label = "Close";
			btnClose.navigationCode = NavigationCode.GAMEPAD_B;
			
			focused = 1;
			mcPlayerGrid.ignoreGridPosition = true;
			mcPlayerGrid.focused = 1;
			mcPlayerGrid.focusable = false;
		
			mcPlayerGrid.addEventListener(SlotActionEvent.EVENT_ACTIVATE, handleItemSelect, false, 0, true);
		}
		
		override protected function showAnimation():void
		{
			visible = true;
			alpha = .5;
			GTweener.to(this, 1, { x:0, alpha:1 },  { ease: Exponential.easeOut } );
		}
		
		protected function handleItemSelect(event:SlotActionEvent):void
		{
			
			var targetSlot:IBaseSlot = event.targetSlot as IBaseSlot;
			if (!targetSlot.isEmpty())
			{
				trace("GFX [ItemSelectMenu] handleItemSelect, item id: ", targetSlot.data.id);
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnSelectItem", [targetSlot.data.id] ) );
			}
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