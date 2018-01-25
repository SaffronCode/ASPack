package
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.PermissionEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.permissions.PermissionStatus;
	import flash.text.TextField;
	import flash.utils.ByteArray;

	public class FileManager
	{
		private static var onDone:Function;
		/**This will load local file instantly*/
		public static function loadFile(fileTarget:File,openAsync:Boolean=false,onLoaded:Function=null):ByteArray
		{
			if(!fileTarget.exists)
			{
				trace("File not found");
				return null ;
			}
			var fileBytes:ByteArray = new ByteArray();
			var fileStream:FileStream = new FileStream();
			
			
			controlFilePermission(function(){
				
				if(!openAsync)
				{
					fileStream.open(fileTarget,FileMode.READ);
					
					fileStream.readBytes(fileBytes);
					fileStream.close();
					fileBytes.position = 0 ;
				}
				else
				{
					onDone = onLoaded ;
					fileStream.addEventListener(Event.COMPLETE,fileLoaded);
					fileStream.openAsync(fileTarget,FileMode.READ);
				}
			});
			
			return fileBytes;
		}
		
		private static function fileLoaded(e:Event):void
		{
			var fileStream:FileStream = e.currentTarget as FileStream;
			
			var fileBytes:ByteArray = new ByteArray();
			fileStream.readBytes(fileBytes);
			fileStream.close();
			fileBytes.position = 0 ;
			
			if(onDone!=null && onDone.length>0)
				onDone(fileBytes);
		}
		
		/**Control the file permission*/
		public static function controlFilePermission(onPermissionGranted:Function):void
		{
			var _file:File = new File() ;
			if (File.permissionStatus != PermissionStatus.GRANTED)
			{
				_file.addEventListener(PermissionEvent.PERMISSION_STATUS,
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
					_file.requestPermission();
				} catch(e:Error)
				{
					// another request is in progress
				}
			}
			else
			{
				onPermissionGranted();
			}
		}
		
		/**Save thesebytes to selected location<br>
		 * This function will return the exeption string to*/
		public static function seveFile(fileTarget:File,bytes:ByteArray,openAsync:Boolean=false,onSaved:Function=null):String
		{
			//The async file saver had problem. it cannot save all binary datas by one request.
			openAsync = false ;
			onDone = onSaved ;
			if(onDone==null)
			{
				onDone = new Function();
			}
			
			controlFilePermission(function(){
				try
				{
					if(fileTarget.exists)
					{
						fileTarget.deleteFile();
					}
					trace("File length : "+bytes.length+' save to :'+fileTarget.name);
					var fileStream:FileStream = new FileStream();
					
					if(openAsync)
					{
						fileStream.addEventListener(Event.CLOSE,savingDone);
						fileStream.addEventListener(IOErrorEvent.IO_ERROR,cannotSaveThisFile);
						fileStream.openAsync(fileTarget,FileMode.WRITE);
					}
					else
					{
						fileStream.open(fileTarget,FileMode.WRITE);
					}
					bytes.position = 0 ;
					fileStream.writeBytes(bytes,0,bytes.bytesAvailable);
					fileStream.close();
					//fileStream.position = 0 ;
					//trace("fileStream : "+fileStream.bytesAvailable);
				}
				catch(e:Error)
				{
					return "Error:"+e.message ;
				}
				if(!openAsync)
				{
					onDone();
				}
			});
				return '' ;
		}
		
		protected static function savingDone(event:Event):void
		{
			trace("File Saved async");
			onDone();
		}
		
		private static function cannotSaveThisFile(e:IOErrorEvent):void
		{
			trace("Cant save the file : "+e);
		}
		
		/**Delete all files in this folder*/
		public static function deleteAllFiles(folder:File):void
		{
			
			if(!folder.exists)
			{
				trace("The folder : "+folder.url+" dosn't exist");
				return ;
			}
			var files:Array = folder.getDirectoryListing();
			var _file:File ; 
			
			controlFilePermission(startDeleting);
			
			function startDeleting():void
			{
				for(var i = 0 ; i<files.length ; i++)
				{
					_file = files[i] as File;
					if(_file.isDirectory)
					{
						deleteAllFiles(_file);
					}
					else
					{
						try
						{
							_file.deleteFile();
						}
						catch(e){};
					}
				}
				try
				{
					folder.deleteFile();
				}catch(e){};
			}
		}
		
		/**Copy the folder to destination*/
		public static function copyFolder(folderFile:File,destinationFolder:File,letsStartClean:Boolean=true,extentionExption:Array=null):void
		{
			if(extentionExption==null)
			{
				extentionExption = new Array();
			}
			if(letsStartClean && destinationFolder.isDirectory)
			{
				destinationFolder.deleteDirectory(true);
			}
			controlFilePermission(onPermissionGranted);
			
			function onPermissionGranted():void
			{
				if(folderFile.isDirectory)
				{
					destinationFolder = destinationFolder.resolvePath(folderFile.name) ;
					destinationFolder.createDirectory();
					trace("Folder created : "+destinationFolder.nativePath);
					var childFolders:Array = folderFile.getDirectoryListing() ;
					for(var i:int = 0 ; i<childFolders.length ; i++)
					{
						copyFolder(childFolders[i] as File,destinationFolder,false,extentionExption);
					}
				}
				else
				{
					var fileTarget:File = destinationFolder.resolvePath(folderFile.name) ;
					if(extentionExption.indexOf(fileTarget.extension)==-1)
					{
						folderFile.copyTo(fileTarget,true);
						trace("File copied : "+fileTarget.nativePath);
					}
					else
					{
						trace("!!File didn't copied because of exeption: "+fileTarget.nativePath);
					}
				}
			}
		}
	}
}