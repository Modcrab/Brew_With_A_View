package red.game.witcher3.popups
{
	import flash.events.MouseEvent;
	import red.core.CorePopup;
	import red.core.events.GameEvent;
	import red.game.witcher3.hud.modules.lootpopup.HudLootItemModule;
	import scaleform.clik.events.InputEvent;
	/**
	 * System messages
	 * @author Jason Slama
	 */
	public class LootPopupMenu extends CorePopup
	{
		public var mcLootItemModule : HudLootItemModule;
		

		public function LootPopupMenu()
		{
			_enableInputValidation = true;
			
			mcLootItemModule.mcInputFeedback.filterKeyCodeFunction = isKeyCodeValid;
			mcLootItemModule.mcInputFeedback.filterNavCodeFunction = isNavEquivalentValid;
		}
		
		override protected function get popupName():String { return "LootPopup" } 
		
		override protected function configUI():void
		{
			super.configUI();
			
			registerDataBinding( "LootItemList", mcLootItemModule.handleItemListData );
			
			stage.addEventListener( InputEvent.INPUT, mcLootItemModule.handleInput, false, 0, true );
			
			mcLootItemModule._bWaitForKey = true;
			mcLootItemModule.visible = false;
			
			//dispatchEvent( new GameEvent( GameEvent.REGISTER, 'message.show', [showMessage]));
			
			//playStartupAnim();
			//mcMessageModule.focused = 1;
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}
		
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function SetWindowTitle( _Title : String )
		{
			mcLootItemModule.tfTitle.text = _Title;
		}
		
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function SetWindowScale( scale : Number )
		{
			mcLootItemModule.scaleX = scale;
			mcLootItemModule.scaleY = scale;
			mcLootItemModule.visible = true;
		}
		
		public function resizeBackground( value:Boolean ):void
		{
			mcLootItemModule.resizeBackground( value );
		}
		
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function SetSelectionIndex( _Index:int )
		{
			mcLootItemModule.m_indexToSelect = _Index;
		}
	}
}
