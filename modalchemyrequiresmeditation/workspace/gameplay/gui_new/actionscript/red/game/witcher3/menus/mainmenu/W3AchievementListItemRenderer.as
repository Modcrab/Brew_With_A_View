/***********************************************************************
/** Achievement list item renderer
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import flash.display.MovieClip;
	import flash.text.TextField;

	import scaleform.clik.events.InputEvent;
	import flash.events.MouseEvent;
	import red.game.witcher3.controls.BaseListItem;
	import scaleform.clik.controls.Slider;
	import scaleform.clik.events.SliderEvent;
	import flash.utils.getDefinitionByName;
	import red.core.events.GameEvent;
	import scaleform.clik.controls.UILoader;
	
	public class W3AchievementListItemRenderer extends BaseListItem
	{
		public var tfCurrentValue : TextField;
		public var tfDescription : TextField;
		public var mcIconLoader:UILoader;
		public var mcHitArea : MovieClip;
		private var _currentValue : String = "";
		private var _IconName : String = "";
		
		public function W3AchievementListItemRenderer()
		{
			super();
			preventAutosizing = true;
			//constraintsDisabled = true;
			mouseChildren = mouseEnabled = true;
			hitArea = mcHitArea;
		}
		
		protected override function configUI():void
		{
			super.configUI();
			//addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
		}
		
		override public function setData( data:Object ):void
		{
			super.setData( data );
			if ( !data )
			{
				return;
			}
			
			label = data.label;
			_currentValue = data.current as String;
			if ( !_currentValue )
			{
				if (data.current)
				{
					_currentValue = data.current.toString();
				}
			}
			tfDescription.htmlText = data.description as String;
			_IconName = data.iconPath as String;
			updateIcon();
		}
		
		private function updateIcon():void
		{
			if (_IconName && _IconName != "")
			{
				mcIconLoader.source = "img://" + _IconName;
			}
		}
		
		override protected function updateText():void
		{
			super.updateText();
			updateCurrentValue();
		}
		protected function updateCurrentValue():void
		{
			tfCurrentValue.htmlText = _currentValue;
		}
		
		override protected function updateAfterStateChange():void
		{
		}
		
/*		override public function handleInput(event:InputEvent):void
		{
			mcSlider.handleInput(event);
			if ( !event.handled )
			{
				super.handleInput(event);
			}
        }*/
	}
}
