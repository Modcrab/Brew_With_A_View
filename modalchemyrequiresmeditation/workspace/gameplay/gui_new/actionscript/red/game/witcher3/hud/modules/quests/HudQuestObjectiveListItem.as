package red.game.witcher3.hud.modules.quests
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize; // TBD: while the CLIK component property is useless
	import red.core.CoreComponent;

	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.controls.ListItemRenderer;

	import red.core.events.GameEvent;
	import red.game.witcher3.utils.motion.TweenEx;
	import red.game.witcher3.controls.BaseListItem;

	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;

	public class HudQuestObjectiveListItem extends BaseListItem
	{
		public var tfObjective: TextField;
		public var mcHighlight : MovieClip;
		public var mcNewOverlay : MovieClip;

		private static const ANIMATION_DURATION : Number = 500;

		//{region Initialization
		// ------------------------------------------------

		public function HudQuestObjectiveListItem()
		{
			super();
			constraintsDisabled = true;
		}

		//{region Overrides
		// ------------------------------------------------

		override protected function configUI():void
		{
			super.configUI();

			tfObjective.wordWrap = true;
			tfObjective.autoSize = TextFieldAutoSize.CENTER; // TBD: why is the component autoSize property useless...
			mcHighlight.visible = false;
			mcNewOverlay.alpha = 0;
		}

		//{region Overrides
		// ------------------------------------------------

		override public function setActualSize(newWidth:Number, newHeight:Number):void
		{
			// Do nothing.
			// Stops the unwanted resizing behavior because the movie clip has a different frame size when showing an icon.
		}

		override public function setData( data:Object ):void
		{
			visible = false;

			super.setData( data );

			if ( data )
			{
				tfObjective.htmlText = data.name;
				Highlight( data.isHighlighted );
				ResizeElements();

				if ( data.isNew )
				{
					ShowNewFeedback();
					data.isNew = false;
				}
				validateNow();
			}
		}

		//{region Updates
		// ------------------------------------------------

		public function ShowNewFeedback()
		{		
			GTweener.removeTweens(mcNewOverlay);
			GTweener.to(mcNewOverlay, ANIMATION_DURATION / 1000, { alpha: 1 }, { onComplete:handleNewFeedbackShowComplete } );
		}

		protected function handleNewFeedbackShowComplete( curTween:GTween ):void
		{
			GTweener.removeTweens(mcNewOverlay);
			GTweener.to(mcNewOverlay, ANIMATION_DURATION / 1000, { alpha: 0 } );			
		}

		private function ResizeElements() : void
		{
			mcHighlight.width = tfObjective.textWidth + 10;
			mcHighlight.height = tfObjective.textHeight + 10;
			mcHighlight.y = tfObjective.y;

			mcNewOverlay.width = tfObjective.textWidth + 10;
			mcNewOverlay.height = tfObjective.textHeight + 10;
			mcNewOverlay.x = tfObjective.x + 141;
			mcNewOverlay.y = tfObjective.y  + mcNewOverlay.height / 2;
		}

		public function Highlight( state : Boolean )
		{
			if ( !data )
			{
				return;
			}
			data.isHighlighted = state;
			mcHighlight.visible = state;
			
			if ( data.isHighlighted )
			{
				tfObjective.textColor = 0xFFFFFF;
			}
			else
			{
				tfObjective.textColor = 0x999999;
			}
		}
	}
}
