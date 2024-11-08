package red.game.witcher3.menus.overlay
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.RenderersList;
	import red.game.witcher3.controls.W3RenderToTextureHolder;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;

	/**
	 * Item info popup (full screen tooltip version)
	 * @author Getsevich Yaroslav
	 */
	public class ItemInfoPopup extends BasePopup
	{
		private const PRIM_STAT_FONT_SIZE:Number = 37;
		private const PRIM_STAT_PADDING:Number = 10;
		private const BOTTOM_PADDING:Number = 70;
		private const BOTTOM_SMALL_PADDING:Number = 2;
		private const INPUT_PADDING:Number = 30;
		private const BLOCK_PADDING:Number = 10;
		private const STATS_PADDING:Number = 25;
		
		public var tfItemType:TextField;
		public var tfItemName:TextField;
		public var listStats:RenderersList;
		public var listProps:RenderersList;
		public var background:MovieClip;		
		public var buttonsBackground:MovieClip;
		
		public var lineSeparator1:Sprite;
		public var lineSeparator2:Sprite;
		public var iconRepair:Sprite;
		public var tfDurability:TextField;
		public var tfSockets:TextField;
		public var mcOilInfo:MovieClip;
		
		public var mcInputFeedback:ModuleInputFeedback;
		
		override protected function configUI():void
		{
			super.configUI();
			tabChildren = false;
			listProps.isHorizontal = true;
			mcInputFeedback.buttonAlign = "center";
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleUserInput, false, 0, true);
		}

		override protected function populateData():void
		{
			if ( !_data )
			{
				return;
			}
			
			var currentHeight:Number = 0;
			
			mcInputFeedback.handleSetupButtons(_data.ButtonsList);
			
			if (tfItemName && _data.ItemName)
			{
				tfItemName.htmlText = _data.ItemName;
				tfItemName.htmlText = CommonUtils.toUpperCaseSafe(tfItemName.htmlText);
			}
			
			if (tfItemType && _data.ItemType)
			{
				tfItemType.htmlText = _data.ItemType;
			}
			
			listProps.dataList = _data.PropertiesList as Array;
			listProps.validateNow();
			listProps.x = (background.width - listProps.actualWidth) / 2;
			
			currentHeight = lineSeparator1.y + STATS_PADDING;
			
			if (_data.DurabilityDescription)
			{
				iconRepair.visible = true;
				tfDurability.visible = true;
				iconRepair.y = tfDurability.y = currentHeight;
				tfDurability.htmlText = _data.DurabilityDescription;
				tfDurability.height = tfDurability.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				currentHeight += (Math.max(tfDurability.height, iconRepair.height) + BLOCK_PADDING);
				lineSeparator2.y = currentHeight;
				currentHeight += BLOCK_PADDING;
				lineSeparator2.visible = true;
			}
			else
			{
				lineSeparator2.visible = false;
				iconRepair.visible = false;
				tfDurability.visible = false;
			}
			
			if (_data.appliedOilInfo)
			{
				var tfOilData:TextField = mcOilInfo["textField"];
				tfOilData.htmlText = _data.appliedOilInfo;
				tfOilData.width = tfOilData.textWidth + CommonConstants.SAFE_TEXT_PADDING;
				mcOilInfo.y = currentHeight;
				mcOilInfo.x = (background.width - mcOilInfo.width) / 2;
				mcOilInfo.visible = true;
				currentHeight +=  (mcOilInfo.height + BLOCK_PADDING);
			}
			else
			{
				mcOilInfo.visible = false;
			}
			
			listStats.y = currentHeight;
			listStats.dataList = _data.StatsList as Array;
			listStats.validateNow();
			
			currentHeight += (listStats.actualHeight - 10); //
			
			if (_data.SocketsDescription)
			{
				tfSockets.htmlText = _data.SocketsDescription;
				tfSockets.height = tfSockets.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				tfSockets.width = tfSockets.textWidth + CommonConstants.SAFE_TEXT_PADDING;
				tfSockets.y = currentHeight;
				tfSockets.x = (background.width - tfSockets.textWidth) / 2;
				currentHeight += tfSockets.height;
				tfSockets.visible = true;
			}
			else
			{
				tfSockets.visible = false;
			}
			
			background.height = currentHeight + BOTTOM_PADDING;
			mcInputFeedback.y = background.height - INPUT_PADDING;
			
			if ( buttonsBackground )
				buttonsBackground.y = background.height - buttonsBackground.height;
			
			super.populateData();
		}
		
		private function handleUserInput(event:InputEvent):void
		{
			var details:InputDetails = event.details;
			var keyUpHold :Boolean = details.value == InputValue.KEY_UP || InputValue.KEY_HOLD;
			if (!event.handled && keyUpHold)
			{
				switch (details.navEquivalent)
				{
					case NavigationCode.RIGHT:
						dispatchEvent( new GameEvent( GameEvent.CALL, "OnRotateItemRight" ) );
						break;
					case NavigationCode.LEFT:
						dispatchEvent( new GameEvent( GameEvent.CALL, "OnRotateItemLeft" ) );
						break;
				}
			}
		}
		
	}
}
