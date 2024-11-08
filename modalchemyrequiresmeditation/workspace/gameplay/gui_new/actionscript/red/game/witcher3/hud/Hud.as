package red.game.witcher3.hud
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import red.core.CoreComponent;
	import red.game.witcher3.controls.HintButton;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
	
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.managers.InputDelegate;

	import scaleform.gfx.Extensions;
	import scaleform.clik.core.UIComponent;

	import red.core.CoreHud;
	import red.core.events.GameEvent;

	import red.game.witcher3.hud.HudModuleManager;
	import red.game.witcher3.hud.HudModuleManagerEntry;

	import red.game.witcher3.hud.modules.HudModuleBase;
	import red.game.witcher3.hud.modules.HudModuleAnchors;
	import red.game.witcher3.hud.modules.HudModuleMedallion;
	import red.game.witcher3.hud.modules.HudModuleStatBars;
	import red.game.witcher3.hud.modules.HudModuleInteractions;
	import red.game.witcher3.hud.modules.HudModuleMessage;
	import red.game.witcher3.hud.modules.HudModuleRadialMenu;
	import red.game.witcher3.hud.modules.HudModuleQuests;
	import red.game.witcher3.hud.modules.HudModuleSignInfo;
	import red.game.witcher3.hud.modules.HudModuleSubtitles;
	import red.game.witcher3.hud.modules.HudModuleLootPopup;
	import red.game.witcher3.hud.modules.HudModuleBuffs;
	import red.game.witcher3.hud.modules.HudModulePickedItemsInfo;
	import red.game.witcher3.hud.modules.HudModuleTimeLapse;
	import red.game.witcher3.hud.modules.HudModuleWatermark;
	import red.game.witcher3.hud.modules.HudModuleItemInfo;
	import red.game.witcher3.hud.modules.HudModuleOxygenBar;
	import red.game.witcher3.hud.modules.HudModuleDialog;
	
	public class Hud extends CoreHud
	{
		public var moduleManager : HudModuleManager;
		public var hudModuleStateArray : Dictionary;
		public var loadError : int = 0;
		public var isDynamic : Boolean = true;

		//>------------------------------------------------------------------------------------------------------------------
		// VARIABLES
		//-------------------------------------------------------------------------------------------------------------------
		// Modules
		private var mcTestModule						:	TestModule;
		const m_swfPath = "swf\\hud\\";
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function Hud()
		{
			super();
			moduleManager = new HudModuleManager();

			hudModuleStateArray = new Dictionary();

			hudModuleStateArray["JumpClimb"] = {states:[
				{state:"Hide", 		modules:["RadialMenuModule",
										"DialogModule","BoatHealthModule", "HorseStaminaBarModule", "HorsePanicBarModule"] },
				{state:"Show", 		modules:["QuestsModule","Minimap2Module","OnelinersModule","ControlsFeedbackModule","BuffsModule"] },
				{state:"OnDemand", 	modules:["InteractionsModule","SubtitlesModule","EnemyFocusModule","BossFocusModule","CrosshairModule","DamagedItemsModule",
											"ConsoleModule","MessageModule", "WatermarkModule","JournalUpdateModule","AreaInfoModule","CompanionModule","TimeLeftModule"] },
				{state:"OnUpdate", 	modules:["WolfHeadModule","OxygenBarModule","TimeLapseModule", "ItemInfoModule"] }
				] } ;

			hudModuleStateArray["Exploration"] = {states:[
				{state:"Hide", 		modules:["RadialMenuModule",
										"DialogModule","BoatHealthModule", "HorseStaminaBarModule", "HorsePanicBarModule"] },
				{state:"Show", 		modules:["QuestsModule","Minimap2Module","OnelinersModule","ControlsFeedbackModule","BuffsModule"] },
				{state:"OnDemand", 	modules:["InteractionsModule","SubtitlesModule","EnemyFocusModule","BossFocusModule","CrosshairModule","DamagedItemsModule",
											"ConsoleModule","MessageModule", "WatermarkModule","JournalUpdateModule","AreaInfoModule","CompanionModule","TimeLeftModule"] },
				{state:"OnUpdate", 	modules:["WolfHeadModule","OxygenBarModule","TimeLapseModule", "ItemInfoModule"] }
				] } ;

			hudModuleStateArray["Exploration_Replacer_Ciri"] = {states:[
				{state:"Hide", 		modules:["RadialMenuModule",
										"DialogModule","BoatHealthModule", "HorseStaminaBarModule", "HorsePanicBarModule"] },
				{state:"Show", 		modules:["QuestsModule","Minimap2Module","OnelinersModule","ControlsFeedbackModule","BuffsModule"] },
				{state:"OnDemand", 	modules:["InteractionsModule","SubtitlesModule","EnemyFocusModule","BossFocusModule","CrosshairModule","DamagedItemsModule",
											"ConsoleModule","MessageModule", "WatermarkModule","JournalUpdateModule","AreaInfoModule","CompanionModule","TimeLeftModule"] },
				{state:"OnUpdate", 	modules:["WolfHeadModule","OxygenBarModule","TimeLapseModule", "ItemInfoModule"] }
				] } ;

			hudModuleStateArray["ScriptedAction"] = {states:[
				{state:"Hide", 		modules:["RadialMenuModule", "BuffsModule",
										"DialogModule","BoatHealthModule","ControlsFeedbackModule", "HorseStaminaBarModule", "HorsePanicBarModule"] },
				{state:"Show", 		modules:["QuestsModule","Minimap2Module","OnelinersModule"] },
				{state:"OnDemand", 	modules:["InteractionsModule","SubtitlesModule","EnemyFocusModule","BossFocusModule","CrosshairModule","DamagedItemsModule",
											"ConsoleModule","MessageModule", "WatermarkModule","JournalUpdateModule","AreaInfoModule","CompanionModule","TimeLeftModule"] },
				{state:"OnUpdate", 	modules:["WolfHeadModule","OxygenBarModule","TimeLapseModule", "ItemInfoModule"] }
				] } ;

			hudModuleStateArray["Combat"] ={ states:[
				{state:"Hide", 		modules:["RadialMenuModule",
										"DialogModule","BoatHealthModule","AreaInfoModule"] },
				{state:"Show", 		modules:["Minimap2Module","ItemInfoModule","WolfHeadModule","OnelinersModule","QuestsModule","ControlsFeedbackModule","BuffsModule"] },
				{state:"OnDemand", 	modules:["InteractionsModule", "SubtitlesModule","EnemyFocusModule","BossFocusModule","CrosshairModule","DamagedItemsModule",
											"ConsoleModule","MessageModule", "JournalUpdateModule","WatermarkModule","CompanionModule","TimeLeftModule"] },
				{state:"OnUpdate", 	modules:["OxygenBarModule", "HorseStaminaBarModule","TimeLapseModule", "HorsePanicBarModule"] }
				] };

			hudModuleStateArray["CombatFists"] ={ states:[
				{state:"Hide", 		modules:["RadialMenuModule",
										"DialogModule","BoatHealthModule","AreaInfoModule"] },
				{state:"Show", 		modules:["Minimap2Module","ItemInfoModule","WolfHeadModule","OnelinersModule","QuestsModule","ControlsFeedbackModule","BuffsModule"] },
				{state:"OnDemand", 	modules:["InteractionsModule", "SubtitlesModule","EnemyFocusModule","BossFocusModule","CrosshairModule","DamagedItemsModule",
											"ConsoleModule","MessageModule", "JournalUpdateModule","WatermarkModule","CompanionModule","TimeLeftModule"] },
				{state:"OnUpdate", 	modules:["OxygenBarModule", "HorseStaminaBarModule","TimeLapseModule", "HorsePanicBarModule"] }
				] };

			hudModuleStateArray["Combat_Replacer_Ciri"] ={ states:[
				{state:"Hide", 		modules:["RadialMenuModule",
										"DialogModule","BoatHealthModule","AreaInfoModule"] },
				{state:"Show", 		modules:["Minimap2Module","ItemInfoModule","WolfHeadModule","OnelinersModule","QuestsModule","ControlsFeedbackModule","BuffsModule"] },
				{state:"OnDemand", 	modules:["InteractionsModule", "SubtitlesModule","EnemyFocusModule","BossFocusModule","CrosshairModule","DamagedItemsModule",
											"ConsoleModule","MessageModule", "JournalUpdateModule","WatermarkModule","CompanionModule","TimeLeftModule"] },
				{state:"OnUpdate", 	modules:["OxygenBarModule", "HorseStaminaBarModule","TimeLapseModule", "HorsePanicBarModule"] }
				] };

			hudModuleStateArray["Scene"] ={ states:[
				{state:"Hide", 		modules:["QuestsModule","RadialMenuModule", "BuffsModule",
										"OxygenBarModule", "BoatHealthModule", "InteractionsModule", "SubtitlesModule","CrosshairModule",
										"EnemyFocusModule", "BossFocusModule", "ConsoleModule", "MessageModule","AreaInfoModule","OnelinersModule","DamagedItemsModule",
										"WatermarkModule", "HorseStaminaBarModule", "HorsePanicBarModule", "Minimap2Module", "ItemInfoModule", "WolfHeadModule","CompanionModule","ControlsFeedbackModule","TimeLeftModule"] },
				{state:"OnDemand", 	modules:["JournalUpdateModule"] },
				{state:"Show", 		modules:[ "DialogModule"] },
				{state:"OnUpdate", 		modules:[ "TimeLapseModule"] }
				] };

				hudModuleStateArray["LootPopup"] ={ states:[
				{state:"Hide", 		modules:["InteractionsModule","RadialMenuModule","DebugFastMenuModule"/*,"ItemInfoModule"*/] },
				{state:"Show", 		modules:[ "BuffsModule"] }
				] };


			hudModuleStateArray["RadialMenu"] ={ states:[
				{state:"Hide", 		modules:["QuestsModule", "CrosshairModule","DamagedItemsModule",
										"OxygenBarModule", "BoatHealthModule", "InteractionsModule", "SubtitlesModule","OnelinersModule",
										"EnemyFocusModule", "BossFocusModule", "ConsoleModule", "MessageModule", "TimeLapseModule","AreaInfoModule","CompanionModule",
										"WatermarkModule", "HorseStaminaBarModule", "HorsePanicBarModule","Minimap2Module","WolfHeadModule","DialogModule","JournalUpdateModule","ControlsFeedbackModule","TimeLeftModule"] },
				{state:"Show", 		modules:[ "RadialMenuModule","BuffsModule","ItemInfoModule"] }
				] };

			hudModuleStateArray["Swimming"] ={ states:[
				{state:"Hide", 		modules:["RadialMenuModule",
										"DialogModule","BoatHealthModule", "OxygenBarModule", "HorseStaminaBarModule", "HorsePanicBarModule"] },
				{state:"Show", 		modules:["QuestsModule","Minimap2Module","OnelinersModule","ControlsFeedbackModule", "BuffsModule"] },
				{state:"OnDemand", 	modules:["InteractionsModule","SubtitlesModule","EnemyFocusModule","BossFocusModule","AreaInfoModule","CompanionModule",
											"DamagedItemsModule","ConsoleModule","MessageModule", "WatermarkModule","CrosshairModule","JournalUpdateModule","TimeLeftModule"] },
				{state:"OnUpdate", 	modules:["WolfHeadModule","ItemInfoModule","OxygenBarModule","TimeLapseModule"] }
				] } ;

			hudModuleStateArray["Diving"] ={ states:[
				{state:"Hide", 		modules:["RadialMenuModule",
										"DialogModule","BoatHealthModule", "HorsePanicBarModule","OxygenBarModule", "HorseStaminaBarModule"] },
				{state:"Show", 		modules:["QuestsModule","Minimap2Module","OnelinersModule","ControlsFeedbackModule", "BuffsModule"] },
				{state:"OnDemand", 	modules:["InteractionsModule","SubtitlesModule","EnemyFocusModule","BossFocusModule","AreaInfoModule","CompanionModule",
											"DamagedItemsModule","ConsoleModule","MessageModule", "WatermarkModule","CrosshairModule","JournalUpdateModule","TimeLeftModule"] },
				{state:"OnUpdate", 	modules:["WolfHeadModule","ItemInfoModule","OxygenBarModule","TimeLapseModule"] }
				] } ;

			hudModuleStateArray["Horse"] ={ states:[
				{state:"Hide", 		modules:["RadialMenuModule",
										"DialogModule","BoatHealthModule"] },
				{state:"Show", 		modules:["QuestsModule","Minimap2Module","OnelinersModule","ControlsFeedbackModule", "BuffsModule"] },
				{state:"OnDemand", 	modules:["InteractionsModule","SubtitlesModule","EnemyFocusModule","BossFocusModule","AreaInfoModule","CompanionModule",
											"DamagedItemsModule","ConsoleModule","MessageModule", "WatermarkModule","CrosshairModule","JournalUpdateModule","TimeLeftModule"] },
				{state:"OnUpdate", 	modules:["WolfHeadModule", "HorseStaminaBarModule","ItemInfoModule","TimeLapseModule","OxygenBarModule", "HorsePanicBarModule"] }
				] } ;
					
			hudModuleStateArray["Horse_Replacer_Ciri"] ={ states:[
				{state:"Hide", 		modules:["RadialMenuModule",
										"DialogModule","BoatHealthModule"] },
				{state:"Show", 		modules:["QuestsModule","Minimap2Module","OnelinersModule","ControlsFeedbackModule", "BuffsModule"] },
				{state:"OnDemand", 	modules:["InteractionsModule","SubtitlesModule","EnemyFocusModule","BossFocusModule","AreaInfoModule","CompanionModule",
											"DamagedItemsModule","ConsoleModule","MessageModule", "WatermarkModule","CrosshairModule","JournalUpdateModule","TimeLeftModule"] },
				{state:"OnUpdate", 	modules:["WolfHeadModule", "HorseStaminaBarModule","ItemInfoModule","TimeLapseModule","OxygenBarModule", "HorsePanicBarModule"] }
				] } ;

			hudModuleStateArray["Boat"] ={ states:[
				{state:"Hide", 		modules:["RadialMenuModule",
										"DialogModule", "HorseStaminaBarModule", "HorsePanicBarModule"] },
				{state:"Show", 		modules:["QuestsModule","Minimap2Module","BoatHealthModule","OnelinersModule","ControlsFeedbackModule","BuffsModule"] },
				{state:"OnDemand", 	modules:["InteractionsModule","SubtitlesModule","EnemyFocusModule","BossFocusModule","AreaInfoModule","CompanionModule",
											"DamagedItemsModule","ConsoleModule","MessageModule", "WatermarkModule","CrosshairModule","JournalUpdateModule","TimeLeftModule"] },
				{state:"OnUpdate", 	modules:["WolfHeadModule","ItemInfoModule","TimeLapseModule","OxygenBarModule"] }
				] } ;
			
			hudModuleStateArray["BoatPassenger"] ={ states:[
				{state:"Hide", 		modules:["RadialMenuModule", "LootPopupModule",
										"DialogModule", "HorseStaminaBarModule", "HorsePanicBarModule"] },
				{state:"Show", 		modules:["QuestsModule","Minimap2Module","BoatHealthModule","OnelinersModule","ControlsFeedbackModule","BuffsModule"] },
				{state:"OnDemand", 	modules:["InteractionsModule","SubtitlesModule","EnemyFocusModule","BossFocusModule","AreaInfoModule","CompanionModule",
											"DamagedItemsModule","ConsoleModule","MessageModule", "WatermarkModule","CrosshairModule","JournalUpdateModule","TimeLeftModule"] },
				{state:"OnUpdate", 	modules:["WolfHeadModule","ItemInfoModule","TimeLapseModule","OxygenBarModule"] }
				] } ;

			hudModuleStateArray["Death"] ={ states:[
				{state:"Hide", 		modules:["RadialMenuModule", "BuffsModule","CrosshairModule","OnelinersModule","DamagedItemsModule",
											 "DialogModule", "HorseStaminaBarModule", "HorsePanicBarModule", "QuestsModule", "Minimap2Module", "BoatHealthModule","JournalUpdateModule",
											 "InteractionsModule","SubtitlesModule","ItemInfoModule","EnemyFocusModule","BossFocusModule","AreaInfoModule","CompanionModule",
											 "ConsoleModule","MessageModule", "TimeLapseModule","WatermarkModule","WolfHeadModule","OxygenBarModule","ControlsFeedbackModule","TimeLeftModule"] }
				] } ;
			//#B order of depth for hd modules for now 0 - 29
			moduleManager.AddEntry( "AnchorsModule",       		"hud_anchors.swf",0 );
			moduleManager.AddEntry( "HorseStaminaBarModule",    "hud_horsestaminabar.swf",4 );
			moduleManager.AddEntry( "HorsePanicBarModule",    	"hud_horsepanicbar.swf",5 );
			moduleManager.AddEntry( "InteractionsModule",   	"hud_interactions.swf",20 );
			moduleManager.AddEntry( "MessageModule",        	"hud_message.swf",6 );
			moduleManager.AddEntry( "RadialMenuModule",     	"hud_radialmenu.swf",24 );
			moduleManager.AddEntry( "QuestsModule",         	"hud_quests.swf",7);
			moduleManager.AddEntry( "SubtitlesModule",      	"hud_subtitles.swf",21 );
			moduleManager.AddEntry( "ControlsFeedbackModule",  	"hud_controlsfeedback.swf",28 );
			//moduleManager.AddEntry( "LootPopupModule",      	"hud_lootpopup.swf",18 ); // moved to super HUD
			moduleManager.AddEntry( "BuffsModule",          	"hud_buffs.swf",26 );
			moduleManager.AddEntry( "PickedItemsInfoModule",	"hud_pickeditemsinfo.swf",1 ); // shuld be killed ?
			//moduleManager.AddEntry( "WatermarkModule",      	"hud_watermark.swf",10 );
			moduleManager.AddEntry( "WolfHeadModule",       	"hud_wolfstatbars.swf",12 );
			moduleManager.AddEntry( "ItemInfoModule",       	"hud_iteminfo.swf",25 );
			moduleManager.AddEntry( "OxygenBarModule",      	"hud_oxygenbar.swf",13 );
			moduleManager.AddEntry( "EnemyFocusModule",     	"hud_enemyfocus.swf",19 );
			moduleManager.AddEntry( "BossFocusModule",     		"hud_bossfocus.swf",15 );
			moduleManager.AddEntry( "DialogModule",         	"hud_dialog.swf",22 );
			//moduleManager.AddEntry( "DebugTextModule",         	"hud_debugtext.swf",2 );
			moduleManager.AddEntry( "BoatHealthModule",        	"hud_boathealth.swf",8 );
			moduleManager.AddEntry( "ConsoleModule",       		"hud_console.swf",9 );
			moduleManager.AddEntry( "TimeLapseModule",      	"hud_timelapse.swf",27 );
			moduleManager.AddEntry( "JournalUpdateModule",      "hud_journalupdate.swf",16 );
			//moduleManager.AddEntry( "AreaInfoModule",      		"hud_areainfo.swf",14 );
			moduleManager.AddEntry( "CrosshairModule",      	"hud_crosshair.swf",17 );
			moduleManager.AddEntry( "OnelinersModule",      	"hud_oneliners.swf",3 );
			moduleManager.AddEntry( "Minimap2Module",        	"hud_minimap2.swf",11 );
			moduleManager.AddEntry( "CompanionModule",        	"hud_companion.swf",30 );
			moduleManager.AddEntry( "DamagedItemsModule",      	"hud_damageditems.swf", 8 );
			moduleManager.AddEntry( "TimeLeftModule",      		"hud_timeleft.swf", 26 );

			//SetInputContext("Combat");
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function get hudName():String
		{
			return "defaultHud";
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
			
			_inputMgr = InputManager.getInstance();
			_inputMgr.enableHoldEmulation = false;
			_inputMgr.enableInputDeviceCheck = false;
			_inputMgr.addInputBlocker(true, "HUD_ROOT");
			
			var dummyButton:InputFeedbackButton = new InputFeedbackButton(); // dummy to include this class to hud.swf
			var dummyHintButton:HintButton = new HintButton(); // dummy to include this class to hud.swf
			var dummyModuleBase:HudModuleBase = new HudModuleBase();
			var dummyInputDelegate:InputDelegate = InputDelegate.getInstance();
			var dummyList:W3ScrollingList = new W3ScrollingList();
			var dummyModuleInputFeedback:ModuleInputFeedback = new ModuleInputFeedback();
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function loadModule( moduleName:String, ex:int ):void
		{
			var ref:Class
			var loader:Loader;
			var loaderContext:LoaderContext;

			var moduleEntry : HudModuleManagerEntry = moduleManager.FindModuleByName( moduleName );
			if ( moduleEntry )
			{
				loader = new Loader();
				loaderContext = new LoaderContext( false, ApplicationDomain.currentDomain );
				loader.load( new URLRequest( m_swfPath + moduleEntry.m_filename ), loaderContext );
				loader.contentLoaderInfo.addEventListener( Event.COMPLETE, handleMovieLoadComplete, false, 0, true );
				loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, handleMovieLoadError, false, 0, true );
			}
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override protected function unloadModule( moduleName:String, ex:int ):void
		{
			var moduleEntry : HudModuleManagerEntry = moduleManager.FindModuleByName( moduleName );
			if ( moduleEntry )
			{
				if ( moduleEntry.m_movieClip != null )
				{
					removeChild( moduleEntry.m_movieClip );
					moduleEntry.m_movieClip = null;
				}
			}
			else if ( moduleName == "TestModule" && mcTestModule != null )
			{
				removeChild(mcTestModule);
				mcTestModule = null;
			}
		}

		private function handleMovieLoadComplete( event:Event ):void
		{
			var loaderInfo:LoaderInfo = LoaderInfo( event.target );
			var loader:Loader = loaderInfo.loader;
			var depthIndex : int = 0;
			loaderInfo.removeEventListener( Event.COMPLETE, handleMovieLoadComplete, false );
			loaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, handleMovieLoadError, false );

			var filename : String = loaderInfo.url.slice( loaderInfo.url.lastIndexOf("\\") + 1 );

			var moduleEntry : HudModuleManagerEntry = moduleManager.FindModuleByFilename( filename );
			if ( moduleEntry )
			{
				moduleEntry.m_movieClip = loader.content as HudModuleBase;
				moduleEntry.m_movieClip.SetState(moduleEntry.m_state);
				depthIndex = moduleEntry.m_depthIndex;
			}
			else
			{
				trace( "ERROR load completed, but unknown movie: " + loaderInfo.url );
			}
			
			addChildAt( loader.content, Math.min(depthIndex,Math.max(numChildren-1,0)) );
			CheckModulesDepth();
		}

		function CheckModulesDepth()
		{
			if ( numChildren + loadError == moduleManager.entries.length )
			{
				moduleManager.SortEntries();
			}
		}

		private function handleMovieLoadError( event : Event ):void
		{
			var loaderInfo:LoaderInfo = LoaderInfo( event.target );
			var loader:Loader = loaderInfo.loader;
			loaderInfo.removeEventListener( Event.COMPLETE, handleMovieLoadComplete, false );
			loaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, handleMovieLoadError, false );
			loadError++;
			trace("ERROR cannot load " + loaderInfo.url );
		}

		public function ShowModules( show : Boolean )
		{
			moduleManager.ShowModules( show );
		}

		public function PrintInfo()
		{
			moduleManager.PrintInfo();
			debugHudList();
		}

		public function SetDynamic( value : Boolean )
		{
			isDynamic = value;
		}
		
		public function SetInputContext( value : String )
		{
			if (hudModuleStateArray.hasOwnProperty(value))
			{
				//trace("HUD hud module def for " + value + " exists !!! ");
				//trace("HUD hudModuleStateArray[value] "+hudModuleStateArray[value] );
				//trace("HUD hudModuleStateArray[value].findIndexOfValue(Show)" + hudModuleStateArray[value].findIndexOfValue("Show"));
				//trace("HUD hudModuleStateArray[value][0] " + hudModuleStateArray[value][0]);
				//trace("HUD hudModuleStateArray[value].Hide "+hudModuleStateArray[value].Hide );

				//trace("HUD hudModuleStateArray[value].states[0] " + hudModuleStateArray["Exploration"].states[0].state);
				//trace("HUD hudModuleStateArray[value].states[0] " + hudModuleStateArray["Exploration"].states[0].modules);

				var statesSize : int = hudModuleStateArray[value].states.length;
				
				var state : String;
				var moduleName : String;
				var modules : Array = new Array();
				var module : HudModuleBase;
				var j : int;
				var moduleEntry : HudModuleManagerEntry;

				for ( var i : int; i < statesSize; i ++ )
				{
					var curState:Object = hudModuleStateArray[value].states[i];
					state = curState.state;
					modules = curState.modules;
					
					//
					//trace("HUD");
					//trace("HUD for state: " + state+ " (state "+i+" )");
					//trace("HUD modules: " + modules);
					//trace("HUD modules.length: " + modules.length);
					//
					
					var modulesCount:int = modules.length;
					for(j = 0; j < modulesCount; j ++ )
					{
						moduleName = modules[ j ];
						moduleEntry = moduleManager.FindModuleByNameDict(moduleName);
						if ( moduleEntry )
						{
							module = moduleEntry.m_movieClip;
							
							if ( module )
							{
								//
								//trace("HUD module " + module + " moduleName " + moduleName );
								//
								
								if ( !module.isEnabled )
								{
									module.SetState("Hide")
								}
								if ( !isDynamic && state == "OnUpdate" && !module.isAlwaysDynamic )
								{
									if (module.getState() != "Show")
									{
										module.SetState("Show");
									}
								}
								else
								{
									if (module.getState() != state)
									{
										module.SetState(state);
									}
								}
							}
							else
							{
								moduleEntry.m_state = state;
								//
								//trace("HUD there is no module def for " + value+" state "+state);
								//
							}
						}
					}
				}
			}
			else
			{
				trace("HUD there is no hud module def for " + value);
			}
		}
		
		public function setGameLanguage( value : String )
		{
			CoreComponent.gameLanguage = value;
		}
		
		public function debugHudList():void
		{
			for(var j = 0; j < moduleManager.entries.length; j ++ )
			{
				var curHudModule:HudModuleManagerEntry = moduleManager.entries[j];
				if (curHudModule)
				{
					var curMc:HudModuleBase = curHudModule.m_movieClip;
					if (curMc)
					{
						trace("GFX ", curHudModule.m_name, " visible ",curMc.visible, "; alpha ", curMc.alpha);
					}
					else
					{
						trace("GFX ", curHudModule.m_name, " [NULL SWF] ");
					}
				}
			}
		}
		
		public function onCutsceneStartedOrEnded( started : Boolean )
		{
			var moduleEntry : HudModuleManagerEntry;
			var anchorsModule : HudModuleAnchors;

			moduleEntry = moduleManager.FindModuleByName( "AnchorsModule" );
			if ( moduleEntry )
			{
				anchorsModule = moduleEntry.m_movieClip as HudModuleAnchors;
				if ( anchorsModule )
				{
					if ( anchorsModule.isAspectRatio21_9() )
					{
						for ( var i = 0; i < moduleManager.entries.length; i++ )
						{
							if ( moduleManager.entries[ i ].m_name == "TimeLapseModule" ||
							     moduleManager.entries[ i ].m_name == "JournalUpdateModule" )
							{
								moduleManager.entries[ i ].m_movieClip.onCutsceneStartedOrEnded( started );
							}
						}
					}
				}
			}
		}
	}
}
