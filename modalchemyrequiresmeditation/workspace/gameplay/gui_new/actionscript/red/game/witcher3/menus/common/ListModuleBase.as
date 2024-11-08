/***********************************************************************
/** PANEL jurnal quest main cclass
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/
package  red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.controls.W3DropdownMenuListItem;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;

	public class ListModuleBase extends CoreMenuModule
	{
		/********************************************************************************************************************
				ART CLIPS
		/ ******************************************************************************************************************/
		public var textField 					: TextField;
		public var mcScrollBar 					: ScrollBar;
		public var mcList						: W3ScrollingList;
		public var tfCurrentState				: TextField;
		public var mcMask						: MovieClip;
		public var mcEmptyListFeedback			: MovieClip;

		public var mcListItem1					: BaseListItem;
		public var mcListItem2					: BaseListItem;
		public var mcListItem3					: BaseListItem;
		public var mcListItem4					: BaseListItem;
		public var mcListItem5					: BaseListItem;
		public var mcListItem6					: BaseListItem;
		public var mcListItem7					: BaseListItem;
		public var mcListItem8					: BaseListItem;

		/********************************************************************************************************************
				Variables
		/ ******************************************************************************************************************/
		protected var _dataBindingKey : String = "journal.quest.list";
		protected var _moduleDisplayName : String = "";

		protected var _itemInputFeedbackLabel:String;
		protected var _itemInputFeedback:int = -1;
		protected var _toggleInputFeedback:int = -1;
		protected var _itemButtonShown:Boolean;
		protected var _toggleButtonShown:Boolean;

        public var itemRenderer:String;
        public var _itemListClass:String= "W3ScrollingListNoBG";
        public var _itemRendererClass:String = "IconListItem";
        public var menuName:String;
		public var _listWidth					: Number = 1200;
		public var _listHeight 					: Number = 600;
		public var _movieIsPlaying				: Boolean = false;

		/********************************************************************************************************************
				Init
		/ ******************************************************************************************************************/
		public function ListModuleBase()
		{
			super();
			dataBindingKey = _dataBindingKey;
		}

		override protected function configUI():void
		{
			super.configUI();

			dispatchEvent( new GameEvent( GameEvent.REGISTER, _dataBindingKey + '.name', [handleModuleNameSet]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, _dataBindingKey, [handleListData]));

			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);

			if ( mcList)
			{
				if (!mcList.mask )
				{
					mcList.mask = mcMask;
				}

				_inputHandlers.push(mcList);
				mcList.addEventListener(ListEvent.INDEX_CHANGE, handleIndexChange, false, 0, true);
				mcList.addEventListener(ListEvent.ITEM_CLICK, handleClick, false, 0, true);
			}
			UpdateEmptyStateFeedback(true);
		}

		/********************************************************************************************************************
				Class setters
		/ ******************************************************************************************************************/

		[Inspectable(type="String", defaultValue="")]
		public function get itemInputFeedbackLabel():String { return _itemInputFeedbackLabel };
		public function set itemInputFeedbackLabel(value:String):void
		{
			_itemInputFeedbackLabel = value;
		}

		[Inspectable(type="String", defaultValue="W3ScrollingListNoBG")]
		public function set ItemListClass( value :String )
		{
			_itemListClass = value;
		}

		[Inspectable(type="String", defaultValue="IconListItem")]
		public function set ItemRendererClass( value :String )
		{
			_itemRendererClass = value;
		}

		[Inspectable(type="String", defaultValue="journal.quest.list")]
		public function set DataBindingKey( value :String )
		{
			_dataBindingKey = value;
		}

		[Inspectable(defaultValue = 200)]
		public function get listWidth( ) : Number
		{
			return _listWidth;
		}
		public function set listWidth( value : Number ) : void
		{
			_listWidth = value;
		}

		[Inspectable(defaultValue = 843)] 
		public function get listHeight( ) : Number
		{
			return _listHeight;
		}
		public function set listHeight( value : Number ) : void
		{
			_listHeight = value;
		}

		/********************************************************************************************************************
				Data load
		/ ******************************************************************************************************************/
		public function handleListData( gameData:Object, index:int ):void
		{
			var dataList:Array = gameData as Array;

			if ( mcList )
			{
				if ( dataList.length > 0 )
				{
					mcList.dataProvider = new DataProvider(dataList);
					mcList.validateNow();
					mcList.focused = 1;
					UpdateEmptyStateFeedback(false);
					if ( mcList.selectedIndex == -1 )
					{
						mcList.selectedIndex = 0;
					}
				}
			}
		}

		protected function handleModuleNameSet(  name : String ):void
		{
			if (tfCurrentState)
			{
				_moduleDisplayName = name;
				tfCurrentState.htmlText = name;
			}
		}

		protected function handleIndexChange(event:ListEvent):void
		{
			var currentRenderer:BaseListItem = mcList.getRendererAt(mcList.selectedIndex) as BaseListItem;
			if ((!currentRenderer && (event.index == -1)) || !enabled)
			{
				hideItemInputFeedback();
				return;
			}
			if (currentRenderer)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnEntrySelected', [currentRenderer.data.tag] ) );
				showItemInputFeedback();
			}
		}

		private function handleClick( event:ListEvent = null ):void
		{
			var currentRenderer:BaseListItem = event.itemRenderer as BaseListItem;
			if ((!currentRenderer && (event.index == -1)) || !enabled || _movieIsPlaying )
			{
				return;
			}
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnEntryPress', [currentRenderer.data.tag] ) );
			SetMovieIsPlaying(true);
		}

		public function SetMovieIsPlaying( value : Boolean )
		{
			_movieIsPlaying = value;
			if ( value )
			{
				mcList.removeEventListener(ListEvent.ITEM_CLICK, handleClick);
				mcList.focused = 0;
			}
			else
			{
				mcList.addEventListener(ListEvent.ITEM_CLICK, handleClick, false, 0, true);
				mcList.focused = 1;
			}
		}

		public function GetMovieIsPlaying() : Boolean
		{
			return _movieIsPlaying;
		}

		protected function showItemInputFeedback():void
		{
			if (visible && enabled)
			{
				if (_itemInputFeedbackLabel && _itemInputFeedback < 0)
				{
					_itemInputFeedback = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, KeyCode.ENTER, _itemInputFeedbackLabel);
					InputFeedbackManager.updateButtons(this);
					_itemButtonShown = true;
				}
			}
		}

		protected function hideItemInputFeedback():void
		{
			if (_itemInputFeedback > 0)
			{
				InputFeedbackManager.removeButton(this, _itemInputFeedback);
				InputFeedbackManager.updateButtons(this);
				_itemInputFeedback = -1;
				_itemButtonShown = false;
			}
		}

		override public function set focused(value:Number):void
		{
            if (value == _focused || !_focusable)
			{
				return;
			}

			super.focused = value;

			var selectedRenderer:W3DropdownMenuListItem;
			if ( _focused )
			{
				SetAsActiveContainer(true);

				if (_itemButtonShown) showItemInputFeedback();
			}
			else
			{
				SetAsActiveContainer(false);
				if (_itemInputFeedback > 0)
				{
					hideItemInputFeedback();
					_itemButtonShown = true;
				}
			}
		}

		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if (!mcList) return;

			if (visible)
			{
				if (_itemButtonShown) showItemInputFeedback();
			}
			else
			{
				if (_itemInputFeedback > 0)
				{
					hideItemInputFeedback();
					_itemButtonShown = true;
				}
			}
		}

		protected function CreateMask()
		{
			if ( mcMask )
			{
				mcMask.width = listWidth;
				mcMask.height = listHeight;
			}
		}

		public function UpdateEmptyStateFeedback( value : Boolean )
		{

			if (textField)
			{
				textField.visible = value;
				if (value)
				{
					textField.htmlText = GetPanelEmptyStateFeedbackDescription();
					textField.htmlText = CommonUtils.toUpperCaseSafe(textField.htmlText);
				}
			}

			if (mcEmptyListFeedback)
			{
				mcEmptyListFeedback.visible = value;
				if ( value && mcEmptyListFeedback.mcIcon && menuName)
				{
					mcEmptyListFeedback.mcIcon.gotoAndStop(menuName);
				}
			}
		}

		protected function GetPanelEmptyStateFeedbackDescription() : String
		{
			return "[[panel_menu_empty_list_" + (menuName ? menuName.toLowerCase() : "") + "]]";
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
			if ( event.handled || !focused || !enabled || !visible || _movieIsPlaying)
			{
				return;
			}

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
