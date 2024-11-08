package red.game.witcher3.menus.character_menu
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import red.core.constants.KeyCode;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.hud.states.OnDemandState;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.slots.SlotsListPreset;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.ui.InputDetails;
	
	/**
	 * red.game.witcher3.menus.character_menu.MutationResourcesList
	 * @author Getsevich Yaroslav
	 */
	public class MutationResourcesList extends UIComponent
	{
		const TWEEN_DURATION = .2;
		const RENDERER_CLASS_REF = "MutationProgressItemRendererRef";
		
		private var _scrollingList  : W3ScrollingList;
		private var _renderersList  : Vector.<IListItemRenderer>;
		private var _positionsCache : Object;
		private var _data           : Array;
		private var _activated      : Boolean;
		private var _selectedItem   : MutationProgressItemRenderer;
		
		function MutationResourcesList()
		{
			_renderersList = new Vector.<IListItemRenderer>;
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			_scrollingList = new W3ScrollingList();
			_scrollingList.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, handleItemDoubleClick, false, 0, true);
			_scrollingList.addEventListener(ListEvent.INDEX_CHANGE, handleItemIndexChanged, false, 0, true);
			_scrollingList.UpAction = KeyCode.LEFT;
			_scrollingList.DownAction = KeyCode.RIGHT;
			_scrollingList.selectOnOver = true;
			
			addChild(_scrollingList);
		}
		
		public function get data():Array { return _data; }
		public function set data(value:Array):void
		{
			_data = [];
			
			for each (var dataItem:Object in value)
			{
				if (dataItem.required > 0)
				{
					_data.push(CommonUtils.replicateDataObject(dataItem));
				}
			}
		}
		
		public function updateMutationResearch(newData:Object):void
		{
			var count:int = _renderersList.length;
		
			for (var i:int = 0; i < count; i++ )
			{
				var curItem:MutationProgressItemRenderer = _renderersList[i] as MutationProgressItemRenderer;
				var curData:Object = curItem.data;
				
				if (curData.type == newData.type)
				{
					curItem.setData(newData);
					curItem.validateNow();
				}
			}
		}
		
		public function activate():void
		{
			trace("GFX activate res list", _data);
			
			_scrollingList.selectedIndex = -1;
			
			createRenderers();
			
			if (_data)
			{
				_scrollingList.itemRendererList = _renderersList;
				_scrollingList.dataProvider = new DataProvider(_data);
				_scrollingList.validateNow();
				
				tweenRenderers(true, handleRenderersShown);
			}
		}
		
		public function deactiavate():void
		{
			tweenRenderers(false, handleRenderersHidden);
		}
		
		// --- UNDERHOOD
		
		private function createRenderers():void
		{
			if (_data)
			{
				var dataCount:int = _data.length;
				
				cleanup();
				
				for (var i:int = 0; i < dataCount; i++)
				{
					_renderersList.push( spawnRenderer( data[i] ) as MutationProgressItemRenderer );
				}
			}
		}
		
		private function tweenRenderers( show:Boolean = true, callback : Function = null ):void
		{
			trace("GFX tweenRenderers ", show, callback );
			
			var count:int = _renderersList.length;
			var callbackSet:Boolean = false;
			
			if (show)
			{
				_positionsCache = getPositionsList(count);
			}
			
			trace("GFX tweens count ", count);
			
			for (var i:int = 0; i < count; i++ )
			{
				var curRenderer:MutationProgressItemRenderer = _renderersList[i] as MutationProgressItemRenderer;
				var props:Object = { ease:Exponential.easeOut };
				var targetLocation:Object;
				
				if (!show)
				{
					targetLocation = { x: 0, y: 0 };
				}
				else
				{
					var posCache:Object = _positionsCache[i];
					
					if (posCache)
					{
						targetLocation = { x: posCache.x, y: posCache.y };
					}
				}
				
				if (!callbackSet && callback != null)
				{
					props.onComplete = callback;
					callbackSet = true;
				}
				
				trace("GFX move ", curRenderer, " to ", targetLocation.x, targetLocation.y);
				
				GTweener.removeTweens(curRenderer);
				GTweener.to(curRenderer, TWEEN_DURATION, targetLocation, props );
			}
		}
	
		private function handleRenderersShown(tw:GTween = null):void
		{
			_scrollingList.selectedIndex = 0;
			_scrollingList.focusable = false;
			_scrollingList.bSkipFocusCheck = true;
			
			dispatchEvent( new Event( Event.ACTIVATE ) );
		}
		
		private function handleRenderersHidden(tw:GTween = null):void
		{
			cleanup();
			dispatchEvent( new Event( Event.DEACTIVATE ) );
		}
		
		private function cleanup():void
		{
			while (_renderersList.length) removeChild( _renderersList.pop() );
			
			trace("GFX /cleanup/ _renderersList ", _renderersList.length);
		}
		
		private function spawnRenderer(data:Object):MutationProgressItemRenderer
		{
			var newRendereClass : Class = getDefinitionByName( RENDERER_CLASS_REF ) as Class;
			var newRenedere : MutationProgressItemRenderer  = new newRendereClass() as MutationProgressItemRenderer;
			
			var radValue:Number = newRenedere.mcHitArea.width / 2;
			
			addChild( newRenedere );
			newRenedere.preventAutosizing = true;
			newRenedere.constraintsDisabled = true;
			newRenedere.setData(data);
			newRenedere.validateNow();
			
			newRenedere.x = - radValue;
			newRenedere.y = - radValue;
			
			return newRenedere;
		}
		
		// --- event handlers
		
		private function handleItemDoubleClick(event:ListEvent):void
		{
			// _selectedItem = event.itemRenderer as MutationProgressItemRenderer;
			// dispatchEvent(event);
		}
		
		private function handleItemIndexChanged(event:ListEvent):void
		{
			_selectedItem = event.itemRenderer as MutationProgressItemRenderer;
			dispatchEvent(event);
		}
		
		override public function handleInput(event:InputEvent):void
		{
			super.handleInput(event);
			_scrollingList.handleInput(event);
		}
		
		//  --- utils
		
		private function getPositionsList(itemsCount:int):Array
		{
			var result:Array = [];
			
			switch( itemsCount )
			{
				case 1:
					result.push( { x: -38, y : 70 } );
					break;
				case 2:
					result.push( { x: -82, y: 70 } );
					result.push( { x: 6,   y: 70 } );
					break;
				case 3:
					result.push( { x: -140, y: 40 } );
					result.push( { x: -34,  y: 75 } );
					result.push( { x: 70,   y: 54 } );
					break;
				case 4:
					result.push( { x: -160, y: 40 } );
					result.push( { x: -80,  y: 70 } );
					result.push( { x: 5,    y: 70 } );
					result.push( { x: 85,   y: 40 } );
					break;
			}
			
			return result;
		}
		
	}
}

