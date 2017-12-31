package com.mteamapp.recorder
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import fr.kikko.lab.ShineMP3Encoder;
	
	import org.bytearray.micrecorder.MicRecorder;
	import org.bytearray.micrecorder.encoder.WaveEncoder;
	import org.bytearray.micrecorder.events.RecordingEvent;
	
	import wrokersJob.WorkerFunctions;

	/**Recording is completed and mp3 is ready to use*/
	[Event(name="complete", type="flash.events.Event")]
	/**Converting faild*/
	[Event(name="error", type="flash.events.ErrorEvent")]
	/**Recording is over and converting is started*/
	[Event(name="progress", type="flash.events.ProgressEvent")]
	public class SoundRecorder extends EventDispatcher
	{
		public static var volue:Number = 0.5 ;
		
		public static var dispatcher:SoundRecorder = new SoundRecorder();
		
		private static var recorder:MicRecorder;
		
		public static var length:Number ;
		
		private static var _isRecording:Boolean = false ;
		
		private static var timeOutId:uint;
		
		private static var isSetUp:Boolean = false ;
		
		private static var mp3Encoder:ShineMP3Encoder;
		
		private static var MP3Bytes:ByteArray ;
		
		private static var WAVEByte:ByteArray ;
		
		private static var saveWaveFormat:Boolean = false ;
		
		private static var _onSaveProccess:Boolean = false ;
		private static var recordStartTime:int;
		private static var Duration:Number;
		
		public static function get MP3File():ByteArray
		{
			return MP3Bytes ;
		}
		
		public static function get wavFile():ByteArray
		{
			return WAVEByte ;
		}
		
		public static function createWaveForm(len:uint=50):Array
		{
			if(WAVEByte==null)
			{
				return [] ;
			}
			
			const div:uint = 4 ;
			
			var waveForm:Array = [] ;
			var fileL:Number = WAVEByte.length;
			len = Math.min(fileL,len);
			var sliceL:uint = Math.max(1,Math.floor((fileL/div)/len)) ;
			
			trace("fileL : "+fileL);
			trace("sliceL : "+sliceL);
			for(var j:int = 0 ; waveForm.length<len ; j+=sliceL)
			{
				trace("Get sound position from : "+j);
				WAVEByte.position = Math.min(fileL,j*div) ;
				waveForm.push(WAVEByte.readByte())
			}
			return waveForm ;
		}
		
		private static function setUp():void
		{
			if(!isSetUp)
			{
				var wavEncoder:WaveEncoder  = new WaveEncoder();
				
				recorder = new MicRecorder( wavEncoder );
				recorder.addEventListener(RecordingEvent.RECORDING, onRecording);
				recorder.addEventListener(Event.COMPLETE, onRecordComplete);
			}
		}
		
		protected static function onRecordComplete(event:Event):void
		{
			
			trace("Record is stopped!");
			
			dispatcher.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
			length = recorder.length ;
			
			WAVEByte = new ByteArray();
			WAVEByte.writeBytes(recorder.output);
			
			if(!saveWaveFormat)
			{
				//WorkerFunctions.byteToBase64(fd
				mp3Encoder = new ShineMP3Encoder(recorder.output);
				mp3Encoder.addEventListener(Event.COMPLETE, mp3EncodeComplete);
				mp3Encoder.addEventListener(ProgressEvent.PROGRESS, mp3EncodeProgress);
				mp3Encoder.addEventListener(ErrorEvent.ERROR, mp3EncodeError);
				mp3Encoder.start();
			}
			else
			{
				MP3Bytes = new ByteArray();
				MP3Bytes.writeBytes(recorder.output);
				trace("Wave is ready");
				_isRecording = false ;
				_onSaveProccess = false ;
				dispatcher.dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		protected static function mp3EncodeError(event:Event):void
		{
			
			trace("Mp3 convertor error on SoundRecorder class");
			_isRecording = false ;
			dispatcher.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
		}
		
		protected static function mp3EncodeProgress(event:ProgressEvent):void
		{
			
			trace("On recording progress : "+event.bytesLoaded,event.bytesTotal);
			dispatcher.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS,false,false,event.bytesLoaded,event.bytesTotal));
		}
		
		protected static function mp3EncodeComplete(event:Event):void
		{
			
			MP3Bytes = new ByteArray();
			MP3Bytes.writeBytes(mp3Encoder.mp3Data);
			trace("MP3 is ready");
			_isRecording = false ;
			_onSaveProccess = false ;
			dispatcher.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private static function onRecording(e:RecordingEvent):void
		{
			trace("... on recording proccess");
		}
		
		public static function get isRecording():Boolean
		{
			return _isRecording;
		}

		/**Recrod duration is based on milisecond.*/
		public static function startRecording(duration:Number=10*60*1000,SaveWaveFormat:Boolean = false):void
		{
			saveWaveFormat = SaveWaveFormat ;
			setUp();
			if(WAVEByte!=null)
			{
				WAVEByte.clear();
			}
			WAVEByte = null ;
			
			if(_isRecording)
			{
				trace("The SoundRecorder is already recording");
				cansel() ;
			}
			_onSaveProccess = false ;
			clearTimeout(timeOutId);
			MP3Bytes = new ByteArray();
			_isRecording = true;
			recorder.record();
			recordStartTime = getTimer();
			Duration = duration ;
			if(duration!=0)
			{
				timeOutId = setTimeout(stopRecording,duration);
			}
		}
		
		/**Returns in miliseconds*/
		public static function getRecordingTimeLeft():int
		{
			if(Duration == 0)
			{
				return 0 ;
			}
			else
			{
				var deltaTime:int = getTimer()-recordStartTime ;
				return Math.max(0,Duration-deltaTime);
			}
		}
		
		public static function getRecordingTimeLeftInSecond():uint
		{
			return Math.floor(getRecordingTimeLeft()/1000)
		}
		
		public static function pause():void
		{
			recorder.pause();
		}
		
		public static function unPause():void
		{
			recorder.unPuase();
		}
		
		/**cansel the recording and do not dispatch any events*/
		public static function cansel():void
		{
			trace("Recording canseled");
			recorder.removeEventListener(Event.COMPLETE, onRecordComplete);
			clearTimeout(timeOutId);
			_isRecording = false ;
			recorder.stop();
			recorder.addEventListener(Event.COMPLETE, onRecordComplete);
		}
		
		/**Stop the recording progress*/
		public static function stopRecording():void
		{
			_onSaveProccess = true ;
			clearTimeout(timeOutId);
			if(!_isRecording)
			{
				trace("Nothing is recording");
				return ;
			}
			trace("Stop the recording!");
			recorder.stop();
		}
		
		/**Returns true if it is on the saving proccess*/
		public static function isOnSavingProccess():Boolean
		{
			return _onSaveProccess ;
		}
	}
}