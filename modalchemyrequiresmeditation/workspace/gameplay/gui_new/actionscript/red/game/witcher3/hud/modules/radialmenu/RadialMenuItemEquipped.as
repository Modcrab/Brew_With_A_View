package red.game.witcher3.hud.modules.radialmenu
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.Timer;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.utils.CommonUtils;
	
	/**
	 * red.game.witcher3.hud.modules.radialmenu.RadialMenuItemEquipped
	 * @author Getsevich Yaroslav
	 */
	public class RadialMenuItemEquipped extends RadialMenuItem
	{
		public static var enableAnimationFx:Boolean = false;
		
		public var mcItemCounter  : RadialMenuItemCounter;
		public var mcAmmoCounter  : MovieClip;
		public var mcEquipped	  : MovieClip;
		public var tfItemDescName : TextField;
		
		private var _subIndex	   : int;
		private var _subItemsCount : int;
		private var _subListViewer : RadialMenuSubItemView;
		private var _ammoTextField : TextField;
		private var _data 		   : Object;
		private var _isPocketData  : Boolean;
		
		// NGE
		private var _showChangeItemText  : Boolean;
		// NGE		
		
		private var _baseItemData  : Object;
		private var _alterItemData : Object;
		private var _subItemsList  : Array;
		
		public function RadialMenuItemEquipped()
		{
			//_glowFilter = new GlowFilter( OVER_GLOW_COLOR, OVER_GLOW_ALPHA, OVER_GLOW_BLUR, OVER_GLOW_BLUR, OVER_GLOW_STRENGHT, BitmapFilterQuality.HIGH );
			
			mcAmmoCounter.visible = false;
			tfItemDescName.visible = false;
			_ammoTextField = mcAmmoCounter.textField;
			
			bItemField = true;
		}
		
		public function get data():Object { return _data; }
		public function set data(value:Object):void
		{
			_data = value;
			
			updateData();
		}
		
		public function get subListViewer():RadialMenuSubItemView { return _subListViewer; }
		public function set subListViewer(value:RadialMenuSubItemView):void
		{
			_subListViewer = value;
			updateExternalViewer();
		}
		
		public function getCurrentGroupSlotName():String
		{
			if (_data)
			{
				return _data.slotName;
			}
			
			return "";
		}
		
		public function getCurrentSlotName():String
		{
			if (_isPocketData)
			{
				if (_baseItemData)
				{
					return _baseItemData.slotName;
				}
			}
			else
			if (_data)
			{
				return _data.slotName;
			}
			
			return "";
		}
		
		public function isCrossbow():Boolean
		{
			return !_isPocketData;
		}
		
		// NGE
		public function ShowChangeItemText():Boolean
		{
			return _showChangeItemText;
		}
		// NGE
		
		public function isSwitchable():Boolean
		{
			if (_isPocketData)
			{
				return _baseItemData && _alterItemData;
			}
			
			return _subItemsList && _subItemsList.length > 1;
		}
		
		protected function updateExternalViewer():void
		{
			if ( _subListViewer && _alterItemData && _isSelected )
			{
				if ( _isPocketData )
				{
					// #TMP ignoring for pockets
					// var inversedIdx:int = _subIndex == 1 ? inversedIdx = 2 : inversedIdx = 1;
					// _subListViewer.setData( _alterItemData.name, _alterItemData.itemIconPath, inversedIdx, _subItemsCount );
				}
				else
				if ( _alterItemData )
				{
					_subListViewer.setData( _alterItemData.name, _alterItemData.itemIconPath, _subIndex, _subItemsCount );
					
					if ( _alterItemData.hasOwnProperty( "id" ) )
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnEquipBolt', [ uint( _alterItemData.id ) ] ) );
					}
				}
			}
		}
		
		override public function SetSelected():void
		{
			super.SetSelected();
			
			//trace("GFX SetSelected ", _subListViewer, _alterItemData);
			
			updateExternalViewer();
		}
		
		override public function SetDeselected():void
		{
			super.SetDeselected();
			
			if ( _subListViewer )
			{
				_subListViewer.cleanup();
			}
		}
		
		public function nextSubItem():void
		{
			trace("GFX nextSubItem");
			
			if ( _subItemsCount < 1 )
			{
				return;
			}
			
			if ( _isPocketData )
			{
				// bombs, pockets
				
				swapPocketItems();
			}
			else
			{
				// crossbow
				
				if ( _subItemsList && _subItemsList.length > 1 )
				{
					if ( _subIndex < _subItemsCount )
					{
						_subIndex++;
					}
					else
					{
						_subIndex = 1;
					}
					
					_alterItemData = _subItemsList[ _subIndex - 1 ];
					
					if (_alterItemData)
					{
						_itemDescription = _alterItemData.description;
					}
					
					updateExternalViewer();
					updateAmmo( _alterItemData, true );
					
					if (_data)
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnActivateSlot', [ _data.slotName, true, true ] ) );  // NGE
						mcEquipped.visible = true;
					}
					
					dispatchEvent( new Event( Event.CHANGE, true ) );
				}
			}
		}
		
		public function priorSubItem():void
		{
			//trace("GFX priorSubItem");
			
			if ( _subItemsCount < 1 )
			{
				return;
			}
			
			if ( _isPocketData )
			{
				// bombs, pockets
				
				swapPocketItems();
			}
			else
			{
				// crossbow
				
				if ( _subItemsList && _subItemsList.length > 1 )
				{
					if ( _subIndex > 1 )
					{
						_subIndex--;
					}
					else
					{
						_subIndex = _subItemsCount;
					}
					
					_alterItemData = _subItemsList[ _subIndex - 1 ];
					
					if (_alterItemData)
					{
						_itemDescription = _alterItemData.description;
					}
					
					updateExternalViewer();
					updateAmmo( _alterItemData, true );
					
					if (_data)
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnActivateSlot', [ _data.slotName, true, true ] ) );  // NGE
						mcEquipped.visible = true;
					}
					
					dispatchEvent( new Event( Event.CHANGE, true ) );
				}
			}
		}
		
		private function swapPocketItems():void
		{
			if ( _alterItemData )
			{
				_subIndex = _subIndex == 1 ? 2 : 1;
				
				trace("GFX /swapPocketItems/ _subIndex -> ", _subIndex);
				
				var tmpBuf:Object = _alterItemData;
				
				_alterItemData = _baseItemData;
				_baseItemData = tmpBuf;
				
				setBaseDataFromObject( _baseItemData );
				
				/*
				var equipped:Boolean = ( _baseItemData && _baseItemData.isEquipped ) || ( _alterItemData && _alterItemData.isEquipped );
				
				if ( _alterItemData.isEquipped && !_baseItemData.isEquipped )
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnActivateSlot', [ _baseItemData.slotName ] ) );
				}
				*/ // AUTO SELECTION INSTEAD:
				
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnActivateSlot', [ _baseItemData.slotName, false, true ] ) );  // NGE
				mcEquipped.visible = true;
				
				//
				
				dispatchEvent( new Event( Event.CHANGE, true ) );
			}
		}
		
		
		public function ResetPetardData():void
		{
			cleanup();
			_baseItemData = null;
			_alterItemData = null;
			_subItemsList.Clear();
		}
		
		protected function updateData():void
		{
			trace("GFX [ITM] updateData");

			if ( !_data )
			{
				cleanup();
				return;
			}

			_isPocketData = _data.isPocketData;
			// NGE
			_showChangeItemText = _data.showChangeItemText;					
			// NGE		
			
			if (_isPocketData)
			{
				updatePocketData();
			}
			else
			{
				updateCrossbowData();
				mcEquipped.visible = _data && _data.isEquipped;
			}
			
			if (mcEquipped.visible)
			{
				mcEquipped.gotoAndPlay( 2 );				
			}
			
			enableAnimationFx = false;
		}
		
		protected function updatePocketData():void
		{
			
			//var er:Error = new Error();
			
			var itemsList : Array = _data.itemsList;
			var len : int = itemsList.length;
			
			
			trace("GFX updatePocketData --- ", len);
			
			_subItemsList = itemsList;
			
			if ( len < 1 )
			{
				// no items
				_subIndex = -1;
				_subItemsCount = -1;
				
				cleanup();
				
				return;
			}
			else
			if ( len < 2 )
			{
				// only one item
				
				_subIndex = 1;
				_subItemsCount = 1;
				
				trace("GFX / updatePocketData ( len < 2 ) / _subIndex -> ", _subIndex);
				
				_baseItemData = itemsList[0];
				_alterItemData = null;
			}
			else
			{
				// 2 items (or more, but only 2 items supported by now)
				
				_subIndex = 1;
				_subItemsCount = 2;
				
				trace("GFX /updatePocketData else/ _subIndex -> ", _subIndex);
				
				if ( itemsList[0].isEquipped )
				{
					_baseItemData = itemsList[0];
					_alterItemData = itemsList[1];
				}
				else
				{
					_baseItemData = itemsList[1];
					_alterItemData = itemsList[0];
				}
			}
			
			setBaseDataFromObject(_baseItemData);
			mcEquipped.visible = ( _baseItemData && _baseItemData.isEquipped ) || ( _alterItemData && _alterItemData.isEquipped );
		}
		
		protected function updateCrossbowData():void
		{
			_subItemsList = _data.itemsList;
			
			if (_subItemsList)
			{
				_subIndex = 1;
				_subItemsCount = _subItemsList.length;
				
				var actualList : Array = [];
				
				for ( var i:int = 0; i < _subItemsCount; i++ )
				{
					var curData : Object = _subItemsList[ i ];
					
					if ( curData.isEquipped )
					{
						_alterItemData = curData;
						_data.charges = _alterItemData.charges;
						
						if (_alterItemData)
						{
							_itemDescription = _alterItemData.description;
						}
						
						//actualList.unshift( curData );
						actualList.push( curData );
						_subIndex = i + 1;
					}
					else
					{
						actualList.push( curData );
					}
				}
				
				_subItemsList = actualList;
			}
			
			updateExternalViewer();
			setBaseDataFromObject( _data, true );
			
			mcItemCounter.visible = false;
			tfItemDescName.y = mcItemCounter.y - mcItemCounter.height/2;
		}
		
		protected function setBaseDataFromObject( obj : Object, isBolt:Boolean = false ) : void
		{
			trace("GFX ::setBaseDataFromObject: ", obj, isBolt);
			
			if (obj)
			{
				_iconPath = obj.itemIconPath;
				_itemName = obj.name;
				_itemCategory = obj.category;
				_itemDescription = obj.description;
				_radialName = obj.slotName;
				
				updateAmmo( obj, isBolt );
			}
			else
			{
				mcAmmoCounter.visible = false;
			}
			
			tfItemDescName.visible = true;
			tfItemDescName.htmlText = _itemName;
			tfItemDescName.height = tfItemDescName.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			
			mcItemCounter.value = _subIndex;
			mcItemCounter.maximum = _subItemsCount;
			
			loadIcon();
		}
		
		protected function updateAmmo( parentObj : Object, isBolt:Boolean = false ) : void
		{
			if ( !isNaN( parentObj.charges ) && ( parentObj.charges >= 0 || isBolt) )
			{
				mcAmmoCounter.visible = true;
				
				if (parentObj.charges >= 0)
				{
					_ammoTextField.text = parentObj.charges;
				}
				else if (isBolt)
				{
					_ammoTextField.text = "∞";
				}
				
				const RED_COLOR = 0xFF0000;
				const NORMAL_COLOR = 0xD0C8BF;
				
				if( parentObj.charges == 0 )
				{
					_ammoTextField.textColor = RED_COLOR;
				}
				else
				{
					_ammoTextField.textColor = NORMAL_COLOR;
				}
			}
			else
			{
				mcAmmoCounter.visible = false;
			}
		}
		
		protected function cleanup():void
		{
			_subItemsCount = 0;
			_subIndex = 0;
			
			_iconPath = "";
			_itemName = "";
			_itemCategory = "";
			_itemDescription = "";
			_radialName = "";
			
			mcAmmoCounter.visible = false;
			tfItemDescName.visible = false;
			mcEquipped.visible = false;
			mcItemCounter.visible = false;
			
			var curLoader : W3UILoader = mcIcon.mcLoader;
			
			if (curLoader)
			{
				curLoader.unload();
			}
		}
		
		protected var _cachedSourcePath:String;
		protected function loadIcon():void
		{
			if (mcIcon)
			{
				var curLoader:W3UILoader;
				
				if ( _itemCategory != "crossbow" )
				{
					mcIcon.gotoAndStop( "iconLoader" );
					curLoader = mcIcon.mcLoader;
				}
				else
				{
					mcIcon.gotoAndStop( "iconLoaderLarge" );
					curLoader = mcIcon.mcLoaderLarge;
				}
				
				curLoader.fallbackIconPath = "img://" + GetDefaultFallbackIconFromType(_itemCategory);
				
				var targetSource:String = "";
				
				if ( _iconPath != "" )
				{
					targetSource = "img://" + _iconPath;
				}
				else
				{
					targetSource = "";
				}
				
				if ( _cachedSourcePath != targetSource )
				{
					curLoader.source = targetSource;
					mcIcon.filters = [];
				}
				
				/*
				 *
				 * if (InputManager.getInstance().getPlatform()) ???
				 *
				curLoader.removeEventListener( IOErrorEvent.IO_ERROR, onImageLoaded );
				curLoader.removeEventListener( Event.COMPLETE, onImageLoaded );
				
				curLoader.addEventListener( IOErrorEvent.IO_ERROR, onImageLoaded, false, 0, true);
				curLoader.addEventListener( Event.COMPLETE, onImageLoaded, false, 0, true);
				*/
			}
		}
		
		private function onImageLoaded(event:Event):void
		{
			//var desFilter:ColorMatrixFilter = CommonUtils.getDesaturateFilter();
			//mcIcon.filters = [ _glowFilter ];
		}
		
		
	}

}
