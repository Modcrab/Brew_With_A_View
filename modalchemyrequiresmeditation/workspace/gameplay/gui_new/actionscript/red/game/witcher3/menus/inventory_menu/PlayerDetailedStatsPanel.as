package red.game.witcher3.menus.inventory_menu
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.menus.common.AdaptiveStatsListItem;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.gfx.Extensions;
	
	/**
	 * red.game.witcher3.menus.inventory_menu.PlayerDetailedStatsPanel
	 * @author Getsevich Yaroslav
	 */
	public class PlayerDetailedStatsPanel extends UIComponent
	{
		private const RENDERER_CLASS_REF:String = "AdaptiveStatsListItem_Ref";
		private const TIME_TEXT_PADDING:Number = 10;
		private const ANIM_OFFSET:Number = 5;
		private const PANEL_PADDING:Number = 145;
		
		public var mcAnchor:MovieClip;
		public var tfTimeLabel:TextField;
		public var tfHoursValue:TextField;
		public var tfMinutesValue:TextField;
		public var tfHoursLabel:TextField;
		public var tfMinutesLabel:TextField;
		
		private var _renderersList:Vector.<AdaptiveStatsListItem>;
		private var _data:Array;
		private var _canvas:Sprite;
		private var _maxValueTextSize:Number = 0;
		
		public function PlayerDetailedStatsPanel()
		{
			_renderersList = new Vector.<AdaptiveStatsListItem>;
			_canvas = new Sprite();
			_canvas.x = mcAnchor.x;
			_canvas.y = mcAnchor.y;
			addChild(_canvas);
			
			tfHoursLabel.text = "[[time_hours]]";
			tfMinutesLabel.text = "[[time_minutes]]";
		}
		
		public function setTimeData(hours:String, minutes:String):void
		{
			tfTimeLabel.text = "[[message_total_play_time]]";
			tfTimeLabel.text = CommonUtils.toUpperCaseSafe(tfTimeLabel.text);
			tfTimeLabel.width = tfTimeLabel.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			
			tfHoursValue.htmlText = hours;
			tfHoursValue.htmlText = CommonUtils.toUpperCaseSafe(tfHoursValue.htmlText);
			tfMinutesValue.htmlText = minutes;
			tfMinutesValue.htmlText = CommonUtils.toUpperCaseSafe(tfMinutesValue.htmlText);
			
			var maxTextWidth:Number = Math.max(tfMinutesValue.textWidth, tfHoursValue.textWidth);
			
			tfHoursValue.width = maxTextWidth + CommonConstants.SAFE_TEXT_PADDING;
			tfMinutesValue.width = maxTextWidth + CommonConstants.SAFE_TEXT_PADDING;
			
			tfHoursValue.x = tfMinutesValue.x = tfTimeLabel.x + tfTimeLabel.width + TIME_TEXT_PADDING;
			tfHoursLabel.x = tfMinutesLabel.x = tfMinutesValue.x + tfMinutesValue.width + TIME_TEXT_PADDING;
		}
		
		public function setData(value:Array):void
		{
			data = value;
		}
		
		public function get data():Array { return _data }
		public function set data(value:Array):void
		{
			if (!_data)
			{
				_data = value;
				cleanupRenderers();
				createRenderers();
			}
			else
			{
				_data = value;
				GTweener.removeTweens(_canvas);
				GTweener.to(_canvas, .2, { alpha:0 }, { ease:Sine.easeIn, onComplete:handleCanvasHidden } );
			}
		}
		
		private function handleCanvasHidden(tw:GTween):void
		{
			cleanupRenderers();
			createRenderers();
			
			GTweener.removeTweens(_canvas);
			GTweener.to(_canvas, .2, { alpha:1 }, { ease:Sine.easeOut } );
		}
		
		private function createRenderers():void
		{
			if (!_data) return;
			
			const HEADER_ITEM_PADDING = 8;
			const SUPER_HEADER_ITEM_PADDING = 20;
			const ITEM_PADDING = 0;
			const VALUE_PADDING = 20;
			
			var len:int = _data.length;
			var curPosition:Number =  0;
			var additionalPadding:Number = 0;
			var classRef:Class = getDefinitionByName(RENDERER_CLASS_REF) as Class;
			
			_maxValueTextSize = 0;
			
			for (var i:int = 0; i < len; ++i)
			{
				var newInstance:AdaptiveStatsListItem = new classRef() as AdaptiveStatsListItem;
				
				additionalPadding = 0;
				
				if (_data[i].tag == "Header")
				{
					curPosition += HEADER_ITEM_PADDING;
				}
				else
				if (_data[i].tag == "SuperHeader")
				{
					additionalPadding += SUPER_HEADER_ITEM_PADDING;
				}
				
				newInstance.setData(_data[i]);
				newInstance.validateNow();
				newInstance.visible = true;
				newInstance.y = curPosition;
				
				trace("GFX --- newInstance ", newInstance.width, newInstance.actualWidth);
				
				var curValueTextSize:Number = newInstance.tfStatValue.textWidth + VALUE_PADDING;
				
				if (_maxValueTextSize < curValueTextSize)
				{
					_maxValueTextSize  = curValueTextSize;
				}
				
				_canvas.addChild(newInstance);
				_renderersList.push(newInstance);
				
				curPosition += (newInstance.rendererHeight + ITEM_PADDING + additionalPadding);
			}
			
			_renderersList.forEach(setRendererTextPosition);
			_canvas.x = mcAnchor.x - _canvas.width + PANEL_PADDING;
			
			/*
			_canvas.x = mcAnchor.x;
			var listSafePos:Number = Extensions.visibleRect.width * 0.95;
			if (this.x + _canvas.x + _canvas.width > listSafePos)
			{
				_canvas.x = listSafePos -_canvas.width - this.x;
			}
			*/
			
			//trace("GFX _canvas", _canvas.width, "; listSafePos ", listSafePos, "; _canvas.x ", _canvas.x );
		}
		
		private function setRendererTextPosition(target:AdaptiveStatsListItem):void
		{
			if (target)
			{
				target.textField.x = _maxValueTextSize;
			}
		}
		
		private function cleanupRenderers():void
		{
			trace("GFX cleanupRenderers ", _renderersList.length);
			
			while (_renderersList.length)
			{
				_canvas.removeChild(_renderersList.pop());
			}
		}
		
	}

}
