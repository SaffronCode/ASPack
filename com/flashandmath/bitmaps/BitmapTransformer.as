
/*
ActionScript 3 Tutorials by Barbara Kaskosz.

www.flashandmath.com

Last modified: March 20, 2008. 

Many of the ideas used in this class, in particular triangulating a bitmap
in order to obtain the distortion effect, are inspired by earlier work by:
Andre Michelle of void.andre-michelle.com, Thomas Pfeiffer of www.flashsandy.org,
and Ruben Swieringa of www.rubenswieringa.com.
*/

package com.flashandmath.bitmaps {
	
	import flash.display.*;
	
	import flash.geom.Matrix;
	
	import flash.geom.Point;
	
	public class BitmapTransformer {
		
		private var dataWidth:Number;
		
		private var dataHeight:Number;
		
		private var vertsArray:Array;
		
		private var newVertsArray:Array;
		
		private var hDiv:int;
		
		private var vDiv:int;
		
		/*
		The public property 'smoothOn' should be used with caution. By default
		it is set to false. When 'smoothOn' is set to 'true', ASVM will try
		to 'smooth' images before rendering them. If you have more than a couple
		of images, like for example in our cube menu, smoothing
		may cause slight delays and jerkiness in rotation.
		*/
		
		public var smoothOn:Boolean;
		
		/*
		The class constructor takes as parameters the width and the height (w and h)
		of the BitmapData objects to which mapBitmapData method will be applied. 
		One instance of BitmapTransformer can manipulate more than one BitmapData object,
		but all of them have to have the same dimensions. The optional parameters,
		hdiv, vdiv control the number of subdivisions of a rectangular bitmap
		horizontally and vertically. Clearly, the higher values, the better picture.
		In our cube menu we use 10, 10. 5 and 5 usually suffice for good results.
		*/
		
		public function BitmapTransformer(w:Number,h:Number,hdiv:int=5,vdiv:int=5){
			
			this.dataWidth=w;
			
			this.dataHeight=h;
			
			this.hDiv=hdiv;
			
			this.vDiv=vdiv;
			
			this.vertsArray=[];
			
			this.newVertsArray=[];
			
			this.smoothOn=false;
			
			setVertices();
			
		}
		
		/*
		The next function sets a hDiv by vDiv mesh of vertices over a rectangular BitampData
		object of dimensions dataWidth by dataHeight. Values for hDiv, vDiv, dataWidth, dataHeight
		set by the constructor based on the parameters. 
		*/
		
		private function setVertices():void {
			
			var j:int;
			
			var i:int;
			
			var k:int;
			
			var hStep:Number=dataWidth/hDiv;
			
			var vStep:Number=dataHeight/vDiv;
			
			for(j=0;j<=vDiv;j++){
				
				vertsArray[j]=[];
				
				for(i=0;i<=hDiv;i++){
					
					vertsArray[j][i]=new Point(i*hStep,j*vStep);
					
				}
							
			}
			
		}
		
		/*
		The next function calculates the corresponding vertices in a distorted
		object. It will be used by the public mapBitmapData method.
		*/
		
		private function calcNewVerts(a:Point,b:Point,c:Point,d:Point):void {
			
			var i:int;
			
			var j:int;
			
			var verVecLeft:Array=[d.x-a.x,d.y-a.y];
			
			var verVecRight:Array=[c.x-b.x,c.y-b.y];
			
			var curVert:Point;
			
			var curYCoeff:Number;
			
			var curXCoeff:Number;
			
			var curPointLeft:Point=new Point();
			
			var curPointRight:Point=new Point();
			
			var newVert:Point=new Point();
			
			for(j=0;j<=vDiv;j++){
				
				newVertsArray[j]=[];
				
				for(i=0;i<=hDiv;i++){
					
					newVertsArray[j][i]=new Point();
					
					curVert=vertsArray[j][i];
					
					curYCoeff=curVert.y/dataHeight;
					
					curXCoeff=curVert.x/dataWidth;
					
					curPointLeft.x=a.x+curYCoeff*verVecLeft[0];
					
					curPointLeft.y=a.y+curYCoeff*verVecLeft[1];
					
					curPointRight.x=b.x+curYCoeff*verVecRight[0];
					
					curPointRight.y=b.y+curYCoeff*verVecRight[1];
					
					newVert.x=curPointLeft.x+(curPointRight.x-curPointLeft.x)*curXCoeff;
					
					newVert.y=curPointLeft.y+(curPointRight.y-curPointLeft.y)*curXCoeff;
					
					newVertsArray[j][i].x=newVert.x;
					
					newVertsArray[j][i].y=newVert.y;
				
				}
							
			}
			
		}
		
		
		/*
		The main method of the class, mapBitmapData, takes a BitmapData object of the dimensions
		set by the constructor and maps it onto an arbitrary quadrangle. The method does it by
		splitting each subrectangle of the distorted mesh into two triangles, and filling
		each triangle with the distorted portion of the bitmap via beginBitmapFill. To use
		beginBitmapFill, we need to draw the distorted triangle in some target container
		in which the distorted bitmap will eventually reside. In our cube menu, each side
		resides in a Sprite, side0, side1,...,side5. So for each side we draw in the corresponding
		Sprite, side0, side1, and so on. 
		
		The method takes the following parameters: a BitmapData object, Points that represent
		vertices of the distortion quadrangle in a specific order: top-left, top-right,
		bottom-right, bottom-left. The last parameter is the target object where drawing will take place.
		It can be a Sprite, a Shape, or a MovieClip, depending on your application.
		
		The reason why all of this works is that beginBitmapFill method takes a transform matrix as a possible
		parameter. Any three points can be mapped onto any three points using an affine transformation;
		that is, using a transform matrix. (Three yes, four no.) In the method's body,
		we calculate the right transform matrix to apply to our bitmap at each step based on the positions of
		the vertices of the original and of the distorted triangles.
		*/
		
		
		public function mapBitmapData(bd:BitmapData,topl:Point,topr:Point,botr:Point,botl:Point, cont:*):void {
			
			var i:int;
			
			var j:int;
			
			var curVertOld0:Point=new Point();
			
			var curVertNew0:Point=new Point();
			
			var curVertOld1:Point=new Point();
			
			var curVertNew1:Point=new Point();
			
			var curVertOld2:Point=new Point();
			
			var curVertNew2:Point=new Point();
			
			var finMat:Matrix=new Matrix();
			
			var linMat:Matrix=new Matrix();
			
			calcNewVerts(topl,topr,botr,botl);
			
			for(j=0;j<vDiv;j++){
				
				for(i=0;i<hDiv;i++){
					
					curVertOld0.x=vertsArray[j][i].x;
					
					curVertOld0.y=vertsArray[j][i].y;
					
					curVertOld1.x=vertsArray[j+1][i].x;
					
					curVertOld1.y=vertsArray[j+1][i].y;
					
					curVertOld2.x=vertsArray[j][i+1].x;
					
					curVertOld2.y=vertsArray[j][i+1].y;
					
					curVertNew0.x=newVertsArray[j][i].x;
					
					curVertNew0.y=newVertsArray[j][i].y;
					
					curVertNew1.x=newVertsArray[j+1][i].x;
					
					curVertNew1.y=newVertsArray[j+1][i].y;
					
					curVertNew2.x=newVertsArray[j][i+1].x;
					
					curVertNew2.y=newVertsArray[j][i+1].y;
					
				    finMat.tx= curVertOld0.x;
					
				    finMat.ty= curVertOld0.y;
				
				    finMat.a=0;
					
				    finMat.b=(curVertOld1.y - curVertOld0.y)/dataWidth;
					
				    finMat.c=(curVertOld2.x - curVertOld0.x)/dataHeight;
					
				    finMat.d=0;
					
				    linMat.a=(curVertNew1.x - curVertNew0.x)/dataWidth;
					
				    linMat.b=(curVertNew1.y - curVertNew0.y)/dataWidth;
					
				    linMat.c=(curVertNew2.x - curVertNew0.x)/dataHeight;
					
				    linMat.d=(curVertNew2.y - curVertNew0.y)/dataHeight;
					
				    linMat.tx=curVertNew0.x;
					
				    linMat.ty=curVertNew0.y;
					
				    finMat.invert();
					
				    finMat.concat(linMat);
				
				    cont.graphics.beginBitmapFill(bd,finMat,false,smoothOn);
					
				    cont.graphics.moveTo(curVertNew0.x, curVertNew0.y);
					
				    cont.graphics.lineTo(curVertNew1.x, curVertNew1.y);
					
				    cont.graphics.lineTo(curVertNew2.x, curVertNew2.y);
					
					cont.graphics.lineTo(curVertNew0.x, curVertNew0.y);
					
				    cont.graphics.endFill();
					
					curVertOld0.x=vertsArray[j+1][i+1].x;
					
					curVertOld0.y=vertsArray[j+1][i+1].y;
					
					curVertOld1.x=vertsArray[j][i+1].x;
					
					curVertOld1.y=vertsArray[j][i+1].y;
					
					curVertOld2.x=vertsArray[j+1][i].x;
					
					curVertOld2.y=vertsArray[j+1][i].y;
					
					curVertNew0.x=newVertsArray[j+1][i+1].x;
					
					curVertNew0.y=newVertsArray[j+1][i+1].y;
					
					curVertNew1.x=newVertsArray[j][i+1].x;
					
					curVertNew1.y=newVertsArray[j][i+1].y;
					
					curVertNew2.x=newVertsArray[j+1][i].x;
					
					curVertNew2.y=newVertsArray[j+1][i].y;
					
				    finMat.tx= curVertOld0.x;
					
				    finMat.ty= curVertOld0.y;
				
				    finMat.a=0;
					
				    finMat.b=(curVertOld1.y - curVertOld0.y)/dataWidth;
					
				    finMat.c=(curVertOld2.x - curVertOld0.x)/dataHeight;
					
				    finMat.d=0;
					
				    linMat.a=(curVertNew1.x - curVertNew0.x)/dataWidth;
					
				    linMat.b=(curVertNew1.y - curVertNew0.y)/dataWidth;
					
				    linMat.c=(curVertNew2.x - curVertNew0.x)/dataHeight;
					
				    linMat.d=(curVertNew2.y - curVertNew0.y)/dataHeight;
					
				    linMat.tx=curVertNew0.x;
					
				    linMat.ty=curVertNew0.y;
					
				    finMat.invert();
					
				    finMat.concat(linMat);
				
					//Sepehr debug
				    cont.graphics.beginBitmapFill(bd,finMat, false, smoothOn);
					
				    cont.graphics.moveTo(curVertNew0.x, curVertNew0.y);
					
				    cont.graphics.lineTo(curVertNew1.x, curVertNew1.y);
					
				    cont.graphics.lineTo(curVertNew2.x, curVertNew2.y);
					
					cont.graphics.lineTo(curVertNew0.x, curVertNew0.y);
					
				    cont.graphics.endFill();
					
				}
							
			}
			
		}
		
		
		
	}
	
	
}