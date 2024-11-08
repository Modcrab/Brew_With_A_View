/*
Scene 1 -> UniverseMap -> UniverseMapContainer
Layer Toussaint
PrologVillage -> Show in library
Duplicate 2x movie clips
Rename to Toussaint
Export to AS with universearea
Place on layer
Set instance names
Set active data key to universearea.toussaint.active
*/

package red.game.witcher3.menus.worldmap
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.plugins.CurrentFramePlugin;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import red.game.witcher3.events.MapAnimation;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.core.UIComponent;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.display.Sprite;
	
	import scaleform.clik.controls.UILoader;	// NGE

	public class UniverseMapContainer extends UIComponent
	{
		protected static const SCROLL_ANIM_DURATION:Number = .1;
		protected static const DARK_INTENSITY:Number = .8;
		
		public var mcUniverseMapImage	: MovieClip;
		
		public var mcKaerMorhen			: UniverseArea;
		public var mcSkellige			: UniverseArea;
		public var mcWyzima				: UniverseArea;
		public var mcNovigrad			: UniverseArea;
		public var mcPrologVillage		: UniverseArea;
		public var mcNoMansLand			: UniverseArea;
		public var mcToussaint			: UniverseArea;
		
		public var mcKaerMorhen_mask    : MovieClip;
		public var mcSkellige_mask		: MovieClip;
		public var mcWyzima_mask		: MovieClip;
		public var mcNovigrad_mask		: MovieClip;
		public var mcPrologVillage_mask	: MovieClip;
		public var mcNoMansLand_mask	: MovieClip;
		public var mcToussaint_mask		: MovieClip;
				
		protected var m_hubs : Vector.< UniverseArea >;

		private const m_scale = 1;
		private var currentArea:UniverseArea;		
		
		private var _scrollTween:GTween;
		
		private var _mapCopy:MovieClip;
		private var _mapCopyMask:MovieClip;
		
		private var _areaContainer:Sprite;
		private var _currentAreaMask:Sprite;
		private var _darkOverlay:Sprite;

		protected override function configUI():void
		{
			super.configUI();
			
			m_hubs = new Vector.< UniverseArea >;
			m_hubs.push( mcKaerMorhen );
			m_hubs.push( mcSkellige );
			m_hubs.push( mcWyzima );
			m_hubs.push( mcNovigrad );
			m_hubs.push( mcPrologVillage );
			m_hubs.push( mcNoMansLand );
			m_hubs.push( mcToussaint );
			
			_areaContainer = new Sprite();
			addChild(_areaContainer);
			//m_hubs.forEach(setupAreas);
			
			mcKaerMorhen_mask.visible = false;
			mcSkellige_mask.visible = false;
			mcWyzima_mask.visible = false;
			mcNovigrad_mask.visible = false;
			mcPrologVillage_mask.visible = false;
			mcNoMansLand_mask.visible = false;
			mcToussaint_mask.visible = false;
			
			// this should be the same as in AreaTypeToName in scripts/game/types.ws
			mcNovigrad.SetWorldName( "novigrad" );
			mcSkellige.SetWorldName( "skellige" );
			mcKaerMorhen.SetWorldName( "kaer_morhen" );
			mcPrologVillage.SetWorldName( "prolog_village" );
			mcWyzima.SetWorldName( "wyzima_castle" );
			mcNoMansLand.SetWorldName( "no_mans_land", "novigrad" );
			mcToussaint.SetWorldName( "bob" );
			
			mcNovigrad.recLevel = 10;
			mcSkellige.recLevel = 16;
			mcKaerMorhen.recLevel = 19;
			mcPrologVillage.recLevel = 1;
			mcWyzima.recLevel = 2;
			mcNoMansLand.recLevel = 5;
			mcToussaint.recLevel = 35;
			
			// there is supposed to be no zooming in universe layer, but presumably we should rescale it a bit
			// #Y WARNING: Cause problems with textures quality!
			scaleX = actualScaleX * m_scale;
			scaleY = actualScaleY * m_scale;
			
			_darkOverlay = CommonUtils.createSolidColorSprite(getRect(mcUniverseMapImage), 0, .3);
			_darkOverlay.x = mcUniverseMapImage.x;
			_darkOverlay.y = mcUniverseMapImage.y;
			_darkOverlay.visible = false;
		}
		
		private function setupAreas(item:UniverseArea, index:int, vector:Vector.<UniverseArea>) 
		{ 
			_areaContainer.addChild(item) ;
		}
		
		public function highlightArea(targetArea:MovieClip):void
		{
			removeHiglighting(); // cleanup first
			
			var mapCopyRef:Class = getDefinitionByName("UniverseMapImageRef") as Class;
			_mapCopy = new mapCopyRef() as MovieClip;
			_mapCopy.x = mcUniverseMapImage.x;
			_mapCopy.y = mcUniverseMapImage.y;
			_mapCopy.scaleX = mcUniverseMapImage.scaleX;
			_mapCopy.scaleY = mcUniverseMapImage.scaleY;
			
			_currentAreaMask = getChildByName(targetArea.name + "_mask") as Sprite;
			_currentAreaMask.visible = true;
			
			addChild(_darkOverlay);
			addChild(_mapCopy);
			addChild(targetArea);
			_mapCopy.mask = _currentAreaMask;
			
			GTweener.removeTweens(_darkOverlay);
			GTweener.to(_darkOverlay, 1, { alpha:1 }, { ease:Exponential.easeOut } );
			_darkOverlay.visible = true;
			_darkOverlay.alpha = 0;
		}
		
		
		
		public function removeHiglighting():void
		{
			if (_mapCopy)
			{
				_mapCopy.mask = null;
				removeChild(_mapCopy);
				_mapCopy = null;
			}
			if (_currentAreaMask)
			{
				_currentAreaMask.visible = false;
				_currentAreaMask = null;
			}
			
			mcUniverseMapImage.filters = [];
			GTweener.removeTweens(_darkOverlay);
			GTweener.to(_darkOverlay, 1, { alpha:0 }, { ease:Exponential.easeOut, onComplete:handleDarkOverlayHidden } );
		}
		
		private function handleDarkOverlayHidden(tweenInst:GTween):void
		{
			_darkOverlay.visible = false;
		}
		
		//  --> common utils
		private function getDarkFilter(amount:Number):ColorMatrixFilter
		{
			var matrix:Array = new Array();
			matrix=matrix.concat(  [amount, 0,      0,      0, 0]);// red
			matrix=matrix.concat(  [0,      amount, 0,      0, 0]);// green
			matrix=matrix.concat(  [0,      0,      amount, 0, 0]);// blue
			matrix = matrix.concat([0,      0,      0,      1, 0]);// alpha
			return new ColorMatrixFilter(matrix);
		}
		
		public function centerArea(targetArea:UniverseArea, isAnimated:Boolean = true, animDuration:Number = .1):void
		{
			var localCenterPoint : Point = globalToLocal( targetArea.GetCenterPosition() );
			
			var targetX:Number = - localCenterPoint.x * scaleX;
			var targetY:Number = - localCenterPoint.y * scaleY;

			if (isAnimated)
			{
				GTweener.removeTweens(this);
				_scrollTween = GTweener.to(this, animDuration, { x:targetX, y:targetY }, {onComplete:handleScrollAnim} );
			}
			else
			{
				x = targetX;
				y = targetY;
			}
		}
		
		protected function handleScrollAnim(targetTween:GTween):void
		{
			dispatchEvent(new MapAnimation(MapAnimation.AREA_CHANGED, true));
			_scrollTween = null;
		}
		
		public function centerCurrentArea(animTransition:Boolean = true, animDuration:Number = .1):void
		{
			if (currentArea)
			{
				centerArea(currentArea, animTransition, animDuration);
			}
		}
		
		public function setCurrentArea(areaName:String):void
		{
			var len:int = m_hubs.length;
			for (var i:int = 0; i < len; i++)
			{
				var curArea:UniverseArea = m_hubs[i];
				if (curArea.GetWorldName() == areaName)
				{
					curArea.isCurrentArea = true;
					x = - curArea.x;
					y = - curArea.y;
					currentArea = curArea;
				}
				else
				{
					curArea.isCurrentArea = false;
				}
			}
		}
		
		public function setQuestAreas( array : Object )
		{
			var i, j : int;
			var len : int;
			var currArea : UniverseArea;
			
			len = m_hubs.length;
			
			for ( j = 0; j < len; j++ )
			{
				currArea = m_hubs[ j ];
				currArea.hasQuest = false;
			}

			if ( array )
			{
				for ( i = 0; i < array.length; i++ )
				{
					var worldName : String = array[ i ].area as String;
					for ( j = 0; j < len; j++ )
					{
						currArea = m_hubs[ j ];
						if ( currArea.GetWorldName() == worldName )
						{
							currArea.hasQuest = true;
						}
					}
				}
			}
		}


		public function ScrollMap( dx : Number, dy : Number )
		{
			if (_scrollTween)
			{
				return;
			}
			x += dx;
			y += dy;

			if ( x < -680 )
			{
				x = -680;
			}
			else if ( x > 530 )
			{
				x = 530;
			}
			if ( y < -700 )
			{
				y = -700;
			}
			else if ( y > 570 )
			{
				y = 570;
			}
			
			//
			//trace("Minimap " + x + " " + y );
			//
		}
		
		public function GetOveredHub( crosshairPos : Point ):UniverseArea
		{
			for ( var i : int = 0; i < m_hubs.length; i++ )
			{
				if ( m_hubs[ i ].enabled )
				{
					if ( m_hubs[ i ].mcCenterPosition.hitTestPoint( crosshairPos.x, crosshairPos.y, true) )
					{
						return m_hubs[ i ];
					}
				}
			}
			return null;
		}
		
		public function GetHubMapByName( worldName : String ) : UniverseArea
		{
			for ( var i : int = 0; i < m_hubs.length; i++ )
			{
				if ( worldName == m_hubs[ i ].GetWorldName() )
				{
					return m_hubs[ i ];
				}
			}
			return null;
		}

		public function GetHubMapAtPoint( crosshairPos : Point ) : UniverseArea
		{
			for ( var i : int = 0; i < m_hubs.length; i++ )
			{
				if ( m_hubs[ i ].mcCenterPosition.hitTestPoint( crosshairPos.x, crosshairPos.y, true) )
				{
					return m_hubs[ i ];
				}
			}
			return null;
		}

		// NGE
		public function addCustomHubs(arr : Array)
		{
			var i : int = 0;
			var area : UniverseArea = null;
			var _imageLoader:UILoader;
			
			while(i < arr.length)
			{
				area = arr[i] as UniverseArea;
				addChild(area);
				area.SetWorldName(arr[i].worldName,arr[i].realName);
				area.mcPlayerIndicator.visible = arr[i].isPlayer;
				area.mcQuestIndicator.visible = arr[i].isQuest;
				area.tfLabel.x += arr[i].worldNameOffsetX;	
				area.tfLabel.y += arr[i].worldNameOffsetY;	
				
				_imageLoader = new UILoader();
				_imageLoader.source = arr[i].uiIcon;
				_imageLoader.x = -58.0;
				_imageLoader.y = -55.0;
				_imageLoader.name = "customUILoader";
				area.mcIcon.addChild(_imageLoader);
								
				this.m_hubs.push(area);
				i++;
			}
		}
		// NGE
	}
	
}
