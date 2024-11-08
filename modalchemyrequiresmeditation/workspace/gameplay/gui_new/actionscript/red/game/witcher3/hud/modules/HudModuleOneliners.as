package red.game.witcher3.hud.modules
{
	import adobe.utils.CustomActions;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import red.game.witcher3.hud.modules.HudModuleBase;
	import flash.utils.getDefinitionByName;
	import flash.utils.Dictionary;
	import flash.display.Sprite;

	public class HudModuleOneliners extends HudModuleBase
	{
		private var savedScale : Number;
		private var oneliners : Dictionary = new Dictionary(true);
		private var onelinerClassRef : Class;
		private var onelinerPool : Vector.< Sprite > = new Vector.< Sprite >();
		
		override public function get moduleName():String
		{
			return "OnelinersModule";
		}

		override protected function configUI():void
		{
			super.configUI();
			alpha = 0;
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
			
			onelinerClassRef = getDefinitionByName("OnelinerLabelRef") as Class;
			if ( !onelinerClassRef )
			{
				trace("Minimap No OnelinerLabelRef definition found!");
				return;
			}
			
			AddOnelinersToPool( 5 );
		}
		
		private function AddOnelinersToPool( count : int )
		{
			var label : Sprite;
			var textField : TextField;

			if ( !onelinerClassRef )
			{
				trace("Minimap No OnelinerLabelRef definition found!");
				onelinerPool.push( null );
				return;
			}
			
			for ( var i = 0; i < count; ++i )
			{
				label = new onelinerClassRef as Sprite;
				onelinerPool.push( label );
			}
			
			//
			trace("Minimap Oneliner pool: " + onelinerPool.length );
			//
		}
		
		private function GetOnelinerFromPool() : Sprite
		{
			if ( onelinerPool.length == 0 )
			{
				// initial number of labels was not enough?
				AddOnelinersToPool( 1 );
			}
			return onelinerPool.pop();
		}
		
		private function PutOnelinerToPool( label : Sprite )
		{
			return onelinerPool.push( label );
		}
		
		public function UpdateScale( value : Number ) : void
		{
			savedScale = value;
			for each ( var label : Sprite in oneliners )
			{
				label.scaleX = savedScale;
				label.scaleY = savedScale;
			}
		}
		
        public function CreateOneliner( ID : int, value : String ):void
		{
            var label : Sprite;

			label = GetOnelinerFromPool();
			if ( !label )
			{
				trace("Minimap No oneliner found in pool!");
				return;
			}
			
			//
			trace("Minimap Oneliner pool: " + onelinerPool.length );
			//
			
			var textField : TextField = label["textField"] as TextField;
			textField.htmlText = value;
			textField.y = -textField.textHeight;
			
			label.visible = true;
			label.name = "mcOneliner" + ID;
			label.x = -1920;
			label.y = -1080;
			label.scaleX = savedScale;
			label.scaleY = savedScale;
			
			oneliners[ ID ] = label;
			
			addChild( label );
        }
		
		public function UpdateOneliner( ID : int, xPos : int, yPos : int):void
		{
            var label : Sprite = oneliners[ID] ;
			if ( !label )
			{
				trace("Minimap Missing oneliner id = " + ID );
				return;
			}
			
			label.x = xPos;
			label.y = yPos;
        }
		
		public function RemoveOneliner( ID : int ):void
		{
            var label : Sprite;

			label = oneliners[ ID ] ;
			if ( !label )
			{
				trace("Minimap Missing oneliner id = " + ID );
				return;
			}
			removeChild(label);
			
			label.visible = false;
			PutOnelinerToPool( label );
			
			delete oneliners[ ID ];

			//
			//trace("Minimap Oneliner pool: " + onelinerPool.length );
			//
        }
		
	}
}
