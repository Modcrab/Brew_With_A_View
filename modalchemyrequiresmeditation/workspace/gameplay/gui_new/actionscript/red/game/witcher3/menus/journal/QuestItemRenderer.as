package red.game.witcher3.menus.journal
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import red.game.witcher3.menus.common.IconItemRenderer;
	import red.core.CoreComponent;
	import red.game.witcher3.utils.CommonUtils;

	public class QuestItemRenderer extends IconItemRenderer
	{
		public var mcFeedbackIconSecond : MovieClip;

		protected var questStatusColorMain 	: String = "<font color='#ffcc00'>";
		protected var questStatusColorSide 	: String = "<font color='#bb8237'>";
		protected var questStatusColorMinor : String = "<font color='#d5d5d5'>";
		protected var questStatusColorEnd 	: String = "</font>";
		protected var _Title 				: String = "";
		public var tfLevel					: TextField;
		public var trackedBackground		: MovieClip;

		protected var _tracked : Boolean = false;

		public static var UNTRACK		: String =	"UNTRACK WHOLE LIST";

		public function QuestItemRenderer()
		{
			super();
			if (tfLevel)
			{
				tfLevel.htmlText = "";
			}
		}

		override public function toString() : String
		{
			return "[W3 QuestItemRenderer " + this.name +"]";
		}

		override protected function configUI():void
		{
			super.configUI();
			AddEventListeners();
			
		}

		public function AddEventListeners()
		{
			stage.addEventListener( QuestItemRenderer.UNTRACK, handleUntrackItem, false, 0 , true );
		}

		override public function setData( data:Object ):void
		{
			if ( mcFeedbackIconSecond )
			{
				mcFeedbackIconSecond.visible = false;
			}
			if (! data )
			{
				return;
			}
			if ( data.label )
			{
				_Title = String( data.label );
			}
			
			_tracked = data.tracked;
			super.setData( data );
			UpdateQuestStatusText();
			
			updateText();
		}
		//  seleceted -> _isNew = false, pass info to ws

		override public function handleEntryPress() : void
		{
			trace("HUD handleButtonPress QIR "+data.tag);
			if ( data.status < 2)
			{
				if (!Tracked)
				{
					stage.dispatchEvent( new Event(QuestItemRenderer.UNTRACK) );
					
					Tracked = true;
					dispatchEvent( new GameEvent(GameEvent.CALL, "OnTrackQuest", [data.tag]) );
				}
			}
		}

		protected function UpdateQuestStatusText() : void
		{
			if (tfSecondLine)
			{
				if (data)
				{
					var textValue : String =  GetQuestStatusColor();
					if ( CoreComponent.isArabicAligmentMode )
					{
						textValue = "<p align=\"right\">" + textValue+"</p>";
					}
					tfSecondLine.htmlText = textValue;
					return;
				}
				tfSecondLine.htmlText = "";
			}
		}

		override protected function updateText() : void
		{
			if ( !data )
			{
				textField.htmlText = "";
				return;
			}		
			if ( _tracked )
			{
				_label = "<font color='#FFFFFF'>" + _Title + questStatusColorEnd;
			}
			else if ( data.status == 2 )
			{
				_label = "<font color='#209226'>" + _Title + questStatusColorEnd;
			}
			else if ( data.status == 3 )
			{
				_label = "<font color='#9c1509'>" + _Title + questStatusColorEnd;
			}
			else
			{
				if ( data.epIndex == 0 )
				{
					_label = "<font color='#B0A99F'>" + _Title + questStatusColorEnd;
				}
				else if ( data.epIndex == 1 )
				{
					_label = "<font color='#3e9ddf'>" + _Title + questStatusColorEnd;
				}
				else
				{
					_label = "<font color='#E18168'>" + _Title + questStatusColorEnd;
				}

			}
			if (tfLevel)
			{
				tfLevel.htmlText = data.area;
			}
			super.updateText();
		}

		override protected function UpdateIcons() : void
		{
			mcFeedbackIcon.visible = false;
			mcFeedbackIconSecond.visible = false;
			
			mcFeedbackIcon.gotoAndStop("none");
			mcFeedbackIconSecond.gotoAndStop("none");
			
			if(trackedBackground) trackedBackground.visible = false;
			
			if ( _tracked )
			{
				mcFeedbackIcon.visible = true;
				if(trackedBackground) trackedBackground.visible = true;
				mcFeedbackIcon.gotoAndStop("tracked");
				SetReadState(mcFeedbackIconSecond);
			}
			else if ( data.status == 2 )
			{
				mcFeedbackIcon.visible = true;
				mcFeedbackIcon.gotoAndStop("succed");
				SetReadState(mcFeedbackIconSecond);
			}
			else if ( data.status == 3 )
			{
				mcFeedbackIcon.visible = true;
				mcFeedbackIcon.gotoAndStop("failed");
				SetReadState(mcFeedbackIconSecond);
			}
			else
			{
				SetReadState(mcFeedbackIcon);
			}
		}

		protected function IsStory() : Boolean
		{
			return data.isStory;
		}

		private function GetQuestStatusColor()
		{
			return data.secondLabel;
		}

		override protected function updateAfterStateChange():void
		{
			UpdateQuestStatusText();
		}

		public function set Tracked( value : Boolean ):void
		{
			if ( _tracked != value && data.status < 2 )
			{
				_tracked = value;
				data.tracked = _tracked;
				UpdateIcons();
				updateText();
			}
		}

		public function get Tracked( ): Boolean
		{
			return _tracked;
		}

		public function handleUntrackItem( event : Event )
		{
			if ( event.currentTarget != this && Tracked )
			{
				Tracked = false;
			}
		}
	}

}
