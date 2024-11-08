package red.game.witcher3.menus.character_menu
{
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.text.TextField;
	import red.game.witcher3.events.SlotConnectorEvent;
	import red.game.witcher3.slots.SlotSkillMutagen;
	import red.game.witcher3.slots.SlotSkillSocket;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * ...
	 * @author Yaroslav Getsevich
	 */
	public class SkillSocketsGroup extends EventDispatcher
	{
		public var mutagenSlot:SlotSkillMutagen;
		public var dnaBranch:MovieClip;
		public var connector:SkillSlotConnector;
		public var bonusText:TextField;
		
		protected var _skillSlotConnectorsList:Vector.<SkillSlotConnector>;
		protected var _skillSlotRefs:Vector.<SlotSkillSocket>;
		protected var _currentColor:String;
		protected var _mutagenData:Object;
		
		public function SkillSocketsGroup()
		{
			_skillSlotConnectorsList	= new Vector.<SkillSlotConnector>;
			_skillSlotRefs = new Vector.<SlotSkillSocket>;
		}
		
		public function addSlotConnector(targetSlot:SkillSlotConnector):void
		{
			_skillSlotConnectorsList.push(targetSlot);
		}
		
		public function addSlotSkillRef(targetRef:SlotSkillSocket)
		{
			_skillSlotRefs.push(targetRef);
		}
		
		public function get mutagenData():Object { return _mutagenData }
		public function set mutagenData(value:Object):void
		{
			trace("GFX [SkillSocketsGroup] set mutagenData ------------- ", value);
			
			if (value)
			{
				trace("GFX ", value.color);
			}
			
			_mutagenData = value;
			_mutagenData.gridSize = 1;
			mutagenSlot.cleanup();
			mutagenSlot.data = _mutagenData;
			updateData();
		}
		
		const COLOR_NONE:String = "SC_None";
		const COLOR_MIX:String = "SC_Mix";
		public function updateData():void
		{
			var skillExist:Boolean;
			var len:int = _skillSlotConnectorsList.length;
			var i:int;
			var mutagenColor:String = mutagenSlot.data ? mutagenSlot.data.color : COLOR_NONE;
			skillExist = false;
			
			if (_skillSlotRefs.length != _skillSlotConnectorsList.length)
			{
				throw new Error("GFX [ERROR] " + this + " has invalid number of skills to connectors: " + _skillSlotRefs.length + ", " + _skillSlotConnectorsList.length);
			}
			
			/*
			trace("GFX [SkillSocketsGroup][", mutagenSlot, "] ------------------------------ updateData ", mutagenColor, mutagenSlot.data);
			
			if( mutagenSlot.data )
			{
				trace("GFX * ", mutagenSlot.data.color );
			}
			*/
			
			for (i = 0; i < len; i++)
			{
				if (_skillSlotConnectorsList[i])
				{
					if (mutagenColor != COLOR_NONE && _skillSlotRefs[i].data != null && mutagenColor == _skillSlotRefs[i].data.color)
					{
						
						_skillSlotConnectorsList[i].currentColor = mutagenColor;
						skillExist = true;
					}
					else
					{
						_skillSlotConnectorsList[i].currentColor = COLOR_NONE;
					}
				}
			}
			
			if (skillExist)
			{
				connector.currentColor = mutagenColor;
			}
			else
			{
				connector.currentColor = COLOR_NONE;
			}
		}
		
		protected function getGroupColor(colorsList:Array):String
		{
			var curGroupColor:String = COLOR_NONE;
			var len:int = colorsList.length;
			for (var i:int; i < len; i++)
			{
				if (colorsList[i] != curGroupColor && colorsList[i] != COLOR_NONE)
				{
					if (curGroupColor == COLOR_NONE)
					{
						curGroupColor = colorsList[i];
					}
					else
					{
						return COLOR_NONE;
					}
				}
			}
			return curGroupColor;
		}
		
		protected function getGroupBonus(groupColor:String):String
		{
			return "";
		}
		
	}
}
