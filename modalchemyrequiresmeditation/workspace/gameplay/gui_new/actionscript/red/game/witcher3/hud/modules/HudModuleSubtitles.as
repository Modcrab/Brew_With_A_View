package red.game.witcher3.hud.modules
{
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import red.core.CoreHudModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.utils.CommonUtils;

	import flash.text.TextField;
	import scaleform.gfx.Extensions;

	import red.game.witcher3.utils.motion.TweenEx;
	import fl.transitions.easing.Strong;

	public class HudModuleSubtitles extends HudModuleBase
	{
		public var tfSubtitles:TextField;
		private var _currentId:int = 0;
		private var _defaultWidth;
		private var _defaultX;

		public function HudModuleSubtitles()
		{
			super();
			tfSubtitles.htmlText = "";
			tfSubtitles.autoSize = TextFieldAutoSize.CENTER;
			tfSubtitles.multiline = true;
			tfSubtitles.wordWrap = true;
			_defaultWidth  	= tfSubtitles.width;
			_defaultX		= tfSubtitles.x;
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function get moduleName():String
		{
			return "SubtitlesModule";
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function configUI():void
		{
			super.configUI();
			visible = false;
			alpha = 1;
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}
		
		////////////////////////////////////////////
		//
		// reused in PosterMenu::SetSubtitlesHack, if you change anything here, change out there as well
		//
		private static const BLOCK_PADDING:Number = 160;
		public function addSubtitle( id:int, speakerNameDisplayText:String, dialogLineDisplayHtmlText:String )
		{
			tfSubtitles.htmlText =  "<b><font color='#FFFFFF'>" + speakerNameDisplayText + "</font>" + dialogLineDisplayHtmlText;
			tfSubtitles.height = tfSubtitles.textHeight + CommonConstants.SAFE_TEXT_PADDING+12;
			
			//var safeRect:Rectangle = CommonUtils.getScreenRect();
			var safePadding:Number = 1080 * .95;
			tfSubtitles.y = safePadding - tfSubtitles.height - BLOCK_PADDING;
			_currentId = id;
			ShowElement( true );
		}
		//
		//
		////////////////////////////////////////////

		public function removeSubtitle( id:int ):void
		{
			if  ( id == _currentId )
			{
				tfSubtitles.htmlText = "";
				_currentId = 0;
			}
			ShowElement( false );
		}
		
		public function updateWidth( horizontalScale : Number ) : void
		{
			// Increase the difference so the textfield width will reduce faster than the screen scale
			// That is meant to compensate the fact that the textfield has UI elements getting closer on both left and right sides
			// Ex: if screen scale is 20% smaller, textfield width becomes 40% smaller (x 2)
			horizontalScale		= 1 - (( 1 - horizontalScale ) * 2);
			
			tfSubtitles.width 	= _defaultWidth * horizontalScale;
			tfSubtitles.x  		= _defaultX + ( ( _defaultWidth - tfSubtitles.width ) * 0.5 ) ;
		}
		
		override public function SetScaleFromWS( scale : Number ) : void { /* don't scale*/ }
		
		override protected function effectFade( target:Object , value : Number, time : int = FADE_DURATION ):void
		{
			var tweenEx : TweenEx;
			pauseTweenOn(target);
			desiredAlpha = value;
			tweenEx = TweenEx.to( time, target, { alpha:value }, { paused:false, ease:Strong.easeOut, onComplete:handleTweenComplete } );
			targetTweens.push(tweenEx);
		}
	}
}
