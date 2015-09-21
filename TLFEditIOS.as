// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

/**
* Copyright (c) mteamapp.com - developers
*
* 1.0.2-updated : 5/14/2013
* textFormat Problem Solved
* 
* This Class forces TLFTextFields acts like clasic Texts To
* Make IOS Devices Bring softKeyBoards To Make Them Editable
* With KeyBoard. IOS Cant use your Embeded Fonts on E
* Time, but this class use your TextFormat To make edit time Text
* Same as defuult format. it can switch to RTF for Arabic and
* Persian when user type rtl characters.
*
* Enjoy And Help Us to Improve this Class till Adobe make an decision on TLFTexts.
*
*/
package
{
	import fl.motion.Color;
	import fl.motion.Source;
	import fl.text.TLFTextField;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.geom.ColorTransform;
	import flash.net.getClassByAlias;
	import flash.text.*;
	
	import flashx.textLayout.formats.Direction;
	
	public class TLFEditIOS
	{
		private static var addedTextFieldsName:String = new String("_SistersTextField")
		private static var firstTimeDecoder="_METLF879132FIRSTTIME";
		private static var mylastText:TextField;
		
		public static function steKeyBord(yourTLF:TLFTextField,deleteFirstStringFromIt:Boolean=false)
		{
			if(yourTLF.parent==null){
				trace(new Error("Your TextFiled Had No Parents Or Its Not Added Yet."))
				return;	
			}
			onActivated(yourTLF,deleteFirstStringFromIt)
			yourTLF.addEventListener(Event.RENDER,onActivated)
		}
		
		
		private static function onActivated(e,deleteFirstStringFromIt=false){
			if( e is TLFTextField || e.target is TLFTextField){
				var yourTLF:TLFTextField;
				if(e is TLFTextField){
					yourTLF = e;
				}else{
					yourTLF = e.target;
				}	
				var TextsParent = yourTLF.parent;
				var newTextField:TextField = new TextField();
				var cash
				if((cash = TextsParent.getChildByName(yourTLF.name+addedTextFieldsName))!=null){
					TextsParent.removeChild(cash);
				}else if((cash = TextsParent.getChildByName(yourTLF.name+addedTextFieldsName+firstTimeDecoder))!=null){
					TextsParent.removeChild(cash);
					deleteFirstStringFromIt = true;
				}
				yourTLF.type = TextFieldType.DYNAMIC ;
				
				MovieClip(TextsParent).addChild(newTextField);
				newTextField.width = yourTLF.width;
				newTextField.height = yourTLF.height ;
				newTextField.x = yourTLF.x ;
				newTextField.y = yourTLF.y ;
				newTextField.multiline = yourTLF.multiline;
				
				newTextField.type = TextFieldType.INPUT ;
				
				
				if(deleteFirstStringFromIt){
					newTextField.name = yourTLF.name+addedTextFieldsName+firstTimeDecoder ;
				}else{
					newTextField.name = yourTLF.name+addedTextFieldsName ;
				}
				
				if(mylastText!=null){
					getSister(mylastText).alpha=1;
				}
				mylastText = null;
				
				updateFormat(newTextField);
				
				newTextField.addEventListener(FocusEvent.FOCUS_IN,focused);
				newTextField.addEventListener(FocusEvent.FOCUS_OUT,focusedOut);
				newTextField.addEventListener(Event.REMOVED_FROM_STAGE,removver)
			}
		}
		
		private static function removver(e){
			TextField(e.currentTarget).removeEventListener(FocusEvent.FOCUS_IN,focused);
			TextField(e.currentTarget).removeEventListener(FocusEvent.FOCUS_OUT,focusedOut);
			TextField(e.currentTarget).removeEventListener(Event.REMOVED_FROM_STAGE,removver);
		}
		
		
		private static function updateFormat(e){
			var targ:TextField;
			if(e is TextField){
				targ = e ;
			}else{
				targ = e.target;
			}
			var sis:TLFTextField = getSister(TextField(targ)) ;
			var textFormat:TextFormat = sis.getTextFormat();
			TextField(targ).defaultTextFormat = textFormat;
		}
		
		private static function focused(e:FocusEvent){
			if(mylastText!=TextField(e.target) && mylastText!=null){
				getSister(mylastText).alpha=1;
			}
			mylastText = TextField(e.target) ;
			var isItFirstTime:Boolean=false;
			if(String(e.target.name).indexOf(firstTimeDecoder)!=-1){
				e.target.name = String(e.target.name).substring(0,String(e.target.name).length-firstTimeDecoder.length)
				isItFirstTime=true;
			}
			var sis:TLFTextField = getSister(TextField(e.target)) ;
			e.target.alpha=1;
			sis.alpha = 0;
			if(!isItFirstTime){
				TextField(e.target).text = String(sis.text);
			}else{
				TextField(e.target).text = " " ;
			}
		}
		
		private static function focusedOut(e:FocusEvent){
			var sis = getSister(TextField(e.target)) ;
			e.target.alpha=0;
			sis.alpha = 1;
			sis.text = TextField(e.target).text;
			if(checkRTL(sis.text)){
				sis.direction = Direction.RTL ;
			}else{
				sis.direction = Direction.LTR ;
			}
		}
		
		
		
		private static function getSister(targ:TextField):TLFTextField{
			var myParent = targ.parent ;
			if(myParent == null){
				trace('Text is in incorrect place.');
				return new TLFTextField();
			}
			var myName = String(targ.name).substring(0,String(targ.name).length-addedTextFieldsName.length);
			var mySister = myParent.getChildByName(myName);
			if(mySister==null){
				myName = String(targ.name).substring(0,String(targ.name).length-addedTextFieldsName.length-firstTimeDecoder.length);
				mySister = myParent.getChildByName(myName);
				if(mySister==null){
					trace('Sister TLFTextField Not Founded.')
					return new TLFTextField();
				}
			}
			if(!(mySister is TLFTextField)){
				trace("Sister Text is not TLFTextField!");
				return new TLFTextField();
			}
			return TLFTextField(mySister);
		}
		
		private static function checkRTL(yourText:String):Boolean{
			for(var i=0;i<yourText.length;i++){
				if(yourText.charCodeAt(i)>1548)	{
					return true	
				}
			}
			return false
		}
	}
}