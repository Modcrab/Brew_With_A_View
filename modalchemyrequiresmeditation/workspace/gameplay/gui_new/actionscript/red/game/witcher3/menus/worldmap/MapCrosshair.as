package red.game.witcher3.menus.worldmap
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import scaleform.clik.controls.Label;
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.Exponential;
	
	/**
	 * Crosshair for Hub Map
	 * @author Getsevich Yaroslav
	 */
	public class MapCrosshair extends MovieClip
	{
		private const LABEL_SNAP:String = "snap";
		private const LABEL_NORMAl:String = "normal";
		private const ANIM_DURATION:Number = 1;
		private const DESC_PADDING:Number = 60;
		
		private var _capturedState:Boolean;
		private var _label:String;
		
		public var mcDescription:Label;
		
		public function MapCrosshair()
		{
			mcDescription.visible = false;
		}
		
		public function get capturedState():Boolean { return _capturedState }
		public function set capturedState(value:Boolean):void
		{
			_capturedState = value;
			gotoAndPlay(_capturedState ? LABEL_SNAP : LABEL_NORMAl);
		}
		
		public function showLabel( value : String, immediately : Boolean = false ):void
		{
			//trace("Minimap showLabel " + value + " " + immediately );

			_label = value;
			
			mcDescription.visible = true;
			mcDescription.htmlText = _label;
			mcDescription.validateNow();
			
			var descBackground:Sprite = mcDescription["background"] as Sprite;
			descBackground.width = mcDescription.textField.textWidth + DESC_PADDING;

			if ( immediately )
			{
				mcDescription.alpha = 1;
			}
			else
			{
				mcDescription.alpha = 0;
				GTweener.removeTweens(mcDescription);
				GTweener.to(mcDescription, ANIM_DURATION, { alpha:1 }, { ease:Exponential.easeOut } );
			}
		}
		
		public function hideLabel( immediately : Boolean = false ):void
		{
			//trace("Minimap hideLabel " + immediately );
			if ( immediately )
			{
				handleLabelHidden();
			}
			else
			{
				GTweener.removeTweens(mcDescription);
				GTweener.to(mcDescription, ANIM_DURATION, { alpha:0 }, { ease:Exponential.easeOut, onComplete:handleLabelHidden } );
			}
		}
		
		protected function handleLabelHidden(event:GTween = null):void
		{
			mcDescription.visible = false;
		}
		
	}
}
