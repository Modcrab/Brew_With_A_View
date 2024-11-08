/***********************************************************************
/** Base drop down Item Renderer
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.controls
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3DropDownItemRenderer;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.ListEvent;
	import flash.events.Event;

	public class W3DropDownItemRenderer extends BaseListItem
	{
		/********************************************************************************************************************
				ART CLIPS
		/ ******************************************************************************************************************/

		public var mcFeedbackIcon : MovieClip;
		public var tfSecondLine : TextField;
		public var mcNewOverlay : MovieClip;

		/********************************************************************************************************************
				VARIABLES
		/ ******************************************************************************************************************/

		protected var _isNew : Boolean = false;
		protected var readEventName : String = "OnEntryRead";

		/********************************************************************************************************************
				INIT
		/ ******************************************************************************************************************/
		public function W3DropDownItemRenderer()
		{
			super();
			if (mcNewOverlay)
				mcNewOverlay.visible = false;

			if (mcFeedbackIcon)
				mcFeedbackIcon.visible = false;

			preventAutosizing = true;
			constraintsDisabled = true;
		}

		override protected function configUI():void
		{
			super.configUI();
			
			allowDeselect = false;
			toggle = false;
		}

		override public function toString() : String
		{
			return "[W3 W3DropDownItemRenderer]"
		}

		override public function setActualSize(newWidth:Number, newHeight:Number):void
		{
			// Do nothing.
			// Stops the unwanted resizing behavior because the movie clip has a different frame size when showing an icon.
		}

		override public function setData( data:Object ):void
		{
			if ( tfSecondLine )
			{
				tfSecondLine.htmlText = "";
			}
			if ( mcFeedbackIcon )
			{
				mcFeedbackIcon.visible = false;
			}
			super.setData( data );
			if (! data )
			{
				return;
			}
			_isNew = data.isNew;
			UpdateIcons();
			updateText();
		}

		protected function SetReadState( movie : MovieClip )
		{
			if (movie)
			{
				if ( _isNew )
				{
					movie.visible = true;
				}
				else
				{
					movie.visible = false;
				}
			}
		}

		override public function set selected(value:Boolean):void
		{
			super.selected = value;
			if ( _isNew && value && data.tag )
			{
				_isNew = false;
				data.isNew = _isNew;
				UpdateIcons();
				dispatchEvent( new GameEvent(GameEvent.CALL, readEventName, [data.tag]) );
			}
		}

		protected function UpdateIcons() : void
		{
			SetReadState(mcNewOverlay);
		}

		public function handleEntryPress() : void
		{
		}
	}

}
