/***********************************************************************
/** Tooltip stats list item renderer
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.data.ListData;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import flash.events.MouseEvent;

	import red.game.witcher3.controls.BaseListItem;
	
	public class W3StatisticsListItem extends BaseListItem
	{
		public var tfStatValue : TextField;
		protected var _statValue : String = "";
		private var _id : uint;
		public var mcStatInfo : MovieClip;
		
		protected var _statID:String = "";
		[Inspectable(defaultValue="")]
		public function get statID():String { return _statID; }
		public function set statID(value:String):void
		{
			_statID = value;
		}
		
		// TextField
		
		public function W3StatisticsListItem()
		{
			super();
			preventAutosizing = true;
			constraintsDisabled = true;
		}
		
		protected override function configUI():void
		{
			// #J these protection checks are so this code doesn't break the menu's without the updated W3StatisticsListItem information
			if (mcStatInfo)
			{
				var mcTextContainer : MovieClip = mcStatInfo.getChildByName("txfStats") as MovieClip;
				
				// #J system was built assuming there is a textField in the same layer. This compensates for the exception found in this Movie
				if (mcTextContainer)
				{
					var actualTextField : TextField = mcTextContainer.getChildByName("textField") as TextField;
					
					if (actualTextField)
					{
						textField = actualTextField;
					}
					
					actualTextField = mcTextContainer.getChildByName("tfStatValue") as TextField;
					if (actualTextField)
					{
						tfStatValue = actualTextField;
					}
				}
			}
			
			super.configUI();
		}
		
		override public function setData( data:Object ):void
		{
			super.setData( data );
			if ( !data )
			{
				return;
			}
			label = data.name;
			_statValue = data.value as String;
			_id = data.id;
			tfStatValue.htmlText = _statValue;
			
			if (mcStatInfo && data.changedValue == true)
			{
				mcStatInfo.gotoAndPlay("Changed");
			}
		}
		
		override protected function updateText():void
		{
			super.updateText();
			tfStatValue.htmlText = _statValue;
			
			//updateHighlightScale();
		}
		
		protected function updateHighlightScale()
		{
			if (mcStatInfo && tfStatValue && textField)
			{
				var mcHighlight:MovieClip = mcStatInfo.getChildByName("mcChangedHighlight") as MovieClip;
				
				if (mcHighlight)
				{
					// #J calculation seems a bit overkill complicated but is ultimately precise and represents the scene best (two text fields next to each other each aligned to the center
					var leftX:Number = tfStatValue.x + tfStatValue.width - tfStatValue.textWidth;
					var rightX:Number = textField.x + textField.textWidth;
					
					// #J Offset the values based on their parent
					leftX += mcStatInfo.x;
					rightX += mcStatInfo.x;
					
					mcHighlight.width = Math.abs(rightX - leftX);
					mcHighlight.x = leftX + (mcHighlight.width / 2); //#J its centered and used everywhere sooo... ><
					
					trace("GFX ----------------- Setting HighlightScale, leftX:", leftX, ",rightX:", rightX, "actualWidth:", mcHighlight.width, "actualx:", mcHighlight.x, ",actualY:", mcHighlight.y, ",actualHeight:", mcHighlight.height);
				}
			}
		}
		
		override protected function updateAfterStateChange():void
		{
			if ( tfStatValue )
			{
				//tfStatValue.htmlText = _statValue;
			}
		}
		
		public function GetId() : int
		{
			return _id;
		}
	}
}
