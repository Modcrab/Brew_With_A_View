package red.game.witcher3.menus.character_menu
{
	import scaleform.clik.core.UIComponent;
	
	// red.game.witcher3.menus.character_menu.MutationConnector
	public class MutationConnector extends UIComponent
	{
		private var _mutationRendererName:String;
		private var _color:String;
		
		[Inspectable(type = "String", defaultValue = "")]
		public function get mutationRendererName( ) : String { return _mutationRendererName; }
		public function set mutationRendererName( value : String ) : void
		{
			_mutationRendererName = value;
			
			if (parent)
			{
				var renderer:MutationItemRenderer = parent.getChildByName(_mutationRendererName) as MutationItemRenderer;
				
				if (renderer)
				{
					renderer.addConnector(this);
				}
			}
		}
		
		public function get color():String { return _color; }
		public function set color(value:String):void
		{
			_color = value;
			gotoAndStop(_color);
		}
		
	}
}
