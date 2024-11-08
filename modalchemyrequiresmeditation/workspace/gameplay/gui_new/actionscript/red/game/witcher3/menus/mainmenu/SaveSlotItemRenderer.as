/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.IconItemRenderer;
	import red.core.CoreComponent;
	import red.game.witcher3.constants.PlatformType;
	import red.core.events.GameEvent;

	public class SaveSlotItemRenderer extends IconItemRenderer
	{
		public static const TEXT_PADDING = 40;
		public static const HIGHLIGHT_PADDING = 30;
		public static const TWO_HIGHLIGHT_PADDING = 16;
		public static const HIT_PADDING = 15;
		public static const LARGE_HIT_PADDING = 7;

		// cloud status
		public static const CST_INVALID  = 10;
		public static const CST_LOCAL    = 20;
		public static const CST_CLOUD    = 30;
		public static const CST_INSYNC   = 40;
		public static const CST_CONFILCT = 50;
		public static const CST_UPLOAD   = 60;
		public static const CST_ROLL     = 70;
		
		
		public var txtSlotType:TextField;
		public var mcSelection: MovieClip;
		public var mcHighlightFrame: MovieClip;
		public var mcHitArea: MovieClip;
		private var saveTextColor:Number;

		override protected function configUI():void
		{
			super.configUI();
			saveTextColor = 0x999999;
		}

		override public function setData( data:Object ):void
		{
			super.setData(data);
			if (data)
			{
				setSaveType(data.saveType);
				setCloudStatus(data.cloudStatus);
			}
		}
		private function setSaveType(saveType : int) : void
		{
			var platform:uint = InputManager.getInstance().getPlatform();
			var text : String;
			if (txtSlotType)
			{
				switch(saveType)
				{
					case 1: // SGT_AutoSave
						text = PlatformType.getPlatformSpecificResourceString(platform, "save_slot_type_auto");
						saveTextColor = 0x999999;
						break;
					case 2: // SGT_QuickSave
						text = PlatformType.getPlatformSpecificResourceString(platform, "save_slot_type_quick");
						saveTextColor = 0xD2954A;
						break;
					case 3: // SGT_Manual
						text =PlatformType.getPlatformSpecificResourceString(platform, "save_slot_type_manual");
						saveTextColor = 0x4DB13A;
						break;
					case 4: // SGT_ForcedCheckPoint
					case 5: // SGT_CheckPoint
					
						text =PlatformType.getPlatformSpecificResourceString(platform, "save_slot_type_checkpoint");
						saveTextColor = 0x999999;
						break;
						
				}

				txtSlotType.htmlText = "<p align=\"right\">" + text + "</p>";
				txtSlotType.textColor = saveTextColor;
			}

		}
		private function setCloudStatus(cstatus : int) : void
		{
			var	showFlag : Boolean = true;
			if (mcIconLoader)
			{
				// results battle_victory.png
				// mcIconLoader.source = "img://icons\\gwint\\neu_ciri.png";
				switch(cstatus)
				{
					case CST_INVALID:
						mcIconLoader.source = "img://icons\\cloud\\cloud_cross.png";
						break;
					case CST_LOCAL:
						mcIconLoader.source = "img://icons\\cloud\\cloud_arrow_up.png";
						showFlag = false;
						break;
					case CST_CLOUD:
						mcIconLoader.source = "img://icons\\cloud\\cloud_arrow_down.png";
						break;
					case CST_INSYNC:
						mcIconLoader.source = "img://icons\\cloud\\cloud_tick_mark.png";
						break;
					case CST_UPLOAD:
						mcIconLoader.source = "img://icons\\cloud\\cloud_arrow_up.png";
						break;
					case CST_CONFILCT:
						mcIconLoader.source = "img://icons\\cloud\\cloud_exclaim.png";
						break;
					case CST_ROLL:
						mcIconLoader.source = "img://icons\\cloud\\cloud_roll.png";
						break;
					default:
						mcIconLoader.source = "img://icons\\cloud\\cloud_empty.png";
						break;
				}
				mcIconLoader.visible = showFlag;
			}
		}
		override public function set selected(value:Boolean):void
		{
			super.selected = value;
			
			if (mcSelection)
			{
				mcSelection.visible = selected;
			}
		}
		
		override protected function updateText():void 
		{
			var pos:int;
			
			if (_label != null && textField != null)
			{
				if ( !CoreComponent.isArabicAligmentMode && data && data.tag != -1)
				{
					pos = _label.lastIndexOf("-");
					if ( pos != -1)
					{
						var resDateTime:String = _label.slice(pos);
						var resSaveName: String = _label.slice(0, pos -1);
							
						textField.htmlText = resSaveName + " <font color='#FFFFFF'>" + resDateTime;
					}
					else
					{
						textField.htmlText = _label;
					}
					textField.height = textField.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				}
				else
				{
					textField.htmlText = _label;
				}
				
				if (textField.numLines > 1)
				{
					textField.y = -5.2;
					mcHitArea.height = textField.textHeight + HIT_PADDING;
					mcHighlightFrame.height = textField.textHeight + LARGE_HIT_PADDING ;
					mcSelection.height = textField.textHeight + HIGHLIGHT_PADDING;
				}
				else
				{
					mcHitArea.height = textField.textHeight + HIT_PADDING;
					textField.y = 4.75;
					mcHighlightFrame.height = textField.textHeight + HIGHLIGHT_PADDING ;
					mcSelection.height = textField.textHeight + TEXT_PADDING;
				}
			}
		}
	}
}