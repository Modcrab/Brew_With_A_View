package red.game.witcher3.hud.modules
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import red.core.events.GameEvent;
	import red.game.witcher3.hud.modules.lootpopup.HudLootItemModule;
	import scaleform.clik.events.InputEvent;

	public class HudModuleLootPopup extends HudModuleBase
	{
		//>------------------------------------------------------------------------------------------------------------------
		// VARIABLES
		//-------------------------------------------------------------------------------------------------------------------
		private static const FADE_DURATION:Number = 500;

		// On scene elements
		public 		var mcLootItemModule 		: HudLootItemModule;
		private 	var	releaseTimer 			: Timer;

		public function HudModuleLootPopup()
		{
			super();
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function get moduleName():String
		{
			return "LootPopupModule";
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function configUI():void
		{
			super.configUI();
			this.visible = false;
			alpha = 0;

			registerDataBinding( "LootItemList", mcLootItemModule.handleItemListData );

			// DEBUG --------------------------------------------------
			/*var l_dataArray:Array = new Array();
			l_dataArray.push( { label:"Crowns", quantity:556, iconPath:"", category:"Other", type:"Junk", weight:0, price:1  } );
			l_dataArray.push({label:"Tunic Jacket", quantity:1, iconPath:"", category:"Armor", type:"Chest", stats:[ { name:"Armor", value:"+12", icon:"positive" }, { name:"Fire Resistance", value:"+14", icon:"negative" }, { name:"Poison Resistance", value:"+14", icon:"positive" }  ], weight:10, price:140  } );
			l_dataArray.push({label:"Sliver sword", quantity:1, iconPath:"", category:"Weapon", type:"Sword", stats:[ { name:"Damage", value:"+45", icon:"positive" } ], weight:2, price:1200  } );
			l_dataArray.push({label:"Pheromone Bear", quantity:14, iconPath:"", category:"Usable", type:"Potion", stats:[ { name:"Seduction", value:"12", icon:"neutral" } ], weight:0.5, price:30  } );
			l_dataArray.push({label:"Leather Jacket", quantity:100, iconPath:"", category:"Armor", type:"Chest", stats:[ { name:"Armor", value:"+30", icon:"positive" } ], weight:3, price:900  } );
			l_dataArray.push({label:"Illusion Medallion", quantity:1, iconPath:"", category:"Usable", type:"Medallion", weight:0.5, price:350  } );
			l_dataArray.push({label:"Cat Potion", quantity:15, iconPath:"", category:"Usable", type:"Potion", weight:0.5, price:125  } );
			mcLootItemModule.handleItemListData( l_dataArray, -1 );
			SetWindowTitle("Dead Nekker");

			//OpenPC();
			OpenConsole();
			SetSelectionIndex(6);*/
			//---------------------------------------------------------
			stage.addEventListener( InputEvent.INPUT, mcLootItemModule.handleInput, false, 0, true );


			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function ShowElementFromState( bShow : Boolean, bImmediately : Boolean = false ):void
		{
			super.ShowElementFromState( bShow, bImmediately );
			if ( bShow )
			{
				trace("r4",this, "Start new timer" );
				releaseTimer = new Timer(500, 1);
				releaseTimer.start();
				releaseTimer.addEventListener(TimerEvent.TIMER, OnTimerEnd, false, 0, false);
				return;
			}
			else
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseLootWindow' ) );
			}
			if ( releaseTimer && releaseTimer.running )
			{
				releaseTimer.stop();
			}
			mcLootItemModule._bWaitForKey = false;
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		private function OnTimerEnd(e:TimerEvent)
		{
			releaseTimer.stop();
			mcLootItemModule._bWaitForKey = true;
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function OpenPC()
		{
			mcLootItemModule.y += mcLootItemModule.height * 0.2;
			mcLootItemModule.scaleX 	= 0.8;
			mcLootItemModule.scaleY 	= 0.8;

			mcLootItemModule.m_isPCVersion = true;
			OpenCommonElements();
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function OpenConsole()
		{
			mcLootItemModule.m_isPCVersion = false;
			stage.focus = mcLootItemModule;
			OpenCommonElements();
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		private function OpenCommonElements()
		{
			//mcLootItemModule.mcFloatingToolTip_PC.visible = false;
			this.visible = true;
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function SetWindowTitle( _Title : String )
		{
			mcLootItemModule.tfTitle.text = _Title;
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function SetSelectionIndex( _Index:int )
		{
			mcLootItemModule.m_indexToSelect = _Index;
		}

		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function toString():String
		{
			return "[W3 HudModuleLootPopup:" +this.name+"]";
		}
	}

}
