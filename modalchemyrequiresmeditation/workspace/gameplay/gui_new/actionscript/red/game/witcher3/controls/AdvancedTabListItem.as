package red.game.witcher3.controls
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	public class AdvancedTabListItem extends TabListItem
	{
		public var mcText : TextField;
		public var mcSelectedHighlight : MovieClip;
		public var mcOpened : MovieClip;
		public var mcHasNewIcon : MovieClip;
		public var txtLabel:W3TextArea;
		public var mcNew : MovieClip;
		
		protected override function configUI():void
		{
			super.configUI();
			
			if ( mcOpened )
			{
				mcOpened.visible = false;
			}
			
			if (mcHasNewIcon)
			{
				mcHasNewIcon.visible = false;
			}
			
			if (mcNew)
			{
				mcNew.visible = false;
			}
		}
		
		public function setNewFlag(value:Boolean):void
		{
			if (mcNew)
			{
				mcNew.visible = value;
			}
		}
		
		public function hasNewFlag():Boolean
		{
			if (mcNew && mcNew.visible)
			{
				return true;
			}
			
			return false;
		}
		
		protected var _selectionVisible:Boolean = true;
		public function set selectionVisible(value:Boolean):void
		{
			_selectionVisible = value;
			
			if (mcSelectedHighlight)
			{
				if (!isOpen)
				{
					mcSelectedHighlight.visible = value;
				}
			}
		}
		
		protected var isOpen:Boolean = false;
		override public function setIsOpen(value:Boolean):void 
		{
			isOpen = value;
			if (mcOpened)
			{
				mcOpened.visible = value;
			}
			
			if (mcSelectedHighlight && _selectionVisible)
			{
				mcSelectedHighlight.visible = !value;
			}
		}
		
		public function set hasNewIcon(value:Boolean):void
		{
			if (mcHasNewIcon)
			{
				mcHasNewIcon.visible = value;
			}
		}
		
		override protected function updateText():void
		{
			super.updateText();
			
			if (mcOpened)
			{
				mcOpened.visible = isOpen;
			}
			
			if (mcSelectedHighlight)
			{
				if (!_selectionVisible)
				{
					mcSelectedHighlight.visible = false;
				}
				else
				{
					mcSelectedHighlight.visible = !isOpen;
				}
			}
		}
		
		public function setLabel(value:String):void
		{
			if (txtLabel)
			{
				txtLabel.text = value;
			}
		}
		
		public function setText(value:String):void
		{
			if (mcText)
			{
				mcText.text = value;
			}
		}
		
		override public function setData( data:Object ):void
		{
			super.setData( data );
			
			if (mcOpened && data && data.icon)
			{
				mcOpened.gotoAndStop(data.icon);
			}
		}
	}
}