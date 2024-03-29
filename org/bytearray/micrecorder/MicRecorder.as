﻿package org.bytearray.micrecorder
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.PermissionEvent;
	import flash.events.SampleDataEvent;
	import flash.events.StatusEvent;
	import flash.media.Microphone;
	import flash.permissions.PermissionStatus;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import org.bytearray.micrecorder.encoder.WaveEncoder;
	import org.bytearray.micrecorder.events.RecordingEvent;
	import contents.alert.Alert;
	
	/**
	 * Dispatched during the recording of the audio stream coming from the microphone.
	 *
	 * @eventType org.bytearray.micrecorder.RecordingEvent.RECORDING
	 *
	 * * @example
	 * This example shows how to listen for such an event :
	 * <div class="listing">
	 * <pre>
	 *
	 * recorder.addEventListener ( RecordingEvent.RECORDING, onRecording );
	 * </pre>
	 * </div>
	 */
	[Event(name='recording', type='org.bytearray.micrecorder.RecordingEvent')]
	
	/**
	 * Dispatched when the creation of the output file is done.
	 *
	 * @eventType flash.events.Event.COMPLETE
	 *
	 * @example
	 * This example shows how to listen for such an event :
	 * <div class="listing">
	 * <pre>
	 *
	 * recorder.addEventListener ( Event.COMPLETE, onRecordComplete );
	 * </pre>
	 * </div>
	 */
	[Event(name='complete', type='flash.events.Event')]

	/**
	 * This tiny helper class allows you to quickly record the audio stream coming from the Microphone and save this as a physical file.
	 * A WavEncoder is bundled to save the audio stream as a WAV file
	 * @author Thibault Imbert - bytearray.org
	 * @version 1.2
	 * 
	 */	
	public final class MicRecorder extends EventDispatcher
	{
		private var _gain:uint;
		private var _rate:uint;
		private var _silenceLevel:uint;
		private var _timeOut:uint;
		private var _difference:uint;
		private var _microphone:Microphone;
		private var _buffer:ByteArray = new ByteArray();
		private var _output:ByteArray;
		private var _encoder:IEncoder;
		
		private var _completeEvent:Event = new Event ( Event.COMPLETE );
		private var _recordingEvent:RecordingEvent = new RecordingEvent( RecordingEvent.RECORDING, 0 );

		private var isPaused:Boolean = false ;
		
		/**
		 * 
		 * @param encoder The audio encoder to use
		 * @param microphone The microphone device to use
		 * @param gain The gain
		 * @param rate Audio rate
		 * @param silenceLevel The silence level
		 * @param timeOut The timeout
		 * 
		 */		
		public function MicRecorder(encoder:IEncoder, microphone:Microphone=null, gain:uint=100, rate:uint=44, silenceLevel:uint=0, timeOut:uint=4000)
		{
			_encoder = encoder;
			_microphone = microphone;
			_gain = gain;
			_rate = (rate==0)?44:rate;
			_silenceLevel = silenceLevel;
			_timeOut = timeOut;
		}
		
		public function get length():Number
		{
			return _recordingEvent.time ;
		}
		
		public function pause():void
		{
			isPaused = true ;
		}
		
		public function unPuase():void
		{
			isPaused = false ;
		}
		
		/**
		 * Starts recording from the default or specified microphone.
		 * The first time the record() method is called the settings manager may pop-up to request access to the Microphone.
		 */		
		public function record():void
		{
			isPaused = false ;
			_difference = getTimer();
			if ( _microphone == null )
				_microphone = Microphone.getMicrophone();
			
			if (Microphone.permissionStatus != PermissionStatus.GRANTED)
			{
				_microphone.addEventListener(PermissionEvent.PERMISSION_STATUS,
					function(e:PermissionEvent):void {
						if (e.status == PermissionStatus.GRANTED)
						{
							micConnected();
						}
						else
						{
							// permission denied
						}
					});
				
				try {
					_microphone.requestPermission();
				} catch(e:Error)
				{
					// another request is in progress
				}
			}
			else
			{
				micConnected();
			}
			 
			
			
			
			function micConnected():void
			{
				_microphone.setSilenceLevel(_silenceLevel, _timeOut);
				_microphone.gain = _gain;
				_microphone.rate = _rate;
				_buffer.length = 0;
				
				_microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
				_microphone.addEventListener(StatusEvent.STATUS, onStatus);
			}
		}

		public static function getMicrophonePermission(onPermissionGranted:Function=null,noPermission:Function=null):Boolean
		{
			var _mic:Microphone = new Microphone();
			trace("Microphone.permissionStatus : "+Microphone.permissionStatus);
			if (Microphone.permissionStatus != PermissionStatus.GRANTED)
			{
				_mic.addEventListener(PermissionEvent.PERMISSION_STATUS,
					function(e:PermissionEvent):void {
						if (e.status == PermissionStatus.GRANTED)
						{
							if(onPermissionGranted!=null)onPermissionGranted();
						}
						else
						{
							if(noPermission!=null)noPermission();
						}
					});
				
				try {
					_mic.requestPermission();
				} catch(e:Error)
				{
					// another request is in progress
				}
			}
			else
			{
				onPermissionGranted();
				return true;
			}
			return false; 
		}
		
		private function onStatus(event:StatusEvent):void
		{
			_difference = getTimer();
		}
		
		/**
		 * Dispatched during the recording.
		 * @param event
		 */		
		private function onSampleData(event:SampleDataEvent):void
		{
			if(isPaused)
			{
				return ;
			}
			_recordingEvent.time = getTimer() - _difference;
			
			dispatchEvent( _recordingEvent );
			
			while(event.data.bytesAvailable > 0)
				_buffer.writeFloat(event.data.readFloat());
		}
		
		/**
		 * Stop recording the audio stream and automatically starts the packaging of the output file.
		 */		
		public function stop():void
		{
			if(_microphone)
				_microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			
			_buffer.position = 0;
			
			var realRate:uint ;
			
			switch(_rate)
			{
				case 44:
					realRate = 44100;
					break;
				case 22:
					 realRate = 22050;
					 break;
				case 11:
					 realRate = 11025;
					 break;
				case 8:
					 realRate = 8000;
					 break;
				case 5:
					 realRate = 5512;
					 break;
				 default:
				 	realRate = 44100 ;
			}
			
			_output = _encoder.encode(_buffer, 1,16,realRate);
			
			dispatchEvent( _completeEvent );
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get gain():uint
		{
			return _gain;
		}
		
		/**
		 * 
		 * @param value
		 * 
		 */		
		public function set gain(value:uint):void
		{
			_gain = value;
		}

		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get rate():uint
		{
			return _rate;
		}

		/**
		 * 
		 * @param value
		 * 
		 */		
		public function set rate(value:uint):void
		{
			_rate = value;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get silenceLevel():uint
		{
			return _silenceLevel;
		}

		/**
		 * 
		 * @param value
		 * 
		 */		
		public function set silenceLevel(value:uint):void
		{
			_silenceLevel = value;
		}


		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get microphone():Microphone
		{
			return _microphone;
		}

		/**
		 * 
		 * @param value
		 * 
		 */		
		public function set microphone(value:Microphone):void
		{
			_microphone = value;
		}

		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get output():ByteArray
		{
			return _output;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public override function toString():String
		{
			return "[MicRecorder gain=" + _gain + " rate=" + _rate + " silenceLevel=" + _silenceLevel + " timeOut=" + _timeOut + " microphone:" + _microphone + "]";
		}
	}
}