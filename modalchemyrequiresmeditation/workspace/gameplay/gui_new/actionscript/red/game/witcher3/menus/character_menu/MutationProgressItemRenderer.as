package red.game.witcher3.menus.character_menu
{
	import flash.display.MovieClip;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	import red.game.witcher3.slots.SlotBase;
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.controls.StatusIndicator;
	import scaleform.clik.events.InputEvent;
	
	/**
	 * red.game.witcher3.menus.character_menu.MutationProgressItemRenderer
	 * @author Getsevich Yaroslav
	 */
	public class MutationProgressItemRenderer extends ListItemRenderer
	{
		public var mcHitArea:MovieClip;
		public var mcProgressbar:StatusIndicator;
		public var mcIcon:MovieClip;
		
		public var mcCompleteIcon:MovieClip;
		public var tfProgress:TextField;
		
		public function MutationProgressItemRenderer()
		{
			trace("GFX MutationProgressItemRenderer :: construct");
			
			super();
			
			preventAutosizing = constraintsDisabled = true;
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			visible = false;
			selectable = false;
		}
		
		 override protected function draw():void
		 {
			super.draw();
		 }
		
		override public function setData(data:Object):void
		{
			super.setData(data);
			
			trace("GFX MutationProgressItemRenderer :: updateData ", data);
			
			if (data)
			{
				preventAutosizing = constraintsDisabled = true;
				
				visible = true;
				selectable = true;
				
				var curProgress:Number = _data.used;
				var maxProgress:Number = _data.required;
				
				mcProgressbar.maximum = maxProgress;
				
				if (curProgress >= maxProgress)
				{
					mcProgressbar.visible = false;
					mcCompleteIcon.visible = true;
				}
				else
				{
					mcProgressbar.value = curProgress;
					mcProgressbar.visible = true;
					mcCompleteIcon.visible = false;
				}
				
				mcIcon.gotoAndStop(_data.type + 1);
				tfProgress.text = curProgress + "/" + maxProgress;
				
				trace("GFX mcProgressbar scale ", mcProgressbar.scaleX, mcProgressbar.scaleY);
				
				//mcProgressbar.scaleX = mcProgressbar.scaleY = 1.47; // HACK
				mcProgressbar.validateNow();
			}
			else
			{
				visible = false;
				selectable = false;
			}
		}
		
		override public function handleInput(event:InputEvent):void
		{
			// ignore
		}
		
		
	}

}
