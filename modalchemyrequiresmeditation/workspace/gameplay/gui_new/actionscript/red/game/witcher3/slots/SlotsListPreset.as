package red.game.witcher3.slots
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import red.game.witcher3.interfaces.IBaseSlot;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * red.game.witcher3.slots.SlotsListPreset
	 * List control for slots placed on stage (paperdoll, skills)
	 * @author Getsevich Yaroslav
	 */
	public class SlotsListPreset extends SlotsListBase
	{
		protected var _rendererClassName:String;
		protected var _rendererClass:Class;
		protected var _internalRenderers:Boolean;
		
		public var sortData:Boolean = false;

		[Inspectable(defaultValue = "false")]
		public function get internalRenderers():Boolean { return _internalRenderers }
		public function set internalRenderers(value:Boolean):void
		{
			_internalRenderers = value;
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			initRenderers();
			selectedIndex = 0;
		}
		
		override protected function populateData():void
		{
			//trace("GFX SlotsListPreset :: populateData ", data);
			//trace("GFX **  _renderers.length", _renderers.length);
			
			cleanupRenderers();
			
			var i:int;
			
			for (i = 0; i < data.length && i < _renderers.length; ++i)
			{
				_renderers[i].data = data[i];
				_renderers[i].validateNow();
			}
			
			// #J this loop continues previous to cleanup any renderers past the data index
			for (; i < _renderers.length; ++i)
			{
				_renderers[i].data = null;
			}
			
			super.populateData();
			
			findSelection();
		}
		
		protected function cleanupRenderers():void
		{
			var renderersCount:int = _renderers.length;
			for (var i:int = 0; i < renderersCount; i++)
			{
				_renderers[i].cleanup();
			}
		}
		
		protected function getSlotsContainer():DisplayObjectContainer
		{
			return _internalRenderers ? this : this.parent;
		}
		
		protected function initRenderers():void
		{
			var targetContainer:DisplayObjectContainer = getSlotsContainer();
			
			if (!targetContainer)
			{
				trace("GFX {WARNING} missing slots container for ", this);
				return;
			}
			
			var childrenCount:int = targetContainer.numChildren;
			var rendererClasRef:Class;
			
			//trace("GFX * ----------------------------------------------------");
			//trace("GFX * initRenderers ",  childrenCount, _slotRenderer);
			
			if (_slotRenderer)
			{
				rendererClasRef = getDefinitionByName(_slotRenderer) as Class;
			}
			
			_renderersCount = 0;
			
			while (_renderers.length) cleanUpRenderer(_renderers.pop())
			
			for (var i:int = 0; i < childrenCount; i++ )
			{
				var curRenderer:IBaseSlot = targetContainer.getChildAt(i) as IBaseSlot;
				var isClassCorrected:Boolean = !_slotRenderer || (  ( curRenderer is rendererClasRef ) || ( getQualifiedClassName(curRenderer) == _slotRenderer ) )
				
				if ( curRenderer && isClassCorrected )
				{
					_renderers.push(curRenderer);
					curRenderer.index = _renderersCount;
					setupRenderer(curRenderer);
					_renderersCount++;
				}
			}
			
			if (sortData)
			{
				_renderers.sort(rendererNameSorter);
			}
			
			/*
			trace("GFX --- renderers after sort:");
			for (var j:int = 0; j < _renderers.length; j++)
			{
				trace("GFX [", j, "] ", _renderers[j]);
			}
			*/
			
			// hack to restore proper indexes
			_renderers.forEach( function( t : SlotBase, index : int, vector : Vector.<IBaseSlot> ) {t.index = _renderers.indexOf(t); }, null );
			
		}
		
		
		
		protected function rendererNameSorter(element1:IBaseSlot, element2:IBaseSlot):Number
		{
			var uiComponent1:UIComponent = element1 as UIComponent;
			var uiComponent2:UIComponent = element2 as UIComponent;
			
			return (uiComponent1.name < uiComponent2.name) ? -1 : 1;
		}
	}

}
