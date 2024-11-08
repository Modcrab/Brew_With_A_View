package red.game.witcher3.menus.character_menu
{
	import com.gskinner.motion.easing.Linear;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotSkillSocket;
	import red.game.witcher3.slots.SlotsListPreset;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ListEvent;
	
	/**
	 * red.game.witcher3.menus.character_menu.MutationItemsList
	 * TODO: Use SlotsListSkills.as ???
	 * @author Getsevich Yaroslav
	 */
	public class MutationItemsList extends SlotsListPreset
	{
		protected const TWEEN_DISTANCE = 20;
		protected var _connectionsCanvas : Sprite;
		protected var _dependenciesGraph : Dictionary;
		
		override protected function configUI():void
		{
			super.configUI();
			
			_connectionsCanvas = new Sprite();
			parent.addChildAt( _connectionsCanvas, 0 );
		}
		
		public function updateSingleMutation(targetData:Object):void
		{
			var targetRenderer:MutationItemRenderer = getRendererById(targetData.mutationId);
			
			//trace("GFX MutationItemsList :: updateSingleMutation ", targetRenderer);
			
			if (targetRenderer)
			{
				targetRenderer.data	= targetData;
				targetRenderer.validateNow();
			}
		}
		
		override public function set selectedIndex(value:int):void
		{
			super.selectedIndex = value;
			
			// TODO:
		}
		
		override protected function populateData():void
		{
			if (!_data)
			{
				return;
			}
			
			var listLen:int = _data.length;
			
			for (var i:int = 0; i < listLen; i++ )
			{
				var targetData:Object = _data[i];
				var targetRenderer:MutationItemRenderer = getRendererById(targetData.mutationId);
				
				if (targetRenderer)
				{
					targetData.gridSize = 1;
					targetRenderer.data	= targetData;
					targetRenderer.draggingEnabled = false;
				}
			}
			
			//buildDependenciesGraph();
			//updateConnectors( _dependenciesGraph );
			//updateConnectors();
		}
		
		public function setResearchMode( value : Boolean, researchTarget : MutationItemRenderer = null ):void
		{
			var len:int = _renderers.length;
			var curRenderer:MutationItemRenderer;
			
			for (var i:int = 0; i < len; i++)
			{
				curRenderer = _renderers[i] as MutationItemRenderer;
				
				if (curRenderer )
				{
					if ( value && ( curRenderer != researchTarget ) )
					{
						curRenderer.alpha =  .1;
						curRenderer.blocked = true;
					}
					else
					{
						curRenderer.alpha =  1;
						curRenderer.blocked = false;
					}
				}
			}
			
			_connectionsCanvas.alpha = value ? .1 : 1;
		}
		
		
		protected function buildDependenciesGraph():void
		{
			if (!_data)
			{
				return;
			}
			
			_dependenciesGraph = new Dictionary(true);
			
			var dataCount : int = _data.length;
			
			for ( var i : int = 0; i < dataCount; i++ )
			{
				var curMutData 		   : Object = _data[i];
				var curMutRequirements : Array = curMutData.requiredMutations as Array;
				
				if ( curMutRequirements && curMutRequirements.length )
				{
					var reqCount     : int = curMutRequirements.length;
					var dependedNode : MutationItemRenderer = getRendererById( curMutData.mutationId );
					
					if ( dependedNode )
					{
						var requirementNodes : Array = [];
						
						_dependenciesGraph[ dependedNode ] = requirementNodes;
						
						for ( var j : int = 0; j < reqCount; j++ )
						{
							var curReqData : Object = curMutRequirements[ j ];
							var curReqNode : MutationItemRenderer = getRendererById( curReqData.type );
							
							if ( curReqNode )
							{
								requirementNodes.push( curReqNode );
							}
						}
						
					}
				}
			}
		}
		
		protected function updateConnectors( deps : Dictionary ) : void
		{
			if (!deps)
			{
				return;
			}
			
			const mut_radius  : Number = 66.5;
			
			_connectionsCanvas.graphics.clear();
			_connectionsCanvas.graphics.lineStyle( 2, 0xFFFFFF, .5 );
			
			for ( var obj : Object in deps )
			{
				var curNode : MutationItemRenderer = obj as MutationItemRenderer;
				
				if ( curNode )
				{
					var listRequarements : Array = deps[curNode] as Array;
					
					if ( listRequarements )
					{
						for (var i:int = 0; i < listRequarements.length; i++ )
						{
							var curReqNode : MutationItemRenderer = listRequarements[ i ] as MutationItemRenderer;
							
							if ( curReqNode )
							{
								var dx:Number = curNode.x - curReqNode.x;
								var dy:Number = curNode.y - curReqNode.y;
								var angle:Number = Math.atan2(dy, dx);
								
								_connectionsCanvas.graphics.moveTo( curNode.x - mut_radius * Math.cos( angle ), curNode.y - mut_radius * Math.sin( angle ) );
								_connectionsCanvas.graphics.lineTo( curReqNode.x + mut_radius * Math.cos( angle ), curReqNode.y + mut_radius * Math.sin( angle ) );
							}
						}
					}
				}
				
			}
		}
		
		/*
		protected function updateConnectors():void
		{
			
			var ConClass:Class = getDefinitionByName( "MutationConnectorRef" ) as Class;
			const mut_padding : Number = 12;
			
			
			const mut_radius  : Number = 66.5;
			
			if (!_data)
			{
				return;
			}
			
			var listLen:int = _data.length;
			
			_connectionsCanvas.graphics.clear();
			_connectionsCanvas.graphics.lineStyle( 2, 0xFFFFFF, .5 );
			
			for ( var i : int = 0; i < listLen; i++ )
			{
				var curData : Object = _data[i];
				var deps    : Array = curData.requiredMutations as Array;
				
				if ( deps && deps.length )
				{
					var depCount : int = deps.length;
					var sourcRdr : MutationItemRenderer = getRendererById( curData.mutationId );
					
					if (sourcRdr)
					{
						for ( var j : int = 0; j < depCount; j++ )
						{
							var curDep : Object = deps[j];
							var depRdr : MutationItemRenderer = getRendererById( curDep.type );
							
							if ( depRdr )
							{
								var dx:Number = sourcRdr.x - depRdr.x;
								var dy:Number = sourcRdr.y - depRdr.y;
								var angle:Number = Math.atan2(dy, dx);
								
								_connectionsCanvas.graphics.moveTo( sourcRdr.x - mut_radius * Math.cos( angle ), sourcRdr.y - mut_radius * Math.sin( angle ) );
								_connectionsCanvas.graphics.lineTo( depRdr.x + mut_radius * Math.cos( angle ), depRdr.y + mut_radius * Math.sin( angle ) );
								
								
								var itm:MovieClip = new ConClass() as MovieClip;
								
								_connectionsCanvas.addChild( itm );
								
								itm.x = sourcRdr.x - ( mut_radius - mut_padding ) * Math.cos( angle );
								itm.y = sourcRdr.y - ( mut_radius - mut_padding ) * Math.sin( angle );
								
								var dlen : Number = Point.distance( new Point( itm.x, itm.y ), new Point( depRdr.x, depRdr.y ) );
								
								itm["part1"].gotoAndStop( MutationItemRenderer.getColorById( sourcRdr.data.mutationId ) );
								itm["part2"].gotoAndStop( MutationItemRenderer.getColorById( depRdr.data.mutationId ) );
								
								itm.rotation = angle / Math.PI * 180 + 180;
								
								itm.width = dlen - mut_radius - mut_padding;
								
								
							}
						}
					}
					
				}
			}
		}
		*/
		
		protected function getRendererById(mutationId:int):MutationItemRenderer
		{
			var len:int = _renderers.length;
			var curRenderer:MutationItemRenderer;
			
			for (var i:int = 0; i < len; i++)
			{
				curRenderer = _renderers[i] as MutationItemRenderer;
				
				if (curRenderer && curRenderer.mutationId == mutationId)
				{
					return curRenderer;
				}
			}
			
			return null;
		}
		
		override protected function setupRenderer( renderer : IBaseSlot ):void
		{
			super.setupRenderer( renderer );
			
			renderer.addEventListener( MouseEvent.DOUBLE_CLICK, handleItemDoubleClick, false, 0, true );
        }
		
		protected function handleItemDoubleClick( event : MouseEvent ):void
		{
			var targetRenderer:MutationItemRenderer = event.currentTarget as MutationItemRenderer;
			
			if (!targetRenderer && event.currentTarget && event.currentTarget.parent)
			{
				// event from a child
				targetRenderer = event.currentTarget.parent as MutationItemRenderer;
			}
			
			if (targetRenderer)
			{
				var clickEvent:ListEvent = new ListEvent(ListEvent.ITEM_DOUBLE_CLICK, true);
				
				clickEvent.itemData = targetRenderer.data as Object;
				clickEvent.index = targetRenderer.index;
				clickEvent.itemRenderer = targetRenderer;
				
				dispatchEvent(clickEvent);
			}
		}
		
		override protected function rendererNameSorter(element1:IBaseSlot, element2:IBaseSlot):Number
		{
			var uiComponent1:MutationItemRenderer = element1 as MutationItemRenderer;
			var uiComponent2:MutationItemRenderer = element2 as MutationItemRenderer;
			
			return (uiComponent1.slotNavigationId < uiComponent2.slotNavigationId) ? -1 : 1;
		}
		
		// TMP COPY-PASTE
		override protected function initRenderers():void
		{
			var targetContainer:DisplayObjectContainer = _internalRenderers ? this : this.parent;
			var childrenCount:int = targetContainer.numChildren;
			
			_renderersCount = 0;
			
			while (_renderers.length)
			{
				cleanUpRenderer(_renderers.pop());
			}
			
			for (var i:int = 0; i < childrenCount; i++ )
			{
				var curRenderer:SlotBase = targetContainer.getChildAt(i) as SlotBase;
				
				if ( curRenderer && curRenderer && curRenderer.name.indexOf( _slotRenderer ) > -1 )
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
			
			// hack to restore proper indexes
			_renderers.forEach( function( t : SlotBase, index : int, vector : Vector.<IBaseSlot> ) { t.index = _renderers.indexOf( t ) } );
		
		}
		
	}

}



/*
	var itm:MovieClip = new ConClass() as MovieClip;
	
	_connectionsCanvas.addChild( itm );
	
	itm.x = sourcRdr.x - ( mut_radius - mut_padding ) * Math.cos( angle );
	itm.y = sourcRdr.y - ( mut_radius - mut_padding ) * Math.sin( angle );
	
	var dlen : Number = Point.distance( new Point( itm.x, itm.y ), new Point( depRdr.x, depRdr.y ) );
	
	itm["part1"].gotoAndStop( MutationItemRenderer.getColorById( sourcRdr.data.mutationId ) );
	itm["part2"].gotoAndStop( MutationItemRenderer.getColorById( depRdr.data.mutationId ) );
	
	itm.rotation = angle / Math.PI * 180 + 180;
	
	itm.width = dlen - mut_radius - mut_padding;
	*/
