package red.game.witcher3.menus.common 
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import red.core.CoreComponent;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	
	/**
	 * red.game.witcher3.menus.common.EnchantmentListItemRenderer
	 * Item renderer for EnchantingMenu
	 * @author Getsevich Yaroslav
	 */
	public class EnchantmentListItemRenderer extends IconItemRenderer
	{
		public static const PINNED_EVENT:String = "PinChangedEvent";
		
		public static var DISABLE_ACTION:Boolean = false;
		public static var APPLIED_ENCHANTMENT:uint = 0;
		
		private const STATIC_HEIGHT:Number = 87;
		private const CENTER_LINE:Number = 44;
		
		public var mcEnchantmenTypeIcon:MovieClip;
		public var mcPinnedOverlay:MovieClip;
		
		protected static var _currentPinnedTag:uint;
		public static function setCurrentPinnedTag(stage:Stage, value:uint):void
		{
			_currentPinnedTag = value;
			stage.dispatchEvent(new Event(PINNED_EVENT));
		}
		
		public function EnchantmentListItemRenderer() 
		{
			visible = false;
			
			if (mcPinnedOverlay)
			{
				mcPinnedOverlay.visible = false;
			}
		}
		
		override protected function configUI():void 
		{
			super.configUI();
			stage.addEventListener(PINNED_EVENT, onPinnedRecipeChanged, false, 0, true);
		}
		
		protected function onPinnedRecipeChanged(event:Event):void
		{
			updatePinnedIcon();
		}
		
		public function updatePinnedIcon():void
		{
			if (mcPinnedOverlay)
			{
				if (data && data.name == EnchantmentListItemRenderer._currentPinnedTag)
				{
					mcPinnedOverlay.visible = true;
				}
				else
				{
					mcPinnedOverlay.visible = false;
				}
			}
		}
		
		override public function setData( data:Object ):void
		{
			super.setData( data );
			
			if (!data)
			{
				return;
			}
			
			updatePinnedIcon();
			visible = true;
			
			try 
			{
				var timelineOffset:int = (data.name == APPLIED_ENCHANTMENT) ? 3 : 0; // to show orange icon
				mcEnchantmenTypeIcon.gotoAndStop( data.level + timelineOffset );
				mcEnchantmenTypeIcon.visible = true;
			}
			catch (er:Error)
			{
				trace("GFX Enchantment level is undefined! <", data.level, "> ", er.getStackTrace());
				mcEnchantmenTypeIcon.visible = false;
			}
		}
		
		override protected function updateText():void 
		{
			super.updateText();
			
			if (data)
			{
				//var descriptionStr:String = data.description;
				var descriptionStr:String = data.localizedName;
				
				var curTextHeight:Number = 0;
				var textColor:Number;
				
				if (data.name == APPLIED_ENCHANTMENT)
				{
					textColor = 0xE67E0B;
				}
				else
				if (! (data.canApply && !data.notEnoughMoney && !data.notEnoughSlots && !DISABLE_ACTION) )
				{
					textColor = 0xc90202;
				}
				else
				{
					textColor = 0x2eca00
				}
				
				if (CoreComponent.isArabicAligmentMode)
				{
					descriptionStr = "<p align=\"right\">" + descriptionStr + "</p>";
				}
				
				textField.htmlText = descriptionStr;
				textField.textColor = textColor;
				curTextHeight = textField.textHeight;
				textField.height = curTextHeight + CommonConstants.SAFE_TEXT_PADDING;
				textField.y = CENTER_LINE - curTextHeight / 2;
			}
		}
		
		override public function toString() : String
		{
			return "[W3 EnchantmentListItemRenderer]"
		}
		
		override public function get height():Number 
		{
			return STATIC_HEIGHT; // ignore selection MC
		}
		
	}

}

