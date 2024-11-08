package red.game.witcher3.menus.blacksmith
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.RenderersList;
	import red.game.witcher3.controls.W3UILoaderSlot;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotPaperdoll;
	
	/**
	 * Display sockets for current selected item
	 * @author Getsevich Yaroslav
	 */
	public class ItemSocketsInfo extends BlacksmithItemPanel
	{
		private const FILLED_RUNE_NAME:Number = 0x9D9386;
		private const FILLED_SOCKET_COLOR:Number = 0xB68E49;
		private const EMPTY_SOCKET_COLOR:Number = 0x999999;
		
		private const MAX_SOCKETS_COUNT:int = 3;
		private const LABEL_ONE_SLOT:String = "one";
		private const LABEL_TWO_SLOT:String = "two";
		private const LABEL_THREE_SLOT:String = "three";
		
		// #Y Keep names in format <name><index>
		//public var txtLabel1:TextField;
		//public var txtLabel2:TextField;
		//public var txtLabel3:TextField;
		public var txtValue1:TextField;
		public var txtValue2:TextField;
		public var txtValue3:TextField;
		public var connector1:MovieClip;
		public var connector2:MovieClip;
		public var connector3:MovieClip;
		public var mcSlot1:SlotPaperdoll;
		public var mcSlot2:SlotPaperdoll;
		public var mcSlot3:SlotPaperdoll;
		public var mcRunesList:RenderersList;
		
		public function ItemSocketsInfo()
		{
			//txtLabel1.text = "[[panel_blacksmith_first_socket]]";
			//txtLabel2.text = "[[panel_blacksmith_second_socket]]";
			//txtLabel3.text = "[[panel_blacksmith_third_socket]]";

			cleanupSockets();
		}
		
		override public function cleanup():void
		{
			super.cleanup();
			cleanupSockets();
		}
		
		override protected function cleanupView():void
		{
			super.cleanupView();
		}
		
		override protected function updateData():void
		{
			super.updateData();
			
			if (!_data.socketsCount)
			{
				trace("GFX [ItemSocketsInfo] Invalid sockets count");
				return;
			}
			if (_data.actionPrice)
			{
				txtPriceLabel.visible = true;
				txtPriceValue.text = _data.actionPrice;
			}
			if (mcRunesList)
			{
				mcRunesList.dataList = _data.socketsData as Array;
			}
			
			cleanupSockets();
			switch (_data.socketsCount)
			{
				case 1:
					gotoAndStop(LABEL_ONE_SLOT);
					break;
				case 2:
					gotoAndStop(LABEL_TWO_SLOT);
					break;
				case 3:
					gotoAndStop(LABEL_THREE_SLOT);
					break;
			}
			
			// wait for timeline validation
			addEventListener(Event.ENTER_FRAME, handleTimelineValidation, false, 0, true);
		}
		
		private function handleTimelineValidation(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, handleTimelineValidation);
			cleanupSockets();
			populateSocketsData();
		}
		
		private function populateSocketsData():void
		{
			var socketsList:Array = _data.socketsData;
			var socketsCount:int = _data.socketsCount ? _data.socketsCount : 0;
			var curLabel:TextField;
			var curValue:TextField
			
			socketsCount = Math.min(socketsCount, MAX_SOCKETS_COUNT);
			if (socketsList)
			{
				var len:int = Math.min(socketsList.length, MAX_SOCKETS_COUNT);
				for (var i:int = 0; i < len; i++)
				{
					var curData:Object = socketsList[i];
					var curSocket:SlotPaperdoll = getChildByName("mcSlot" + (i + 1)) as SlotPaperdoll;
					var curConnector:MovieClip = getChildByName("connector" + (i + 1)) as MovieClip;
					curLabel = getChildByName("txtLabel" + (i + 1)) as TextField;
					curValue = getChildByName("txtValue" + (i + 1)) as TextField;
					
					if (curSocket)
					{
						curSocket.data = curData;
						curSocket.tfSlotName.text = ""; //curData.name;
					}
					if (curConnector) curConnector.gotoAndPlay("filled");
					if (curLabel)
					{
						curLabel.visible = true;
						curLabel.textColor = FILLED_SOCKET_COLOR;
					}
					if (curValue)
					{
						curValue.text = curData.name;
						//curValue.width = curValue.textWidth + CommonConstants.SAFE_TEXT_PADDING;
						curValue.textColor = FILLED_RUNE_NAME;
					}
				}
				for (var j:int = len; j < socketsCount; j++)
				{
					curLabel = getChildByName("txtLabel" + (j + 1)) as TextField;
					curValue = getChildByName("txtValue" + (j + 1)) as TextField;
					if (curLabel)
					{
						curLabel.visible = true;
						curLabel.textColor = EMPTY_SOCKET_COLOR;
					}
					if (curValue)
					{
						curValue.text = "[[panel_blacksmith_empty_socket]]";
						curValue.textColor = EMPTY_SOCKET_COLOR;
					}
				}
			}
			else
			{
				trace("GFX [ItemSocketsInfo] Invalid sockets data");
			}
		}
		
		private function cleanupSockets():void
		{
			for (var i:int = 0; i < MAX_SOCKETS_COUNT; i++)
			{
				var curSlot:SlotPaperdoll = getChildByName("mcSlot" + (i + 1)) as SlotPaperdoll;
				var curConnector:MovieClip = getChildByName("connector" + (i + 1)) as MovieClip;
				var curLabel:TextField = getChildByName("txtLabel" + (i + 1)) as TextField;
				var curValue:TextField = getChildByName("txtValue" + (i + 1)) as TextField;
				
				if (curSlot)
				{
					curSlot.tfSlotName.text = "";
					curSlot.cleanup();
					curSlot.darkUnselectable = false;
					curSlot.selectable = false;
					curSlot.draggingEnabled = false;
				}
				if (curConnector) curConnector.gotoAndPlay("empty");
				if (curLabel) curLabel.visible = false;
				if (curValue) curValue.text = "";
			}
		}
	
	}
}
