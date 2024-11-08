/***********************************************************************
/** PANEL jurnal quest main cclass
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/
package  red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import red.core.constants.KeyCode;
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3DropDownList;
	import red.game.witcher3.controls.W3DropdownMenuListItem;
	import red.game.witcher3.events.CategoryChangeEvent;
	import red.game.witcher3.managers.InputFeedbackManager;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.constants.WrappingMode;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;

	public class DropdownListModuleBase extends CoreMenuModule
	{
		/********************************************************************************************************************
				ART CLIPS
		/ ******************************************************************************************************************/
		public var mcScrollBar 					: ScrollBar;
		public var mcDropDownList				: W3DropDownList;
		public var tfCurrentState				: TextField;
		public var mcDropDownMask				: MovieClip;

		/********************************************************************************************************************
				Variables
		/ ******************************************************************************************************************/
		protected var _dataBindingKey : String = "journal.quest.list";
		protected var _moduleDisplayName : String = "";

		protected var _itemInputFeedbackLabel:String;
		protected var _toggleInputFeedback:int = -1;
		protected var _itemInputFeedback:int = -1;
		protected var _selectModuleOnClick:Boolean = false;

        public var itemRenderer:String;
        public var _dropDownListClass:String = "DropDownList";
        public var _dropDownItemRendererClass:String = "DropDownListItem";
        public var _itemListClass:String= "W3ScrollingListNoBG";
        public var _itemRendererClass:String = "W3BaseListItem";
        public var menuName:String;
		public var currentDataArrayRef:Array;
		public var inputEnabled:Boolean = true;
		
		public var filterFunc:Function;
		public var sortFunc:Function;

		/********************************************************************************************************************
				Init
		/ ******************************************************************************************************************/
		public function DropdownListModuleBase()
		{
			super();
			dataBindingKey = _dataBindingKey;
		}

		override protected function configUI():void
		{
			super.configUI();

			//mouseEnabled = false;
			dispatchEvent( new GameEvent( GameEvent.REGISTER, _dataBindingKey + '.category', [updateCategoryData]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, _dataBindingKey + '.name', [handleModuleNameSet]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, _dataBindingKey, [handleListData]));

			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);

			//mcDropDownList.addEventListener( Event.SELECT, updateDescription, false, 0, true);
			if( !mcDropDownList )
			{
				CreateDropDownList();
			}

			if ( mcDropDownList)
			{
				mcDropDownList.activeSelectionEnabled = focused != 0;
				
				if (!mcDropDownList.mcMask )
				{
					mcDropDownList.setMask(mcDropDownMask);
				}

				mcDropDownList.focusable = false;
				mcDropDownList.menuName = menuName;
				//mcDropDownList.UpdateEmptyStateFeedback(true);
				_inputHandlers.push(mcDropDownList);
			}
		}

		/********************************************************************************************************************
				Class setters
		/ ******************************************************************************************************************/

		[Inspectable(type="String", defaultValue="DropDownList")]
        public function set DropDownListClass( value :String )
		{
			_dropDownListClass = value;

			if (!mcDropDownList)
			{
				CreateDropDownList();
			}
			else
			{
				mcDropDownList.addEventListener(ListEvent.INDEX_CHANGE, handleDropdownIndexChange, false, 0, true);
				mcDropDownList.addEventListener(CategoryChangeEvent.CATEGORY_CHANGED, handleDropdownCategoryChanged, false, 0, true);
			}
		}

		[Inspectable(type="String", defaultValue="")]
		public function get itemInputFeedbackLabel():String { return _itemInputFeedbackLabel };
		public function set itemInputFeedbackLabel(value:String):void
		{
			_itemInputFeedbackLabel = value;
		}
		
		public function get selectModuleOnClick():Boolean { return _selectModuleOnClick }
		public function set selectModuleOnClick(value:Boolean):void
		{
			_selectModuleOnClick = value;
		}

		protected function CreateDropDownList()
		{
			var classRef:Class = getDefinitionByName(_dropDownListClass) as Class;
			if (classRef != null) { mcDropDownList = new classRef() as W3DropDownList; }

			mcDropDownList.x = 62; // #B initial list placement
			mcDropDownList.y = 20; // #B initial list placement
			mcDropDownList.itemRenderer = getDefinitionByName(_dropDownItemRendererClass) as Class;
			mcDropDownList.enabled = true;
			mcDropDownList.wrapping = WrappingMode.WRAP;
			mcDropDownList.setMask(mcDropDownMask);
			mcDropDownList.scrollBar = mcScrollBar;
			mcDropDownList.menuName = menuName;

			mcDropDownList.dropdownMenuScrollingList = _itemListClass;
			mcDropDownList.dropdownMenuItemRenderer = _itemRendererClass;
			mcDropDownList.addEventListener(MouseEvent.CLICK, handleItemClick, false, 0, true);
			mcDropDownList.addEventListener(ListEvent.INDEX_CHANGE, handleDropdownIndexChange, false, 0, true);
			mcDropDownList.addEventListener(CategoryChangeEvent.CATEGORY_CHANGED, handleDropdownCategoryChanged, false, 0, true);
			addChild(mcDropDownList);
		}

		[Inspectable(type="String", defaultValue="DropDownListItem")]
		public function set DropDownItemRendererClass( value :String )
		{
			_dropDownItemRendererClass = value;
			//mcDropDownList.itemRenderer = getDefinitionByName(_dropDownItemRendererClass) as Class;
		}

		[Inspectable(type="String", defaultValue="W3ScrollingListNoBG")]
		public function set ItemListClass( value :String )
		{
			_itemListClass = value;
			mcDropDownList.dropdownMenuScrollingList = _itemListClass; //#B it could be a grid !!!
		}


		[Inspectable(type="String", defaultValue="W3BaseListItem")]
		public function set ItemRendererClass( value :String )
		{
			_itemRendererClass = value;
			mcDropDownList.dropdownMenuItemRenderer = _itemRendererClass;
		}

		[Inspectable(type="String", defaultValue="journal.quest.list")]
		public function set DataBindingKey( value :String )
		{
			_dataBindingKey = value;
		}

		/********************************************************************************************************************
				Data load
		/ ******************************************************************************************************************/

		public function updateCategoryData( gameData:Object ):void
		{
			validateItemItemFeedback();
			mcDropDownList.updateCategoryData(gameData);
			mcDropDownList.validateNow();
		}

		public function handleListData( gameData:Object, index:int ):void
		{
			trace("DROPDOWN " + this + " handleListData ");
			validateItemItemFeedback();
			if( index > -1 )
			{
				mcDropDownList.updateItemData(gameData);
				dispatchEvent(new Event(Event.CHANGE));
				return;
			}

			var l_sortedArray = gameData as Array;
			
			if (filterFunc != null)
			{
				l_sortedArray = filterFunc(l_sortedArray);
			}
			
			if( l_sortedArray && l_sortedArray.length > 0 )
			{
				if (sortFunc != null)
				{
					sortFunc(l_sortedArray);
				}
				else
				{
					sortData(l_sortedArray);
				}
				
				mcDropDownList.updateData(l_sortedArray);
				mcDropDownList.focused = focused;
				//mcDropDownList.selectedIndex = 0;
			}
			else
			{
				mcDropDownList.clearDataProvider();
			}
			
			currentDataArrayRef = l_sortedArray;
			
			mcDropDownList.activeSelectionEnabled = focused != 0;
			
			dispatchEvent(new Event(Event.CHANGE));
		}

		protected function sortData(targetArray:Array):void
		{
			targetArray.sortOn( "dropDownLabel");
			//targetArray.sortOn( "dropDownLabel", Array.CASEINSENSITIVE | Array.DESCENDING );
			//targetArray.sort( filterList );
		}

		protected function filterList( a, b ):int
		{
			var lastName	:RegExp = /\b\S+$/;
			var areaA = a.dropDownLabel.match(lastName);
			var areaB = b.dropDownLabel.match(lastName);

			if ( a.dropDownLabel != b.dropDownLabel )
			{
				if ( areaA < areaB )	return -1;
				if ( areaA > areaB )	return 1;
				return 0;
			}
			return 0;
		}

		protected function handleModuleNameSet(  name : String ):void
		{
			if (tfCurrentState)
			{
				_moduleDisplayName = name;
				tfCurrentState.htmlText = name;
			}
		}

		private var _initCategoryChange:Boolean = true; // #Y hack, dropdown events don't work properly
		protected function handleDropdownCategoryChanged(event:CategoryChangeEvent):void
		{
			if (!_initCategoryChange)
			{
				validateItemItemFeedback();
			}
			else
			{
				_initCategoryChange = false;
			}
		}
		
		protected function handleDropdownIndexChange(event:ListEvent):void
		{
			validateItemItemFeedback();
		}
		
		protected function canShowSubItemInputFeedback(curItem : W3DropdownMenuListItem ):Boolean
		{
			return true;
		}
		
		protected function handleItemClick(event:Event):void
		{
			trace("Minimap handleItemClick");
			if (selectModuleOnClick && focused < 1)
			{
				dispatchEvent(new Event(EVENT_MOUSE_FOCUSE));
			}
		}
		
		// to prevent multi call
		protected function validateItemItemFeedback():void
		{
			removeEventListener(Event.ENTER_FRAME, handleValidateItemItemFeedback, false);
			addEventListener(Event.ENTER_FRAME, handleValidateItemItemFeedback, false, 0, true);
		}
		
		protected function handleValidateItemItemFeedback(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, handleValidateItemItemFeedback, false);
			updateItemInputFeedback();
		}
		
		public function updateItemInputFeedback():void
		{
			var shouldShowItem:Boolean = false;
			var shouldShowToggle:Boolean = false;
			
			var curCategory:W3DropdownMenuListItem =  mcDropDownList.getRendererAt(mcDropDownList.selectedIndex) as W3DropdownMenuListItem;
			if (curCategory && curCategory.isOpen() && curCategory.IsSubListItemSelected())
			{
				shouldShowItem = _focused && visible && enabled && canShowSubItemInputFeedback(curCategory) && _itemInputFeedbackLabel;
			}
			shouldShowToggle = _focused && !shouldShowItem && curCategory && (!curCategory.isOpen() || !curCategory.IsSubListItemSelected());
			
			if (shouldShowItem && _itemInputFeedback < 0)
			{
				_itemInputFeedback = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, KeyCode.SPACE, _itemInputFeedbackLabel);
				InputFeedbackManager.updateButtons(this);
			}
			else if (!shouldShowItem && _itemInputFeedback >= 0)
			{
				InputFeedbackManager.removeButton(this, _itemInputFeedback);
				InputFeedbackManager.updateButtons(this);
				_itemInputFeedback = -1;
			}
			
			if (shouldShowToggle && _toggleInputFeedback < 0)
			{
				_toggleInputFeedback = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, KeyCode.SPACE, "panel_common_toggle_filters");
				InputFeedbackManager.updateButtons(this);
			}
			else if (!shouldShowToggle && _toggleInputFeedback >= 0)
			{
				InputFeedbackManager.removeButton(this, _toggleInputFeedback);
				InputFeedbackManager.updateButtons(this);
				_toggleInputFeedback = -1;
			}
		}

		override public function set focused(value:Number):void
		{
            if (value == _focused || !_focusable)
			{
				return;
			}

			super.focused = value;

			/*if ( mcDropDownList )
			{
				mcDropDownList.focused = value;
			}*/
			
			mcDropDownList.activeSelectionEnabled = focused != 0;

			var selectedRenderer:W3DropdownMenuListItem;
			if ( _focused )
			{
				SetAsActiveContainer(true);
			}
			else
			{
				SetAsActiveContainer(false);
			}
			
			if (mcDropDownList)
			{
				validateItemItemFeedback();
			}
		}

		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if (!mcDropDownList) return;
			
			validateItemItemFeedback();
		}

		public function SetAsActiveContainer( value : Boolean )
		{
			if (tfCurrentState)
			{
				tfCurrentState.htmlText = _moduleDisplayName;
			}
		}

		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled || !focused || !enabled || !visible || !inputEnabled)
			{
				return;
			}

			//trace("DROPDOWN _inputHandlers.length "+_inputHandlers.length);
			for each ( var handler:UIComponent in _inputHandlers )
			{
				handler.handleInput( event );

				if ( event.handled )
				{
					event.stopImmediatePropagation();
					return;
				}
			}
		}
	}

}
