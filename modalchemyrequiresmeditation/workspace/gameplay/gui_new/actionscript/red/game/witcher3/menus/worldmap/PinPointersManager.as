package red.game.witcher3.menus.worldmap 
{
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import red.game.witcher3.data.StaticMapPinData;
	import red.game.witcher3.utils.CommonUtils;
	
	/**
	 * ...
	 * @author Getsevich Yaroslav
	 */
	public class PinPointersManager
	{	
		private const POINTER_SCALE:Number = 1;
		private const DETECT_PADDING:Number =  -5;
		private const DRAW_PADDING:Number = 5;
		private const QUEST_POINTER_DEF_REF:String = "QuestPinPointer";
		private const USERPIN_POINTER_DEF_REF:String = "UserPinPointer";
		private const PLAYER_POINTER_DEF_REF:String = "PlayerPinPointer";
		
		private static var _instance:PinPointersManager;
		
		private var _canvas:Sprite;			
		private var _pointersMap:Dictionary;
		
		// canvas points
		private var _a, _b, _c, _d, _centerPoint : Point;
		
		public static function getInstance():PinPointersManager
		{
			if (!_instance) _instance = new PinPointersManager();
			return _instance;
		}
		
		protected var _disabled:Boolean = false;
		public function get disabled():Boolean { return _disabled }
		public function set disabled(value:Boolean):void
		{
			_disabled = value;
			
			if (_canvas)
			{
				if (_disabled)
				{
					_canvas.graphics.clear();
					cleanup();
				}	
				_canvas.visible = !_disabled;
			}
		}
		
		public function cleanup():void
		{
			for (var curItem in _pointersMap)
			{
				delete _pointersMap[curItem];
			}
			
			while (_canvas.numChildren > 0)
			{
				_canvas.removeChild(_canvas.getChildAt(0));
			}
		}
		
		public function init(canvas:Sprite):void
		{
			_pointersMap = new Dictionary(true);
			_canvas = canvas;
			
			_a = new Point(-_canvas.width / 2 - DETECT_PADDING, -_canvas.height / 2 - DETECT_PADDING);
			_b = new Point(_canvas.width / 2 + DETECT_PADDING, -_canvas.height / 2 - DETECT_PADDING);
			_c = new Point(_canvas.width / 2 + DETECT_PADDING, _canvas.height / 2 + DETECT_PADDING);
			_d = new Point( -_canvas.width / 2 - DETECT_PADDING, _canvas.height / 2 + DETECT_PADDING);
			
			_centerPoint = new Point(0, 0);
		}
		
		public function updatePointersPosition():void
		{
			if (_disabled)
			{
				return;
			}
			
			_canvas.graphics.clear();
			
			for (var curItem in _pointersMap)
			{
				var curPin:StaticMapPinDescribed = curItem as StaticMapPinDescribed;
				
				if (curPin && curPin.parent)
				{
					var curPointOrigin:Point = new Point(curPin.x, curPin.y);
					var curPointGlobal:Point = curPin.parent.localToGlobal(curPointOrigin);
					var curPoint:Point = _canvas.globalToLocal(curPointGlobal);
					var curPointer:MovieClip = _pointersMap[curPin];
					var pointOfIntersection:Point;
					
					if (curPointer)
					{
						pointOfIntersection = CommonUtils.getPointOfIntersection(_a, _b, _centerPoint, curPoint);
						
						if (!pointOfIntersection) pointOfIntersection = CommonUtils.getPointOfIntersection(_b, _c, _centerPoint, curPoint);
						if (!pointOfIntersection) pointOfIntersection = CommonUtils.getPointOfIntersection(_c, _d, _centerPoint, curPoint);
						if (!pointOfIntersection) pointOfIntersection = CommonUtils.getPointOfIntersection(_d, _a, _centerPoint, curPoint);
						
						if (pointOfIntersection)
						{
							if (curPointer)
							{
								var dx:Number = _centerPoint.x - curPointer.x;
								var dy:Number = _centerPoint.y - curPointer.y;
								var anglRad:Number = Math.atan2(dx, dy);
								var anglGrad:Number = - anglRad / Math.PI * 180;
								var lineOffsetX:Number = DRAW_PADDING * Math.cos(anglRad);
								var lineOffsetY:Number = DRAW_PADDING * Math.sin(anglRad);
								
								curPointer.rotation =  anglGrad;
								curPointer.x = pointOfIntersection.x - lineOffsetX;
								curPointer.y = pointOfIntersection.y - lineOffsetX;
								
								if (!curPointer.alpha && curPointer.visible)
								{
									curPointer.alpha = 1;
								}
							}
							
							/* 
							 * debug lines
							 */
							/*
							_canvas.graphics.lineStyle(1, 0xFFFF00, .35);
							_canvas.graphics.moveTo(curPoint.x, curPoint.y);
							_canvas.graphics.lineTo(pointOfIntersection.x, pointOfIntersection.y);
							_canvas.graphics.lineStyle(1, 0xFF0000, .35);
							_canvas.graphics.lineTo(_centerPoint.x, _centerPoint.y);
							*/
							
						}
						else
						{
							_canvas.graphics.clear();
						}
					}
				}
				else 
				if (curPin)
				{
					curPin.visible = false;
				}
			}
			
			/*
			 * debug lines
			 */
			/*
			_canvas.graphics.lineStyle(1, 0x008000, .5);
			_canvas.graphics.moveTo(_a.x, _a.y);
			_canvas.graphics.lineTo(_b.x, _b.y);
			_canvas.graphics.lineTo(_c.x, _c.y);
			_canvas.graphics.lineTo(_d.x, _d.y);
			_canvas.graphics.lineTo(_a.x, _a.y);
			*/
		}
		
		public function addPinPointer(mapPin:StaticMapPinDescribed):void
		{
			var pinData:StaticMapPinData = mapPin.data as StaticMapPinData;
			
			if (pinData)
			{
				var targetClass:String;
				var newPointer:MovieClip 
				
				if (pinData.isQuest)
				{
					targetClass = QUEST_POINTER_DEF_REF;
				}
				else
				if (pinData.isPlayer)
				{
					targetClass = PLAYER_POINTER_DEF_REF;
				}
				else 
				if (pinData.isUserPin )
				{
					targetClass = USERPIN_POINTER_DEF_REF;
				}
				
				if (!_pointersMap[mapPin])
				{
					newPointer = createPointer(targetClass, pinData.isUserPin? pinData.type: "");
					_pointersMap[mapPin] = newPointer;
				}
			}
		}
		
		public function removePinPointer():void
		{
			// TODO:
		}
		
		public function showPinPointer(mappin:StaticMapPinDescribed, visibility:Boolean):void
		{
			var targetPointer:MovieClip = _pointersMap[mappin];
			
			if (targetPointer && targetPointer.visible != visibility)
			{
				targetPointer.alpha = 0;
				targetPointer.visible = visibility;
			}
		}
		
		private function createPointer(classRefName:String, label : String):MovieClip
		{
			var pointerMovieClip:MovieClip;
			
			try
			{
				var ClassRef:Class = getDefinitionByName(classRefName) as Class;
				
				pointerMovieClip = new ClassRef();
				pointerMovieClip.scaleX = pointerMovieClip.scaleY = POINTER_SCALE;
				pointerMovieClip.visible = false;
				if ( label != "" )
				{
					pointerMovieClip.gotoAndStop( label );
				}
			}
			catch (er:Error)
			{
				// create debug mc
				
				pointerMovieClip = new MovieClip();
				
				var cnv:Graphics = pointerMovieClip.graphics;
				
				cnv.beginFill(0xFF0000);
				cnv.lineStyle(2, 0XCC0000);
				cnv.drawCircle(0, 0, 10);
				cnv.endFill();
			}
			
			_canvas.addChild(pointerMovieClip);			
			return pointerMovieClip;
		}
		
	}

}
