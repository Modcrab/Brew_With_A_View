/***********************************************************************
/** Paperdoll list
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
 * 				Getsevich Yarolsva
/***********************************************************************/

package red.game.witcher3.slots
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import red.game.witcher3.constants.InventorySlotType;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.interfaces.IInventorySlot;
	import red.game.witcher3.interfaces.IPaperdollSlot;
	import red.game.witcher3.menus.common.ItemDataStub;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;

	public class SlotsListPaperdoll extends SlotsListBase
	{
		protected var _slotTypeToIndexMap:Vector.<int>;
		protected var _equipSlotToIndexMap:Vector.<int>;

		override protected function configUI():void
		{
			super.configUI();
		}

		private function initializeSlots():void
		{
			_slotTypeToIndexMap = new Vector.<int>( InventorySlotType._COUNT, true ); // #B -1 due to hair
			_equipSlotToIndexMap = new Vector.<int>( InventorySlotType._COUNT, true );
			_slotTypeToIndexMap[ InventorySlotType.InvalidSlot ] = -1; // TBD: Could initialize the rest to -1 as well in case slots missing...
			var len:uint = _renderers.length;
			for ( var i:uint = 0; i < len; ++i )
			{
				var renderer:IPaperdollSlot = IPaperdollSlot( _renderers[i] );
				var slotType:int = IPaperdollSlot( renderer ).slotType;
				
				setupRenderer( renderer );
				renderer.index = i;
				
				_slotTypeToIndexMap[ slotType ] = i;
				_equipSlotToIndexMap[ renderer.equipID ] = i;
			}
		}

		/*
		 * 				- API -
		 */

		public function set slotList(value:Vector.<IBaseSlot>) { _renderers = value }

		[Inspectable(defaultValue = "")]
        public function set slotsInstanceName(value:String):void
		{
            if ( value == null || value == "" || parent == null )
			{
				throw new Error("Slot instance name is not defined");
			}

			var i:uint = 0;
			var newSlots:Vector.<IBaseSlot> = new Vector.<IBaseSlot>();
			while ( ++i )
			{
                var clip:IBaseSlot = parent.getChildByName( value + i ) as IBaseSlot;

				// No more in list. This allows renderers to start with 1 or 0
				if ( clip == null )
				{
                    if ( i == 0 )
					{
						continue;
					}
                    break;
                }
                newSlots.push( clip );
            }
            slotList = newSlots;
        }

		// Hmmm..
		public function hasItemInSlot( slotType : int ):Boolean
		{
			var renderer:IBaseSlot;
			var itemDataStub:ItemDataStub;

			if (IsQuickSlotBySlotType(slotType))
			{
				for ( var quickslotType:int = InventorySlotType.Quickslot1; quickslotType <= InventorySlotType.Quickslot2; ++quickslotType )
				{
					renderer = getRendererForSlotType( quickslotType );
					itemDataStub = renderer ? renderer.data as ItemDataStub : null;
					if ( Boolean( itemDataStub ) )
					{
						return true;
					}
				}
				return false;
			}

			renderer = getRendererForSlotType( slotType );
			itemDataStub = renderer ? renderer.data as ItemDataStub : null;
			return Boolean( itemDataStub );
		}

		public function getRendererForSlotType(slotType:int):IBaseSlot
		{
			return getRendererAt( getIndexForSlotType( slotType ) ) as IBaseSlot;
		}

		public function getIndexForSlotType( slotType : int ) : int
		{
			if ( _slotTypeToIndexMap.length > 0 )
			{
				if (_slotTypeToIndexMap[ slotType ] > -1)
				{
					return _slotTypeToIndexMap[ slotType ];
				}
				else
				{
					return -1;
				}
			}
			return - 1;
		}
		
		/*
		 * 						  - CORE -
		 */
		
		override public function updateItemData(itemData:Object):void
		{
			var targetDataStub:ItemDataStub = itemData as ItemDataStub;
			var taregetIndex:int = getDataIndex(targetDataStub);
			
			trace("GFX updateItemData ", targetDataStub.iconPath, "		<", targetDataStub.slotType, ">  ");
			
			if (!targetDataStub.groupId)
			{
				removeItem(targetDataStub.id);
			}
			else
			{
				removeGroupItem(targetDataStub.id, targetDataStub.groupId);
			}
			
			if (taregetIndex > -1)
			{
				var targetRenderer:IBaseSlot = _renderers[taregetIndex];

				targetRenderer.data = targetDataStub;
				
				var tipRenderer:SlotBase = targetRenderer as SlotBase;
				if (tipRenderer)
				{
					tipRenderer.showTooltip();
				}
			}
		}
		
		public function removeGroupItem(itemId:uint, groupId:int):void
		{
			var taregetIndex:int = getIdIndex(itemId, groupId);
			if (taregetIndex > -1)
			{
				var targetRenderer:IBaseSlot = _renderers[taregetIndex];
				targetRenderer.cleanup();
				
				var tipRenderer:SlotBase = targetRenderer as SlotBase;
				if (tipRenderer)
				{
					tipRenderer.showTooltip();
				}
			}
		}

		override public function removeItem(itemId:uint, keepSelectionIdx:Boolean = false):void
		{
			var taregetIndex:int = getIdIndex(itemId);
			if (taregetIndex > -1)
			{
				var targetRenderer:IBaseSlot = _renderers[taregetIndex];
				targetRenderer.cleanup();
				
				var tipRenderer:SlotBase = targetRenderer as SlotBase;
				if (tipRenderer)
				{
					tipRenderer.showTooltip();
				}
			}
		}

		override protected function populateData():void
		{
			super.populateData();
			if (!data) return;

			var indexUpdated:Array = new Array();
			var renderer:SlotPaperdoll;

			var renderersCount:int = _renderers.length;
			for (var i:int = 0; i < renderersCount; i++)
			{
				_renderers[i].cleanup();
			}

			initializeSlots();
			_renderersCount = _renderers.length;

			for each ( var itemDataStub:ItemDataStub in data )
			{
				var index:int = getDataIndex(itemDataStub);
				indexUpdated.push(index);
				renderer = getRendererAt( index ) as SlotPaperdoll;
				
				if (renderer.equipID != itemDataStub.equipped)
				{
					trace("GFX ---------------------- Making a huge matching mistake THERE BUDDY BOY! ---------------------", renderer.equipID, ", ", (itemDataStub as ItemDataStub).equipped );
				}
				else
				{
					if ( renderer )
					{
						//itemDataStub.gridSize = 2;
						renderer.data = itemDataStub;
					}
				}
			}
			
			if (selectedIndex == -1)
			{
				findSelection();
			}
		}

		override protected function getDataIndex(targetData:ItemDataStub):int
		{
			var slotId:int;
			var slotType:int = targetData.slotType;
			
			if (targetData.equipped)
			{
				return _equipSlotToIndexMap[targetData.equipped];
			}
			else
			{
				slotId = slotType;
			}
			return getIndexForSlotType( slotId );
		}
		
		override protected function setupRenderer( renderer:IBaseSlot ):void
		{
			var pdRenderer:IPaperdollSlot = renderer as IPaperdollSlot;
			
			if (pdRenderer)
			{
				pdRenderer.owner = this;
				pdRenderer.enabled = enabled;
				(pdRenderer.getHitArea() as MovieClip).addEventListener( MouseEvent.MOUSE_DOWN, handleItemClick, false, 0, true );
				(pdRenderer.getHitArea() as MovieClip).addEventListener( MouseEvent.MOUSE_UP, handleItemMouseUp, false, 0, true );
			}
        }

        override protected function cleanUpRenderer( renderer : IBaseSlot ) : void
		{
			var pdRenderer:IPaperdollSlot = renderer as IPaperdollSlot;
			
			if (pdRenderer)
			{
				pdRenderer.owner = null;
				(pdRenderer.getHitArea() as MovieClip).removeEventListener( MouseEvent.MOUSE_DOWN, handleItemClick );
				(pdRenderer.getHitArea() as MovieClip).removeEventListener( MouseEvent.MOUSE_UP, handleItemMouseUp );
			}
        }
		
		override protected function handleItemClick(event:MouseEvent) : void
		{
			super.handleItemClick(event);
		}
	
		protected function CheckIfNeedUpdate( updated : Array, index : int )
		{
			for ( var i : int = 0 ; i < updated.length; i++ )
			{
				if ( updated[i] == index )
				{
					updated.splice(i, 1);
					return false;
				}
			}
			return true;
		}

		/*
		 * 						- UNDERHOOD -
		 */

		 // Hmmm..
		private function IsQuickSlotBySlotType( slotType:uint ):Boolean
		{
			switch(slotType)
			{
				case InventorySlotType.Quickslot1:
				case InventorySlotType.Quickslot2:
					return true;
				default :
					return false;
			}
		}

		// Hmmm..
		private function IsPotionSlotBySlotType( slotType : uint ) : Boolean
		{
			switch(slotType)
			{
				case InventorySlotType.Potion1:
				case InventorySlotType.Potion2:
					return true;
				default :
					return false;
			}
		}

		// Hmmm..
		private function IsPetardSlotBySlotType( slotType : uint ) : Boolean
		{
			switch(slotType)
			{
				case InventorySlotType.Petard1:
				case InventorySlotType.Petard2:
					return true;
				default :
					return false;
			}
		}

		override public function toString():String
		{
			return "[SlotsListPaperdoll " + name + "]";
		}

	}

}
