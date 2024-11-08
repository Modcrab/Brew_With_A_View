/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.glossary
{
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3UILoader;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.core.UIComponent;
		
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Exponential;
	
	public class GlossaryTextureSubListModule extends UIComponent
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		public var mcLoader : W3UILoader;
		
		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/
		
		public var dataBindingKey : String = "glossary.characters.sublist";
		public var imagePathPrefix : String = "img://textures/journal/characters/";
		protected var DATA_UPDATE_ALPHA_ANIMATION_TIME : Number = 3;
		
		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/
						
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function GlossaryTextureSubListModule()
		{
			super();
			//mcRewards.dataBindingKeyReward = "glossary.bestiary.sublist.items";
			//mcLoader.source = "img://textures/journal/bestiary/alghul.png";
		}
		
		protected override function configUI():void
		{
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey+'.image', [handleSetImage]));
			super.configUI();
		}

		override public function toString() : String
		{
			return "[W3 GlossaryTextureSubListModule]"
		}
		
		/********************************************************************************************************************
			PRIVATE FUNCTIONS
		/ ******************************************************************************************************************/
		
		public function handleSetImage( value : String ) : void
		{
			mcLoader.source = imagePathPrefix + value;
			//if ( alpha != 1 )
			//{
				this.alpha = 0;
				GTweener.to( this, DATA_UPDATE_ALPHA_ANIMATION_TIME, { alpha:1 },  { ease: Exponential.easeOut } );
			//}
		}
		
		public function setImage( value : String ) : void
		{
			mcLoader.source = value;
			
			this.alpha = 0;
			GTweener.to( this, DATA_UPDATE_ALPHA_ANIMATION_TIME, { alpha:1 },  { ease: Exponential.easeOut } );
		}
	}
}
