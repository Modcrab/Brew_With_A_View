/***********************************************************************
/** PANEL glossary Encyclopedia main class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/
package red.game.witcher3.menus.glossary
{
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.menus.common.IconItemRenderer;
	import red.game.witcher3.menus.common.PlainListModule;
	import red.game.witcher3.menus.common.TextAreaModule;
	import red.game.witcher3.menus.common.TextAreaModuleCustomInput;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	
	public class GlossaryEncyclopediaMenu extends CoreMenu
	{
		public var mcModuleList:PlainListModule;
		public var mcModuleEntryDesc:TextAreaModuleCustomInput;
		public var mcModuleEntryImage:GlossaryTextureSubListModule;
		
		override protected function get menuName():String 
		{ 
			return "GlossaryEncyclopediaMenu"; 
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			focused = 1;
			currentModuleIdx = 0;
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "glossary.encyclopedia.list", [handleListData]));
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			mcModuleList.mcScrollingList.addEventListener(ListEvent.INDEX_CHANGE, handleIndexChanged, false, 0, true);
		}
		
		override public function ShowSecondaryModules( value : Boolean )
		{
			super.ShowSecondaryModules( value );
			mcModuleEntryDesc.active = value;
			mcModuleEntryImage.visible = value;
			mcModuleEntryImage.enabled = value;
		}
		
		public function setEntryText(titleTxt:String, descTxt:String):void
		{
			if (titleTxt != "" || descTxt != "")
			{
				mcModuleEntryDesc.visible = true;
				mcModuleEntryDesc.SetTitle(titleTxt);
				mcModuleEntryDesc.SetText(descTxt);
			}
			else
			{
				mcModuleEntryDesc.visible = false;
			}
			
			mcModuleEntryDesc.validateNow();
			
			if (mcModuleEntryDesc.focused && !mcModuleEntryDesc.hasSelectableItems())
			{
				currentModuleIdx = 0;
			}
		}
		
		public function setEntryImg( imageLoc:String ):void
		{
			if (imageLoc == "")
			{
				mcModuleEntryImage.visible = false;
			}
			else
			{
				mcModuleEntryImage.visible = true;
				mcModuleEntryImage.setImage(imageLoc);
			}
		}
		
		protected function handleListData(dataList:Array):void
		{
			mcModuleList.data = dataList;
		}
		
		protected function handleIndexChanged(event:ListEvent):void
		{
			var item:IconItemRenderer = mcModuleList.mcScrollingList.getSelectedRenderer() as IconItemRenderer;
			if (item && item.data)
			{
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnEntrySelected", [item.data.tag]));
			}
		}
		
		override public function handleInput( event : InputEvent ):void
		{
			if ( event.handled )
			{
				return;
			}
			for each ( var handler:UIComponent in actualModules )
			{
				if ( event.handled )
				{
					event.stopImmediatePropagation();
					return;
				}
				handler.handleInput( event );
			}
			super.handleInput( event );
		}
		
	}
}
