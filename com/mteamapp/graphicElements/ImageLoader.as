package com.mteamapp.graphicElements
{
	import com.mteamapp.loader.urlSaver.URLSaver;
	import com.mteamapp.loader.urlSaver.URLSaverEvent;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	[Event(name="IMAGE_LOADED", type="com.mteamapp.loader.urlSaver.URLSaverEvent")]
	[Event(name="IMAGE_URL_NOT_FOUNDS", type="com.mteamapp.loader.urlSaver.URLSaverEvent")]
	
	public class ImageLoader extends MovieClip
	{
		public static const IMAGE_LOADED:String = "IMAGE_LOADED";
		
		public static const IMAGE_URL_NOT_FOUNDS:String = "IMAGE_URL_NOT_FOUNDS";
		
		private var imageURL:String ;
		
		private var myWidth:Number,
					myHeight:Number;
					
		private var loader:Loader;
		
		/**If this boolean is true , that means your image have to fit in the area box , but if not , your area box will fit in the ratio of image*/
		private var loadIn:Boolean ;
		
		private var myURLSaver:URLSaver ;
		
		private var myPreLoader:preLoader ;
		
		/**if you whant to resize image in each ratio , set your size on it*/
		public function ImageLoader(MyWidth:Number=0,MyHeight:Number=0,loadInThisArea:Boolean = false)
		{
			super();
			
			myURLSaver = new URLSaver(true);
			
			//this.alpha = 0.5 ;
			
			loadIn = loadInThisArea;
			
			myWidth = MyWidth ;
			myHeight = MyHeight ;
			
			trace('Create image width '+MyWidth+' width.');
			
			loader = new Loader();
		}
		
		override public function get height():Number
		{
			return myHeight ;
		}
		
		override public function get width():Number
		{
			return myWidth ;
		}
		
		public function load(url:String)
		{
			imageURL = url ;
			stageTest();
		}
		
		private function stageTest(e:Event=null):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE,stageTest);
			// TODO Auto Generated method stub
			if(this.stage == null)
			{
				this.addEventListener(Event.ADDED_TO_STAGE,stageTest);
			}
			else
			{
				this.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
				loadImage();
			}
		}
		
		protected function unLoad(event:Event):void
		{
			// TODO Auto-generated method stub
			myURLSaver.cansel();
			try
			{
				loader.close();
			}catch(e){};
		}
		
		private function loadImage():void
		{
			// TODO Auto Generated method stub
			if(imageURL == "")
			{
				this.dispatchEvent(new Event(IMAGE_URL_NOT_FOUNDS));
			}
			else
			{
				myURLSaver.addEventListener(URLSaverEvent.LOAD_COMPLETE,imageURLChagedToLocal);
				myURLSaver.addEventListener(URLSaverEvent.LOADING,imageLoadingStarted);
				myURLSaver.addEventListener(URLSaverEvent.NO_INTERNET,imageURLChagedToLocal);
				myURLSaver.load(imageURL);
			}
		}
		
		protected function imageLoadingStarted(event:Event):void
		{
			// TODO Auto-generated method stub
			if(myPreLoader == null)
			{
				myPreLoader = new preLoader() ;
				this.addChild(myPreLoader) ;
				myPreLoader.x = myWidth/2 ;
				myPreLoader.y = myHeight/2 ;
			}
		}
		
		protected function imageURLChagedToLocal(event:URLSaverEvent):void
		{
			myURLSaver.cansel();
			// TODO Auto-generated method stub
			imageURL = event.offlineTarget ;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,imageLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,urlProblem);
			loader.load(new URLRequest(imageURL));
			
			if(myPreLoader!=null)
			{
				this.removeChild(myPreLoader);
			}
		}
		
		protected function urlProblem(event:IOErrorEvent):void
		{
			// TODO Auto-generated method stub
			this.dispatchEvent(new Event(IMAGE_LOADED));
		}
		
		protected function imageLoaded(event:Event):void
		{
			// TODO Auto-generated method stub
			var image:Bitmap = loader.content as Bitmap ;
			image.smoothing = true ;
			this.addChild(image);
			
			trace("myWidth : "+myWidth+" , myHeight : "+myHeight+" > "+imageURL);
			
			if(myWidth!=0)
			{
				image.width = myWidth ;
			}
			if(myHeight !=0)
			{
				image.height = myHeight ;
			}
			
			trace("image current hieght : "+image.height);
			
			if(loadIn)
			{
				image.scaleX = image.scaleY = Math.min(image.scaleX,image.scaleY);
			}
			else
			{
				trace("Wrong proccess");
				image.scaleX = image.scaleY = Math.max(image.scaleX,image.scaleY);
			}
			
			trace("image final hieght : "+image.height);
			
			if(myWidth==0)
			{
				myWidth = image.width ;
			}
			if(myHeight == 0)
			{
				myHeight = image.height ;
			}
			
			image.x = (myWidth-image.width)/2 ;
			image.y = (myHeight-image.height)/2 ;
			
			
			this.dispatchEvent(new Event(IMAGE_LOADED));
		}
	}
}