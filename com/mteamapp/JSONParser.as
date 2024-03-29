﻿package com.mteamapp
{
	
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	

	/**All vectors, Arrays and Objects had to be initialized on the main class and all values had to be in public type.*/
	public class JSONParser
	{
		
		private static const mydateIndex:String = "myDateMESDateMineMineMESepehrMineDateBegin(";
		private static const mydateEnd:String = "myDateMESDateMineMineMESepehrMineDateEnd)";
		
		/**This stringiy will make server standard date on json*/
		public static function stringify(object:Object):String
		{
			var json:String = JSON.stringify(object,dateController);
			json = json.split(mydateIndex).join("\\/Date(").split(mydateEnd).join(")\\/");
			return json ;
		}
		
		public static function parse(text:String,catcherObject:*):*
		{
			var fromObject:Object = {};
			fromObject.data = JSON.parse(text,reciver) ;
			
			var toObject:Object = {} ;
			toObject.data = catcherObject ;
			
			parsParams(fromObject,toObject);
			return catcherObject;
		}
		
		/**You can make a copy from simple objecs*/
		public static function makeCopy(fromObject:*):*
		{
			SaffronLogger.log("Clone created by JSONParser");
			var itemType:Class = getDefinitionByName(getQualifiedClassName(fromObject)) as Class;
			var cloneObject:Object = new itemType();
			JSONParser.parse(JSONParser.stringify(fromObject),cloneObject) ;
			return cloneObject ;
		}
		
		private static function dateController(k:*,v:*):*
		{
			/**Sat Jun 13 16:45:04 GMT+0430 2015*/
			if(v is String && v!= null)
			{
				var V:String = v ;
				var vs:Array = V.split(' ');
				if(vs.length == 6)
				{
					if(String(vs[4]).indexOf('+')!=-1)
					{
						if(!isNaN(Number(vs[2])) && !isNaN(Number(vs[5])))
						{
							if(String(vs[3]).split(':').length==3)
							{
								//debug value;
									//return "2014/01/01";
									//return mydateIndex+new Date(v).time+mydateEnd;
								//Required format is :    2015-10-27T10:46:56.9335483+03:30
								return ServerDate.dateToServerDate2(new Date(v));;
							}
						}
					}
				}
			}
			return v ;
		}
		
		
		public var error:Boolean = true  ;
		
		public var modelType:String = '';
		
		public var exceptionType:int ;
		
		
		/**sample value
		public var numbers:Array = [];*/
		
		/**This is dynamic class*/
		public var model:* ;
		
		private var parsed:Object;

		
		/**This function can only use by RestGullJSON parser.<br>
		 * Warning!! Vector.[int] will not catch by this class. you should change it with Array object.
		 * <br><br>
		 * Warning2 : set a default variable for date instanses to make them works correctly. (dat:Date = <strong>new Date()</strong>)*/
		public static function parsParams(fromObject:Object,toObject:*):void
		{
			var arr:* ; // is Array or Vector
			var j:int,l:uint ;
			
			//SaffronLogger.log("From : "+JSON.stringify(fromObject));
			//SaffronLogger.log("To : "+JSON.stringify(toObject));
			
			for(var i:* in fromObject)
			{
				var currentParam:Object = fromObject[i] ;
				if(toObject.hasOwnProperty(i) && !(toObject[i] is Function))
				{
					if(toObject[i] is Vector.<*>)
					{
						//Clear vector if it is full
						//SaffronLogger.log("(model as Vector.<*>).length : "+(fillThisObject as Vector.<*>).length);
						while((toObject[i] as Vector.<*>).length)
						{
							(toObject[i] as Vector.<*>).pop();
						}
						
						
						//SaffronLogger.log("This is vector parameter");
						if(currentParam is Array || currentParam is Vector.<*> )
						{
							var vecClassName:String = getQualifiedClassName(toObject[i]).split("__AS3__.vec::Vector.<").join('').split('>').join('');
							//SaffronLogger.log("Vector element type is : "+vecClassName);
							var vecItemClass:Class = (getDefinitionByName(vecClassName) as Class)
							var vec:Vector.<*> = (toObject[i]) ;
							arr = currentParam;
							l = arr.length ;
							//SaffronLogger.log("pars "+l+" items");
							for(j = 0 ; j<l ; j++)
							{
								var newObject:Object = new vecItemClass();
								vec.push(newObject);
								//SaffronLogger.log("element is : "+newObject+' > '+JSON.stringify(newObject));
								parsParams(arr[j],newObject);
							}
						}
						else if(currentParam!=null)
						{
							SaffronLogger.log("The parameter "+i+" cannot pars on Vector");
						}
					}
					else if(toObject[i] is Array)
					{
						//SaffronLogger.log("Tis is Array");
						if(currentParam is Array)
						{
							arr = currentParam as Array;
							l = arr.length ;
							for(j = 0 ; j<l ; j++)
							{
								toObject[i][j] = arr[j];
							}
						}
						else if(currentParam!=null)
						{
							SaffronLogger.log("The parameter "+i+" cannot pars on Array");
						}
					}
					else if(toObject[i] is Date && toObject[i]!=null)
					{
						try
						{
							(toObject[i] as Date).time = (currentParam as Date).time ;
						}
						catch(e)
						{
							SaffronLogger.log("Date value is wrong : "+currentParam);
						}
					}
					else if(toObject[i] is String )
					{
						//SaffronLogger.log("Convert "+JSON.stringify(currentParam)+" to "+i);
						try
						{
							if(currentParam is String)
							{
								//SaffronLogger.log("** Its string");
								toObject[i] = currentParam ;
							}
							else
							{
								//SaffronLogger.log("** Its Object");
								toObject[i] = JSON.stringify(currentParam);
								//SaffronLogger.log("*** i : "+i);
								//SaffronLogger.log("*** It saved as : "+toObject[i]);
							}
						}
						catch(e)
						{
							SaffronLogger.log("The parameter is readonly : "+getQualifiedClassName(toObject[i]));
						}
					}
					else if(toObject[i] is Number 
						|| toObject[i] is Date 
						|| toObject[i] is Boolean 
						|| toObject[i] == null
					)
					{
						//SaffronLogger.log("Put toObject : "+currentParam);
						//SaffronLogger.log("Put toObject i is : "+i);
						//SaffronLogger.log("befor update : "+getQualifiedClassName(toObject[i]));
						try
						{
							toObject[i] = currentParam ;
						}
						catch(e)
						{
							SaffronLogger.log("The parameter is readonly : "+getQualifiedClassName(toObject[i]));
						}
						//SaffronLogger.log("after update : "+avmplus.getQualifiedClassName(toObject[i])+' > '+toObject[i])
					}
					else
					{
						//SaffronLogger.log("Current parameter is complex parameter");
						if(currentParam!=null)
						{
							parsParams(currentParam,toObject[i]);
						}
						else
						{
							SaffronLogger.log("But the value is null");
							toObject[i] = null ;
						}
					}
					//__AS3__.vec::Vector.<*>
					/*var className:String = getQualifiedClassName(toObject[i]);
					if(className
						SaffronLogger.log("getQualifiedClassName : "+className);*/
					/*	}*/
				}
				
				/*else
				{
					SaffronLogger.log("There is no "+i+" defined");	
				}*/
			}
			//SaffronLogger.log("ToOjbect isDone :"+avmplus.getQualifiedClassName(toObject));
		}
		
		private static function reciver(k:*,v:*):*
		{
			if(v is String)
			{
				if(String(v).indexOf("\/Date(")==0)
				{
					var V:String = String(v) ;
				//	SaffronLogger.log("Get date :"+V);
					//SaffronLogger.log("It is : "+ new Date(Number(V.substring(6,V.length-2))));
					var dateNumberPart:String = V.substring(6, V.length - 2) ;
					var splitedDate:Array = dateNumberPart.split('+') ;
					var dateNumber:Number = Number(splitedDate[0]);
					var zonePart:uint = 0 ;
					var calculatedDate:Date = new Date(dateNumber);
					if (splitedDate.length > 1)
					{
						zonePart = uint(dateNumberPart.split('+')[1]) ;
						//0:
							//Dont change
						//1:
						calculatedDate.minutes = calculatedDate.minutes - uint(zonePart) ;
						//2:
						calculatedDate.minutes = calculatedDate.minutes + uint(zonePart) ;
					}
					return calculatedDate ;
				}
				//Other date format is : 2015-10-27T10:46:56.9335483+03:30
				if(String(v).indexOf('-')!=-1 && String(v).indexOf('T')!=-1 && String(v).indexOf(':')!=-1 && String(v).length>18 && String(v).length<35)
				{
					var tryTheDate:Date = ServerDate.serverDateToDate2(v);
					if(tryTheDate!=null)
					{
						return tryTheDate;
					}
				}
			}

			return v ;
		}
	}
}