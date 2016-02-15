package
{
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class FileManager
	{
		/**This will load local file instantly*/
		public static function loadFile(fileTarget:File):ByteArray
		{
			if(!fileTarget.exists)
			{
				trace("File not found");
				return null ;
			}
			var fileBytes:ByteArray = new ByteArray();
			var fileStream:FileStream = new FileStream();
			
			fileStream.open(fileTarget,FileMode.READ);
			fileStream.readBytes(fileBytes);
			fileStream.close();
			fileBytes.position = 0 ;
			
			return fileBytes;
		}
		
		/**Save thesebytes to selected location<br>
		 * This function will return the exeption string to*/
		public static function seveFile(fileTarget:File,bytes:ByteArray,openAsync:Boolean=false):String
		{
			//The async file saver had problem. it cannot save all binary datas by one request.
			openAsync = false ;
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
				return e.message ;
			}
			return '' ;
		}
		
		private static function cannotSaveThisFile(e:IOErrorEvent):void
		{
			trace("Cant save the file : "+e);
		}
		
		/**Delete all files in this folder*/
		public static function deleteAllFiles(folder:File):void
		{
			// TODO Auto Generated method stub
			if(!folder.exists)
			{
				trace("The folder : "+folder.url+" dosn't exist");
				return ;
			}
			var files:Array = folder.getDirectoryListing();
			var file:File ; 
			for(var i = 0 ; i<files.length ; i++)
			{
				file = files[i] as File;
				if(file.isDirectory)
				{
					deleteAllFiles(file);
				}
				else
				{
					try
					{
						file.deleteFile();
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
}