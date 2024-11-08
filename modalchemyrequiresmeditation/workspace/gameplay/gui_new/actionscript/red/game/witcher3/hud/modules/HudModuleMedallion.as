package red.game.witcher3.hud.modules
{
	import red.core.CoreHudModule;
	import red.core.events.GameEvent;

	import red.game.witcher3.hud.modules.medallion.HudFocusPoint;

	import flash.display.MovieClip;
	
	public class HudModuleMedallion extends HudModuleBase
	{
		public var mcWolfsHead:MovieClip;	
		public var mcBckCircle:MovieClip;	
		public var mcFocusPoint1:HudFocusPoint;
		public var mcFocusPoint2:HudFocusPoint;
		public var mcFocusPoint3:HudFocusPoint;
		public var mcFocusPoint4:HudFocusPoint;
		public var mcFocusPoint5:HudFocusPoint;

		private var _focusPointClips:Vector.<HudFocusPoint> = new Vector.<HudFocusPoint>();

		public function HudModuleMedallion() 
		{
			super();
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function get moduleName():String
		{
			return "MedallionModule";
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function configUI():void
		{
			super.configUI();	
			
			x = 100;
			y = 100;
			z = 100;
			scaleX = 1;
			scaleY = 1;
			visible = true;

			var id:int = 1;
			var focusPointClip:MovieClip;
			for (;;)
			{
				focusPointClip = MovieClip( getChildByName( "mcFocusPoint" + (id++) ) );
				if ( ! focusPointClip )
				{
					break;
				}
				_focusPointClips.push( focusPointClip );
				focusPointClip.enabled = false;
			}
			//GameInterface.sendDisplayObject( this, 'MedallionView' );

			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}
		
		public function setFocusPoints( value:int ):void
		{
			var len : uint = _focusPointClips.length;
			for( var i : uint = 0; i < len; i++ )
			{
				var focusPointClip:HudFocusPoint = _focusPointClips[ i ];
				focusPointClip.enabled = ( i < value );
				focusPointClip.validateNow(); // snappier response
			}
		}
		
		public function setVitality( value:Number, maxValue:Number ):void
		{
			mcWolfsHead.percent = maxValue > 0.0 ? value / maxValue : 0.0;
			mcWolfsHead.validateNow(); // snappy response time
		}
		
		public function setMedallionActive( value:Boolean ):void
		{
			mcWolfsHead.ShakeIt(value);
		}
		
		public function setMedallionThreshold( value:Number ):void
		{
			mcWolfsHead.threshold = value;
		}
	}
	
}
