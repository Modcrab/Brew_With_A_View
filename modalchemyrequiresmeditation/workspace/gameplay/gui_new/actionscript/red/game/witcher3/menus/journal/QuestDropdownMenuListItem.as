package red.game.witcher3.menus.journal
{
	import flash.display.MovieClip;
	import flash.filters.ConvolutionFilter;
	import red.core.CoreComponent;
	import red.game.witcher3.menus.common.FeedbackDropdownMenuListItem;
	import scaleform.clik.events.ListEvent;
	
	public class QuestDropdownMenuListItem extends FeedbackDropdownMenuListItem
	{
		public var headerColor : MovieClip;
		
		public function QuestDropdownMenuListItem()
		{
			super();
		}

		override protected function configUI():void
		{
			bLabelSortingEnabled = false;
			super.configUI();
		}
		
		// #Y Hack *autoselect tracked quest*; check and remove flag
		override public function HasInitialSelection() : Boolean
		{
			for ( var i : int; i < dropDownData.length; i++ )
			{
				if( dropDownData[i].selected )
				{
					selectedIndex = i;
					dropDownData[i].isNew = false;
					dropDownData[i].selected = false;
					return true;
				}
			}
			return false;
        }
		
		override public function setDropdownData( dropdownDataIn : Object ) : void
		{
			var dataArray : Array = dropdownDataIn as Array;
			
			if (dataArray && dataArray.length)
			{
				setColorCoding( dataArray[ 0 ] );
			}
			
			super.setDropdownData( dropdownDataIn );
		}
		
		override public function updateDropdownDataSurgically( dropdownDataIn : Array ) : void
		{
			if (dropdownDataIn && dropdownDataIn.length)
			{
				setColorCoding( dropdownDataIn[ 0 ] );
			}
			
			super.updateDropdownDataSurgically( dropdownDataIn );
		}
		
		override public function setData(data:Object):void
		{
			super.setData(data);
			
			var dataArray : Array = data as Array;
			
			if (headerColor && dataArray && dataArray.length)
			{
				setColorCoding( dataArray[ 0 ] );
			}
		}
		
		override protected function updateText():void 
		{
			super.updateText();
			if ( CoreComponent.isArabicAligmentMode )
			{
				if (mcCollapseBtnIcon)
				{
					mcCollapseBtnIcon.x = textField.x + textField.width - textField.textWidth - mcCollapseBtnIcon.width;
				}
			}
		}
		
		protected function setColorCoding( dataObj :Object ) : void
		{
			trace("GFX **** ------- ", label, "; ", dataObj.dropDownTag )
			
			if (dataObj.status == 2 || dataObj.status == 3)	// finished quests
			{
				headerColor.gotoAndStop( 1 );
				return;
			}
			
			switch( dataObj.isStory )
			{
				case 0://Main Story Quests
					headerColor.gotoAndStop( "main" );
					break;
				case 1: //Main Quests
					headerColor.gotoAndStop( "main" );
					break;
				case 2://Secondary Quests
					headerColor.gotoAndStop( "secondary" );
					break;
				case 3://Witcher Contracts
					headerColor.gotoAndStop( "contract" );
					break;
				case 4://Treasure Hunts
					headerColor.gotoAndStop( "treasurehunt" );
					break;
				default:
					headerColor.gotoAndStop( 1 );
					break;
			}
		}
		
		override public function toString() : String
		{
			return "[W3 QuestDropdownMenuListItem]"
		}
	}
}
