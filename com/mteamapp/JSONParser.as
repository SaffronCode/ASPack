package com.mteamapp
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
			trace("Clone created by JSONParser");
			var itemType:Class = getDefinitionByName(getQualifiedClassName(fromObject)) as Class;
			var cloneObject:Object = new itemType();
			JSONParser.parse(JSONParser.stringify(fromObject),cloneObject) ;
			return cloneObject ;
		}
		
		private static function dateController(k,v):*
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
		 * Warning!! Vector.<int> will not catch by this class. you should change it with Array object.*/
		private static function parsParams(fromObject:Object,toObject:*):void
		{
			var arr:Array ;
			var j:int,l:uint ;
			
			//trace("From : "+JSON.stringify(fromObject));
			//trace("To : "+JSON.stringify(toObject));
			
			for(var i in fromObject)
			{
				var currentParam:Object = fromObject[i] ;
				if(toObject.hasOwnProperty(i) && !(toObject[i] is Function))
				{
					if(toObject[i] is Vector.<*>)
					{
						//Clear vector if it is full
						//trace("(model as Vector.<*>).length : "+(fillThisObject as Vector.<*>).length);
						while((toObject[i] as Vector.<*>).length)
						{
							(toObject[i] as Vector.<*>).pop();
						}
						
						
						//trace("This is vector parameter");
						if(currentParam is Array)
						{
							var vecClassName:String = getQualifiedClassName(toObject[i]).split("__AS3__.vec::Vector.<").join('').split('>').join('');
							//trace("Vector element type is : "+vecClassName);
							var vecItemClass:Class = (getDefinitionByName(vecClassName) as Class)
							var vec:Vector.<*> = (toObject[i]) ;
							arr = currentParam as Array;
							l = arr.length ;
							//trace("pars "+l+" items");
							for(j = 0 ; j<l ; j++)
							{
								var newObject:Object = new vecItemClass();
								vec.push(newObject);
								//trace("element is : "+newObject+' > '+JSON.stringify(newObject));
								parsParams(arr[j],newObject);
							}
						}
						else if(currentParam!=null)
						{
							trace("The parameter "+i+" cannot pars on Vector");
						}
					}
					else if(toObject[i] is Array)
					{
						//trace("Tis is Array");
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
							trace("The parameter "+i+" cannot pars on Array");
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
							trace("Date value is wrong : "+currentParam);
						}
					}
					else if(toObject[i] is String 
						|| toObject[i] is Number 
						|| toObject[i] is Date 
						|| toObject[i] is Boolean 
						|| toObject[i] == null
					)
					{
						//trace("Put toObject : "+currentParam);
						//trace("Put toObject i is : "+i);
						//trace("befor update : "+getQualifiedClassName(toObject[i]));
						try
						{
							toObject[i] = currentParam ;
						}
						catch(e)
						{
							trace("The parameter is readonly : "+getQualifiedClassName(toObject[i]));
						}
						//trace("after update : "+avmplus.getQualifiedClassName(toObject[i])+' > '+toObject[i])
					}
					else
					{
						//trace("Current parameter is complex parameter");
						if(currentParam!=null)
						{
							parsParams(currentParam,toObject[i]);
						}
						else
						{
							trace("But the value is null");
							toObject[i] = null ;
						}
					}
					//__AS3__.vec::Vector.<*>
					/*var className:String = getQualifiedClassName(toObject[i]);
					if(className
						trace("getQualifiedClassName : "+className);*/
					/*	}*/
				}
				
				/*else
				{
					trace("There is no "+i+" defined");	
				}*/
			}
			//trace("ToOjbect isDone :"+avmplus.getQualifiedClassName(toObject));
		}
		
		private static function reciver(k,v):*
		{
			if(v is String)
			{
				if(String(v).indexOf("\/Date(")!=-1)
				{
					var V:String = String(v) ;
					trace("Get date :"+V);
					trace("It is : "+ new Date(Number(V.substring(6,V.length-2))));
					return new Date(Number(V.substring(6,V.length-2))) ;
				}
				//Other date format is : 2015-10-27T10:46:56.9335483+03:30
				if(String(v).indexOf('-')!=-1 && String(v).indexOf('T')!=-1 && String(v).indexOf(':')!=-1)
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