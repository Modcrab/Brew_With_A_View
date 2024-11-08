package red.game.witcher3.menus.meditation
{
	import adobe.utils.CustomActions;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * red.game.witcher3.menus.meditation.MeditationBonusPanel
	 * @author Getsevich Yaroslav
	 */
	public class MeditationBonusPanel extends UIComponent
	{
		private static const ITEM_RDR_REF : String = "MeditationBonusItemRendererRef";
		
		public var tfTitle 	    : TextField;
		public var mcListAnchor : MovieClip;
		
		private var _data 	   : Array;
		private var _active	   : Boolean;
		private var _renderers : Vector.<MeditationBonusItemRenderer>;
		
		public function MeditationBonusPanel()
		{
			visible = false; // by default
			tfTitle.text = "[[panel_title_buff_sleep]]";
			_renderers = new Vector.<MeditationBonusItemRenderer>;
		}
		
		public function get data():Array { return _data; }
		public function set data(value:Array):void
		{
			_data = value;
			populateData();
		}
		
		public function get active():Boolean { return _active; }
		public function set active(value:Boolean):void
		{
			if (_active != value)
			{
				_active = value;
				
				var len:int = _renderers.length;
				
				for (var i:int = 0; i < len; i++)
				{
					_renderers[i].activate = _active;
				}
			}
		}
		
		private function populateData():void
		{
			trace("GFX - populateData ", _data);
			
			while (_renderers.length)
			{
				removeChild( _renderers.pop() );
			}
			
			if (_data)
			{
				var RendererClassName:Class = getDefinitionByName( ITEM_RDR_REF ) as Class;
				var len:int = _data.length;
				var initX:Number = mcListAnchor.x;
				var initY:Number = mcListAnchor.y;
				
				trace("GFX - populateData ", len);
				
				for ( var i:int = 0; i < len; i++ )
				{
					var newRenderer : MeditationBonusItemRenderer = new RendererClassName() as MeditationBonusItemRenderer;
					
					newRenderer.data = _data[ i ];
					newRenderer.activate = _active;
					newRenderer.x = initX;
					newRenderer.y = initY;
					addChild(newRenderer);
					initY += newRenderer.actualHeight;
					
					_renderers.push( newRenderer );
				}
				
				visible = true;
			}
			else
			{
				visible = false;
			}
		}
		
	}

}
