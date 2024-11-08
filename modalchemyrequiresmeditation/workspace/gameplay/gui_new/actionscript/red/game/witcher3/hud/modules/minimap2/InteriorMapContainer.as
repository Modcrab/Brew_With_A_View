package red.game.witcher3.hud.modules.minimap2
{
	import flash.display.MovieClip;
	import scaleform.clik.core.UIComponent;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import red.game.witcher3.hud.modules.HudModuleMinimap2;

	public class InteriorMapContainer extends UIComponent
	{
		private var _interior		: MinimapLoader;
		private var _interiorPosX	: Number;
		private var _interiorPosY	: Number;
		private var _interiorYaw	: Number;
		
		private const PENDING_NOTHING  : int = 0;
		private const PENDING_INTERIOR : int = 1;
		private const PENDING_EXTERIOR : int = 2;
		
		private var _pendingAction : int = PENDING_NOTHING;
		private var _pendingInteriorPosX : Number;
		private var _pendingInteriorPosY : Number;
		private var _pendingInteriorYaw : Number;
		private var _pendingInteriorTexture : String;

		public function InteriorMapContainer()
		{
			super();
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			_interior = new MinimapLoader();
			_interior.autoSize = false;
			_interior.addEventListener( Event.COMPLETE, handleTextureLoaded, false, 0, true );
			_interior.addEventListener( IOErrorEvent.IO_ERROR, handleTextureFailed, false, 0, true );
		}
		
		public function NotifyPlayerEnteredInterior( interiorPosX : Number, interiorPosY : Number, interiorYaw : Number, texture : String )
		{
			var path : String;
			
			trace("Minimap NotifyPlayerEnteredInterior [" + texture + "]" );
			
			if ( _interior.IsLoading() )
			{
				trace("Minimap Texture is being loaded, pending action" );
				_pendingAction          = PENDING_INTERIOR;
				_pendingInteriorPosX    = interiorPosX;
				_pendingInteriorPosY    = interiorPosY;
				_pendingInteriorYaw     = interiorYaw;
				_pendingInteriorTexture = texture;
				return;
			}
			
			path = "img://" + texture;
			if ( _interior.source != path )
			{
				// this can happen, when interior stays the same and players are changed (specifically Ciri -> Geralt after q103)
				_interior.source = path;
				addChild( _interior );
				_interior.x = 0;
				_interior.y = 0;
			}
			
			_interiorPosX = interiorPosX;
			_interiorPosY = interiorPosY;
			_interiorYaw = interiorYaw;
			
			rotation = -_interiorYaw;
		}

		public function NotifyPlayerExitedInterior()
		{
			trace("Minimap NotifyPlayerExitedInterior" );
			
			if ( _interior.IsLoading() )
			{
				trace("Minimap Texture is being loaded, pending action" );
				_pendingAction = PENDING_EXTERIOR;
				return;
			}
			_interior.source = "";
		}

		private function handleTextureLoaded( event : Event )
		{
			var bm : Bitmap = Bitmap( event.currentTarget.content );
			_interior.x = -bm.width / 2;
			_interior.y = -bm.height / 2;
			_interior.visible = true;
			
			trace("Minimap handleTextureLoaded" );
			_interior.OnLoadingComplete();
			
			RunPendingAction();
		}

		protected function handleTextureFailed(event:Event):void
		{
			trace("Minimap handleTextureFailed" );
			_interior.OnLoadingError();
			
			RunPendingAction();
		}
		
		private function RunPendingAction()
		{
			if ( _pendingAction  == PENDING_INTERIOR )
			{
				trace("Minimap RunPendingAction NotifyPlayerEnteredInterior [" + _pendingInteriorTexture + "]" );
				_pendingAction = PENDING_NOTHING;
				NotifyPlayerEnteredInterior( _pendingInteriorPosX, _pendingInteriorPosY, _pendingInteriorYaw, _pendingInteriorTexture );
			}
			else if ( _pendingAction  == PENDING_EXTERIOR )
			{
				trace("Minimap RunPendingAction NotifyPlayerExitedInterior" );
				_pendingAction = PENDING_NOTHING;
				NotifyPlayerExitedInterior();
			}
		}
		
		public function UpdatePosition()
		{
			x = HudModuleMinimap2.WorldToInteriorMapX( _interiorPosX - HudModuleMinimap2.m_playerWorldPosX );
			y = HudModuleMinimap2.WorldToInteriorMapY( _interiorPosY - HudModuleMinimap2.m_playerWorldPosY );
		}

	}
	
}
