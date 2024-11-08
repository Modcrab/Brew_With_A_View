package red.game.witcher3.menus.worldmap
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import scaleform.clik.core.UIComponent;
	import red.game.witcher3.utils.CommonUtils;

	public class UniverseArea extends UIComponent
	{
		protected static const INVALID_ACTIVE_KEY:String = "invalid.active.key";
		
		public var mcPlayerIndicator:MovieClip;
		public var mcQuestIndicator:MovieClip;
		public var mcIcon:MovieClip;
		public var mcBackground:MovieClip;
		public var mcBorder:MovieClip;
		public var tfLabel:TextField;
		public var mcCenterPosition:MovieClip;
		public var recLevel:Number;
				
		protected var m_worldName : String;
		protected var m_realWorldName : String;
		
		override protected function configUI():void
		{
			super.configUI();
			
			isActive = false;
			if (_activeDataKey != UniverseArea.INVALID_ACTIVE_KEY)
			{
				dispatchEvent( new GameEvent(GameEvent.REGISTER, _activeDataKey, [setIsActive]));
			}
			
			mcIcon.gotoAndStop("inactive");
		}

		protected var _hasQuest:Boolean
		public function get hasQuest():Boolean { return _hasQuest}
		public function set hasQuest(value:Boolean):void
		{
			_hasQuest = value;
			if ( mcQuestIndicator ) mcQuestIndicator.visible = value;
		}

		protected var _isCurrentArea:Boolean
		public function get isCurrentArea():Boolean { return _isCurrentArea}
		public function set isCurrentArea(value:Boolean):void
		{
			_isCurrentArea = value;
			if (mcPlayerIndicator) mcPlayerIndicator.visible = value;
		}
		
		protected var _isActive : Boolean = false;
		public function get isActive():Boolean { return _isActive; }
		public function set isActive(value:Boolean):void
		{
			_isActive = value;
			
			/*
			if (_isActive)
			{
				if (mcIcon) mcIcon.gotoAndStop("active");
				if (mcBorder) mcBorder.gotoAndStop("active");
			}
			else
			{
				if (mcIcon) mcIcon.gotoAndStop("inactive");
				if (mcBorder) mcBorder.gotoAndStop("inactive");
			}
			*/
		}
		
		protected var _activeDataKey:String
		// Default value should remain UniverseArea.INVALID_ACTIVE_KEY
		[Inspectable(defaultValue = "invalid.active.key")]
		public function get activeDataKey():String { return _activeDataKey; }
		public function set activeDataKey(value:String):void
		{
			_activeDataKey = value;
		}
		
		public function SetWorldName( worldName : String, realWorldName : String = "" )
		{
			m_worldName = worldName;
			m_realWorldName = realWorldName;
			if (tfLabel)
			{
				tfLabel.text = "[[map_location_" + m_worldName + "]]";
				tfLabel.text = CommonUtils.toUpperCaseSafe(tfLabel.text);
				
				if ( mcBackground )
				{
					//tfLabel.numLines
					mcBackground.height = 2.2 * ( tfLabel.y - mcBackground.y ) + tfLabel.textHeight ;
				}
			}
		}

		public function GetWorldName( real : Boolean = false ) : String
		{
			if ( real && m_realWorldName != "" )
			{
				return m_realWorldName;
			}
			return m_worldName;
		}
		
		protected function setIsActive(value:Boolean):void
		{
			isActive = value;
		}
		
		public function GetCenterPosition():Point
		{
			if ( mcCenterPosition )
			{
				return localToGlobal( new Point( mcCenterPosition.x, mcCenterPosition.y ) );
			}
			return localToGlobal( new Point( 0, 0 ) );
		}
	}
}
