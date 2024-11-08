package red.game.witcher3.menus.character_menu
{
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotsListBase;
	
	public class CharacterSkillSlotsList extends SlotsListBase
	{
		private var _widthPadding:int = 0;
		private var _heightPadding:int = 0;
		
		private var _numRows = 0;
		
		private var _dataByColumns:Array = new Array();
		private var _columnNames:Array = new Array();
		
		[Inspectable(defaultValue = "true")]
		public function get widthPadding():int { return _widthPadding }
		public function set widthPadding(value:int):void
		{
			_widthPadding = value;
		}
		
		[Inspectable(defaultValue = "true")]
		public function get heightPadding():int { return _heightPadding }
		public function set heightPadding(value:int):void
		{
			_heightPadding = value;
		}
		
		override protected function configUI():void
		{
			super.configUI();
		}
		
		override public function get numColumns():uint
		{
			return _dataByColumns.length;
		}
		
		override public function get numRows():uint
		{
			return _numRows;
		}
		
		override public function getColumn( index : int ) : int
		{
			if ( index < 0 )
			{
				return -1;
			}
			return index % (numColumns - 1);
		}
			
		override public function getRow( index : int ) : int
		{
			if ( index < 0 )
			{
				return -1;
			}
			return Math.abs(index / numColumns);
		}
		
		public function getSkillWithType(skillType:int):SlotBase
		{
			var renderersCount:int = _renderers.length;
			for (var i:int = 0; i < renderersCount; ++i)
			{
				var targetRenderer:SlotBase = _renderers[i] as SlotBase;
				if (targetRenderer && targetRenderer.data && targetRenderer.data.skillType == skillType)
				{
					return targetRenderer;
				}
			}
			
			return null;
		}
		
		override protected function populateData():void
		{
			organizeData();
			
			trace("GFX - done organizing data with ", _columnNames.length, " columns");
			for (var i:int = 0; i < _dataByColumns.length; ++i)
			{
				trace("GFX - Column: ", i, " has: ", _dataByColumns[i].length, " rows and name: ", _columnNames[i]);
				
				if (i > 4)
				{
					trace("GFX - SPECIAL!!!!", _dataByColumns[i][0].id);
				}
			}
			
			setupRenderers();
		}
		
		private function organizeData():void
		{
			var data_index:int;
			var name_it:int;
			var currentColumnName:String;
			var curColumnIndex:int;
			
			_dataByColumns.length = 0;
			_columnNames.length = 0;
			_numRows = 0;
			
			for (data_index = 0; data_index < _data.length; ++data_index)
			{
				currentColumnName = _data[data_index].skillSubPath;
				
				// figure out which column it currently fits in
				curColumnIndex = -1;
				for (name_it = 0; name_it < _columnNames.length; ++name_it)
				{
					if (_columnNames[name_it] == currentColumnName)
					{
						curColumnIndex = name_it;
						break;
					}
				}
				
				// NEW COLUMN!
				if (curColumnIndex == -1)
				{
					_columnNames.push(currentColumnName);
					_dataByColumns.push(new Array(_data[data_index]));
					
					if (_numRows < 1)
					{
						_numRows = 1;
					}
				}
				else
				{
					_dataByColumns[curColumnIndex].push(_data[data_index]);
					
					if (_dataByColumns[curColumnIndex].length > _numRows)
					{
						_numRows = _dataByColumns[curColumnIndex].length;
					}
				}
			}
			
			// Sort the data arrays by requiredPoints spent so the things first unlocked are at the top ;)
			for (curColumnIndex = 0; curColumnIndex < _dataByColumns.length; ++curColumnIndex)
			{
				_dataByColumns[curColumnIndex].sort( sortDataByRequiredPoints );
			}
		}
		
		protected function sortDataByRequiredPoints( a, b ):int
		{
			if (!a.isCoreSkill && b.isCoreSkill)
			{
				return 1;
			}
			else if (a.isCoreSkill && !b.isCoreSkill)
			{
				return -1;
			}
			
			if ((int)(a.requiredPointsSpent) > int(b.requiredPointsSpent))
			{
				return 1;
			}
			else if (int(a.requiredPointsSpent) < int(b.requiredPointsSpent))
			{
				return -1;
			}
			
			return 0;
		}
		
		private function setupRenderers():void
		{
			// Step 1, make sure we have the right number of renderers
			adjustRendererCount();
			
			// Step 2, position all the renderers
			positionRenderers();
			
			// Step 3, make sure all the renderers have the right data
			updateRendererData();
			
			selectedIndex = 0;
		}
		
		private function adjustRendererCount():void
		{
			var numRenderers:int = _numRows * _columnNames.length;
			if (numRenderers < 0)
			{
				throw new Error("GFX - adjusting renderer count to an invalid value: " + numRenderers);
			}
			
			while (_renderers.length != numRenderers)
			{
				if (_renderers.length > numRenderers)
				{
					var curRdr:SlotBase = _renderers.pop() as SlotBase;
					if (curRdr)
					{
						curRdr.cleanup();
						_canvas.removeChild(curRdr as DisplayObject);
					}
					else
					{
						throw new Error("GFX - trying to remove a slotRenderer of invalid type. Will NOT be properly removed!");
					}
				}
				else if (_renderers.length < numRenderers)
				{
					var newRenderer:SlotBase = new _slotRendererRef() as SlotBase;
					
					if (newRenderer)
					{
						setupRenderer(newRenderer);
						_canvas.addChild(newRenderer);
						newRenderer.index = _renderers.length; // OMEGA
						_renderers.push(newRenderer); // << Super important to call !AFTER! line tagged OMEGA for proper indexes
					}
					else
					{
						throw new Error("GFX - unsupported _slotRendererRef() used: " + _slotRendererRef);
					}
				}
				else
				{
					throw new Error("GFX - something has gone horribly wrong!");
				}
			}
			
			_renderersCount = _renderers.length;
		}
		
		private function positionRenderers():void
		{
			var rendererIdx:int;
			var curCol:int = 0;
			var curRow:int = 0;
			var currentRenderer:SlotBase;
			
			for (rendererIdx = 0; rendererIdx < _renderers.length; ++rendererIdx)
			{
				currentRenderer = _renderers[rendererIdx] as SlotBase;
				curCol = rendererIdx % _columnNames.length;
				curRow = Math.floor(rendererIdx / _columnNames.length);
				currentRenderer.x = curCol * _widthPadding;
				currentRenderer.y = curRow * _heightPadding;
			}
		}
		
		private function updateRendererData():void
		{
			var rendererIdx:int;
			var curCol:int = 0;
			var curRow:int = 0;
			var currentRenderer:SlotBase;
			
			// TEST, REMOVE US before submitting
			var numVisible:int = 0;
			var numHidden:int = 0;
			// END TEST
			
			if (data && data.length && data[0].perkPosition)
			{
				//
				// hotfix for perks positioning
				//
				
				for (rendererIdx = 0; rendererIdx < _renderers.length; ++rendererIdx)
				{
					currentRenderer = _renderers[rendererIdx] as SlotBase;
					currentRenderer.enabled = false;
					currentRenderer.visible = false
				}
				
				var sortedData:Array = data;
				
				sortedData.sortOn("perkPosition", Array.NUMERIC);
				
				for (var dataIdx = 0; dataIdx < sortedData.length; ++dataIdx)
				{
					var curData : Object = sortedData[ dataIdx ];
					
					currentRenderer = _renderers[ dataIdx ] as SlotBase;
					currentRenderer.setData( curData );
					currentRenderer.validateNow();
					currentRenderer.enabled = true;
					currentRenderer.visible = true;
				}
			}
			else
			{
				for (rendererIdx = 0; rendererIdx < _renderers.length; ++rendererIdx)
				{
					currentRenderer = _renderers[rendererIdx] as SlotBase;
					curCol = rendererIdx % _columnNames.length;
					curRow = Math.floor(rendererIdx / _columnNames.length);
					
					if (_dataByColumns[curCol].length > curRow)
					{
						currentRenderer.enabled = true;
						currentRenderer.visible = true;
						//currentRenderer.data = _dataByColumns[curCol][curRow];
						
						currentRenderer.setData(_dataByColumns[curCol][curRow]);
						currentRenderer.validateNow();
						++numVisible; // ----------------
					}
					else
					{
						currentRenderer.enabled = false;
						currentRenderer.visible = false
						++numHidden; // ------------------
					}
				}
			}
			
			trace("GFX - Updated renderer data with (", numVisible, " visible) renderers and (", numHidden, " hidden) renderers");
		}
	}
}
