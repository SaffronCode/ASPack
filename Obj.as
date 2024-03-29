﻿// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************
/***Version log
 * 1.2 findAllClass added on 93-11-20
 * 
 * 
 */
package 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.text.TextFormat;
	import appManager.mains.App;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import contents.alert.Alert;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import contents.LinkData;
	import appManager.event.AppEventContent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;

	/**detect objects on display object with names*/
	public class Obj
	{
		/**cash all onAddEvents on this Object*/
		private static var onAddedHelper:Object = new Object();
		
		
		
		public static function button_disable(item:Sprite):void
		{
			item.mouseChildren = item.mouseEnabled = false ;
			item.alpha = 0.7 ;
		}

		public static function controlZIndex(items:Vector.<MovieClip>):void
		{
			var eventListner:DisplayObjectContainer = (items!=null && items.length>0)?items[0]:null;
			if(eventListner==null)return;//Do nothing

			Obj.addEventListener(eventListner,Event.ENTER_FRAME,switchDepths);
			function switchDepths():void
			{
				items.sort(sortMovieClipsIndex);
				for(var i:int = 0 ; i<items.length ; i++)
				{
					items[i].parent.addChild(items[i]);
				}
			}
		}

		private static function sortMovieClipsIndex(item1:MovieClip,item2:MovieClip):int
		{
			if(item1.y>item2.y)
				return 1;
			if(item1.y<item2.y)
				return -1;
			return 0 ;
		}
		
		public static function button_enable(item:Sprite):void
		{
			item.mouseChildren = item.mouseEnabled = true ;
			item.alpha = 1.0 ;
		}
		
		public static function get(name:String,on:DisplayObjectContainer,clas:Class=null):*
		{
			if(on==null)
			{
				return null ;
			}
			var targ:* = on.getChildByName(name);
			if(clas!=null)
			{
				return (targ as clas);
			}
			
			if(targ is MovieClip)
			{
				return MovieClip(targ);
			}
			if(targ is TextField)
			{
				return TextField(targ);
			}
			return targ
		}

		public static function stackTrace():String
		{
			try
			{
				throw "StackTrace";
			}
			catch(e:Error)
			{
				return e.getStackTrace();
			}
			return '';
		}

		/**
		 * This function will addEventListner to your eventDispatcher. but this time, 
		 * 1- you don't need to defind input as Event.
		 * 2- The listner will remove if the DisplayObject removed from the state
		 * @param target 
		 * @param eventType 
		 * @param onHappened with optional Event input
		 * @param stopImmediatePropagation 
		 * @param preventDefault 
		 * @return The lisnterRemover function will return. call it to kill eventListner
		 */
		public static function addEventListener(target:EventDispatcher,eventType:String,onHappened:Function,stopImmediatePropagation:Boolean=false,preventDefault:Boolean=false,removeOnThisObjectRemovedFromState:DisplayObject=null):Function
		{
			target.addEventListener(eventType,onDone);
			if(removeOnThisObjectRemovedFromState!=null)
			{
				removeOnThisObjectRemovedFromState.addEventListener(Event.REMOVED_FROM_STAGE,removeThisListner);
			}
			else if(target is DisplayObject)
			{
				target.addEventListener(Event.REMOVED_FROM_STAGE,removeThisListner);
			}

			function onDone(e:Event):void
			{
				if(stopImmediatePropagation)
					e.stopImmediatePropagation();
				if(preventDefault)
					e.preventDefault();

				if(onHappened.length>0)
					onHappened(e);
				else
					onHappened();
			}

			function removeThisListner(e:*=null):void
			{
				target.removeEventListener(Event.REMOVED_FROM_STAGE,removeThisListner);
				target.removeEventListener(eventType,onDone);
			}

			return removeThisListner ;
		}

		public static function removeAllChildBut(target:DisplayObjectContainer,elements:Array):void
		{
			var masAcceptableItemsOnTarget:uint = 0 ;
			while(target.numChildren>masAcceptableItemsOnTarget)
			{
				if(elements.indexOf(target.getChildAt(masAcceptableItemsOnTarget))==-1)
				{
					target.removeChildAt(masAcceptableItemsOnTarget);
				}
				else
				{
					masAcceptableItemsOnTarget++;
				}
			}
		}
		
		/**remove this object from its parents*/
		public static function remove(target:DisplayObject):void
		{
			if(target==null)
			{
				return ;
			}
			if(target is MovieClip)
			{
				try
				{
					(target as MovieClip).stopAllMovieClips();
				}catch(e){};
			}
			if(target!= null && target.parent!=null)
			{
				DisplayObjectContainer(target.parent).removeChild(target);
			}
		}

		public static function onRemoved(target:DisplayObject,trigger:Function):void
		{	
			target.addEventListener(Event.REMOVED_FROM_STAGE,unLoadTrigger);
			function unLoadTrigger(e:Event):void
			{
				if(trigger.length==0)
					trigger();
				else
					trigger(e);
				target.removeEventListener(Event.REMOVED_FROM_STAGE,unLoadTrigger);
			}
		}

		public static function onLongTouch(target:*,onLongTouch:Function):void
		{
			if(target!=null && target is EventDispatcher)
			{
				if(target.stage==null)
				{
					target.addEventListener(Event.ADDED_TO_STAGE,setUpOnce);
				}
				else
				{
					setUpOnce();
				}

				function setUpOnce(e:*=null):void
				{
					var timeOutId:uint ;
					var preventClick:Boolean = false ;
					var activateLongTouch:Boolean = false ;

					target.addEventListener(MouseEvent.MOUSE_DOWN ,onTouched);
					target.addEventListener(MouseEvent.CLICK,onClicked,false,100000000);
					target.stage.addEventListener(MouseEvent.MOUSE_UP,clickIsOkNow);

					function clickIsOkNow(e:MouseEvent):void
					{
						clearTimeout(timeOutId);
						setTimeout(letUserClick,0);
						//trace("preventClick : "+preventClick);
					}

					function letUserClick():void
					{
						preventClick = false ;
					}

					function onTouched(e:MouseEvent):void
					{
						clearTimeout(timeOutId);
						timeOutId = setTimeout(nowTouchCall,700);

						function nowTouchCall():void
						{
							if(target.stage!=null && isAccesibleByMouse(target as DisplayObject))
							{
								preventClick = true ;
								//trace("preventClick : "+preventClick);
								if(onLongTouch.length>0)
								{
									onLongTouch(e);
								}
								else
								{
									onLongTouch();
								}
							}
						}
					}

					

					function onClicked(e:MouseEvent):void
					{
						//trace("Prevent click "+preventClick);
						if(preventClick)
							e.stopImmediatePropagation();
					}
				}
			}
		}

		/**
		 * This function will kill interval when the displayedObject removd from the state. and it will not call closur function when the appliation is not active
		 * @param displayObjctOnStage 
		 * @param closur 
		 * @param delay 
		 * @param ...param 
		 * @return 
		 */
		public static function setIntervalOnDisplayObject(displayObjctOnStage:DisplayObject,closur:Function,delay:Number,...param):uint
		{
			var intervalID:uint = setInterval(onClosur,delay);
			if(displayObjctOnStage!=null)
			{
				addEventListener(displayObjctOnStage,Event.REMOVED_FROM_STAGE,function():void{
					trace("Obj. clear interval");
					clearInterval(intervalID);
				});
			}
			function onClosur():void
			{
				trace("Obj. closurHappend");
				if(DevicePrefrence.isApplicationActive)
				{
					trace("Obj. app is active to call closur");
					closur.apply(displayObjctOnStage,param);
				}
			}
			return intervalID ;
		}
		
		public static function setTimeoutOnDisplayObject(displayObjctOnStage:DisplayObject,closur:Function,delay:Number,...param):uint
		{
			var timeoutId:uint = setTimeout(onClosur,delay);
			addEventListener(displayObjctOnStage,Event.REMOVED_FROM_STAGE,function():void{
				trace("Obj. clear interval");
				clearTimeout(timeoutId);
			});
			function onClosur():void
			{
				trace("Obj. closurHappend");
				closur.apply(displayObjctOnStage,param);
			}
			return timeoutId ;
		}

		/**Set a link oppener button */
		public static function setLinkButton(target:MovieClip,linkdata:LinkData):void
		{
			function openLink():void
			{
				target.dispatchEvent(new AppEventContent(linkdata));
			}

			setButton(target,openLink);
		}

		/**Set a url oppener button */
		public static function setURLButton(target:MovieClip,_url:String):void
		{
			function openLink():void
			{
				navigateToURL(new URLRequest(_url));
			}

			setButton(target,openLink);
		}
		
		/**generate a button from a movieClip*/
		public static function setButton(target:*,onClick:Function,...params):void
		{
			if(target!=null && target is EventDispatcher)
			{
				if(target is MovieClip)
				{
					target.mouseChildren = false ;
					target.buttonMode = true ;
				}
				target.removeEventListener(MouseEvent.CLICK,onClick2);
				target.addEventListener(MouseEvent.CLICK,onClick2);

				function onClick2(e:MouseEvent):void
				{
					App.showShineEffect(target as Sprite);
					Alert.vibratePuls();

					//setTimeout(function():void{
						if(onClick.length>0)
						{
							if(params.length>0)
							{
								onClick.apply(null,params);
							}
							else
							{
								onClick(e);
							}
						}
						else
							onClick();
					//},0);
				}
			}
		}

		/**generate a button from a movieClip*/
		public static function setButtonNoShineEffect(target:*,onClick:Function,...params):void
		{
			if(target!=null && target is EventDispatcher)
			{
				if(target is MovieClip)
				{
					target.mouseChildren = false ;
					target.buttonMode = true ;
				}
				target.removeEventListener(MouseEvent.CLICK,onClick2);
				target.addEventListener(MouseEvent.CLICK,onClick2);

				function onClick2(e:MouseEvent):void
				{
					Alert.vibratePuls();

					//setTimeout(function():void{
						if(onClick.length>0)
						{
							if(params.length>0)
							{
								onClick.apply(null,params);
							}
							else
							{
								onClick(e);
							}
						}
						else
							onClick();
					//},0);
				}
			}
		}
		
		
		/**return true if the Target is still in the stage*/
		public static function imInStage(targ:DisplayObject):Boolean
		{
			if(targ.parent==null)
			{
				return false;
			}else if(targ.parent is Stage)
			{
				return true ;
			}
			else
			{
				return imInStage(targ.parent)
			}
		}
		
		/**move this object to top of all other objects*/
		public static function moveToFront(target:MovieClip):void
		{
			var par:MovieClip = (target.parent as MovieClip);
			par.swapChildrenAt(par.getChildIndex(target),par.numChildren-1);
		}
		
		
		
		
		
		
		
		
		/**call back the onsomthingAdded function if something is added to this target*/
		public static function onAddSomething(target:MovieClip,onSomthingAdded:Function):void
		{
			onAddedHelper[target] = onSomthingAdded ;
			target.addEventListener(Event.ADDED,someThingAdded);
			target.addEventListener(Event.REMOVED_FROM_STAGE,unLoaded);
		}
		
		
		/**some thing is added*/
		private static function someThingAdded(e:Event):void
		{
			var target:MovieClip = MovieClip(e.currentTarget);
			if(onAddedHelper[target] is Function)
			{
				thisIsAdded(target,onAddedHelper[target]);
			}
		}
		
		/**this object is added to stage*/
		private static function thisIsAdded(target:MovieClip,onAddFunc:Function):void
		{
			onAddFunc(target);
			for(var i:int = 0 ; i<target.numChildren ; i++)
			{
				var targ:* = target.getChildAt(i);
				if(targ is MovieClip)
				{
					thisIsAdded(targ,onAddFunc);
				}
			}
		}
		
		/**unload the */
		private static function unLoaded(e:Event):void
		{
			var target:MovieClip = MovieClip(e.currentTarget) ;
			
			onAddedHelper[target] = null ;
			
			target.addEventListener(Event.ADDED,someThingAdded);
			target.addEventListener(Event.REMOVED_FROM_STAGE,unLoaded);
		}
		
//////////////////////////////////////////////////////////////
		
		/**this function will return arrray of founded object on displayObject<br>
		 * This function will returns at least one element that could be the null!*/
		public static function getAllChilds(name:String,onThe:DisplayObjectContainer,returnOnlyFirstFounded:Boolean=false):Array
		{
			var founded:Array = [] ;
			var i:int ;

			if(onThe == null)
			{
				throw "whattt???"
			}
			
			//trace("Search for childs : "+onThe.numChildren);
			var myChildToSearch:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			myChildToSearch.push(onThe);
			var targ:DisplayObject ;
			for(i=0;i<myChildToSearch.length ; i++)
			{
				targ = myChildToSearch[i] ;
				if(i>0 && targ.name == name)
				{
					founded.push(targ);
					if(returnOnlyFirstFounded)
					{
						return founded ;
					}
				}
				if(targ is DisplayObjectContainer)
				{
					var l:uint = (targ as DisplayObjectContainer).numChildren ;
					for( var j:int = 0 ; j < l ; j++)
					{
						myChildToSearch.push((targ as DisplayObjectContainer).getChildAt(j));
					}
				}
			}
			
			if(founded.length==0)
			{
				founded.push(null);
			}
			
			return founded ;
		}
		
		
	/////////////////////////////////////////////////////////////////
		/**set the target position to this point*/
		public static function setPosition(target:DisplayObject,newPose:Point):void
		{
			target.x = newPose.x;
			target.y = newPose.y;
		}
		
		/**Returns the global scale of this display object from the stage in its all parents*/
		public static function getScale(targ:DisplayObject,returnScaleX:Boolean=true):Number
		{
			//return targ.scaleX;
			var currentScale:Number = returnScaleX?targ.scaleX:targ.scaleY ;
			while(targ.parent != null)
			{
				targ = targ.parent ;
				currentScale *= returnScaleX?targ.scaleX:targ.scaleY ;
			}
			return currentScale ;
		}
		
		/**Check if this display object is visible at all of its parents*/
		public static function getVisible(targ:DisplayObject):Boolean
		{
			//return targ.visible;
			while(targ != null)
			{
				if(!targ.visible)
				{
					return false;
				}
				targ = targ.parent ;
			}
			return true ;
		}
		
		/**Check if this display object is on the stage area or not*/
		public static function getImOnStage(targ:DisplayObject):Boolean
		{
			return true;
		}
		
		
	///////////////////////////new functions ↓
		/**Fide all MovieClips on child and grand childs of this container*/
		public static function getChildIn(myName:String,container:DisplayObjectContainer):Array
		{
			var founded:Array = [] ;
			for(var i:int = 0 ; i<container.numChildren ; i++)
			{
				var targ:* = container.getChildAt(i) ;
				if(targ is MovieClip)
				{
					var targ2:MovieClip = targ as MovieClip ;
					if(targ2.name == myName)
					{
						founded.push(targ2);
					}
					founded = founded.concat(getChildIn(myName,targ2));
				}
			}
			return founded ;
		}
		
		/**Fide all MovieClips on child and grand childs of this container*/
		public static function findAllClass(requestedClass:Class,container:DisplayObjectContainer):Array
		{
			var founded:Array = [] ;
			for(var i:int = 0 ; i<container.numChildren ; i++)
			{
				var targ:* = container.getChildAt(i) ;
				if(targ is requestedClass)
				{
					founded.push(targ);
				}
				if(targ is DisplayObjectContainer)
				{
					var targ2:DisplayObjectContainer = targ as DisplayObjectContainer ;
					founded = founded.concat(findAllClass(requestedClass,targ2));
				}
			}
			return founded ;
		}


		/**Find all MovieClips on child and grand childs with name contanes this*/
		public static function getSameTo(sameNameTo:String,container:DisplayObjectContainer):*
		{
			for(var i:int = 0 ; i<container.numChildren ; i++)
			{
				var targ:* = container.getChildAt(i) ;
				if(String(targ.name).indexOf(sameNameTo)!=-1)
				{
					return targ;
				}
				if(targ is DisplayObjectContainer)
				{
					var targ2:DisplayObjectContainer = targ as DisplayObjectContainer ;
					var findedOne:* = getSameTo(sameNameTo,targ2);
					if(findedOne!=null)
						return findedOne ;
				}
			}
			return null ;
		}
		
		
		/**Find requested class in this container.*/
		public static function findThisClass(requestedClass:Class,container:DisplayObjectContainer,searchOnGrandChilds:Boolean=false):*
		{
			for(var i:int = 0 ; i<container.numChildren ; i++)
			{
				var targ:* = container.getChildAt(i);
				//trace("targ is : "+targ,container);
				if(targ is requestedClass)
				{
					return targ ;
				}
				else if(targ is MovieClip && searchOnGrandChilds)
				{
					var checker:* =  findThisClass(requestedClass,targ as DisplayObjectContainer,searchOnGrandChilds);
					if(checker!=null)
					{
						//item founds 
						return checker ;
					}
				}
			}
			return null ;
		}
		
		
	//////////////////////////////////////////Class functions ↓
		
		/**Return class with this name*/
		public static function generateClass(className:String):Class
		{
			try
			{
				return (getDefinitionByName(className) as Class);
			}
			catch(e){}
			return null ;
		}
		
		public static function getObjectClass(object:*):Class
		{
			return generateClass(getQualifiedClassName(object));
		}
	
	////////////////////////////////////////////////
		public static function createReadAbleObject(obj:*):Object
		{
			var ba:ByteArray = new ByteArray();
			ba.writeObject(obj);
			ba.position = 0 ;
			var newObj:Object = ba.readObject();
			
			for(var i:* in newObj)
			{
				if(getQualifiedClassName(newObj[i]).indexOf("__AS3__.vec::Vector")!=-1 && newObj[i].hasOwnProperty('length'))
				{
					var arr:Array = [];
					for(var j:uint = 0 ; j<(newObj[i]).length ; j++)
					{
						arr.push(newObj[i][j]);
					}
					newObj[i] = arr ;
				}
			}
			
			return newObj ;
		}
		
	//////////////////////////////////////////////////////
		public static function playAll(target:MovieClip):void
		{
			target.play();
			for(var i:int = 0 ; i<target.numChildren ; i++)
			{
				if(target.getChildAt(i) is MovieClip)
				{
					playAll(target.getChildAt(i) as MovieClip);
				}
			}
		}
		
	///////////////////////////////////////////////////////
		/**Returns true if user can click the center of this object*/
		public static function isAccesibleByMouse(targ:DisplayObject,ignoreAllTextsOnTheStage:Boolean=true,conrollPosition:Point=null):Boolean
		{
			/**Parent list for current target*/
			var targParents:Vector.<DisplayObjectContainer>;
			/**It will contain targ itself*/
			var itemsOnItsArea:Array;
			var i:int,j:int,k:int;
			
			if(targ.stage == null)
			{
				//trace("The item is not on stage");
				return false ;
			}
			
			//trace("targ.parent : "+targ.parent);
			//trace("targ.parent.parent : "+targ.parent.parent);
			
			targParents = new Vector.<DisplayObjectContainer>();
			var targParent:DisplayObjectContainer = targ.parent ;
			while(targParent!=targ.stage)
			{
				targParents.push(targParent);
				targParent = targParent.parent ;
			}
			
			
			targParents.push(targ.stage);
			//targParents.reverse() ;
			//trace("targParents : "+targParents);
			
			//return true ;
			
			
			var targArea:Rectangle;
			targArea = targ.getBounds(targ.stage);
			var targCenterPoint:Point;
			if(conrollPosition==null)
			{
				targCenterPoint = new Point(targArea.x+targArea.width/2,targArea.y+targArea.height/2);
			}
			else
			{
				targCenterPoint = conrollPosition ;
			}
			itemsOnItsArea = targ.stage.getObjectsUnderPoint(targCenterPoint);
			//trace("** total items under poit : "+itemsOnItsArea.length+' < '+targCenterPoint);
			for(i = 0 ; i<itemsOnItsArea.length ; i++)
			{
				var item:* = itemsOnItsArea[i] ;
				//trace("Start with this targ : "+Obj.displayObjectInfo(item));
				if(targ is DisplayObjectContainer && (targ as DisplayObjectContainer).contains(item))
				{
					//trace("The targ is container of "+item);
					continue ;
				}
				if(item.hasOwnProperty('parent'))
				{
					for(j = 0 ; j<targParents.length ; j++)
					{
						if(targParents[j].contains(item) && (targParents[j]!=item))
						{
							//trace(targParents[j]+" contains the "+item);
							//trace("targParents[j] is "+displayObjectInfo(targParents[j]));
							//trace("item is "+displayObjectInfo(item));
							var targLastChild:DisplayObject ;
							if(j == 0)
							{
								targLastChild = targ ;
							}
							else
							{
								targLastChild = targParents[j-1] ;
							}
							//trace("targLastChild is : "+targLastChild);
							var canClick:Boolean = true ;
							var itemParent:DisplayObjectContainer = item.parent ;
							//trace("itemParent : "+itemParent);
							
							canClick = canClick && itemParent.mouseChildren ;
							
							while(itemParent!=targParents[j])
							{
								item = itemParent;
								//trace("1. itemParent : "+itemParent);
								itemParent = item.parent ;
								//trace("2. itemParent : "+itemParent);
								if(itemParent!=null)
								{
									canClick = canClick && itemParent.mouseChildren ;
								}
								else
								{
									//trace("itemParent is null now!!");
									return true ;
								}
							}
							if(item.hasOwnProperty("mouseEnabled"))
							{
								canClick = item.mouseEnabled ;
							}
							if(item == targLastChild)
							{
								//trace("Dont controll itself");
								break ;
							}
							
							if(!canClick)
							{
								//trace("The item cannot click");
								break;
							}
							
							if((ignoreAllTextsOnTheStage || targ is TextField) && item is TextField && item.parent == targ.stage)
							{
								//trace("It should be the stage text");
								break;
							}
							
							if(String(item) == "[object StageWebViewImpl]")
							{
								//trace("It is the stage themplete");
								break;
							}
							
							//trace("item.parent == targ.stage : "+(item.parent == targ.stage)+" > "+item.parent);
							//trace("targ is TextField : "+(targ is TextField)+' > '+targ);
							
							//trace("targLastChild : "+targLastChild+' > '+(targLastChild == targ));
							//trace("itemParent : "+itemParent);
							//trace("itemParent contains targ??? "+targ.parent.getChildIndex(targ)+' > '+targ.parent);
							//trace("founded target is : "+item+' item.name : '+item.name+' area : '+item.getBounds(targ.stage));
							//I found the shared parrent
							var targInsex:int = itemParent.getChildIndex(targLastChild);
							//trace("targ last child index is : "+targInsex);
							var itemIndex:int = itemParent.getChildIndex(item);
							//trace("item last child index is : "+itemIndex);
							if(itemIndex>targInsex)
							{
								//trace("Hitted!!  itemIndex:"+itemIndex+' targInsex:'+targInsex+' >>> '+item);
								//trace("The item is : "+displayObjectInfo(item));
								return false ;
							}
							//trace("Nothing founded");
							break;
						}
					}
				}
			}
			
			return true ;
		}
		
		/**Move the item to the front of others*/
		public static function moveFront(item:DisplayObject):void
		{
			
			if(item.parent!=null)
			{
				item.parent.addChild(item);
			}
		}
		
		public static function stopAll(target:MovieClip):void
		{
			
			target.stopAllMovieClips();
		}
		
		public static function displayObjectInfo(target:DisplayObject):String
		{
			if(!DevicePrefrence.isDebuggingMode())
			{
				return '';
			}
			var info:String = "" ;
			var locationString:String ='';
			info += "\tName: "+target.name+'\n' ;
			info += "\tType: "+getQualifiedClassName(target)+'\n' ;
			if(target.stage)
			{
				info += "\tArea on : "+target.getBounds(target.stage)+'\n' ;
			}
			while(target!=null)
			{
				locationString=target.name+'.'+locationString;
				target = target.parent ;
			}
			info += "\tLocation: "+locationString;
			
			
			return info;
		}
		
		/**This will dispatches event to all children*/
		public static function dispatchReverse(target:Sprite,event:Event):void
		{
			for(var i:int = 0 ; i<target.numChildren ; i++)
			{
				if(target.getChildAt(i) is Sprite)
				{
					(target.getChildAt(i) as Sprite).dispatchEvent(event);
					dispatchReverse((target.getChildAt(i) as Sprite),event);
				}
			}
		}
		
		public static function setMouseClickDebugger(stage:Stage):void
		{
			if(!DevicePrefrence.isDebuggingMode())
				return;
			stage.addEventListener(MouseEvent.MOUSE_DOWN,function(e:MouseEvent):void{
				trace(Obj.displayObjectInfo(e.target as DisplayObject));
			});
		}

		public static function copyTextField(textField:TextField,copyContent:Boolean=false):TextField
		{
			var text:TextField = new TextField();
			var format:TextFormat = textField.defaultTextFormat ;
			var textFormat:TextFormat = new TextFormat(format.font,format.size,format.color,format.bold,
				format.italic,format.underline,format.url,format.target,format.align,format.leftMargin,
				format.rightMargin,format.indent,format.leading);
						//text.defaultTextFormat = textField.defaultTextFormat.
			text.defaultTextFormat = textFormat ;
			text.maxChars = textField.maxChars ;
			text.multiline = textField.multiline;
			text.selectable = textField.selectable;
			text.sharpness = textField.sharpness;
			text.textColor = textField.textColor;
			text.thickness = textField.thickness;
			text.type = textField.type;
			text.wordWrap = textField.wordWrap;
			text.embedFonts = textField.embedFonts;
			text.width = textField.width;
			text.height = textField.height;
			return text ;
		}
	}
}