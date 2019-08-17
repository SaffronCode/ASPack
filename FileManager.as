package
{
	import com.coltware.airxzip.ZipEntry;
	import com.coltware.airxzip.ZipFileReader;
	import com.coltware.airxzip.ZipFileWriter;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.PermissionEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.permissions.PermissionStatus;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
	import contents.alert.Alert;
	import flash.events.FileListEvent;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;

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
		public static function saveFile(fileTarget:File,bytes:ByteArray,openAsync:Boolean=false,onSaved:Function=null):String
		{
			return seveFile(fileTarget,bytes,openAsync,onSaved);
		}
		
		/**Save thesebytes to selected location<br>
		 * This function will return the exeption string to*/
		public static function seveFile(fileTarget:File,bytes:ByteArray,openAsync:Boolean=false,onSaved:Function=null):String
		{
			//The async file saver had problem. it cannot save all binary datas by one request.
			if(bytes==null)
			{
				throw "The required byte to save is empty! check it";
			}
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
		

	///////////////////////////////////////////////////

		public static var searchPattern:String ;

		/** function(file:File):void*/
		private static var callForEachFileFounded:Function ;

		/**function(files:Vector.<File>):void */
		private static var onSearchDone:Function ; 

		private static var 	searchQue:Vector.<File>;
		public static  var foundedQue:Vector.<File> ;

		private static var lastFileToSearch:File ;

		private static var searchFunctionTimerId:Number ; 

		public static function searchFor(target:File,pattern:String,searchDone:Function,onFoundedItem:Function=null):void
		{
			cancelSearch();

			lastFileToSearch = new File(target.nativePath);
			searchPattern = pattern.replace('.','\.').replace('*','.') ;
			callForEachFileFounded = onFoundedItem ;
			onSearchDone = searchDone;
			searchQue = new Vector.<File>();
			foundedQue = new Vector.<File>();

			if(!target.isDirectory)
			{
				trace("Target wasnt directory : "+target.nativePath);
				onSearchDone(foundedQue);
				return ;
			}

			startSearch();
		}

		public static function cancelSearch():void
		{
			clearTimeout(searchFunctionTimerId);
			if(lastFileToSearch!=null)
			{
				lastFileToSearch.removeEventListener(FileListEvent.DIRECTORY_LISTING,directoriesLoadedForSearch);
				lastFileToSearch.cancel();
				lastFileToSearch = null ;
			}
		}

			private static function startSearch():void
			{
				lastFileToSearch.addEventListener(FileListEvent.DIRECTORY_LISTING,directoriesLoadedForSearch);
				trace("lastFileToSearch > "+lastFileToSearch.nativePath);
				lastFileToSearch.getDirectoryListingAsync();
			}

			private static function directoriesLoadedForSearch(e:FileListEvent):void
			{
				trace("!!!!!");
				var currentFileSearch:File = lastFileToSearch ;
				lastFileToSearch.removeEventListener(FileListEvent.DIRECTORY_LISTING,directoriesLoadedForSearch);
				trace("Search on "+lastFileToSearch.nativePath);
				var list:Array = e.files ;
				var foundedFiles:Vector.<File> = new Vector.<File>();
				for(var i:int = 0 ; i<list.length ; i++)
				{
					var aFile:File = list[i] as File ;
					trace("aFile.name ? "+aFile.name+" << "+searchPattern);
					if(aFile.isDirectory)
					{
						if(aFile.name!='.git')
							searchQue.push(aFile);
					}
					else if(aFile.name.match(searchPattern)!=null)
					{
						trace(searchPattern+" founded on "+aFile.name);
						foundedQue.push(aFile);
						foundedFiles.push(aFile);
					}
				}
				if(callForEachFileFounded!=null && foundedFiles.length>0)
					callForEachFileFounded(foundedFiles);
				if(searchQue.length>0)
				{
					lastFileToSearch = searchQue.shift() ;
					lastFileToSearch.addEventListener(FileListEvent.DIRECTORY_LISTING,directoriesLoadedForSearch);
					lastFileToSearch.getDirectoryListingAsync();
				}
				else
				{
					trace("Seach done for "+(e.currentTarget as File).nativePath+" vs "+lastFileToSearch.nativePath);
					if(lastFileToSearch!=null && currentFileSearch == lastFileToSearch)
						onSearchDone(foundedQue);
				}
			}

	////////////////////////////////////////////////////
	public static function getRelatedTarget(ContainerFolder:File,ChildFolder:File):String
	{
		var adress1:String = ContainerFolder.nativePath ;
		var adress2:String = ChildFolder.nativePath ;
		var finalAdress:String = '';
		for(var i:int= 0 ; i<adress2.length ; i++)
		{
			if(adress1.charAt(i)!=adress2.charAt(i))
			{
				finalAdress = adress2.substring(i);
				break;
			}
		}
		return "."+finalAdress ;
	}
		
	////////////////////////////////////////////////////
		
		/**Pass the file types to make it open the file browser for you.<br/>
		 * You should set your extension like this ["*.xml", "*.jpg"]*/
		public static function browse(getSelectedFilePath:Function,fileTypes:Array=null,title:String = "Select your file"):void
		{
			var fil:File = new File();
			fil.addEventListener(Event.SELECT,folderSelected);
			var fileFilters:Array = (fileTypes==null)?null:[] ;
			var allFileModels:String = '' ;
			for(var i:int = 0 ;fileTypes!=null && i<fileTypes.length ; i++)
			{
				var fileModel:String = fileTypes[i] ;
				if(fileModel.indexOf('*.')!=0)
				{
					fileModel = '*.'+fileModel ;
				}
				allFileModels += fileModel+";";
				fileFilters.push(new FileFilter(fileTypes[i]+' fromat',fileModel));
			}
			if(fileTypes.length>0)
			{
				fileFilters.push(new FileFilter('All fromat',allFileModels));
			}
			fileFilters.reverse();
			fil.browseForOpen(title,fileFilters);
			function folderSelected(e:Event):void
			{
				trace("A file selected : "+fil.nativePath);
				if(fil.exists)
				{
					getSelectedFilePath(fil);
				}
			}
		}
		
		public static function browseForDirectory(getSelectedDirectory:Function,title:String="Select a directory"):void
		{
			var fil:File = new File();
			fil.addEventListener(Event.SELECT,aDirectorySelected);
			fil.browseForDirectory(title);
			
			function aDirectorySelected(e:Event):void
			{
				getSelectedDirectory(fil);
			}
		}
		
		public static function browseToSave(getSelectedFilePath:Function,title:String = "Where do you whant to save your file?",extension:String=null):void
		{
			var fil:File = new File();
			fil.addEventListener(Event.SELECT,aFileSelected);
			fil.browseForSave(title);
			
			function aFileSelected(e:Event):void
			{
				if(extension!=null)
				{
					var dotIndex:int ;
					var fileName:String = fil.name ;
					if( (dotIndex = fileName.lastIndexOf('.')) != -1)
					{
						fileName = fileName.substring(0,dotIndex) ;
					}
					fileName += (extension.indexOf('.')==0)?extension:'.'+extension ;
				}
				fil = fil.parent.resolvePath(fileName);
				getSelectedFilePath(fil);
			}
		}
		
		/////////////////////////Zip utilities
		
		public static function Zip(folder:File,zipTarget:File):void
		{
			var zipW:ZipFileWriter = new ZipFileWriter(ZipFileWriter.HOST_UNIX);
			zipW.open(zipTarget);
			writeZipForFolder(folder);
			
			function writeZipForFolder(currentFolder:File):void
			{
				var FileList:Array = currentFolder.getDirectoryListing() ;
				for(var i:int = 0 ; i<FileList.length ; i++)
				{
					var aFile:File = FileList[i] as File ;
					if(aFile.isDirectory)
					{
						writeZipForFolder(aFile);
					}
					else
					{
						zipW.addFile(aFile,aFile.nativePath.substr(folder.nativePath.length+1));
					}
				}
			}
			
			zipW.close();
		}
		
		/**UnZip file*/
		public static function unZip(zipFile:File,target:File):void
		{
			var zipR:ZipFileReader = new ZipFileReader();
			zipR.open(zipFile);
			
			if(target.exists && target.isDirectory)
				target.deleteDirectory(true);
			target.createDirectory();
			
			var list:Array = zipR.getEntries();
			
			for each(var entry:ZipEntry in list){
				//unZipFile(entry,target,zipR);
				var toWhere:File ;
				toWhere = target.resolvePath(entry.getFilename());
				if(entry.isDirectory()){
					toWhere.createDirectory();
				}
				else{
					var bytes:ByteArray = zipR.unzip(entry);
					//trace("Save to : "+toWhere.nativePath);
					FileManager.saveFile(toWhere,bytes);
				}
			}
			
			zipR.close();
		}
	}
}