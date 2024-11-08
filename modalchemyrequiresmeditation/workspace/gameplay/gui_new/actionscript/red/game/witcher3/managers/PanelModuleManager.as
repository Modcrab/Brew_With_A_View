package red.game.witcher3.managers
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import scaleform.clik.core.UIComponent;
	import flash.utils.getDefinitionByName;
	
	import red.core.events.GameEvent;
	
	import flash.external.ExternalInterface;
	
	//>---------------------------------------------------------------------------
	
	// This module has two matching array as parameters
	// 		- m_moduleClasses contains the list of class to load from the library and attach on the stage
	// 		- m_moduleAnchors contains the list of anchors to attach those modules on.
	//			*An anchor can be any kind of displayobject and will be set at visible=false when the component is attached
	// This two arrays must be exactly the same size
	//----------------------------------------------------------------------------
	public class PanelModuleManager extends UIComponent
	{
		//>---------------------------------------------------------------------------
		// VARIABLES
		//----------------------------------------------------------------------------
		// Constants
		// Max Ratio
		private	const	MAX_SCREEN_WIDTH 	: Number	=	1920;
		private	const	MAX_SCREEN_HEIGHT 	: Number	=	1080;
		// Inspectable (modifiable in the flash IDE)
		
		// [Collection(collectionClass="fl.data.DataProvider", identifier="item", collectionItem="fl.data.SimpleCollectionItem")]
		// above is to have everything in one array, to have array with multi fields
		
		[Inspectable]	public 	var 	m_moduleClasses : Array;
		[Inspectable]	public 	var 	m_moduleClassesOverride : Array;
		[Inspectable]	public 	var 	m_moduleChilds : Array;
		[Inspectable]	public 	var 	m_moduleAnchors : Array;
		// Storage
		private 	var 		m_modulesA					: Vector.<MovieClip>;
		private		var			m_anchorsDefaultPositionsVP	: Vector.<Point>;
		private		var			m_bUsingGamepad	: Boolean = true;
		//>---------------------------------------------------------------------------
		// Init
		//----------------------------------------------------------------------------
		public function PanelModuleManager()
		{
		}
		//>---------------------------------------------------------------------------
		// NB: Component parameters (inspectable variables) are initialized in the configUI
		//----------------------------------------------------------------------------
		override protected function configUI():void
		{
			dispatchEvent( new GameEvent(GameEvent.REGISTER, 'inventory.gamepad.state',[SetUsingGamepad]));
			//dispatchEvent( new GameEvent(GameEvent.CALL, 'OnRequestGamepadUsageState'));
			if ( m_moduleAnchors ) // #B Null check
			{
				SaveAnchorsDefaultPosition();
				
				InstanciateModules();
				MatchModulesWithAnchors();
			}
			super.configUI();
		}
		//>---------------------------------------------------------------------------
		//----------------------------------------------------------------------------
		private function SaveAnchorsDefaultPosition() : void
		{
			var l_anchorNameS	: String;
			var l_anchorDO		: DisplayObject;
			m_anchorsDefaultPositionsVP = new Vector.<Point>();
			
			for (var i:int = 0; i < m_moduleAnchors.length; i++)
			{
				l_anchorNameS = m_moduleAnchors[i];
				l_anchorDO = this.parent[ l_anchorNameS ];
					
				if ( l_anchorDO )
				{
					m_anchorsDefaultPositionsVP.push( new Point( l_anchorDO.x, l_anchorDO.y ) );
				}
			}
		}
				
		public function SetUsingGamepad( value : Boolean ) : void
		{
			m_bUsingGamepad = value;
		}
		
		public function IsUsingGamepad() : Boolean
		{
			if ( ExternalInterface.available )
			{
				m_bUsingGamepad =  ExternalInterface.call( "isPadConnected" ); // #B fix that after engine fix
			}
			return m_bUsingGamepad;
		}
		
		//>---------------------------------------------------------------------------
		//----------------------------------------------------------------------------
		private function InstanciateModules() : void
		{
			var l_classNameS 		: String;
			var l_classC			: Class;
			var l_moduleM			: MovieClip;
			var l_platformSuffix	: String;
			var i					: int			;
			//trace("LOAD InstanciateModules ");
			m_modulesA = new Vector.<MovieClip>();
			i = 0;
			
			if ( m_moduleChilds )
			{
				for ( i = 0; i < m_moduleChilds.length; i++ )
				{
					l_classNameS = m_moduleChilds[i];
					l_moduleM = this.parent.getChildByName(l_classNameS) as MovieClip;
					//trace("LOAD FIND CHILD "+( l_classNameS )+" "+l_moduleM);
					if (l_moduleM)
					{
						m_modulesA.push( l_moduleM );
					}
				}
			}
			//trace("LOAD MODULE BF " + i);
			if ( m_moduleClasses )
			{
				for ( i = 0; i < m_moduleClasses.length; i++ )
				{
					//trace("LOAD MODULE "+i);
					l_classNameS = m_moduleClasses[i];
					l_classC = getDefinitionByName( l_classNameS ) as Class;
					//trace("LOAD MODULE "+( l_classNameS  ));
					if ( l_classC != null )
					{
						l_moduleM = new l_classC() as MovieClip;
						m_modulesA.push( l_moduleM );
					}
				}
			}
			if ( m_moduleClassesOverride )
			{
				if( IsUsingGamepad() )// #B for now is working only for pad connected/unconected
				{
					l_platformSuffix = "_CONSOLE";
				}
				else
				{
					l_platformSuffix = "_PC";
				}
				//trace("LOAD MODULE OV "+i);
				for ( i = 0; i < m_moduleClassesOverride.length; i++ )
				{
					//trace("LOAD MODULE OV "+i);
					l_classNameS = m_moduleClassesOverride[i];
					//trace("LOAD MODULE OV "+( l_classNameS + l_platformSuffix ));
					l_classC = getDefinitionByName( l_classNameS + l_platformSuffix ) as Class; // #B
					
					if ( l_classC != null )
					{
						l_moduleM = new l_classC() as MovieClip;
						m_modulesA.push( l_moduleM );
					}
				}
			}
		}
		//>---------------------------------------------------------------------------
		//----------------------------------------------------------------------------
		private function MatchModulesWithAnchors() : void
		{
			
			var l_anchorNameS	: String;
			var l_anchorDO		: DisplayObject;
			
			UpdateAnchorsPositions();
			
			for (var i:int = 0; i < m_modulesA.length; i++)
			{
				if ( m_moduleAnchors.length >= i )
				{
					l_anchorNameS = m_moduleAnchors[i];
					l_anchorDO = this.parent[ l_anchorNameS ];
					
					if ( l_anchorDO )
					{
						l_anchorDO.visible = false;
						m_modulesA[i].x = l_anchorDO.x;
						m_modulesA[i].y = l_anchorDO.y;
						if ( !parent.contains( m_modulesA[i] ))
							parent.addChild( m_modulesA[i] );
						
					}
				}
			}
		}
		//>---------------------------------------------------------------------------
		// Could be call from the Witcher Script
		//----------------------------------------------------------------------------
		public function UpdateAnchorsPositions() : void
		{
			var l_anchorNameS	: String;
			var l_anchorDO		: DisplayObject;
			
			var l_widthPerN		: Number;
			var l_heightPerN	: Number;
			
			for (var i:int = 0; i < m_moduleAnchors.length; i++)
			{
				l_anchorNameS = m_moduleAnchors[i];
				l_anchorDO = this.parent[ l_anchorNameS ];
				
				if ( l_anchorDO )
				{
					l_widthPerN 	=  m_anchorsDefaultPositionsVP[i].x / MAX_SCREEN_WIDTH;
					l_heightPerN 	=  m_anchorsDefaultPositionsVP[i].y / MAX_SCREEN_HEIGHT;
					
					l_anchorDO.x = stage.stageWidth * l_widthPerN;
					l_anchorDO.y = stage.stageHeight * l_heightPerN;
				}
			}
		}
		//>---------------------------------------------------------------------------
		//----------------------------------------------------------------------------
		public function GetModules() : Vector.<MovieClip> //#B
		{
			return m_modulesA;
		}
		//>---------------------------------------------------------------------------
		//----------------------------------------------------------------------------
	}

}