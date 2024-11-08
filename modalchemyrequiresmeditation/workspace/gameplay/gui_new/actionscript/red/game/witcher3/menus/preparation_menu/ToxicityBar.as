package red.game.witcher3.menus.preparation_menu
{
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import scaleform.clik.controls.StatusIndicator;
	import scaleform.clik.core.UIComponent;
	import red.game.witcher3.utils.CommonUtils;

	/**
	 * ...
	 * @author Getsevich Yaroslav
	 */
	public class ToxicityBar extends UIComponent
	{
		public var dataBindingKey:String = "preparation.toxicity.bar.";
		public var txtTitle:TextField;
		public var txtMinValue:TextField;
		public var txtMaxValue:TextField;
		public var txtValue:TextField;
		public var mcProgressBar:StatusIndicator;

		protected override function configUI():void
		{
			super.configUI();
			focusable = false;
			mouseChildren = mouseEnabled = false;

			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey + "max", [handleMaxValueSet]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey + "value", [handleValueSet]));

			txtMinValue.text = "0";
			mcProgressBar.minimum = 0;

			txtTitle.htmlText = "[[panel_preparation_toxicitybar_description]]";
			txtTitle.htmlText = CommonUtils.toUpperCaseSafe(txtTitle.htmlText);
		}

		protected function handleMaxValueSet( value : Number ):void
		{
			txtMaxValue.htmlText = value.toString();
			mcProgressBar.maximum = value;
		}

		protected function handleValueSet( value : int ):void
		{
			txtValue.text = value + "%";
			mcProgressBar.value = value;
		}
	}

}