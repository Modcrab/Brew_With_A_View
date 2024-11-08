package red.game.witcher3.menus.journal
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import red.core.CoreComponent;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.BaseListItem;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ButtonEvent;
	import flash.events.Event;
	import red.game.witcher3.controls.W3ScrollingList;

	public class ObjectiveItemRenderer extends QuestItemRenderer // #B temp fastest solution
	{
		protected static var UNHILIGHT		: String =	"UNHILIGHT WHOLE LIST";
		public var mcSelection : MovieClip;
		public var mcSelectionGlow : MovieClip;
		public var mcHitArea : MovieClip;
		public var mcOverBackground : MovieClip;
		public var mcCheckboxFrame : MovieClip;

		private const INVALID_VALUE:int = -100000;
		public static const DELIMITER_STATUS:int = 1000;

		private var selectionStartY:int = INVALID_VALUE;
		private var selectionGlowStartY:int = INVALID_VALUE;
		private var selectionGlowStartHeight:int = INVALID_VALUE;

		private var startingColor:uint;

		/********************************************************************************************************************
				INIT
		/ ******************************************************************************************************************/
		public function ObjectiveItemRenderer()
		{
			super();
			
			if (mcHitArea)
			{
				hitArea = mcHitArea;
			}
		}

		override protected function configUI():void
		{
			if (textField)
			{
				startingColor = textField.textColor;
			}

			if (mcSelection && selectionStartY == INVALID_VALUE)
			{
				selectionStartY = mcSelection.y;
			}

			if (mcSelectionGlow && selectionGlowStartY == INVALID_VALUE)
			{
				selectionGlowStartY = mcSelectionGlow.y;
				selectionGlowStartHeight = mcSelectionGlow.height;
			}

			addEventListener(ButtonEvent.PRESS, handleButtonPress, false, 0, false);
			super.configUI();
		}

		override protected function UpdateQuestStatusText() : void
		{
		}

		override public function setData( data:Object ):void
		{
			if ( index == 0 )
			{
				SetIsNew(false);
			}
			super.setData( data );
			//UpdateIcons();

			updateSelectionStrokePosition();

			updateVisibility();
			enabled = !isDelimiter();
		}

		protected var _selectionGlowEnabled:Boolean = true;
		public function set selectionGlowEnabled(value:Boolean):void
		{
			_selectionGlowEnabled = value;
			if (mcSelectionGlow)
			{
				mcSelectionGlow.visible = _selectionGlowEnabled;
			}
		}

		override protected function IsStory() : Boolean
		{
			return false;
		}

		protected function handleButtonPress( event : ButtonEvent ) : void
		{
			if ( data.status < 2 )
			{
				stage.dispatchEvent( new Event(ObjectiveItemRenderer.UNHILIGHT) );
				Tracked = !Tracked;
				trace("HUD handleButtonPress Tracked "+Tracked+" data.tag "+data.tag);
				if ( Tracked )
				{
					dispatchEvent( new GameEvent(GameEvent.CALL, "OnHighlightObjective", [data.tag]) );
				}
			}
		}

		override public function AddEventListeners()
		{
			stage.addEventListener( ObjectiveItemRenderer.UNHILIGHT, handleUntrackItem, false, 0 , false );
		}

		public function RemoveEventListeners()
		{
			stage.removeEventListener( ObjectiveItemRenderer.UNHILIGHT, handleUntrackItem );
		}

		public function SetIsNew( value : Boolean )
		{
			_isNew = value;
			/*	if ( Tracked )
			{
				//mcFeedbackIconSecond.
				SetReadState(mcFeedbackIconSecond);
			}
			else
			{
				SetReadState(mcFeedbackIcon);
			}*/
		}

		override protected function updateText() : void
		{
            if (_label != null && textField != null)
			{
				if (data && !data.isLegend)
				{
					var textValue: String ;
					if ( _tracked )
					{
						textValue = "<font color='#FFFFFF'>" + _Title + questStatusColorEnd;
						
					}
					else if ( data.status == 2 )
					{
						textValue = "<font color='#6B6A69'>" + _Title + questStatusColorEnd;
					}
					else if ( data.status == 3 )
					{
						textValue = "<font color='#BE190B'>" + _Title + questStatusColorEnd;

					}
					else
					{
						textValue = _label;

					}
				}
				else
				{
					textValue = _label;
				}
				
				
				if (CoreComponent.isArabicAligmentMode)
				{
					textField.htmlText = "<p align=\"right\">" + textValue + "</p>";
				}
				else
				{
					textField.htmlText = textValue;
				}
				
				
            }
			
			if (mcSelectionGlow)
			{
				mcSelectionGlow.visible = _selectionGlowEnabled;
			}

			updateSelectionStrokePosition();
		}

		private function updateSelectionStrokePosition() : void
		{
			/*if (mcSelection && selectionStartY == INVALID_VALUE)
			{
				selectionStartY = mcSelection.y;
			}

			if (mcSelectionGlow && selectionGlowStartY == INVALID_VALUE)
			{
				selectionGlowStartY = mcSelectionGlow.y;
				selectionGlowStartHeight = mcSelectionGlow.height;
			}*/

			/*if (textField.numLines > 1)
			{
				if (mcSelection) { mcSelection.y = selectionStartY + 23; }
				if (mcSelectionGlow)
				{
					mcSelectionGlow.height = selectionGlowStartHeight + 22;
					mcSelectionGlow.y = selectionGlowStartY + 2;
				}
			}
			else
			{
				if (mcSelection) { mcSelection.y = selectionStartY; }
				if (mcSelectionGlow)
				{
					mcSelectionGlow.height = selectionGlowStartHeight;
					mcSelectionGlow.y = selectionGlowStartY;
				}
			}*/
			if (mcSelection) { mcSelection.y = textField.textHeight - 7; }
			if (mcSelectionGlow)
			{
				mcSelectionGlow.height = textField.textHeight + 14;
				mcSelectionGlow.y = -6;
			}
			
			if (mcHitArea)
			{
				mcHitArea.height = textField.textHeight + 13;
			}
			if (mcOverBackground)
			{
				mcOverBackground.height = textField.textHeight + 13;
			}
			parent.dispatchEvent(new Event(W3ScrollingList.REPOSITION));
		}

		override protected function SetReadState( movie : MovieClip )
		{
			super.SetReadState( movie  );
			if( movie.visible )
			{
				movie.gotoAndStop("new");
			}
		}
		
		private function updateVisibility()
		{
			var alpha : Number = 1;
			if ( isDelimiter() )
			{
				alpha = 0;
			}
			
			if ( mcFeedbackIcon )			mcFeedbackIcon.alpha		= alpha;
			if ( mcFeedbackIconSecond )		mcFeedbackIconSecond.alpha	= alpha;
			if ( mcCheckboxFrame )			mcCheckboxFrame.alpha		= alpha;
			if ( mcOverBackground )			mcOverBackground.alpha		= alpha;
		}

		override protected function updateAfterStateChange():void
		{
			super.updateAfterStateChange();
			
			updateVisibility();
		}

		private function isDelimiter() : Boolean
		{
			if ( data )
			{
				return data.status == DELIMITER_STATUS;
			}
			return false;
		}
	}
}
