/***********************************************************************
/** The master of all that is and ever was hub related ish.
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.common_menu
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.TabListItem;
	import red.game.witcher3.controls.W3TextArea;
	import red.game.witcher3.utils.CommonUtils;

	public class MenuHubTabListItem extends TabListItem
	{
		public var mcHasNewIcon : MovieClip;
		public var txtLabel:TextField;
		public var isSmallTab:Boolean = false;
		
		
		protected override function configUI():void
		{
			super.configUI();
			if (mcHasNewIcon)
			{
				mcHasNewIcon.visible = false;
			}
			doubleClickEnabled = false;
			
		}

		public function set hasNewIcon(value:Boolean):void
		{
			if (mcHasNewIcon && enabled)
			{
				mcHasNewIcon.visible = value;
			}
		}

		public function setLabel(value:String):void
		{
			if (txtLabel)
			{
				updateLabelPosition();
				txtLabel.htmlText = CommonUtils.toUpperCaseSafe(value);
				txtLabel.height = txtLabel.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				
			}
			
		}
		public function updateLabelPosition():void
		{
			if ( isSmallTab )
			{
				//txtLabel.height = txtLabel.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				
				trace("GFX >>////////////////////txtLabel.numLines>>>>>>>>>>" + txtLabel.numLines ) ;
				if ( txtLabel.numLines > 1 )
				{
					txtLabel.y = 4;
				}
				else
				{
					txtLabel.y = 11.55;
				}
			}
		}

		override public function get selectable():Boolean
		{
			return enabled;
		}

		override protected function updateAfterStateChange():void
		{
			super.updateAfterStateChange();

			if (txtLabel && data)
			{
				txtLabel.htmlText = CommonUtils.toUpperCaseSafe(data.label);
				txtLabel.height = txtLabel.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				updateLabelPosition();
			}
			
		}
		
		override public function setData( data:Object ):void
		{
			super.setData( data );

			if (txtLabel && data)
			{
				txtLabel.htmlText = CommonUtils.toUpperCaseSafe(data.label);
				txtLabel.height = txtLabel.textHeight + CommonConstants.SAFE_TEXT_PADDING;
				//updateLabelPosition();			
			}
		}
	}
}