package red.game.witcher3.hud.modules
{
	import red.core.CoreHudModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.hud.modules.lootpopup.HudLootScrollingList;
	import red.game.witcher3.controls.W3ScrollingList;
	
	import flash.text.TextField;
	import flash.display.MovieClip;
	
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.interfaces.IDataProvider;
	//import witcher3.game.data.BoundDataProvider;
	import red.game.witcher3.utils.motion.TweenEx;
	import red.game.witcher3.hud.modules.pickeditemsinfo.HudPickedItemsInfoListItem;
	
	public class HudModulePickedItemsInfo extends HudModuleBase
	{
		public var tfPickedItem	: TextField;
		public var mcItemsList :  W3ScrollingList;
		public var mcItemsListItem1 : HudPickedItemsInfoListItem;
		public var mcItemsListItem2 : HudPickedItemsInfoListItem;
		public var mcItemsListItem3 : HudPickedItemsInfoListItem;
		public var mcItemsListItem4 : HudPickedItemsInfoListItem;
		
		private static const FADE_DURATION:Number = 500;
		
		private var _bShowDescription:Boolean;

		public function HudModulePickedItemsInfo() 
		{
			super();
			_bShowDescription = false;
			
			trace( "Minimap HudModulePickedItemsInfo::HudModulePickedItemsInfo" );
			//mcItemsList.dataProvider = BoundDataProvider.getInstance( 'hud.pickeditems' );
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function get moduleName():String
		{
			return "PickedItemsInfoModule";
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function configUI():void
		{
			super.configUI();	
			
			x = 470.55;
			y = 55.05;
			z = 100;
			scaleX = 1;
			scaleY = 1;
			visible = true;
			alpha = 0;
			
			registerDataBinding( 'pickeditem.lastid', handleSetLastPickedItemInfoId );
	
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
			
			trace("Minimap HudModulePickedItemsInfo::configUI");
		}
		
		override public function ShowElement(bShow : Boolean, bImmediately : Boolean = false ) : void
		{
			if (bShow != _bShowDescription)
			{
				_bShowDescription = bShow;
				
				if (_bShowDescription)
				{
					effectFade(this,1.0,FADE_DURATION);
				}
				else
				{
					effectFade(this,0.0,FADE_DURATION);
				}
			}
		}
		
		override protected function handleTweenComplete(tween : TweenEx) : void
		{
			super.handleTweenComplete(tween);
			if ( alpha == 1.0 )
			{
				//GameInterface.playSound("gui_loot_item_generic");
			}
		}
		
		private function handleSetLastPickedItemInfoId( value : int ) : void
		{
			var lastItem : HudPickedItemsInfoListItem = HudPickedItemsInfoListItem( mcItemsList.getRendererAt( value ) );
			lastItem.isLast = true;
		}

	}
	
}
