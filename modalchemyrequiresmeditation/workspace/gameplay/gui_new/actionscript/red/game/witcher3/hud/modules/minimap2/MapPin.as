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
	import red.game.witcher3.hud.modules.HudModuleMinimap2;
	import 	flash.geom.	ColorTransform;
	import red.game.witcher3.menus.overlay.BookPopup;
	import flash.utils.getDefinitionByName;
	
	public class MapPin
	{		
		public var pinClip		: MovieClip;
		public var arrowClip	: MovieClip;

		public var id			: int;
		public var tag			: String;
		public var type			: String;
		public var posX			: Number;
		public var posY			: Number;
		public var posZ			: Number;
		public var radius		: Number;
		public var highlighted	: Boolean;
		public var canBePointedByArrow : Boolean;
		public var canHeightArrowsBeShown : Boolean;
		public var priority : int;
		public var isQuestPin : Boolean;
		public var isUserPin : Boolean;
		
		private var isUpArrowVisible : Boolean = false;
		private var isDownArrowVisible : Boolean = false;
		private var isNormalQuestIconVisible : Boolean = false;
		
		public function MapPin()
		{
			id		= 0;
			posX	= 0;
			posY	= 0;
			posZ	= 0;
			radius	= 0;
			highlighted = false;
			canBePointedByArrow = false;
			canHeightArrowsBeShown = false;
			priority = 0;
			isQuestPin = false;
		}

		
		public function OnInitialize( type : String )
		{
			var ref : Class = getDefinitionByName( "class" + type ) as Class;
			if ( ref )
			{
				pinClip.PinIcon = new ref();
				pinClip.PinIcon.name = "PinIcon";
				pinClip.addChild( pinClip.PinIcon );
			}
		}
		
		public function OnDeinitialize()
		{
			pinClip.removeChild( pinClip.PinIcon );
			pinClip.PinIcon = null;
		}

		public function ShowPin( bShow : Boolean )
		{
			pinClip.visible = bShow;
		}

		public function ShowPinIcon( bShow : Boolean )
		{
			pinClip.PinIcon.visible = bShow;
		}

		public function ShowPinRadius( bShow : Boolean )
		{
			pinClip.mcRadius.visible = bShow;
		}

		public function UpdatePinRadiusColor()
		{
			if ( radius == 0 )
			{
				pinClip.mcRadius.mcRadiusQuest.visible   = false;
				pinClip.mcRadius.mcRadiusRegular.visible = false;
				pinClip.mcRadius.mcRadiusBelgard.visible = false;
				pinClip.mcRadius.mcRadiusCoronata.visible = false;
				pinClip.mcRadius.mcRadiusVermentino.visible = false;
			}
			else if ( isQuestPin )
			{
				if ( type == 'QuestBelgard' )
				{
					pinClip.mcRadius.mcRadiusQuest.visible   = false;
					pinClip.mcRadius.mcRadiusRegular.visible = false;
					pinClip.mcRadius.mcRadiusBelgard.visible = true;
					pinClip.mcRadius.mcRadiusCoronata.visible = false;
					pinClip.mcRadius.mcRadiusVermentino.visible = false;
				}
				else if ( type == 'QuestCoronata' )
				{
					pinClip.mcRadius.mcRadiusQuest.visible   = false;
					pinClip.mcRadius.mcRadiusRegular.visible = false;
					pinClip.mcRadius.mcRadiusBelgard.visible = false;
					pinClip.mcRadius.mcRadiusCoronata.visible = true;
					pinClip.mcRadius.mcRadiusVermentino.visible = false;
				}
				else if ( type == 'QuestVermentino' )
				{
					pinClip.mcRadius.mcRadiusQuest.visible   = false;
					pinClip.mcRadius.mcRadiusRegular.visible = false;
					pinClip.mcRadius.mcRadiusBelgard.visible = false;
					pinClip.mcRadius.mcRadiusCoronata.visible = false;
					pinClip.mcRadius.mcRadiusVermentino.visible = true;
				}
				else
				{
					pinClip.mcRadius.mcRadiusQuest.visible   = true;
					pinClip.mcRadius.mcRadiusRegular.visible = false;
					pinClip.mcRadius.mcRadiusBelgard.visible = false;
					pinClip.mcRadius.mcRadiusCoronata.visible = false;
					pinClip.mcRadius.mcRadiusVermentino.visible = false;
				}
			}
			else
			{
				pinClip.mcRadius.mcRadiusQuest.visible   = false;
				pinClip.mcRadius.mcRadiusRegular.visible = true;
				pinClip.mcRadius.mcRadiusBelgard.visible = false;
				pinClip.mcRadius.mcRadiusCoronata.visible = false;
				pinClip.mcRadius.mcRadiusVermentino.visible = false;
			}
		}

		public function ShowArrow( bShow : Boolean )
		{
			if ( arrowClip )
			{
				arrowClip.visible = bShow;
			}
		}

		import com.gskinner.motion.GTween;
		import com.gskinner.motion.GTweener;
	
		public function ShowNewFeedback( bShow : Boolean )
		{
			if ( pinClip.mcNewFeedback )
			{
				pinClip.mcNewFeedback.visible = bShow;
				if ( bShow )
				{
					pinClip.mcNewFeedback.mcCircle.alpha   = 1;
					pinClip.mcNewFeedback.mcCircle.scaleX  = 0.31;
					pinClip.mcNewFeedback.mcCircle.scaleY  = 0.31;
					
					GTweener.removeTweens( this );
					
					var nextTween:GTween =  GTweener.to( pinClip.mcNewFeedback.mcCircle, 0.33,  { alpha: 0 } );
					nextTween.paused = true;
					GTweener.to( pinClip.mcNewFeedback.mcCircle, 0.33,  { scaleX: 1, scaleY: 1 }, { nextTween: nextTween } );
					
					//pinClip.mcNewFeedback.gotoAndPlay( 2 );
				}
			}
		}
		
		public function SetPinRotation( rot : Number )
		{
			pinClip.rotation = rot;
		}

		public function SetArrowRotation( rot : Number )
		{
			arrowClip.rotation = rot;
		}

		public function AddArrowRotation( rotDelta : Number )
		{
			arrowClip.rotation += rotDelta;
		}

		public function SetIconScale( sc )
		{
			if ( pinClip.PinIcon )
			{
				pinClip.PinIcon.scaleX = sc;
				pinClip.PinIcon.scaleY = sc;
			}
			if ( pinClip.PinGlow )
			{
				pinClip.PinGlow.scaleX = sc;
				pinClip.PinGlow.scaleY = sc;
			}
			if ( pinClip.mcArrows )
			{
				pinClip.mcArrows.scaleX = sc;
				pinClip.mcArrows.scaleY = sc;
			}
			if ( pinClip.mcNewFeedback )
			{
				pinClip.mcNewFeedback.scaleX = sc;
				pinClip.mcNewFeedback.scaleY = sc;
			}
		}

		public function SetRadiusScale( radius : Number, coef : Number )
		{
			if ( radius > 0 )
			{
				pinClip.mcRadius.scaleX = ( radius / 5 ) * coef;
				pinClip.mcRadius.scaleY = ( radius / 5 ) * coef;
			}
			else
			{
				pinClip.mcRadius.scaleX = 0.1;
				pinClip.mcRadius.scaleY = 0.1;
			}
		}

		public function UpdateMapPinPosition( px : Number, py : Number )
		{
			pinClip.x = px;
			pinClip.y = py;
		}

		public function UpdateMapPinArrowRotation( rotDelta : Number )
		{
			if ( CanArrowBeShown() )
			{
				AddArrowRotation( rotDelta );
			}
		}

		public function UpdateMapPinAppearance( radiusSquared : Number, updateHeightArrows:Boolean = true )
		{
			if ( CanArrowBeShown() )
			{
				var distSqr : Number = ( HudModuleMinimap2.m_playerWorldPosX - posX ) * ( HudModuleMinimap2.m_playerWorldPosX - posX ) +
				                       ( HudModuleMinimap2.m_playerWorldPosY - posY ) * ( HudModuleMinimap2.m_playerWorldPosY - posY );
				if ( distSqr > radiusSquared )
				{
					var playerMapX = HudModuleMinimap2.WorldToMapX( HudModuleMinimap2.m_playerWorldPosX );
					var playerMapY = HudModuleMinimap2.WorldToMapY( HudModuleMinimap2.m_playerWorldPosY );
					var pinMapX    = HudModuleMinimap2.WorldToMapX( posX );
					var pinMapY    = HudModuleMinimap2.WorldToMapY( posY );

					ShowArrow( true );
					SetArrowRotation( HudModuleMinimap2.GetCameraAngle() + Math.atan2( pinMapY - playerMapY, pinMapX - playerMapX ) * 180 / Math.PI );
				}
				else
				{
					ShowArrow( false );
				}
			}

			if (updateHeightArrows)
			{
				UpdateHeightArrows();
			}
		}

		public function UpdateHeightArrowsForQuestPins()
		{
			if ( isQuestPin )
			{
				pinClip.mcArrows.mcUp.mcStatic.visible = false;
				pinClip.mcArrows.mcUp.mcDynamic.visible = true;
				pinClip.mcArrows.mcDown.mcStatic.visible = false;
				pinClip.mcArrows.mcDown.mcDynamic.visible = true;
			}
			else
			{
				pinClip.mcArrows.mcUp.mcStatic.visible = true;
				pinClip.mcArrows.mcUp.mcDynamic.visible = false;
				pinClip.mcArrows.mcDown.mcStatic.visible = true;
				pinClip.mcArrows.mcDown.mcDynamic.visible = false;
			}
		}
		
		public function UpdateHeightArrows()
		{
			var playerWorldPosZ : Number = HudModuleMinimap2.m_playerWorldPosZ;
			var heightThreshold : Number = HudModuleMinimap2.HEIGHT_THRESHOLD;
			
			if ( CanHeightArrowsBeShown() )
			{
				if ( playerWorldPosZ > posZ + heightThreshold )
				{
					ShowHeightArrows( false, true, true, false );
				}
				else if ( playerWorldPosZ < posZ - heightThreshold )
				{
					ShowHeightArrows( true, false, true, false );
				}
				else
				{
					ShowHeightArrows( false, false, true, true );
					
				}
			}
			else
			{
				ShowHeightArrows( false, false, false, false );
			}
		}
		
		public function ForceShowHeightArrows( upArrow, downArrow, normalQuestIcon : Boolean )
		{
			isUpArrowVisible = upArrow;
			pinClip.mcArrows.mcUp.visible = upArrow;
			
			isDownArrowVisible = downArrow;
			pinClip.mcArrows.mcDown.visible = downArrow;
			
			isNormalQuestIconVisible = normalQuestIcon;
			if ( pinClip.PinIcon.mcQuestNormal )
			{
				pinClip.PinIcon.mcQuestNormal.visible = normalQuestIcon;
			}
		}
		
		private function ShowHeightArrows( upArrow, downArrow, updateQuestIcon, normalQuestIcon : Boolean )
		{
			if ( isUpArrowVisible != upArrow )
			{
				isUpArrowVisible = upArrow;
				pinClip.mcArrows.mcUp.visible = upArrow;
			}
			if ( isDownArrowVisible != downArrow )
			{
				isDownArrowVisible = downArrow;
				pinClip.mcArrows.mcDown.visible = downArrow;
			}
			if ( updateQuestIcon && isQuestPin )
			{
				if ( isNormalQuestIconVisible != normalQuestIcon )
				{
					isNormalQuestIconVisible = normalQuestIcon;
					pinClip.PinIcon.mcQuestNormal.visible = normalQuestIcon;
				}
			}
		}
		
		private static const ARROW_REGULAR_USER			= 1;
		private static const ARROW_REGULAR_QUEST		= 2;
		private static const ARROW_HIGHLIGHTED_QUEST	= 3;

		public function UpdateHighlighting()
		{
			if ( radius == 0 )
			{
				pinClip.PinGlow.visible = highlighted;
			}
			else
			{
				// no highlighting for area mappins
				pinClip.PinGlow.visible = false;
			}

			if ( highlighted )
			{
				if ( arrowClip )
				{
					arrowClip.mcUser.visible             = false;
					arrowClip.mcRegularQuest.visible     = false;
					arrowClip.mcHighlightedQuest.visible = true;
				}
			}
			else
			{
				if ( arrowClip )
				{
					if ( isQuestPin )
					{
						arrowClip.mcUser.visible             = false;
						arrowClip.mcRegularQuest.visible     = true;
						arrowClip.mcHighlightedQuest.visible = false;
					}
					else
					{
						arrowClip.mcUser.visible             = true;
						arrowClip.mcUser.gotoAndStop( type );
						arrowClip.mcRegularQuest.visible     = false;
						arrowClip.mcHighlightedQuest.visible = false;
					}
				}
			}
		}

		public function CanHeightArrowsBeShown() : Boolean
		{
	 		return canHeightArrowsBeShown;
		}

		public function CanArrowBeShown() : Boolean
		{
	 		return canBePointedByArrow || highlighted;
		}

	}
}
