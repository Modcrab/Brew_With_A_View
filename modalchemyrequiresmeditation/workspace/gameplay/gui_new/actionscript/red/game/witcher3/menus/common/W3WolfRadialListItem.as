/***********************************************************************
/** Right click menu list item renderer
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.display.MovieClip;
	import red.game.witcher3.controls.BaseListItem;
	
	public class W3WolfRadialListItem extends BaseListItem
	{
		
		public var mcIcon : MovieClip;
		public var mcSlotBkg : MovieClip;
		public var mcGlowHighlight : MovieClip;
		
		public var _IconPath : String;
		public var _IsEmpty : Boolean;
		public var _HaxFieldName : uint;
		
		public var AngleMin : Number;
		public var AngleMax : Number;
		
		public function W3WolfRadialListItem()
		{
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
		}
		
		override public function setData( data:Object ):void
		{
			super.setData( data );
			if ( !data )
			{
				return;
			}
			_IconPath = data.iconPath;
			_IsEmpty = !data.equipped;
			_HaxFieldName = data.name;
			updateIcon();
		}
		
		override protected function updateAfterStateChange():void
		{
		}
		
        override protected function updateText():void
		{
        }
		
		protected function updateIcon():void
		{
			var str : String;
			if ( _IsEmpty )
			{
				str = "_empty";
				if( mcSlotBkg )
				{
					mcSlotBkg.gotoAndStop( "empty" );
				}
			}
			else
			{
				str = "";
				if( mcSlotBkg )
				{
					mcSlotBkg.gotoAndStop( "equipped" );
				}
			}
			
			if( mcIcon )
			{
				mcIcon.gotoAndStop( _IconPath + str );
			}
        }

		public function GetIcon() : String
		{
			return _IconPath;
		}
		
		public function GetFieldName() : uint
		{
			return _HaxFieldName;
		}
		
		public function CheckSelectRendererByAngle( angle : Number ) : Boolean
		{
			var temp : Number = 0;
			if( AngleMin > AngleMax ) //@FIXME BIDON - check it in detail is clunky
			{
				temp = 2 * Math.PI;
/*				if ( _IconPath == "silver" )
				{
					trace("INVENTORY CheckSelectRendererByAngle EDGE CASE !!!!!!!! " + angle + " _IconPath " + _IconPath);
				}
			}
			
			if ( _IconPath == "silver" )
			{
				trace("INVENTORY angle "+angle);
				trace("INVENTORY AngleMin "+AngleMin);
				trace("INVENTORY AngleMax "+AngleMax);
				trace("INVENTORY angle > AngleMin- temp  "+(angle > AngleMin- temp ));
				trace("INVENTORY angle < AngleMax "+(angle < AngleMax));
*/			}
			
			if ( angle > AngleMin- temp && angle < AngleMax )
			{
				return true;
			}

			//trace("INVENTORY CheckSelectRendererByAngle failed because angle "+angle);
			//trace("INVENTORY AngleMin "+AngleMin+" AngleMax "+AngleMax);
			return false;
		}
		
				
		public function SetBackgroundGlowAnimation( value : Boolean ): void
		{
			if ( mcGlowHighlight )
			{
				if ( value )
				{
					mcGlowHighlight.gotoAndPlay("start");
				}
				else
				{
					mcGlowHighlight.gotoAndStop("stop");
				}
			}
		}
	}
}