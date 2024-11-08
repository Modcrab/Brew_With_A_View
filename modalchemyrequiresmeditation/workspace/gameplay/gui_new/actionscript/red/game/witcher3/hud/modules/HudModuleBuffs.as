package red.game.witcher3.hud.modules
{
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import red.core.CoreHudModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.hud.Hud;
	import scaleform.clik.interfaces.IListItemRenderer;
	
	import flash.display.MovieClip;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.controls.TileList;
	import scaleform.clik.controls.ListItemRenderer;
	import red.game.witcher3.utils.motion.TweenEx;
	import fl.transitions.easing.Strong;
	
	import red.game.witcher3.hud.modules.buffs.HudBuff;
	import red.game.witcher3.hud.modules.buffs.HudBuffDurationBar;
	import scaleform.clik.data.DataProvider;
	import red.game.witcher3.controls.W3ScrollingList;
	
	public class HudModuleBuffs extends HudModuleBase
	{
		/*
		public var mcBuffListItem1 : HudBuff;
		public var mcBuffListItem2 : HudBuff;
		public var mcBuffListItem3 : HudBuff;
		public var mcBuffListItem4 : HudBuff;
		public var mcBuffListItem5 : HudBuff;
		public var mcBuffListItem6 : HudBuff;
		public var mcBuffListItem7 : HudBuff;
		public var mcBuffListItem8 : HudBuff;
		public var mcBuffListItem9 : HudBuff;
		public var mcBuffListItem10 : HudBuff;
		public var mcBuffListItem11 : HudBuff;
		public var mcBuffListItem12 : HudBuff;
		*/
		
		protected static const MINIM_CELL_HEIGHT:int = 50;
		protected static const MINIM_CELL_WIDTH:int = 50;
		protected static const MAXIM_CELL_HEIGHT:int = 150;
		protected static const MAXIM_CELL_WIDTH:int = 130;
		
		protected static const MINIM_NUM_COLUMNS :int = 6;
		protected static const MINIM_NUM_ROWS :int = 4;
		protected static const MAXIM_NUM_COLUMNS :int = 4;
		protected static const MAXIM_NUM_ROWS :int = 6;
		
		public var mcMinimViewAnchor: MovieClip;
		public var mcMaximViewAnchor: MovieClip;
		private var itemListVector : Vector.<IListItemRenderer>;
		
		public var minimViewMode	: Boolean;
		public var mcBuffsList : W3ScrollingList;//HudBuffsTileList;

		public function HudModuleBuffs()
		{
			super();
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function get moduleName():String
		{
			return "BuffsModule";
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function configUI():void
		{
			super.configUI();
			
			minimViewMode = true;
			mcMinimViewAnchor.visible = false;
			mcMaximViewAnchor.visible = false;
			itemListVector = new Vector.<IListItemRenderer>;
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
			registerDataBinding('hud.buffs', handleDataSet);
			
			createBuffGrid(MINIM_NUM_COLUMNS, MINIM_NUM_ROWS , MINIM_CELL_HEIGHT, MINIM_CELL_WIDTH, mcMinimViewAnchor);
		}
		
		public function setViewMode( value : Boolean ) : void
		{
			minimViewMode = value;
			updateViewMode();
		}
		public function updateViewMode()
		{
			
				var buffCount : int = mcBuffsList.dataProvider.length;
				var buff : HudBuff;
				var i: int;
				
				if (buffCount > 0 )
				{
					for ( i = 0; i <= buffCount; i++)
					{
						buff = mcBuffsList.getRendererAt( i ) as HudBuff;
						if (buff)
						{
							buff.setMinimalView( minimViewMode );
						}
						
					}
				}
				
				if ( minimViewMode )
				{
					repositionGrid( MINIM_NUM_COLUMNS , MINIM_NUM_ROWS , MINIM_CELL_HEIGHT ,  MINIM_CELL_WIDTH , minimViewMode );
				}
				else
				{
					repositionGrid( MAXIM_NUM_COLUMNS , MAXIM_NUM_ROWS , MAXIM_CELL_HEIGHT , MAXIM_CELL_WIDTH , minimViewMode );
				}
			
		}
		
		public function createBuffGrid(numColumns: Number , numRows:Number, cellHeight: Number, cellWidth: Number , anchor: MovieClip ) : void
		{
			var col : Number = 0;
			var row : Number = 0;
			var index:uint = 1;
			var nrOfItems:int = 16;
			var b:HudBuff;
			
			while ( itemListVector.length )
			{
				removeChild( itemListVector.pop() );
			}
			
			for (var i:int = 0;  i < nrOfItems; i++)
			{
				var ItemClass:Class = getDefinitionByName("BuffItemRendererRef") as Class;
				b = new ItemClass() as HudBuff;
				b.x = anchor.x + (col * cellWidth );
				b.y = anchor.y + (row * cellHeight );
				//b.name = "mcBuffListItem" + index;
				//index ++;
				
				addChild(b);
				itemListVector.push(b);
				
				if (col >= numColumns)
				{
					col = 0;
					row++;
				}
				else
				{
					col++;
				}
			}
			
			mcBuffsList.itemRendererList = itemListVector;
		}
		
		public function repositionGrid(numColumns: Number , numRows:Number, cellHeight: Number, cellWidth: Number , minViewMode : Boolean  ) : void
		{
				var col : Number;
				var row : Number;
				var index:uint = 0;
				var b:HudBuff;
				var anchor : MovieClip = minViewMode ?  mcMinimViewAnchor : mcMaximViewAnchor;
				
				for ( row = 0; row < numRows; row++)
				{	
					for ( col = 0 ; col < numColumns; col++ )
					{				
						b = mcBuffsList.getRendererAt( index ) as HudBuff;
						if (b)
						{
							b.x = anchor.x + (col * cellWidth );
							b.y = anchor.y + (row * cellHeight );
							index++;
						}
						
					}
			}
			
		}
		
		public function setPercent(buffId : int , value:Number, maxValue:Number, extraValue : int ) : void
		{
			var currentBuff : HudBuff;
			currentBuff = HudBuff(mcBuffsList.getRendererAt(buffId));
			currentBuff.updatePercent(maxValue > 0.0 ? value / maxValue : 0.0);
			if ( currentBuff.getFormat() == 1 || currentBuff.getFormat() == 2 )
			{
				currentBuff.updateCounter( value, maxValue );
			}
			else if ( currentBuff.getFormat() == 3 )
			{
				currentBuff.updateTimer(int(value), int(maxValue) );
			}
			else if ( currentBuff.getFormat() == 4 )
			{
				currentBuff.updateTimerAndCounter( int(value), int(maxValue), extraValue );
			}
			else
			{
				currentBuff.updateEmpty();
			}
		}
		
		public function showBuffUpdateFx():void
		{
			var renderlist:Vector.<IListItemRenderer> = mcBuffsList.getRenderers();
			var l:int = renderlist.length;
			
			for (var i:int = 0 ; i < l; i++ )
			{
				var currentRenderer : HudBuff = renderlist[i] as HudBuff;
				
				if (currentRenderer)
				{
					var currentData : Object = currentRenderer.data;					
					
					if (currentData && currentData.IsPotion)
					{
						currentRenderer.mcBuffUpdate.gotoAndPlay("start");
					}
				}
			
			}
			
		}
		
		
				
		protected function handleDataSet( gameData:Object, index:int ):void
		{
			var dataArray:Array = gameData as Array;
			if ( index > 0 )
			{
				//@FIXME BIDON update only one index here
				if (gameData)
				{
					mcBuffsList.dataProvider = new DataProvider( dataArray );
					mcBuffsList.ShowRenderers(true);
				}
			}
			else if (gameData)
			{
				mcBuffsList.dataProvider = new DataProvider( dataArray );
				mcBuffsList.ShowRenderers(true);
				updateViewMode();
				mcBuffsList.validateNow();
			}
		}
		

		override public function ShowElementFromState( bShow : Boolean, bImmediately : Boolean = false ):void
		{
			super.ShowElementFromState( bShow , bImmediately );
			dispatchEvent(new GameEvent(GameEvent.CALL, 'OnBuffsDisplay', [bShow]));
		}
	
	}
}
