package red.game.witcher3.menus.character_menu
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.text.TextColorType;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.constants.SkillColor;
	import red.game.witcher3.constants.TextColor;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * red.game.witcher3.menus.character_menu.MutationResourceInfo
	 * @author Getsevich Yaroslav
	 */
	public class MutationResourceInfo extends UIComponent
	{
		private const ICON_PADDING:Number = 5;
		
		public var mcFeedback		   : MovieClip;
		public var mcMissingIngredient : MovieClip;
		public var mcBackground        : MovieClip;
		public var tfCounter  		   : TextField;
		public var tfLabel 		 	   : TextField;
		
		private var _iconLoader : UILoader;
		private var _data		: Object;
		
		public function MutationResourceInfo()
		{
			visible = false;
		}
		
		public function get data():Object { return _data; }
		public function set data( value : Object ) : void
		{
			_data = value;
			
			if (_data)
			{
				updateData( _data );
			}
		}
		
		public function playFeedbackAnim():void
		{
			if ( data && data.avaliableResources < data.required )
			{
				mcFeedback.gotoAndPlay( 2 );
			}
		}
		
		private function updateData( value : Object ) : void
		{
			visible = true;
			
			if (_iconLoader)
			{
				_iconLoader.removeEventListener( Event.COMPLETE, handleImageLoaded );
				_iconLoader.unload();
				removeChild(_iconLoader);
				_iconLoader = null;
			}
			
			if (value.resourceIconPath)
			{
				_iconLoader = new UILoader();
				_iconLoader.source = value.resourceIconPath;
				_iconLoader.addEventListener( Event.COMPLETE, handleImageLoaded, false, 0, true );
				_iconLoader.x = mcBackground.x;
				_iconLoader.y = mcBackground.y;
				addChild(_iconLoader);
			}
			
			if ( value.avaliableResources >= value.required )
			{
				mcMissingIngredient.visible = false;
				tfCounter.textColor = TextColor.AVAILABLE;
			}
			else
			{
				mcMissingIngredient.visible = true;
				tfCounter.textColor = TextColor.WRONG;
			}
			
			tfLabel.text = value.resourceName;
			tfCounter.text = value.avaliableResources + "/" + value.required;
			
			
			tfLabel.y = mcBackground.y + ( mcBackground.height - tfLabel.textHeight ) / 2;
		}
		
		private function handleImageLoaded( event : Event ) : void
		{
			addChild(tfCounter);
		}
		
	}
}
