/***********************************************************************/
/** Action Script file
/***********************************************************************/
/** Copyright © 2012 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.hud.modules.radialmenu
{
	import scaleform.clik.core.UIComponent
	import scaleform.clik.controls.UILoader;
	import flash.display.MovieClip;

	public class RadialMenuFieldsContainer extends UIComponent
	{
		public var mcRadialMenuItem1		: RadialMenuItem;
		public var mcRadialMenuItem2		: RadialMenuItem;
		public var mcRadialMenuItem3		: RadialMenuItem;
		public var mcRadialMenuItem4		: RadialMenuItem;
		public var mcRadialMenuItem5		: RadialMenuItem;
		public var mcRadialMenuItem6		: RadialMenuItem;
		public var mcRadialMenuItem7		: RadialMenuItem;
		public var mcRadialMenuItem8		: RadialMenuItem;

		private var RadialMenuFields : Array = new Array();

		private var SlotsNames : Array = new Array();

		public function RadialMenuFieldsContainer()
		{
			super();
		}
		
		public function setExternalViewer( ref : RadialMenuSubItemView ) : void
		{
			(mcRadialMenuItem6 as RadialMenuItemEquipped).subListViewer = ref;
			(mcRadialMenuItem7 as RadialMenuItemEquipped).subListViewer = ref;
			(mcRadialMenuItem8 as RadialMenuItemEquipped).subListViewer = ref;
		}
		
		protected override function configUI():void
		{
			super.configUI();
			
			Init();
			
			RadialMenuFields.push({ obj:mcRadialMenuItem1, initX:mcRadialMenuItem1.x, initY:mcRadialMenuItem1.y});
			RadialMenuFields.push({ obj:mcRadialMenuItem2, initX:mcRadialMenuItem2.x, initY:mcRadialMenuItem2.y});
			RadialMenuFields.push({ obj:mcRadialMenuItem3, initX:mcRadialMenuItem3.x, initY:mcRadialMenuItem3.y});
			RadialMenuFields.push({ obj:mcRadialMenuItem4, initX:mcRadialMenuItem4.x, initY:mcRadialMenuItem4.y});
			RadialMenuFields.push({ obj:mcRadialMenuItem5, initX:mcRadialMenuItem5.x, initY:mcRadialMenuItem5.y});
			RadialMenuFields.push({ obj:mcRadialMenuItem6, initX:mcRadialMenuItem6.x, initY:mcRadialMenuItem6.y});
			RadialMenuFields.push({ obj:mcRadialMenuItem7, initX:mcRadialMenuItem7.x, initY:mcRadialMenuItem7.y});
			RadialMenuFields.push({ obj:mcRadialMenuItem8, initX:mcRadialMenuItem8.x, initY:mcRadialMenuItem8.y});

			mcRadialMenuItem6.SetAsItemField(true);
			mcRadialMenuItem7.SetAsItemField(true);
			mcRadialMenuItem8.SetAsItemField(true);
		}

		public function Init()
		{
			UpdateRadialMenuFieldsNames(SlotsNames);
		}

		public function SetSelected(ID : int) : Boolean
		{
			var currentMc : RadialMenuItem;
			
			if (ID < RadialMenuFields.length)
			{
				currentMc = RadialMenuFields[ID].obj as RadialMenuItem;
				
				if (currentMc)
				{
					currentMc.SetSelected();
				}
			}
			
			return true;
		}
		
		public function SetDeselected(ID : int) : void
		{
			var currentMc : RadialMenuItem;
			
			if (ID < RadialMenuFields.length)
			{
				currentMc = RadialMenuFields[ID].obj as RadialMenuItem;
				
				if (currentMc)
				{
					currentMc.SetDeselected();
				}
			}
		}

		public function SetDesatureted( desName : String, value : Boolean) : void
		{
			var currentMc : RadialMenuItem;
			
			currentMc = GetRadialMenuFieldByName(desName);
			
			if (currentMc)
			{
				currentMc.SetDesatureted(value);
			}
		}

		public function IsDesatureted( desName : String ) : Boolean
		{
			var currentMc : RadialMenuItem;
			
			currentMc = GetRadialMenuFieldByName(desName);
			
			if (currentMc)
			{
				return currentMc.IsDesatureted();
			}
			
			return false;
		}
		
		public function GetSelectedRadialMenuField() : RadialMenuItem
		{
			var i : int;
			var radialItem : RadialMenuItem;
			
			for ( i = 0; i < RadialMenuFields.length; i++ )
			{
				radialItem = RadialMenuFields[i].obj as RadialMenuItem;
				
				if ( radialItem.getIsSelected() )
				{
					return radialItem;
				}
			}
			
			return null;
		}
		
		public function GetRadialMenuFieldByName(selectionName : String) : RadialMenuItem
		{
			var i : int;
			var radialItem : RadialMenuItem;

			for ( i = 0; i < RadialMenuFields.length; i++ )
			{
				radialItem = RadialMenuFields[i].obj as RadialMenuItem;
				if (radialItem.getRadialItemName() == selectionName)
				{
					return radialItem;
				}
			}
			return null;
		}

		public function GetRadialMenuFieldByID(ID : int) : RadialMenuItem
		{
			var radialItem : RadialMenuItem;
			radialItem = getChildByName("mcRadialMenuItem" + ID) as RadialMenuItem;

			if( radialItem )
			{
				return radialItem;
			}
			return null;
		}

		public function SetRadialMenuFieldsNames(namesArray : Array) : void
		{
			SlotsNames = namesArray;
		}

		public function IsEnabled( ID : int ) : Boolean
		{
			var radialItem : RadialMenuItem;
			
			radialItem = getChildByName("mcRadialMenuItem" + ID) as RadialMenuItem;
			
			if (radialItem)
			{
				return radialItem.enabled;
			}
			
			return false;
		}

		public function UpdateRadialMenuFieldsNames(namesArray : Array) : void
		{
			var i : int;
			var radialItem : RadialMenuItem;

			for ( i = 0; i < namesArray.length; i++ )
			{
				radialItem = GetRadialMenuFieldByID(i + 1) as RadialMenuItem;
				if ( namesArray[i] == "disabled" )
				{
					if ( radialItem )
					{
						radialItem.visible = false;
						radialItem.enabled = false;
					}
				}
				else
				{
					if ( radialItem )
					{
						radialItem.visible = true;
						radialItem.enabled = true;
					}
				}
				
				if ( radialItem )
				{
					radialItem.setRadialItemName(namesArray[i]);
					radialItem["mcEquipped"].visible = false; // #Y FIX mcEquipped should be a property
					//radialItem["mcButton"].visible = false; //#Y FIX mcEquipped should be a property
				}
			}
		}
	}
}
