package red.game.witcher3.menus.photomode 
{
	import scaleform.clik.controls.Button;	
	import flash.display.MovieClip;

	public class PhotomodeTabRenderer extends Button
	{
		public var m_icon : MovieClip;
		public var m_background : MovieClip;


		override protected function configUI():void 
		{
			constraintsDisabled = true;
			preventAutosizing = true;

            super.configUI();
		}

        protected override function updateText():void 
		{
			super.updateText();

			var index : int = data.index;

			if( index > 0 )
			{
            	m_icon.gotoAndStop( index );
				m_icon.visible = true;
			}
			else
			{
				m_icon.visible = false;
			}

			const iconPadding : Number = 2;
			const displayBlockSize : Number = textField.textWidth + iconPadding + m_icon.width;

			m_background.width = 200;
			m_icon.x = m_background.width / 2 - displayBlockSize / 2;
			m_icon.alpha = _selected ? 1 : .6;
			textField.x = m_icon.x + m_icon.width + iconPadding;
			textField.width = textField.textWidth + 5;
        }
	}
}