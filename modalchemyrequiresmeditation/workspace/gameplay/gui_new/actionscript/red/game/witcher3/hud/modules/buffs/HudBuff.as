package red.game.witcher3.hud.modules.buffs
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import red.game.witcher3.constants.CommonConstants;

	import red.game.witcher3.hud.LightweightUILoader;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.controls.ListItemRenderer;

	public class HudBuff extends ListItemRenderer
	{

	//{region Art clips
	// ------------------------------------------------
		protected static const STACK_PADDING:Number = 4;
		
		public var mcBuffDuration:HudBuffDurationBar;
		public var tfTimer:TextField;
		public var tfTitle:TextField;
		public var mcBuffUpdate:MovieClip;
		public var negativeBackground: MovieClip;
		public var positiveBackground: MovieClip;
		public var mcPermaBuffCircle: MovieClip;
		public var mcBuffStackIndicator: MovieClip;
		private var minimalView: Boolean;
		private var _iconLoader:LightweightUILoader;

	//{region Internal clips
	// ------------------------------------------------

	//{region Private constants
	// ------------------------------------------------

	//{region Internal properties
	// ------------------------------------------------

	private var _IconName : String = "";

	private var _percent:Number = NaN;
	
	private var _lowerBuffPosition : Point;
	
	private var _format : int;

	//{region Component properties
	// ------------------------------------------------

	//{region Component setters/getters
	// ------------------------------------------------

	//{region Initialization
	// ------------------------------------------------

		public function HudBuff()
		{
			super();
		}

	//{region Public functions
	// ------------------------------------------------
		public function setMinimalView(value : Boolean )
		{
			minimalView = value;
			//updateText();
			tfTimer.visible = !minimalView;
			tfTitle.visible = !minimalView;
			
			
		}
		/*
		override protected function updateText():void 
		{
			super.updateText();
			tfTimer.visible = minimalView;
			tfTitle.visible = minimalView;
		}
		*/
		
		public function reset():void
		{
			mcBuffDuration.reset();
		}

		public function getFormat() : int
		{
			return _format;
		}
		
		public function getLowerBuffPosition() : Point
		{
			return _lowerBuffPosition;
		}
		
		public function updatePercent(newPercent : Number):void
		{

			if ( newPercent != mcBuffDuration.percent )
			{
				mcBuffDuration.percent = newPercent;
				mcBuffDuration.validateNow();
			}
			
		}
		
		
		public function updateCounter( val : Number, maxVal : Number )
		{
			if (mcBuffStackIndicator)
			{
				if (mcBuffStackIndicator.visible == false )
				{
					mcBuffStackIndicator.visible = true;
					tfTimer.text = "";
				}
				mcBuffStackIndicator.tfBuffStack.text = val + ( ( _format == 2 )? "%": "" );
				mcBuffStackIndicator.mcStackBackground.x = mcBuffStackIndicator.tfBuffStack.x + mcBuffStackIndicator.tfBuffStack.width - mcBuffStackIndicator.tfBuffStack.textWidth/2 -STACK_PADDING/2;
				mcBuffStackIndicator.mcStackBackground.width = mcBuffStackIndicator.tfBuffStack.textWidth + STACK_PADDING ;
			}
			
			//tfTimer.text = "" + val + "/" + maxVal;
			//tfTimer.y = tfTitle.y + tfTitle.textHeight + 5;
			
		}

		public function updateTimer(timeLeft:int, maxTime : int ):void
		{
			if ( !data )
			{
				return;
			}
			
			if (timeLeft <=5 && !expireTween )
			{
				displayExpireFeedback();
			}
			else if (timeLeft >5 && expireTween )
			{
				expireTween = null;
				alpha = 1;
				GTweener.removeTweens(this);
			}
			if ( !( _format == 1 || _format == 2 ) && mcBuffStackIndicator.visible)
			{
				mcBuffStackIndicator.visible = false;
			}
			if ( minimalView )
			{
				return;
			}

			if ( data.initialDuration < 1.0 )
			{
				tfTimer.text = "";
				return;
			}
			if ( maxTime < timeLeft )
			{
				tfTimer.text = "";
				return;
			}
			
			var formattedString:String;
			var nMins:int;
			var nSeconds:int;

			nMins = int(timeLeft / 60);
			nSeconds = timeLeft % 60;
			tfTimer.text = "" + formatLeadingZero(nMins) + ":" + formatLeadingZero(nSeconds);
			tfTimer.y = tfTitle.y + tfTitle.textHeight + 5;
		}
		
		public function updateTimerAndCounter(timeLeft:int, maxTime : int, extraValue : int):void
		{
			if ( !data )
			{
				return;
			}
			
			if (timeLeft <=5 && !expireTween )
			{
				displayExpireFeedback();
			}
			else if (timeLeft >5 && expireTween )
			{
				expireTween = null;
				alpha = 1;
				GTweener.removeTweens(this);
			}

			if (mcBuffStackIndicator)
			{
				if (mcBuffStackIndicator.visible == false )
				{
					mcBuffStackIndicator.visible = true;
					tfTimer.text = "";
				}
				mcBuffStackIndicator.tfBuffStack.text = extraValue + ( ( _format == 2 || _format == 4 )? "%": "" );
				mcBuffStackIndicator.mcStackBackground.x = mcBuffStackIndicator.tfBuffStack.x + mcBuffStackIndicator.tfBuffStack.width - mcBuffStackIndicator.tfBuffStack.textWidth/2 -STACK_PADDING/2;
				mcBuffStackIndicator.mcStackBackground.width = mcBuffStackIndicator.tfBuffStack.textWidth + STACK_PADDING ;
			}
			
			if ( minimalView )
			{
				return;
			}

			if ( data.initialDuration < 1.0 )
			{
				tfTimer.text = "";
				return;
			}
			if ( maxTime < timeLeft )
			{
				tfTimer.text = "";
				return;
			}
			
			var formattedString:String;
			var nMins:int;
			var nSeconds:int;

			nMins = int(timeLeft / 60);
			nSeconds = timeLeft % 60;
			tfTimer.text = "" + formatLeadingZero(nMins) + ":" + formatLeadingZero(nSeconds);
			tfTimer.y = tfTitle.y + tfTitle.textHeight + 5;
		}
		
		public function updateEmpty()
		{
			if (mcBuffStackIndicator)
			{
				if (mcBuffStackIndicator.visible  )
				{
					mcBuffStackIndicator.visible = false;
				}
				tfTimer.text = "";
				mcBuffStackIndicator.tfBuffStack.text = "";
			}
		}
		
		private var expireTween : GTween;
		public function displayExpireFeedback()
		{
			
			expireTween = GTweener.to(this, 0.5, { alpha:0.4 },{repeatCount : 0 , reflect : true} );
		}

		private function formatLeadingZero(value:int):String
		{
			return (value < 10) ? "0" + value.toString() : value.toString();
		}


	//{region Overrides
	// ------------------------------------------------

		override protected function configUI():void
		{
			super.configUI();
			visible = false;
			mcBuffStackIndicator.visible = false;
			negativeBackground.visible = false;
			positiveBackground.visible = false;
			setMinimalView(true);
		}

		override public function setData( data:Object ):void
		{
			super.setData( data );
			if (! data )
			{
				return;
			}
			else
			{
				_format = data.format;
				if ( !( _format == 1 || _format == 2 ) && mcBuffStackIndicator.visible)
				{
					mcBuffStackIndicator.visible = false;
				}
				if (data.isVisible == true)
				{
					this.visible = true;
					expireTween = null;
					alpha = 1;
					GTweener.removeTweens(this);
					if (data.iconName != "")
					{
						_IconName = data.iconName;
					}
					else
					{
						_IconName = "";
					}
					if(data.title)
					{
						tfTitle.htmlText = data.title;
						tfTimer.y = tfTitle.y + tfTitle.textHeight + 5;
						_lowerBuffPosition = localToGlobal( new Point( 0, tfTimer.y + tfTimer.textHeight + 30 ) );

						//tfTitle.width = tfTitle.textWidth + CommonConstants.SAFE_TEXT_PADDING;
						//tfTitle.x = - tfTitle.width / 2;
					}

					if (data.duration && data.initialDuration)
					{
						if ( data.duration != -1.0 )
						{
							_percent = data.duration / data.initialDuration;
						}
						else
						{
							_percent = 0.0; // 100 %
						}
					}
					mcBuffDuration.setPositive(data.isPositive);
					setBuffBackground( data.isPositive );
					update();
				}
				else
				{
					expireTween = null;
					GTweener.removeTweens(this);
					mcBuffStackIndicator.visible = false;
					this.visible = false;
					
				}
			}
		}

	//{region Updates
	// ------------------------------------------------

		public function update()
		{
			updateIcon();
			updatePercent(_percent);
		}
		
		private function setBuffBackground( value: int ): void
		{
			
			if ( value == 0)
			{
				positiveBackground.visible = false;
				negativeBackground.visible = true;
			}
			else
			{
				positiveBackground.visible = true;
				negativeBackground.visible = false;
			}
			
		}

		private function updateIcon():void
		{
			if ( _iconLoader && _iconLoader.source && _iconLoader.source.length && ( _iconLoader.source == _IconName ) )
			{
				// do not unload & load when it's the same icon
				return;
			}

			if (_IconName && _IconName != "") 
			{
				if ( _iconLoader )
				{
					_iconLoader.unload();
					removeChild( _iconLoader );
				}
				
				var imageLoaderClass = getDefinitionByName("IconLoaderRef");
				_iconLoader = new imageLoaderClass();

				_iconLoader.source = "img://" + _IconName;
			
				_iconLoader.x = -19;
				_iconLoader.y = -19;

				addChild( _iconLoader );
				addChild( mcBuffStackIndicator );
			}
		}

		public function set IconName( val : String ):void
		{
			if ( _IconName != val )
			{
				_IconName = val;
				updateIcon();
			}
		}
	}
}
