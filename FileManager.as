package
{
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
		public static function seveFile(fileTarget:File,bytes:ByteArray):String
		{
			try
			{
				if(fileTarget.exists)
				{
					fileTarget.deleteFile();
				}
				trace("File length : "+bytes.length+' save to :'+fileTarget.name);
				var fileStream:FileStream = new FileStream();
				fileStream.open(fileTarget,FileMode.WRITE);
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
	}
}