package red.game.witcher3.menus.photomode 
{
	public class PhotomodeSliderDataModel extends Object
	{
		public var id : int;
		public var label : String;
		public var minValue : Number;
		public var maxValue : Number;
		public var slideStep : Number;
		public var stringValues : Vector.<String>;
		public var currentValue : Number;
		
		public function PhotomodeSliderDataModel(... args)
		{
			setDataModel.apply(this, args);
		}
		
		public function setDataModel(... args):void 
		{
			
			if (args.length == 0)
			{
				this.id = 0;
				this.label = "text";
				this.minValue = 0.0;
				this.maxValue = 10.0;
				this.slideStep = 1.0;
				this.currentValue = 0.0;
				this.stringValues = new Vector.<String>();
			}
			else if (args.length == 1)
			{
				this.id = args[0];
				this.label = "text";
				this.minValue = 0.0;
				this.maxValue = 10.0;
				this.slideStep = 1.0;
				this.currentValue = 0.0;
				this.stringValues = new Vector.<String>();
			}
			else if (args.length == 2 && args[1] is String)
			{
				this.id = args[0];
				this.label = args[1];
				this.minValue = 0.0;
				this.maxValue = 10.0;
				this.slideStep = 1.0;
				this.stringValues = new Vector.<String>();
			}
			else if (args.length == 4 && args[2] is Object)
			{
				this.id = args[0];
				this.label = args[1];
				this.minValue = 0.0;
				this.maxValue = args[2].length - 1;
				this.currentValue = args[3];
				this.slideStep = 1.0;
				this.stringValues = Vector.<String>(args[2].strings);
			}
			else if (args.length == 6 && args[2] is Number)
			{
				this.id = args[0];
				this.label = args[1];
				this.minValue = args[2];
				this.maxValue = args[3];
				this.slideStep = args[4];
				this.currentValue = args[5];
				stringValues = new Vector.<String>();
			}
			else
			{
				var str : String = "wrong arguments: count " + args.length + "types " + typeof(args[0]) + ", " + typeof(args[1]) + ", " + typeof(args[2]);
				throw new ArgumentError(str);
			}		
		}
	}
}