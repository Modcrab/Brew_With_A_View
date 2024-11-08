package red.game.witcher3.menus.inventory_menu 
{	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.controls.StatusIndicator;
	import scaleform.clik.core.UIComponent;
	
	/*
	 * Displaying single character stat in the Inventory Menu
	 * red.game.witcher3.menus.inventory_menu.PlayerStatInfo
	 */
	
	public class PlayerStatInfo extends UIComponent
	{
		public static const TYPE_VITALITY:String = "vitality";
		public static const TYPE_TOXICITY:String = "toxicity";
		
		public var tfLabel:TextField;
		public var tfValue:TextField;
		public var mcProgressBar:StatusIndicator;
		public var mcGlowNegative:MovieClip;		
		public var mcGlowPositive:MovieClip;
		public var mcIcon:MovieClip;
		public var mcIconAnimation:MovieClip;
		
		protected var _min:Number;
		protected var _max:Number;
		protected var _value:Number;
		protected var _label:String;
		protected var _type:String;
		protected var _isPositive:Boolean;
		protected var _dangerLimit:Number = -1;
		protected var _isPercentage:Boolean;
		
		private var _dataSet:Boolean;
		
		public function PlayerStatInfo() 
		{
			mcIcon = mcIconAnimation.getChildByName("mcIcon") as MovieClip;
			mcGlowNegative.visible = false;
			mcGlowPositive.visible = false;
			_dataSet = false;
		}
		
		public function get label():String { return _label }
		public function set label(value:String):void
		{
			_label = value;
			tfLabel.text = _label;
			tfLabel.htmlText = CommonUtils.toUpperCaseSafe(tfLabel.text);
			tfLabel.width = tfLabel.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			tfLabel.x = mcProgressBar.x + mcProgressBar.actualWidth / 2 - tfLabel.width / 2;
			if (tfLabel.numLines > 1 )
			{
				tfLabel.y = -53;
			}
			else
			{
				tfLabel.y = -27.2;
			}
			
		}
		
		public function get type():String { return _type; }
		public function set type(value:String):void 
		{
			_type = value;
			mcIcon.gotoAndStop(_type);
		}
		
		public function get dangerLimit():Number { return _dangerLimit; }
		public function set dangerLimit(value:Number):void 
		{
			_dangerLimit = value;
		}
		
		public function get isPositive():Boolean { return _isPositive; }
		public function set isPositive(value:Boolean):void 
		{
			_isPositive = value;
		}
		
		public function get isPercentage():Boolean { return _isPositive; }
		public function set isPercentage(value:Boolean):void 
		{
			_isPercentage = value;
		}
		
		public function setData(value:Number, min:Number = 0, max:Number = 100):void
		{
			trace("GFX [", this, "] setData  ", _value , " -> ", value, "; ", _dataSet);
			
			if (!isNaN(_value) && _dataSet)
			{
				var diff:Number = value - this._value;
				
				if (diff != 0)
				{
					var targetAnim:MovieClip = (diff && _isPositive) ? mcGlowPositive : mcGlowNegative;
					targetAnim.gotoAndPlay("start");
				}
			}
			
			_value = value;
			_min = min;
			_max = max;
			
			mcProgressBar.minimum = min;
			mcProgressBar.maximum = max;
			mcProgressBar.value = value;
			
			if (_dangerLimit != -1)
			{
				var bar:MovieClip = mcProgressBar.getChildByName("mcBar") as MovieClip;
				var curPercent:Number = value / max;
				
				if (_isPositive && curPercent < _dangerLimit)
				{
					bar.gotoAndStop("red");
					mcIconAnimation.gotoAndPlay("start");
				}
				else
				if (!_isPositive && curPercent > _dangerLimit)
				{
					bar.gotoAndStop("red");
					mcIconAnimation.gotoAndPlay("start");
				}
				else
				{
					bar.gotoAndStop("white");
					mcIconAnimation.gotoAndStop("stop");
				}
			}
			
			if (_isPercentage)
			{
				tfValue.text = Math.round(value / max * 100) + " %";
			}
			else
			{
				tfValue.text = String(value);
			}
			
			tfValue.x = mcProgressBar.x + mcProgressBar.actualWidth / 2 - tfValue.width / 2;
			
			_dataSet = true;
		}
		
	}

}