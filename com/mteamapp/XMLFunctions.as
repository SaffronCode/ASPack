package com.mteamapp
{
	public class XMLFunctions
	{
		public static function getValueOfKey(KeyName:String,mainXMLList:XMLList):XML
		{
			var l:int = mainXMLList.length() ;
			for(var i:int = 0 ; i<l ; i++)
			{
				if(mainXMLList[i].name()=="key" && String(mainXMLList[i]) == KeyName)
				{
					if(i+1<l)
					{
						return mainXMLList[i+1] ;
					}
					else 
					{
						return null ;
					}
				}
			}
			return null ;
		}
		
		public static function removeKeyValue(mainXML:XML, KeyName:String):void
		{
			var mainXMLList:XMLList = mainXML.children();
			var l:int = mainXMLList.length() ;
			for(var i:int = 0 ; i<l ; i++)
			{
				if(mainXMLList[i].name()=="key" && String(mainXMLList[i]) == KeyName)
				{
					if(i+1<l)
					{
						delete mainXMLList[i+1];
						delete mainXMLList[i];
						l = mainXMLList.length();
					}
				}
			}
		}
		
		public static function deleteChildren(manifestAdditions:XML):void
		{
			var children:XMLList = manifestAdditions.children();
			for(var i:int = 0 ; i<children.length() ; i++)
			{
				delete children[i] ;
			}
		}
	}
}