package red.game.witcher3.menus.character_menu 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.CoreMenuModule;
	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.controls.W3UILoaderSlot;
	import red.game.witcher3.menus.common.ColorSprite;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.ComponentEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	
	// Absolete
	public class CharacterSkillListItem extends BaseListItem
	{	
		public var iconLock:MovieClip;
		public var mcColorBackground:ColorSprite;
		public var mcStateSelectedActive:MovieClip;
		
		protected var _imageLoader:W3UILoaderSlot;
		protected var _categoryIndex:int = 0;
		
		override protected function configUI():void 
		{
			super.configUI();
			
			if (iconLock) iconLock.visible = false;
			enabled = true;
			toggle = true;
			if (mcStateSelectedActive) mcStateSelectedActive.stop();
		}
		
		override public function gotoAndPlay (frame:Object, scene:String = null) : void //#J fastest approach
		{
			super.gotoAndStop(frame, scene);
		}
		
		override public function setData( data:Object ):void
		{
			super.setData(data);
			
			if (!data)
				return;
				
			//super.setData(data);
			var dataArray:Array = data as Array;
			
			if (dataArray.length >= 2 && dataArray[1] is int)
			{
				_categoryIndex = dataArray[1];
				loadIcon();
			}
			
			if (mcColorBackground && dataArray.length >= 4 && dataArray[3] is String)
			{
				var colorName:String = dataArray[3] as String;
				
				mcColorBackground.visible = true;
				switch (colorName)
				{
					case "SC_Blue":
						mcColorBackground.color = ColorSprite.COLOR_BLUE;
						break;
					case "SC_Red":
						mcColorBackground.color = ColorSprite.COLOR_RED;
						break;
					case "SC_Green":
						mcColorBackground.color = ColorSprite.COLOR_GREEN;
						break;
					case "SC_Yellow":
						mcColorBackground.color = ColorSprite.COLOR_ORANGE;
						break;
				}
			}
		}
		
		protected function loadIcon():void
		{
			unloadIcon();
			_imageLoader = new W3UILoaderSlot();
			_imageLoader.maintainAspectRatio = false;
			_imageLoader.autoSize = false;
			_imageLoader.source = "icons\\Skills\\category_" + (_categoryIndex + 1) + ".png";
			_imageLoader.mouseChildren = false;
			_imageLoader.mouseEnabled = false;
			addChild(_imageLoader);
		}
		
		protected function unloadIcon():void
		{
			if (_imageLoader)
			{
				_imageLoader.unload();
				removeChild(_imageLoader);
				_imageLoader = null;
			}
		}
		
		override public function handleInput(event:InputEvent):void
		{
			// #J so that the tree can get the a events
			if (event.details.navEquivalent == NavigationCode.GAMEPAD_A || event.details.code == KeyCode.A)
			{
				return;
			}
			else
			{
				super.handleInput(event);
			}
		}
	}
}