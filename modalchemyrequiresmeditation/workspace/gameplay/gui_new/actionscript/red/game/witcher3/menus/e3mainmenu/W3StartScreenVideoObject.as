package red.game.witcher3.menus.e3mainmenu
{
	import scaleform.clik.core.UIComponent;
	
	import flash.display.MovieClip;
	
	import flash.events.Event;
	
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.media.SoundTransform;
	import flash.events.NetStatusEvent;
	
	import scaleform.gfx.Extensions;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;
	
	public class W3StartScreenVideoObject extends UIComponent
	{
		
		public var video : MovieClip;
		private var ns:NetStream;
		private var videoToPlay:String;
		
		public function W3StartScreenVideoObject()
		{
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
			update();
		}
		
		private function update()
		{
		}
		
		public function OpenVideo(movieName : String)
		{
			videoToPlay = movieName;
			//videoToPlay = "W3_DEMO_START.usm";
			var myVideo:Video = new Video(video.width, video.height);
			video.addChild(myVideo);
			
			var nc:NetConnection = new NetConnection();
			nc.connect(null);
			ns = new NetStream(nc);
			
			myVideo.attachNetStream(ns);

			var netClient:Object = new Object();
			netClient.onMetaData = handleMetaDataEvent;
			netClient.onCuePoint = handleCuePointEvent;
			netClient.onSubtitle = handleSubtitleEvent;
			ns.client = netClient;

			var sound:SoundTransform = new SoundTransform( 1.0 );
			var subSound:SoundTransform = new SoundTransform( 1.0 );
			
			ns.soundTransform = sound;
			
			if ( Extensions.enabled )
			{
				ns["subSoundTransform"] = subSound;
			}

			//btn_play.selected = true;

			ns.bufferTime = 1.5;
			
			//ns.reloadThresholdTime = 0.3;
			//ns.numberOfFramePools = 1;
			//ns.openTimeout = 0;
			
			if ( Extensions.isScaleform )
			{
				ns["loop"] = true;
			}
			
			ns.play(videoToPlay);
			ns.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			trace("video play "+videoToPlay);
		}
		
		function statusHandler(event:NetStatusEvent):void {
			trace("status: " + event.info.code);

			if(event.info.code == "NetStream.Play.Start")
			{
		//		ns.audioTrack = 16;
		//		ns.voiceTrack = 17;
		//		ns.subAudioTrack = 18;
		//		ns.subtitleTrack = 1;
		//		ns.s
			}

			if (event.info.code == "NetStream.Play.Stop") {
				//ns.seek(0);
				//ns.play(videoToPlay);
				//myvideo.clear();
			}
		}
		
		/*
		public function get IconPath():String { return _iconPath; }
		public function set IconPath(value:String):void
		{
			_iconPath = value;
			updateIcon();
		}*/
		
		function handleMetaDataEvent(meta:Object):void {
			if (meta) {
				trace("duration: "    + meta.duration);
				trace("width: "       + meta.width);
				trace("height: "      + meta.height);
				trace("frameRate: "   + meta.frameRate);
				trace("totalFrames: " + meta.totalFrames);
				trace("audioTracks: "    + meta.audioTracksCount);
				trace("subtitleTracks: " + meta.subtitleTracksCount);
				trace("cuePoints: "      + meta.cuePointsCount);
			}
		}
		function handleCuePointEvent(item:Object):void {
			if (item) {
				trace("cuePoint: " + item.name + ", " + item.time + ", " + item.type);
				for (var param:String in item.parameters) {
					trace("\t" + param + ":\t" + item.parameters[param]);
				}
			}
		}
		function handleSubtitleEvent(msg:String) {
			if (msg) {
				trace("subtitle: " + msg);
			}
		}
		
		public function PauseVideo() : void
		{
			ns.togglePause();
		}
		
		public function SetSoundVolume(value:Number)
		{
			var sound:SoundTransform = new SoundTransform( value );
			var subSound:SoundTransform = new SoundTransform( value );
			
			ns.soundTransform = sound;
			
			if ( Extensions.enabled )
			{
				ns["subSoundTransform"] = subSound;
			}
		}
	}
}
