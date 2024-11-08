package red.game.witcher3.hud.modules.minimap2
{
	import flash.display.MovieClip;
	import scaleform.clik.core.UIComponent;
	import red.game.witcher3.hud.modules.HudModuleMinimap2;
	import flash.display.Sprite;
		
	public class CommonMapContainer extends UIComponent
	{
		private var _pinsLayers : Vector.< Sprite >;
		
		public function CommonMapContainer()
		{
			super();
			_pinsLayers = new Vector.<Sprite>;
			_pinsLayers.push( addChild( new Sprite() ) );
			_pinsLayers.push( addChild( new Sprite() ) );
			_pinsLayers.push( addChild( new Sprite() ) );
			
		}
		
		public function addChildPin( layerIdx : uint, ref : MovieClip )
		{
			_pinsLayers[ layerIdx ].addChild( ref );
		}

		public function removeChildPin( layerIdx : uint, ref : MovieClip )
		{
			_pinsLayers[ layerIdx ].removeChild( ref );
		}

		public function UpdatePosition()
		{
			x =  -HudModuleMinimap2.WorldToMapX( HudModuleMinimap2.m_playerWorldPosX );
			y =  -HudModuleMinimap2.WorldToMapY( HudModuleMinimap2.m_playerWorldPosY );
		}


	}
	
}
