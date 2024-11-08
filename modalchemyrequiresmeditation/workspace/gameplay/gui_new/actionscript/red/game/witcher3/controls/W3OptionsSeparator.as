package red.game.witcher3.controls 
{
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	public class W3OptionsSeparator extends MovieClip
	{
		public var label : TextField;
		public var leftLine : MovieClip;
		public var rightLine : MovieClip;
		
		public override function set width ( value:Number ) : void
		{
			label.width = label.textWidth;
			//label.scaleX
			var totalLineWidth : int = value - label.textWidth;
			var leftPadding : int = 5;
			var rightPadding : int = 15;

			if (label.textWidth == 0)
			{
				// No text, just one big line
				rightLine.visible = false;
				leftLine.width = totalLineWidth;
			}
			else
			{
				leftLine.width = totalLineWidth / 2 - leftPadding;
				rightLine.width = totalLineWidth / 2 - rightPadding;
				
				leftLine.x = 0;
				label.x = leftLine.width + leftPadding;
				rightLine.x = leftLine.width + label.textWidth + rightPadding;
			}
		}
		
		public override function set height ( value:Number ) : void
		{
			label.height = value;
		}
	}
}