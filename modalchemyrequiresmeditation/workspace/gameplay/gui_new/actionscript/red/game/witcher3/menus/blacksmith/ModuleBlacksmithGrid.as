package red.game.witcher3.menus.blacksmith
{
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.menus.common.ModuleCommonPlayerGrid;
	import red.game.witcher3.menus.inventory_menu.GridTabSections;
	import red.game.witcher3.menus.inventory_menu.ItemSectionData;
	import red.game.witcher3.menus.inventory_menu.ModulePlayerGrid;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotsListGrid;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.events.InputEvent;
	
	/**
	 * Grid for blacksmith menu
	 * @author Getsevich Yaroslav
	 */
	public class ModuleBlacksmithGrid extends ModuleCommonPlayerGrid
	{
		private const SECTION_BORDER_REF:String = "GridSegmentationRef";
		private const SECTION_BORDER_SIDE_PADDING:Number = 3;
		private const SECTION_BORDER_TOP_PADDING:Number = 9;
		
		public var mcSectionTitlesAnchor:MovieClip;
		
		protected var _sectionTitlesContainer:MovieClip;
		protected var _sectionTitlesList:Vector.<TextField> = new Vector.<TextField>;
		protected var _sectionBordersList:Vector.<MovieClip> = new Vector.<MovieClip>;
		protected var _itemSectionsList:GridTabSections;
		
		public function ModuleBlacksmithGrid()
		{
			super();
			dataBindingKey = "repair.grid.player";
			mcPlayerGrid.handleScrollBar = true;
			mcPlayerGrid.ignoreGridPosition = true;
			mcPlayerGrid.useContextMgr = false;
		}
		
		public function checkItemsCount():void
		{
			if (mcPlayerGrid.NumNonEmptyRenderers() > 0)
			{
				dispatchEvent(new Event(Event.ACTIVATE));
			}
			else
			{
				dispatchEvent(new Event(Event.DEACTIVATE));
			}
		}
		
		public function displaySection(curSectionsList:Array):void
		{
			var sectionPadding:Number = SlotsListGrid.SECTION_PADDING;
			var columnSize:Number = mcPlayerGrid.gridSquareSize;
			
			if (_sectionTitlesContainer)
			{
				while (_sectionTitlesList.length)
				{
					_sectionTitlesContainer.removeChild(_sectionTitlesList.pop());
				}
				
				while (_sectionBordersList.length)
				{
					var curBorder:MovieClip =  _sectionBordersList.pop();
					
					GTweener.removeTweens(curBorder);
					_sectionTitlesContainer.removeChild(curBorder);
				}
				
				removeChild(_sectionTitlesContainer);
				
				_sectionTitlesContainer = null;
			}
			
			if (curSectionsList && mcSectionTitlesAnchor)
			{
				var borderRef:Class = getDefinitionByName(SECTION_BORDER_REF) as Class;
				var len:int = curSectionsList.length;
				var curPosition:Number = 0;
				var gridPos:Point = this.localToGlobal( new Point(mcPlayerGrid.x, mcPlayerGrid.y) );
				
				_sectionTitlesContainer = new MovieClip();
				_sectionTitlesContainer.y = mcSectionTitlesAnchor.y;
				_sectionTitlesContainer.x = mcSectionTitlesAnchor.x - mcPlayerGrid.width / 2;
				
				addChild(_sectionTitlesContainer);
				_sectionTitlesContainer.mouseChildren = _sectionTitlesContainer.mouseEnabled = false;
				
				// for debug
				//_sectionTitlesContainer.graphics.clear();
				
				for (var i:int = 0; i < len; ++i)
				{
					var curSectionData:ItemSectionData = curSectionsList[i] as ItemSectionData;
					
					if (curSectionData)
					{
						var curBlockWidth:Number = (curSectionData.end - curSectionData.start + 1) * columnSize;
						
						if (curBlockWidth < 0)
						{
							throw new Error("Invalid grid sections structure. Check MenuInventory.as or InventoryTabbedListModule.as ;-)");
						}
						
						// Create text filed for title
						
						var curBlockMiddle:Number = curBlockWidth / 2;
						var newTextField:TextField = CommonUtils.spawnTextField(21);
						
						newTextField.text = curSectionData.label;
						CommonUtils.toSmallCaps(newTextField);
						
						newTextField.width = newTextField.textWidth + CommonConstants.SAFE_TEXT_PADDING;
						newTextField.x = curPosition + curBlockMiddle - newTextField.width / 2;
						
						_sectionTitlesContainer.addChild(newTextField);
						
						// create border
						
						var newBorder:MovieClip = new borderRef() as MovieClip;
						
						newBorder.x = curPosition - SECTION_BORDER_SIDE_PADDING;
						newBorder.y = -SECTION_BORDER_TOP_PADDING;
						newBorder.width = curBlockWidth + SECTION_BORDER_SIDE_PADDING * 2;
						_sectionTitlesContainer.addChild(newBorder);
						
						curSectionData.border = newBorder;
						newBorder.alpha = CommonConstants.BORDER_ALPHA_UNSELECTED;
						mcPlayerGrid.lastSelectedSection = -1;
						
						/*
						 * for debug
						 *
						var tmpEnd:Number = curPosition + curBlockWidth;
						
						_sectionTitlesContainer.graphics.beginFill(Math.random() * 0xFFFFFF, .3);
						_sectionTitlesContainer.graphics.moveTo(curPosition, 0);
						_sectionTitlesContainer.graphics.lineTo(tmpEnd, 0);
						_sectionTitlesContainer.graphics.lineTo(tmpEnd, 10);
						_sectionTitlesContainer.graphics.lineTo(curPosition, 10);
						_sectionTitlesContainer.graphics.endFill();
						*/
						/*
						_sectionTitlesContainer.graphics.lineStyle(1, 0xFF00000, 1);
						_sectionTitlesContainer.graphics.moveTo( tmpEnd / 2, -10 );
						_sectionTitlesContainer.graphics.lineTo( tmpEnd / 2, 10 );
						_sectionTitlesContainer.graphics.lineStyle(0, 0, 0);
						*/
						
						curPosition += (sectionPadding + curBlockWidth);
					}
				}
			}
			
		}
		
		override protected function configUI():void
		{
			super.configUI();
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
		}
		
		override protected function handleDataSet(gameData:Object, index:int):void
		{
			mcPlayerGrid.selectedIndex = -1;
			mcPlayerGrid.validateNow();
			mcPlayerGrid.clearRenderers();
			mcPlayerGrid.validateNow();
			
			if (gameData && (gameData as Array).length > 0)
			{
				super.handleDataSet(gameData, index);
				
				dispatchEvent(new Event(Event.ACTIVATE));
			}
			else
			{
				dispatchEvent(new Event(Event.DEACTIVATE));
			}
		}
		
		override public function handleInput(event:InputEvent):void
		{
			if (event.handled || !focused)
			{
				return;
			}
			if (!event.handled)
			{
				mcPlayerGrid.handleInputNavSimple(event);
			}
			super.handleInput(event);
		}
		
		override protected function handleModuleSelected():void
		{
			super.handleModuleSelected();
			if (mcPlayerGrid.selectedIndex < 0)
			{
				mcPlayerGrid.findSelection();
			}
		}
	}

}
