package red.game.witcher3.menus.overlay
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTweener;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3GamepadButton;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import red.core.CoreComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;

	/**
	 * Overlay layer for popups and other stuff
	 * @author Yaroslav Getsevich
	 *
	 * TODO: RENAME
	 */
	public class OverlayPanel extends CoreMenu
	{
		public var background:Sprite;
		protected var _feedbackMap:Array;
		protected var _popup:BasePopup;

		public function OverlayPanel()
		{
			upToCloseEnabled = false;
			_restrictDirectClosing = true;
			_disableShowAnimation = true;
			_enableInputValidation = true;
			_loadAssets = false;
			visible = false;
			super();
		}

		override protected function configUI():void
		{
			super.configUI();
			
			///registerRenderTarget( "test_nopack", 1024, 1024 );
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'popup.data', [handlePopupData]));
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );

			background.x = Extensions.visibleRect.x;
			background.y = Extensions.visibleRect.y;
			background.width = Extensions.visibleRect.width;
			background.height = Extensions.visibleRect.height;

			if (!Extensions.isScaleform)
			{
				//startDebugMode();
			}

			visible = true;
			this.alpha = 0;
			GTweener.to(this, .5, { alpha:1 }, { ease:Exponential.easeOut } );
		}

		protected function handlePopupData(dataObject:Object):void
		{
			var popupContentRef:Class;
			var popupInstance:BasePopup;
			
			if (!dataObject)
			{
				throw(new Error("WARNING: Can't create a popup, data is NULL"));
				closeMenu();
			}

			if ( _popup as QuantityMonsterBarganingPopup )
			{
				popupInstance = _popup;
			}
			else
			{
				try
				{
					popupContentRef = getDefinitionByName(dataObject.ContentRef) as Class;
					popupInstance = new popupContentRef() as BasePopup;
					
					var inputModule:ModuleInputFeedback = popupInstance.mcInpuFeedback;
					if (inputModule)
					{
						inputModule.filterKeyCodeFunction = isKeyCodeValid;
						inputModule.filterNavCodeFunction = isNavEquivalentValid;
					}
				}
				catch (er:Error)
				{
					throw(new Error("WARNING: Can't create definition " + dataObject.ContentRef + " in the OverlayMenu.fla : " + er.message));
					closeMenu();
				}
			}
			if (popupInstance)
			{
				popupInstance.data = dataObject;
				_popup = popupInstance;
				addChild(popupInstance);
				popupInstance.validateNow();
			}
			if( dataObject.backgroundVisible != null )
			{
				background.visible = dataObject.backgroundVisible;
			}
			if (dataObject.ButtonsList)
			{
				_feedbackMap = dataObject.ButtonsList;
			}
		}

		// deprecated
		protected function checkInputMap(navEq:String = "", navCode:int = 0):Boolean
		{
			if (_feedbackMap)
			{
				var len:int = _feedbackMap.length;
				for (var i:int = 0; i < len; i++ )
				{
					if (_feedbackMap[i].gamepad_navEquivalent == navEq ||
						_feedbackMap[i].keyboard_keyCode == navCode)
					{
						return true;
					}
				}
			}
			return false;
		}

		override protected function get menuName():String
		{
			return "PopupMenu";
		}

		private function startDebugMode():void
		{
			var debugData:Object = { };
			debugData.ContentRef = "ItemInfoPopupRef";
			
			var tutorialsList:Array = [];
			tutorialsList.push( { label:"1", title:"Some Title 1", description:"Some Description 1" } );
			tutorialsList.push( { label:"1", title:"Some Title 2", description:"Some Description 2" } );
			tutorialsList.push( { label:"1", title:"Some Title 3", description:"Some Description 3" } );
			debugData.tutorialList = tutorialsList;
				
			handlePopupData(debugData);
		}

		public function setBarValue( _Percentage : Number ):void
		{
			var quantityMonsterBarganingPopup : QuantityMonsterBarganingPopup = _popup as QuantityMonsterBarganingPopup;
			if ( quantityMonsterBarganingPopup )
			{
				quantityMonsterBarganingPopup.setBarValue( _Percentage );
			}
		}
	}
}
