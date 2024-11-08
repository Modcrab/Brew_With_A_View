package red.game.witcher3.menus.worldmap
{
	import com.gskinner.motion.GTweener;
	import flash.events.Event;
	import scaleform.clik.core.UIComponent;
	import flash.display.MovieClip;
	import flash.geom.Point;

	public class HubMapContainer extends UIComponent
	{
		public var mcLodContainer                : LodContainer;
		public var mcGradientContainer           : MovieClip;
		public var mcHubMapContainerLodMask      : MovieClip;
		public var mcHubMapContainerGradientMask : MovieClip;

		private var _visibleAreaGlobalLeftBottom	: Point;
		private var _visibleAreaGlobalRightTop		: Point;

		private var _visibleAreaLocalLeftBottom		: Point;
		private var _visibleAreaLocalRightTop		: Point;
			
		private var _mapVisMinX			: int;
		private var _mapVisMaxX			: int;
		private var _mapVisMinY			: int;
		private var _mapVisMaxY			: int;

		private var _mapScrollMinX		: int;
		private var _mapScrollMaxX		: int;
		private var _mapScrollMinY		: int;
		private var _mapScrollMaxY		: int;
		
		private var _gradientScale		: Number;

		public function GetCurrentLod() : int
		{
			return mcLodContainer.GetCurrentLod();
		}
		
		public function GetMapTextureSize() : int
		{
			return mcLodContainer.GetCurrentContainer().GetMapTextureSize();
		}
		
		public function SetMapVisibilityBoundaries( minX : int, maxX : int, minY : int, maxY : int, gradientScale : Number )
		{
			_mapVisMinX = minX;
			_mapVisMaxX = maxX;
			_mapVisMinY = minY;
			_mapVisMaxY = maxY;
			_gradientScale = gradientScale;
			//
			//trace("Minimap VIS COORDS " + _mapVisMinX + " " + _mapVisMaxX + "   " + _mapVisMinY + " " + _mapVisMaxY );
			//
			UpdateGradient();
		}

		public function SetMapScrollingBoundaries( minX : int, maxX : int, minY : int, maxY : int )
		{
			_mapScrollMinX = minX;
			_mapScrollMaxX = maxX;
			_mapScrollMinY = minY;
			_mapScrollMaxY = maxY;

			//
			//trace("Minimap SCR COORDS " + _mapScrollMinX + " " + _mapScrollMaxX + "   " + _mapScrollMinY + " " + _mapScrollMaxY );
			//
		}

		public function SetMapSettings( textureSize : int, minLod : int, maxLod : int, mapImagePath : String, visibleArea : MovieClip )
		{
			mcLodContainer.CreateLods( textureSize, minLod, maxLod, mapImagePath, _mapVisMinX, _mapVisMaxX, _mapVisMinY, _mapVisMaxY );
			
			_visibleAreaGlobalLeftBottom = new Point( visibleArea.x - visibleArea.width / 2, visibleArea.y + visibleArea.height / 2 );
			_visibleAreaGlobalRightTop   = new Point( visibleArea.x + visibleArea.width / 2, visibleArea.y - visibleArea.height / 2 );
		}
		
		public function UpdateGradient()
		{
			var GRADIENT_SHIFT : int = 1;
			
			mcGradientContainer.mcGradientLeft.x   =  _mapVisMinX - GRADIENT_SHIFT;
			mcGradientContainer.mcGradientRight.x  =  _mapVisMaxX + GRADIENT_SHIFT;
			mcGradientContainer.mcGradientTop.y    = -_mapVisMaxY - GRADIENT_SHIFT;
			mcGradientContainer.mcGradientBottom.y = -_mapVisMinY + GRADIENT_SHIFT;

			mcGradientContainer.mcGradientLeft.scaleX   = _gradientScale;
			mcGradientContainer.mcGradientRight.scaleX  = _gradientScale;
			mcGradientContainer.mcGradientTop.scaleY    = _gradientScale;
			mcGradientContainer.mcGradientBottom.scaleY = _gradientScale;
			
			mcHubMapContainerLodMask.x      = _mapVisMinX;
			mcHubMapContainerLodMask.y      = -_mapVisMaxY;
			mcHubMapContainerLodMask.width  = Math.abs( _mapVisMinX - _mapVisMaxX );
			mcHubMapContainerLodMask.height = Math.abs( _mapVisMinY - _mapVisMaxY );
			
			// gradient map needs to be a bit bigger to avoid artifacts
			mcHubMapContainerGradientMask.x      = mcHubMapContainerLodMask.x - 1;
			mcHubMapContainerGradientMask.y      = mcHubMapContainerLodMask.y - 1;
			mcHubMapContainerGradientMask.width  = mcHubMapContainerLodMask.width + 2;
			mcHubMapContainerGradientMask.height = mcHubMapContainerLodMask.height + 2;
		}

		public function UpdateVisibileArea()
		{
			_visibleAreaLocalLeftBottom  = globalToLocal( _visibleAreaGlobalLeftBottom );
			_visibleAreaLocalRightTop    = globalToLocal( _visibleAreaGlobalRightTop );
			
			//
			//trace("Minimap ---------------------------------------------------" );
			//trace("Minimap CENTER         [" + mapCenter.x      + " " + mapCenter.y      + "]" );
			//trace("Minimap LEFT TOP       [" + _mapLeftBottom.x + " " + _mapLeftBottom.y + "]" );
			//trace("Minimap RIGHT BOTTOM   [" + _mapRightTop.x   + " " + _mapRightTop.y   + "]" );
			//
		}
		
		public function GetVisibleAreaLocalLeftBottomPos() : Point
		{
			return _visibleAreaLocalLeftBottom;
		}

		public function GetVisibleAreaLocalRightTopPos() : Point
		{
			return _visibleAreaLocalRightTop;
		}

		public function UpdateDebugBorders()
		{
			mcLodContainer.UpdateDebugBorders();
		}

		//const SOFT_SCROLL_LIMIT:Number = 5;
		//const SPEED_COEFF:Number = 0.01;
		public function scrollMap( dx : Number, dy : Number, softTransition:Boolean = false )
		{
			var targetX:Number = x + dx;
			var targetY:Number = y + dy;
			
			// restrict to move crosshair map
			targetX = GetRestrictedX( targetX );
			targetY = GetRestrictedY( targetY );
			
			x = targetX;
			y = targetY;
			
			//
			// DEBUG INFO
			//
			//MapMenu.m_debugInfo.__DebugInfo_SetScroll( x, -y );
			//var ptx : int = mcLodContainer.GetCurrentContainer().GetBoundaryX(  _visibleAreaLocalCenter.x );
			//var pty : int = mcLodContainer.GetCurrentContainer().GetBoundaryY( -_visibleAreaLocalCenter.y );
			//MapMenu.m_debugInfo.__DebugInfo_SetPointedTile( ptx, pty );
			//
			// DEBUG INFO END
			//
			
			ShowTilesFromCurrentLod();
			
			/*
			 * Test feature for soft transition
			 * 
			trace("GFX scrollMap, ", softTransition, (dx + dy));
			var posDef:Number = Math.sqrt(dx * dx + dy * dy);
			if (softTransition && posDef > SOFT_SCROLL_LIMIT )
			{
				var speed:Number = posDef * SPEED_COEFF;
				trace("GFX * speed ", speed, "posDef", posDef);
				GTweener.removeTweens(this);
				GTweener.to(this, speed, { x:targetX, y:targetY } );
			}
			else
			{
				x = targetX;
				y = targetY;
			}
			*/
		}
		
		public function setImmediatePosition( posX : Number, posY : Number )
		{
			x = GetRestrictedX( posX );
			y = GetRestrictedY( posY );
		}
		
		private function GetRestrictedX( targetX : Number ) : Number
		{
			if ( targetX > -_mapScrollMinX )
			{
				return -_mapScrollMinX;
			}
			else if ( targetX < -_mapScrollMaxX )
			{
				return -_mapScrollMaxX;
			}
			return targetX;
		}

		private function GetRestrictedY( targetY : Number ) : Number
		{
			if ( targetY > _mapScrollMaxY )
			{
				return _mapScrollMaxY;
			}
			else if ( targetY < _mapScrollMinY )
			{
				return _mapScrollMinY;
			}
			return targetY;
		}
		
		public function IncreaseLod()
		{
			var maxLod : int = mcLodContainer.GetMaxLod();
			var currLod : int = mcLodContainer.GetCurrentLod();
			
			if ( currLod < maxLod )
			{
				currLod++;
				SwitchToLod( currLod, true );
			}
		}

		public function DecreaseLod()
		{
			var minLod : int = mcLodContainer.GetMinLod();
			var currLod : int = mcLodContainer.GetCurrentLod();
			
			if ( currLod > minLod )
			{
				currLod--;
				SwitchToLod( currLod, true );
			}
		}
		
		public function SwitchToLod( newLod : int, updateTextures : Boolean )
		{
			var minLod : int = mcLodContainer.GetMinLod();
			var maxLod : int = mcLodContainer.GetMaxLod();

			//
			//trace("Minimap @@@@@@@@@@@@@@@@@@@@@@@@ SwitchToLod " + newLod);
			//

			mcLodContainer.SetCurrentLod( newLod, true );

			if ( updateTextures )
			{
				for ( var lod = minLod; lod <= maxLod; ++lod )
				{
					if ( lod == newLod )
					{
						ShowTiles( lod );
					}
					else
					{
						HideTiles( lod );
					}
				}
			}
			
			//
			// DEBUG INFO
			//
			//MapMenu.m_debugInfo.__DebugInfo_SetCurrentLod( newLod );
		}
		
		public function ShowTilesFromCurrentLod()
		{
			//
			//trace("Minimap @@@@@@@@@@@@@@@@@@@@@@@@ ShowTilesFromCurrentLod");
			//
			ShowTiles( mcLodContainer.GetCurrentLod() );
		}

		public function ShowTiles( lod : int )
		{
			//
			//trace("Minimap @@@@@@@@@@@@@@@@@@@@@@@@ ShowTiles " + lod );
			//
			var container : ImageContainer = mcLodContainer.GetContainer( lod );
			if ( container )
			{
				container.UpdateTiles( /*globalCenter*/ null, _visibleAreaLocalLeftBottom, _visibleAreaLocalRightTop );
			}
		}
		
		public function HideTiles( lod : int )
		{
			var container : ImageContainer = mcLodContainer.GetContainer( lod );
			if ( container )
			{
				container.RequestHideTiles();
			}
		}

		public function HideAllTiles()
		{
			var minLod     : int = mcLodContainer.GetMinLod();
			var maxLod     : int = mcLodContainer.GetMaxLod();
			var container : ImageContainer;
			
			for ( var lod = minLod; lod <= maxLod; ++lod )
			{
				container = mcLodContainer.GetContainer( lod );
				if ( container )
				{
					container.HideTiles();
				}
			}
		}

		public function ProcessHidingTiles( interval : int )
		{
			var minLod     : int = mcLodContainer.GetMinLod();
			var maxLod     : int = mcLodContainer.GetMaxLod();
			var currentLod : int = mcLodContainer.GetCurrentLod();

			for ( var lod = minLod; lod <= maxLod; ++lod )
			{
				if ( lod != currentLod )
				{
					var container : ImageContainer = mcLodContainer.GetContainer( lod );
					if ( container )
					{
						container.ProcessHidingTiles( interval );
					}
				}
			}
		}
	}
	
}
