/***********************************************************************
/** Used for minimap
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/***********************************************************************/

package red.game.witcher3.hud.modules.minimap2
{	
	import flash.display.MovieClip;
	import flash.geom.Vector3D;
	import flash.geom.Point;
	import flash.display.Graphics;
	import red.game.witcher3.hud.modules.HudModuleMinimap2;
		
	public class MapPath extends MovieClip
	{
		private var _globalX : Number;
		private var _globalY : Number;
		private var _color : int;
		private var _lineWidth : Number;
		private var _controlPoints : Vector.<Vector3D >;
		private var _splinePoints : Vector.<Vector3D >;
		
		private const _defaultLineWidth : Number = 0.25;
		
		public function AddControlPoint( pointX : Number, pointY : Number )
		{
			if ( !_controlPoints )
			{
				_controlPoints = new Vector.< Vector3D >();
			}
			_controlPoints[ _controlPoints.length ] = new Vector3D( pointX, pointY, 0, 0 );
		}
		
		public function AddSplinePoint( pointX : Number, pointY : Number )
		{
			if ( !_splinePoints )
			{
				_splinePoints = new Vector.< Vector3D >();
			}
			_splinePoints[ _splinePoints.length ] = new Vector3D( pointX, pointY, 0, 0 );
		}

		public function SetupCurve( globalX : Number, globalY : Number, color : int, lineWidth : Number )
		{
			_globalX   = globalX;
			_globalY   = globalY;
			_color     = color;
			_lineWidth = lineWidth;
			
			DrawCurve();

		}
		
		public function DrawCurve()
		{
			var i : int;
			var colorAlpha : Number;

			colorAlpha = ( ( _color & 0xFF000000 ) >> 24 ) / 255.0;
			
			graphics.clear();

			if ( _controlPoints && _controlPoints.length > 0 )
			{
				graphics.lineStyle( _lineWidth * _defaultLineWidth, _color, colorAlpha );
				graphics.moveTo( _controlPoints[ 0 ].x, -_controlPoints[ 0 ].y );

				for ( i = 1; i < _controlPoints.length; ++i )
				{
					graphics.lineTo( _controlPoints[ i ].x, -_controlPoints[ i ].y );
				}
			}

			if ( _splinePoints && _splinePoints.length > 0 )
			{
				graphics.lineStyle( _lineWidth * _defaultLineWidth, _color, colorAlpha );
				graphics.moveTo( HudModuleMinimap2.WorldToMapX( _globalX + _splinePoints[ 0 ].x ),
								 HudModuleMinimap2.WorldToMapY( _globalY + _splinePoints[ 0 ].y ) );

				for ( i = 1; i < _splinePoints.length; ++i )
				{
					graphics.lineTo( HudModuleMinimap2.WorldToMapX( _globalX + _splinePoints[ i ].x ),
									 HudModuleMinimap2.WorldToMapY( _globalY + _splinePoints[ i ].y ) );
				}
			}

		}
		
	}
}
