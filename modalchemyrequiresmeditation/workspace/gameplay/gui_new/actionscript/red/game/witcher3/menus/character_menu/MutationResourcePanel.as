package red.game.witcher3.menus.character_menu
{
	import flash.text.TextField;
	import red.core.CoreComponent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * red.game.witcher3.menus.character_menu.MutationResourcePanel
	 * @author Getsevich Yaroslav
	 */
	public class MutationResourcePanel extends UIComponent
	{
		public var tfTitle:TextField;
		public var mcRenderer1:MutationResourceInfo;
		public var mcRenderer2:MutationResourceInfo;
		public var mcRenderer3:MutationResourceInfo;
		public var mcRenderer4:MutationResourceInfo;
		
		private var _renderers:Vector.<MutationResourceInfo>;
		private var _data:Array;
		private var _textValue : String;
		
		public function MutationResourcePanel()
		{
			
			
			_renderers = new Vector.<MutationResourceInfo>;
			_renderers.push(mcRenderer1);
			_renderers.push(mcRenderer2);
			_renderers.push(mcRenderer3);
			_renderers.push(mcRenderer4);
		}
		
		
		public function get data():Array { return _data; }
		public function set data(value:Array):void
		{
			_data = value;
			populate();
		}
		
		public function getListHeight():Number
		{
			if (mcRenderer3.visible)
			{
				return mcRenderer3.y + mcRenderer3.actualHeight; // 2 lines
			}
			else
			if (mcRenderer1.visible)
			{
				return mcRenderer1.y + mcRenderer1.actualHeight; // 1 lines
			}
			else
			{
				return 0;
			}
		}
		
		public function playFeedbackAnim():void
		{
			for each (var curItem:MutationResourceInfo in _renderers)
			{
				curItem.playFeedbackAnim();
			}
		}
		
		protected function populate():void
		{
			var dataIdx:int = 0;
			var rdrIdx:int = 0;
			var dataCount:int = _data ? _data.length : 0;
			var rdrCount:int = _renderers.length;
			
	
			tfTitle.text = "[[panel_crafting_ingredients_start]]";
			_textValue = tfTitle.text;
			//tfTitle.width = tfTitle.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			if (CoreComponent.isArabicAligmentMode)
			{
				tfTitle.htmlText = "<p align=\"right\">" + _textValue + "</p>";
			}
			else
			{
				tfTitle.htmlText = CommonUtils.toUpperCaseSafe( _textValue );
			}
			
			while ( dataIdx < dataCount && rdrIdx < rdrCount )
			{
				var curData:Object = _data[dataIdx];
				
				if (curData && curData.required > 0)
				{
					var curItem:MutationResourceInfo = _renderers[rdrIdx];
					
					curItem.visible = true;
					curItem.data = curData;
					rdrIdx++;
				}
				
				dataIdx++;
			}
			
			while ( rdrIdx < rdrCount)
			{
				_renderers[rdrIdx].visible = false;
				rdrIdx++;
			}
		}
		
	}
}
