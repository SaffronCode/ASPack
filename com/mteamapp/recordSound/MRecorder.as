// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package com.mteamapp.recordSound
{
	import flash.events.SampleDataEvent;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.ByteArray;
	import flash.permissions.PermissionStatus;
	import flash.events.PermissionEvent;

	/**recorder class , contains */
	public class MRecorder
	{
///////////////////////////////cashed variable from user
		/**this function will send back any thing that saved on byte array*/
		private static var onRecordEnded:Function;
		
		/**controlls max time that it can save data with it*/
		private static var maxTimeSupports:uint;
		
		/**save recorded sound on this byte array*/
		private static var recordedSound:ByteArray;
		
		
/////////////////////////////
		
		
		
		/**mian microphone object and its values*/
		private static var 	mic:Microphone,
							timeRate=44000,
							RATE = 11,
							SilentsSence:Number = 2,
							MULTYPLY=8;
		
		
/////////////////////////////////////////////play sound variables
		
		/**sound variables*/
		private static var 	snd:Sound,
							sndChan:SoundChannel;
							
		/**on audio is played*/
		private static var onPlayedFinished:Function;
		
		
		
/////////////////////////////////////////////user functions
		
		
		/**returns boolean that tells this device can support microphone or not*/
		public static function get isAvailable():Boolean
		{
			return Microphone.isSupported ;
		}
		
		/**it will returns recorded time based on seconds - if no recording activated , it will returns false time */
		public static function get recordedTime():uint
		{
			return Math.ceil(recordedSound.length/timeRate) ;
		}
		
		/**returns available time to record*/
		public static function get recordAvailableTime():uint
		{
			return Math.max(0,maxTimeSupports-recordedTime) ;
		}
		
		
		
		
		
		
		
		
		
		
		
		
		/**start recording audio and after record ended ( with stop function or time ups) 
		 * it will returns saved record on byteArray to onRecorded() function<br>
		 * if you call this function befor recording stoped , you will loose your recorded datas*/
		public static function startRecord(OnRecordEnded:Function,MaxTimeInSeconds:uint,silenceLinimt:Number=2)
		{
			//stop played sound if its playing
			stopPlayingSound(true)
			//cahs user values
			onRecordEnded = OnRecordEnded ;
			maxTimeSupports = MaxTimeInSeconds ;
			
			//reset recorded sounds
			recordedSound = new ByteArray();
			
			//start mic works
			
			mic = Microphone.getMicrophone();
			if (Microphone.permissionStatus != PermissionStatus.GRANTED)
			{
				mic.addEventListener(PermissionEvent.PERMISSION_STATUS,
					function(e:PermissionEvent):void {
						if (e.status == PermissionStatus.GRANTED)
						{
							onPermissionGranted();
						}
						else
						{
							// permission denied
						}
					});
				
				try {
					mic.requestPermission();
				} catch(e:Error)
				{
					// another request is in progress
				}
			}
			else
			{
				onPermissionGranted();
			}

			function onPermissionGranted():void
			{
				mic.rate = RATE ;
				SilentsSence = silenceLinimt ;
				mic.setSilenceLevel(SilentsSence);
				mic.addEventListener(SampleDataEvent.SAMPLE_DATA,recordAudio);
			}
		}
		
		
////////////////////////////////////////////////private functions
		
		/**sample data catched , now its time to save some records*/
		private static function recordAudio(e:SampleDataEvent)
		{
			while(e.data.bytesAvailable)
			{
				recordedSound.writeFloat(e.data.readFloat());
			}
			
			if(recordedTime>maxTimeSupports)
			{
				stop();
			}
		}
		
		
		/**stop recording and returns saved sound to onRecordEnded()  function*/
		public static function stop(withOutFeedBack:Boolean=false)
		{
			maxTimeSupports = 0 ;
			if(mic!=null)
			{
				mic.removeEventListener(SampleDataEvent.SAMPLE_DATA,recordAudio);
				mic = null ;
				
				if(!withOutFeedBack)
				{
					recordedSound.position = 0 ;
					if(recordedSound.length<MULTYPLY*5)
					{
						//the sound is very small and it will not save any datas
						onRecordEnded(new ByteArray());
					}
					else
					{	
						onRecordEnded(recordedSound);
					}
				}
			}
		}
		
		
//////////////////////////////////////////////////////////sound player classes
		
		/**play thi pyte array as sound*/
		public static function playSavedSound(SavedByteArray:ByteArray,onSoundIsOver:Function = null )
		{
			//stop recording
			stop(true);
			stopPlayingSound(true);
			
			//add event listener
			onPlayedFinished = onSoundIsOver;
			
			//reset pure data
			SavedByteArray.position = 0 ;
			
			// set recorded sound to byte array
			recordedSound = new ByteArray();
			recordedSound.writeBytes(SavedByteArray);
			recordedSound.position = 0 ;
			
			trace('time to play my sound : '+recordedSound.bytesAvailable);
			
			snd = new Sound();
			snd.addEventListener(SampleDataEvent.SAMPLE_DATA,changeSoundWaves);
			sndChan = snd.play();
		}
		
		/**change sound waves with recorded sound variables*/
		private static function changeSoundWaves(e:SampleDataEvent)
		{
			for(var i=0;i<8192;i++)
			{
				if(recordedSound.bytesAvailable)
				{
					var readed = recordedSound.readFloat();
					var nowI = i ;
					for(i;i<Math.min(nowI+MULTYPLY,8192);i++)
					{
						e.data.writeFloat(readed);
					}
				}else{
					break;
				}
			}
			if(!recordedSound.bytesAvailable){
				stopPlayingSound();
			}
		}
		
		
		/**stop current playing sound wave*/
		public static function stopPlayingSound(withoutFeedBack:Boolean = false)
		{
			if(snd!=null)
			{
				snd.removeEventListener(SampleDataEvent.SAMPLE_DATA,changeSoundWaves);
				if(!withoutFeedBack && onPlayedFinished!=null)
				{
					onPlayedFinished()
				}
			}
		}
		
		
		
		
		
		/**returns played sound time*/
		public static function get playedSoundTime():uint
		{
			return Math.ceil((recordedSound.length-recordedSound.bytesAvailable)/timeRate);
		}
		
		/**returns available secont to play*/
		public static function get playedSoundAvailable():uint
		{
			return Math.floor(recordedSound.bytesAvailable/timeRate) ;
		}
	}
}