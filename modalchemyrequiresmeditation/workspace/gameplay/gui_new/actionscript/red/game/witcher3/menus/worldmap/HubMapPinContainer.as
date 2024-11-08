package red.game.witcher3.menus.worldmap
{
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.StaticText;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.events.MapContextEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.utils.CommonUtils;
	import red.game.witcher3.utils.Math2;

	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.data.ListData;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.constants.NavigationCode;

	import red.core.constants.KeyCode;
	import red.core.data.InputAxisData;
	import red.core.utils.InputUtils;
	import red.core.events.GameEvent;
	import red.game.witcher3.data.StaticMapPinData;
	
	
	public class HubMapPinContainer extends UIComponent
	{
		public var _defCanvas:Sprite;
		public var _areaCanvas:Sprite;
		public var _travelCanvas:Sprite;
		public var _questCanvas:Sprite;
		public var _boardsCanvas:Sprite;
		public var _selectedCanvas:Sprite;

		public function HubMapPinContainer()
		{
			_defCanvas = new Sprite();
			_areaCanvas = new Sprite();
			_travelCanvas = new Sprite();
			_questCanvas = new Sprite();
			_boardsCanvas = new Sprite();
			_selectedCanvas = new Sprite();
			
			addChild(_areaCanvas);
			addChild(_defCanvas);
			addChild(_boardsCanvas);
			addChild(_questCanvas);
			addChild(_travelCanvas);
			addChild(_selectedCanvas);
		}
		
		public function getPinCanvas(pinData:StaticMapPinData):Sprite
		{
			var resultCanvas:Sprite = _defCanvas;
			
			if (!pinData)
			{
				return resultCanvas;
			}
			
			if (pinData.radius > 0)
			{
				resultCanvas = _areaCanvas;
			}
			else
			{
				switch (pinData.type)
				{
					case 'RoadSign':
					case 'Harbor':
						resultCanvas = _travelCanvas;
						break;
					case 'StoryQuest':
					case 'ChapterQuest':
					case 'SideQuest':
					case 'MonsterQuest':
					case 'TreasureQuest':
						resultCanvas = _questCanvas;
						break;
					case 'NoticeBoard':
						resultCanvas = _boardsCanvas;
						break;
					default:
						resultCanvas = _defCanvas;
				}
			}
			
			return resultCanvas;
		}
		
	}
	
}
