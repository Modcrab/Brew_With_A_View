/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import red.game.witcher3.controls.W3ScrollingList;
	
	import red.game.witcher3.constants.KeyCode;
	import scaleform.clik.constants.InputValue;
	import red.core.data.InputAxisData;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import red.core.utils.InputUtils;
	import scaleform.clik.constants.InvalidationType;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.InventorySlotType;
	
	public class W3WolfRadialScrollingList extends W3ScrollingList
	{
		private var isLoaded : Boolean = false;
		
		public function W3WolfRadialScrollingList()
		{
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
			removeEventListener( InputEvent.INPUT, handleInput); // #B a little bit hacky :/
			stage.addEventListener( InputEvent.INPUT, handleInput,false,100,true);
		}
		
        override public function handleInput(event:InputEvent):void
		{
			if( event.handled )
			{
				return;
			}
			
			var details:InputDetails = event.details;
			var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			
			switch( details.code )
			{
				case KeyCode.PAD_LEFT_STICK_AXIS:
					{
						var axisData:InputAxisData;
						var xvalue:Number;
						var yvalue:Number;
						var magnitude:Number;
						var magnitudeCubed:Number;
						var angleRadians:Number;
								
						axisData = InputAxisData(details.value);
						xvalue = axisData.xvalue;
						yvalue = axisData.yvalue;
						magnitude = InputUtils.getMagnitude( xvalue, yvalue );
						magnitudeCubed = magnitude * magnitude * magnitude;
						angleRadians = InputUtils.getAngleRadians( xvalue, yvalue );
							
						if ( magnitude > 0.3 )
						{
							SelectRendererByAngle(angleRadians);
						}
						event.handled = true;
						event.stopImmediatePropagation();
					}
					break;
				default:
					return;
			}
        }
		
		private function SelectRendererByAngle( angleRadians : Number ) : void
		{
			var wolfRenderer : W3WolfRadialListItem;
			for( var i : int = 0; i < TotalRenderers; i++ )
			{
				wolfRenderer = getRendererAt(i) as W3WolfRadialListItem;
				
				if ( !wolfRenderer.visible || !wolfRenderer.enabled )
				{
					continue;
				}
				
				if( wolfRenderer.CheckSelectRendererByAngle( 2*Math.PI - angleRadians) )
				{
/*					trace("INVENTORY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ");
					trace("INVENTORY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ");
					trace("INVENTORY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ");
					trace("INVENTORY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ");
					trace("INVENTORY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ");
					trace("INVENTORY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ");
					trace("INVENTORY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ");
					trace("INVENTORY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ");
					trace("INVENTORY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ");
					trace("INVENTORY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ");
					trace("INVENTORY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! "+i);*/
					
					if( this.selectedIndex != i )
					{
						dispatchEvent(new GameEvent(GameEvent.CALL, 'OnPlaySound', ['gui_global_highlight']));
					}
					this.selectedIndex = i;

					return;
				}
			}
		}
		
		public function RemoveInputEventListener() : void
		{
			stage.removeEventListener( InputEvent.INPUT, handleInput);
		}
		
		public function AddInputEventListener() : void
		{
			stage.addEventListener( InputEvent.INPUT, handleInput,false,100,true);
		}
		
		override protected function draw():void
		{
            super.draw();
			//trace("INVENTORY %%%%%%%%% ",this.name,isLoaded);
            if (isInvalid(InvalidationType.DATA) && !isLoaded )
			{
				//trace("INVENTORY %%%%%%%%% isInvalid(InvalidationType.DATA)");
				isLoaded = true;
				var renderer : W3WolfRadialListItem;
			
				renderer = getRendererAt(selectedIndex) as W3WolfRadialListItem;
				if ( renderer ) //#B is enabled
				{
					var IST : int = slotTagToType(renderer.GetIcon());
					//trace("INVENTORY %%%%%%%%% renderer.GetFieldName() " + renderer.GetFieldName(), " IST ", IST);
					//trace("INVENTORY %%%%%%%%% renderer.GetIcon ", renderer.GetIcon());
					
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnWolfsRadialItemChange", [IST, renderer.GetFieldName()]));
				}
            }
        }
		
		
		private function slotTagToType( slotTag:String ) : int
		{
			var slotType:int = InventorySlotType.InvalidSlot;
			
			switch ( slotTag )
			{
				case "steel":
					slotType = InventorySlotType.SteelSword;
					break;
				case "silver":
					slotType = InventorySlotType.SilverSword;
					break;
				case "armor":
					slotType = InventorySlotType.Armor;
					break;
				case "gloves":
					slotType = InventorySlotType.Gloves;
					break;
				case "trousers":
				case "pants":
					slotType = InventorySlotType.Pants;
					break;
				case "boots":
					slotType = InventorySlotType.Boots;
					break;
				case "trophy":
					slotType = InventorySlotType.Trophy;
					break;
				case "quick1":
					slotType = InventorySlotType.Quickslot1;
					break;
				case "quick2":
					slotType = InventorySlotType.Quickslot2;
					break;
				case "quick3":
					slotType = InventorySlotType.Quickslot3;
					break;
				case "quick4":
					slotType = InventorySlotType.Quickslot4;
					break;
				case "quick5":
					slotType = InventorySlotType.Quickslot5;
					break;
				default:
					break;
			}
			return slotType;
		}
	}
}
