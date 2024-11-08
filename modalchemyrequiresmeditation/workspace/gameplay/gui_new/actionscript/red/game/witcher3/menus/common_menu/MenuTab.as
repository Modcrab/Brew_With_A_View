package red.game.witcher3.menus.common_menu
{
	import flash.display.MovieClip;
	import flash.filters.ColorMatrixFilter;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.controls.Button;
	import red.game.witcher3.utils.CommonUtils;

	/**
	 * Common menu tab
	 * @author Getsevich Yaroslavc
	 */
	public class MenuTab extends ListItemRenderer
	{
		protected static const DISABLED_ALPHA:Number = .5;
		public var iconHolder:MovieClip;
		protected var _targetMenuIdx:uint;
		protected var _subMenuRef:String;
		protected var _iconName:String;

		public function MenuTab()
		{
			constraintsDisabled = true;
		}

		public function get iconName():String { return _iconName };
		public function set iconName(value:String)
		{
			_iconName = value;
			updateIconFrame();
		}

		protected function updateIconFrame():void
		{
			if (iconHolder && _iconName)
			{
				try
				{
					iconHolder.gotoAndStop(_iconName);
				}
				catch(er:Error)
				{
					var warningMsg:String = "** WARNING ** Icon for menu tab " + _iconName + " is not defined, see MenuCommon.fla [iconHolder]";
					trace("GFX", warningMsg);
					//throw new Error(warningMsg);
				}
			}
		}

		protected function updateIconState(iconEnabled:Boolean):void
		{
			if (!iconEnabled)
			{
				var desFilter:ColorMatrixFilter = CommonUtils.getDesaturateFilter();
				iconHolder.filters = [desFilter];
				iconHolder.alpha = DISABLED_ALPHA;
			}
			else
			{
				iconHolder.filters = [];
				iconHolder.alpha = 1;
			}
		}

		override public function set label(value:String):void
		{
			super.label = CommonUtils.toUpperCaseSafe(value);
		}

		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			updateIconState(value);
		}

		override protected function configUI():void
		{
			super.configUI();
			preventAutosizing = true;
			constraintsDisabled = true;
			focusable = false;
			displayFocus = true;
		}

		// We don't change state after focus
		override protected function changeFocus():void { }

		override protected function updateAfterStateChange():void
		{
			super.updateAfterStateChange();
			updateIconFrame();
			updateIconState(enabled);
		}
	}
}
