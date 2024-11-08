package red.game.witcher3.menus.blacksmith
{
	import flash.display.MovieClip;
	import red.game.witcher3.slots.SlotPaperdoll;
	import red.game.witcher3.slots.SlotsListPaperdoll;
	import red.game.witcher3.utils.CommonUtils;
	
	/**
	 * Display disassemble items for current selected item
	 * @author Getsevich Yaroslav
	 */
	public class ItemDisassembleInfo extends BlacksmithItemPanel
	{
		private const MAX_SOCKETS_COUNT:int = 3;
		private const SLOTS_COUNT:int = 7;
		
		public var mcSlot1:SlotPaperdoll;
		public var mcSlot2:SlotPaperdoll;
		public var mcSlot3:SlotPaperdoll;
		public var mcSlot4:SlotPaperdoll;
		public var mcSlot5:SlotPaperdoll;
		public var mcSlot6:SlotPaperdoll;
		public var mcSlot7:SlotPaperdoll;
		private var _slotsList:Vector.<SlotPaperdoll>;
		
		public var mcRuneSlot1:SlotPaperdoll;
		public var mcRuneSlot2:SlotPaperdoll;
		public var mcRuneSlot3:SlotPaperdoll;
		
		public function ItemDisassembleInfo()
		{
			_slotsList = new Vector.<SlotPaperdoll>;
			for (var i:int = 0; i < SLOTS_COUNT; i++ )
			{
				var curSlots:SlotPaperdoll = getChildByName("mcSlot" + i) as SlotPaperdoll;
				if (curSlots)
				{
					curSlots.darkUnselectable = false;
					curSlots.selectable = false;
					curSlots.draggingEnabled = false;
					_slotsList.push(curSlots);
				}
			}
			mcRuneSlot1.enabled = false;
			mcRuneSlot1.darkUnselectable = false;
			mcRuneSlot1.selectable = false;
			mcRuneSlot1.visible = false;
			mcRuneSlot2.enabled = false;
			mcRuneSlot2.darkUnselectable = false;
			mcRuneSlot2.selectable = false;
			mcRuneSlot2.visible = false;
			mcRuneSlot3.enabled = false;
			mcRuneSlot3.darkUnselectable = false;
			mcRuneSlot3.selectable = false;
			mcRuneSlot3.visible = false;
		}
		
		override protected function cleanupView():void
		{
			super.cleanupView();
			cleanupSlots();
		}
		
		override protected function updateData():void
		{
			super.updateData();
			cleanupSlots();
			populateData();
			populateSocketsData();
			
			if (_data.disableAction)
			{
				filters = [CommonUtils.getDesaturateFilter()];
				alpha = .4;
			}
			else
			{
				filters = [];
				alpha = 1;
			}
		}
		
		private function cleanupSlots():void
		{
			var len:int = _slotsList.length;
			for (var i:int = 0; i < len; i++ )
			{
				_slotsList[i].tfSlotName.text = "";
				_slotsList[i].cleanup();
			}
		}
		
		private function populateData():void
		{
			var partList:Array = _data.partList as Array;
			if (partList)
			{
				var len:int = Math.min(_slotsList.length, partList.length);
				var slotsDisplayList:Vector.<SlotPaperdoll> = new Vector.<SlotPaperdoll>;
				
				// HARDCODE!
				if (len == 1)
				{
					slotsDisplayList.push(mcSlot1);
					//mcSlot1.x = 240;
				}
				else if (len == 2)
				{
					slotsDisplayList.push(mcSlot1);
					slotsDisplayList.push(mcSlot2);
					//mcSlot1.x = 160;
					//mcSlot2.x = 320;
				}
				else if (len == 3)
				{
					slotsDisplayList.push(mcSlot1);
					slotsDisplayList.push(mcSlot2);
					slotsDisplayList.push(mcSlot3);
					//mcSlot1.x = 160;
					//mcSlot2.x = 320;
					//mcSlot4.x = 240;
				}
				else if (len == 4)
				{
					slotsDisplayList.push(mcSlot1);
					slotsDisplayList.push(mcSlot2);
					slotsDisplayList.push(mcSlot3);
					slotsDisplayList.push(mcSlot4);
					//mcSlot3.x = mcSlot1.x = 160;
					//mcSlot4.x = mcSlot5.x = 320;
				}
				else
				{
					slotsDisplayList.push(mcSlot1);
					slotsDisplayList.push(mcSlot2);
					slotsDisplayList.push(mcSlot3);
					slotsDisplayList.push(mcSlot4);
					slotsDisplayList.push(mcSlot5);
					//mcSlot1.x = 160;
					//mcSlot2.x = 320;
					//mcSlot3.x = 77;
					//mcSlot4.x = 240;
					//mcSlot5.x = 400;
				}
				
				for (var j:int = 0; j <  _slotsList.length; j++ )
				{
					_slotsList[j].visible = false;
				}
				var displayLen:int = slotsDisplayList.length;
				for (var i:int = 0; i < displayLen; i++)
				{
					slotsDisplayList[i].data = partList[i];
					slotsDisplayList[i].tfSlotName.text = partList[i].name;
					slotsDisplayList[i].visible  = true;
				}
			}
			else
			{
				trace("GFX [ItemDisassembleInfo] invalid data");
			}
		}
		
		private function populateSocketsData():void
		{
			var socketsList:Array = _data.socketsData;
			var socketsCount:int = _data.socketsCount ? _data.socketsCount : 0;
			var equippedRunesCount:int = 0;
			
			mcRuneSlot1.visible = false;
			mcRuneSlot2.visible = false;
			mcRuneSlot3.visible = false;
			
			mcRuneSlot1.enabled = false;
			mcRuneSlot2.enabled = false;
			mcRuneSlot3.enabled = false;
			
			socketsCount = Math.min(socketsCount, MAX_SOCKETS_COUNT);
			
			if (socketsList)
			{
				var len:int = Math.min(socketsList.length, MAX_SOCKETS_COUNT);
				for (var i:int = 0; i < len; i++)
				{
					var curData:Object = socketsList[i];
					var curSocket:SlotPaperdoll = getChildByName("mcRuneSlot" + (i + 1)) as SlotPaperdoll;
					
					if (curSocket)
					{
						curSocket.visible = true;
						curSocket.enabled = true;
						curSocket.data = curData;
						curSocket.tfSlotName.text = curData.name;
						equippedRunesCount++;
					}
				}
				
				// hardcode position
				switch (equippedRunesCount)
				{
					case 1:
						//mcRuneSlot1.x = 240;
						break;
					case 2:
						//mcRuneSlot1.x = 94;
						//mcRuneSlot2.x = 384;
						break;
					case 3:
						//mcRuneSlot1.x = 30;
						//mcRuneSlot2.x = 240;
						//mcRuneSlot3.x = 447;
						break;
				}
			}
			else
			{
				trace("GFX [ItemSocketsInfo] Invalid sockets data");
			}
		}
		
	}
}
