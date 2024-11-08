package red.game.witcher3.menus.worldmap
{
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import scaleform.clik.core.UIComponent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.data.DataProvider;
	import red.game.witcher3.controls.W3ScrollingList;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	
	public class HubMapQuestTracker extends UIComponent
	{
		public var mcHubMapQuestTrackerQuest : MovieClip;
		public var mcHubMapQuestTrackerList : W3ScrollingList;
		
		private var _objectivesCount : int = 0;
		private var _collapseWhenUpdated : Boolean;
		private var _expandedList : Boolean = false;
		
		public function HubMapQuestTracker()
		{
			super();
			// constructor code
		}
		
		protected override function configUI():void
		{
			super.configUI();
			
			addEventListener( MouseEvent.MOUSE_OVER,		OnMouseOver,		false, 0, true );
			addEventListener( MouseEvent.MOUSE_OUT,			OnMouseOut,			false, 0, true );
			
			mcHubMapQuestTrackerList.addEventListener(ListEvent.INDEX_CHANGE, handleIndexChanged, false, 0, true);
		}
		
		public function enableMouse( enable : Boolean )
		{
			mouseEnabled = enable;
			mouseChildren = enable;
		}
		
		public function OnMouseOver( event : MouseEvent )
		{
			if ( mouseEnabled )
			{
				expandList( true );
			}
		}
		
		public function OnMouseOut( event : MouseEvent )
		{
			expandList( false );
		}
		
		public function OnMouseMoveFromParent(  globalMousePos : Point )
		{
			if ( mouseEnabled )
			{
				expandList( isGlobalPointInsideBounds( globalMousePos ) );
			}
		}
		
		protected function handleIndexChanged( event : ListEvent )
		{
			expandList( true );

			if ( event.index > 0 )
			{
				var renderer : HubMapQuestTrackerItemRenderer;
				renderer = mcHubMapQuestTrackerList.getRendererAt( event.index ) as HubMapQuestTrackerItemRenderer;
				if ( renderer )
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnHighlightObjective', [ renderer.getScriptName() ] ) );
				}
			}
		}

		override public function handleInput( event : InputEvent ) : void
		{
            var details : InputDetails = event.details;
			var keyDown : Boolean  = (details.value == InputValue.KEY_DOWN );
			var keyUp : Boolean    = (details.value == InputValue.KEY_UP );
            var keyPress : Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			
			//trace("Minimap1 " + details.code );
			
			if ( details.code == 1000 )
			{
				expandList( false );
			}
			else if ( details.code == KeyCode.PAD_RIGHT_THUMB || details.code == KeyCode.V )
			{
				expandList( true );
				if ( keyDown )
				{
					if ( _objectivesCount > 1 )
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnHighlightNextObjective' ) );
					}
				}
			}

		}
		
		private function isGlobalPointInsideBounds( globalMousePos : Point ) : Boolean
		{
			var globalBounds : Rectangle = mcHubMapQuestTrackerList.getBounds( stage );
			
			return globalMousePos.x > globalBounds.left &&
				   globalMousePos.x < globalBounds.right &&
				   globalMousePos.y > globalBounds.top &&
				   globalMousePos.y < globalBounds.bottom;
			
		}
		
		public function canBeShown() : Boolean
		{
			return _objectivesCount > 0;
		}
		
		private const RIGHT_MARGIN : int = 70;
		private const LEFT_MARGIN : int = 5;
				
		public function setCurrentQuest( value : Object )
		{
			if ( !value )
			{
				return;
				
			}
			mcHubMapQuestTrackerQuest.tfQuest.htmlText = value.questName;
			mcHubMapQuestTrackerQuest.tfQuest.width = mcHubMapQuestTrackerQuest.tfQuest.textWidth;
			mcHubMapQuestTrackerQuest.tfQuest.x = mcHubMapQuestTrackerQuest.mcBackground.x + 15 - RIGHT_MARGIN - mcHubMapQuestTrackerQuest.tfQuest.width;
			mcHubMapQuestTrackerQuest.mcBackground.width = RIGHT_MARGIN + mcHubMapQuestTrackerQuest.tfQuest.textWidth + LEFT_MARGIN;

			switch ( value.questType )
			{
				case 0:
				case 1:
				case 2:
					{
						switch( value.contentType )
						{
							case 0:
								mcHubMapQuestTrackerQuest.mcPinIcon.gotoAndStop( 'QuestAvailable' );
								break;
							case 1:
								mcHubMapQuestTrackerQuest.mcPinIcon.gotoAndStop( 'QuestAvailableHoS' );
								break;
							case 2:
								mcHubMapQuestTrackerQuest.mcPinIcon.gotoAndStop( 'QuestAvailableBaW' );
								break;
						}
					}
					break;
				case 3:
					mcHubMapQuestTrackerQuest.mcPinIcon.gotoAndStop( "MonsterHunt" );
					break;
				case 4:
					mcHubMapQuestTrackerQuest.mcPinIcon.gotoAndStop( "TreasureHunt" );
					break;
			}
			
			_collapseWhenUpdated = !value.onHighlight;
		}

		public function setCurrentObjectives( array: Array )
		{
			if ( !array )
			{
				return;
			}
			_objectivesCount = array.length;

			mcHubMapQuestTrackerList.dataProvider = new DataProvider( array );
			mcHubMapQuestTrackerList.selectedIndex = -1;
			mcHubMapQuestTrackerList.validateNow(); // needed for resizeHitArea()
			
			if ( _collapseWhenUpdated )
			{
				if ( !expandList( false ) )
				{
					updateVisibility();
					resizeHitArea();
				}
			}
			else
			{
				updateVisibility();
				resizeHitArea();
			}
		}
		
		private function expandList( expand : Boolean ) : Boolean
		{
			if ( _expandedList == expand )
			{
				return false;
			}
			
			_expandedList = expand;
			
			updateVisibility();
			resizeHitArea();
			
			return true;
		}
		
		private function updateVisibility()
		{
			var i : int;
			var renderers : Vector.<IListItemRenderer>;
			var renderer : HubMapQuestTrackerItemRenderer;

			renderers = mcHubMapQuestTrackerList.getRenderers();

			for ( i = 0; i < _objectivesCount; ++i )
			{
				renderer = renderers[ i ] as HubMapQuestTrackerItemRenderer
				if ( renderer )
				{
					if ( _expandedList )
					{
						renderer.alpha = 1;
						if ( i > 2 )
						{
							renderer.visible = true;
						}
					}
					else
					{
						if ( i == 0 )
							renderer.alpha = 1;
						else if ( i == 1 )
							renderer.alpha = 0.5;
						else if ( i == 2 )
							renderer.alpha = 0.3;
						else
							renderer.visible = false;
					}
				}
			}
		}
		
		private function resizeHitArea()
		{
			var left : Number = NaN;
			var right : Number = NaN;
			var top : Number = NaN;
			var bottom : Number = NaN;

			var questButtonBounds : Rectangle;
			
			questButtonBounds = mcHubMapQuestTrackerQuest.getBounds( this );
			
			top    = questButtonBounds.top;
			right  = questButtonBounds.right;
			left   = questButtonBounds.left;
			bottom = questButtonBounds.bottom;
			
			var renderers : Vector.< IListItemRenderer > = mcHubMapQuestTrackerList.getRenderers();
			var i : int;
			
			for ( i = 0; i < renderers.length; ++i )
			{
				var item : HubMapQuestTrackerItemRenderer = renderers[ i ] as HubMapQuestTrackerItemRenderer;
				if ( item && item.visible && item.alpha > 0 )
				{
					var bounds : Rectangle = item.getBounds( this );
					if ( isNaN( left ) || left > bounds.left )
					{
						left = bounds.left;
					}
					if ( isNaN( right ) || right < bounds.right )
					{
						right = bounds.right;
					}
					if ( isNaN( top ) || top > bounds.top )
					{
						top = bounds.top;
					}
					if ( isNaN( bottom ) || bottom < bounds.bottom )
					{
						bottom = bounds.bottom;
					}
				}
			}
			
			mcHubMapQuestTrackerList.x = right;
			mcHubMapQuestTrackerList.y = top;
			mcHubMapQuestTrackerList.scaleX = ( ( right - left ) / 100 );
			mcHubMapQuestTrackerList.scaleY = ( ( bottom - top ) / 100 );
		}
	}
	
}
