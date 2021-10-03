
/*
ActionScript 3 Tutorials by Barbara Kaskosz.

www.flashandmath.com

Last modified: July 15, 2008. 

*/

/*
Our classes in this tutorial are in the sequence of nested folders
com, flashandmath, bitmaps. Hence, the name of the package.
We are importing all the built-in classes that we need and the
custom class BitmapTransformer.

Rendering and rotating the sphere in this class uses the same 3D engine
that we developed in the tutorial 'Simple 3D Drawing in Flash CS3',
http://www.flashandmath.com/advanced/simple3d/. 

Texture mapping will be done using the BitmapTransformer class. The class is discussed
in detail in the tutorial "Cube in Bloom: Distorting Images in AS3",
http://www.flashandmath.com/advanced/menu3d/.
*/

package com.flashandmath.bitmaps {
	
	 import com.flashandmath.bitmaps.BitmapTransformer;
	 
	 import flash.display.*;
	 import flash.events.*;
	 import flash.geom.*;
	 
	
	 public class BitmapSphere extends Sprite {
		 
		 //We are declaring our variables. Their meaning will become clear later.
		 
		private const PI_180:Number = Math.PI/180 ;
		 
		private var isLock:Boolean = false ;
		
		public function lock():void
		{
			isLock = true ;
		}
		
		public function unLock():void
		{
			isLock = false ;
		}
		 
		 
		private var bdPic:BitmapData;

		private var btTransform:BitmapTransformer;
		
		private var tilesArray:Array;

        private var piecesArray:Array;

        private var picWidth:Number;
		
		private var picHeight:Number;

        private var backSize:Number;
		
		private var backColor:Number;

        private var spBoard:Sprite;
		
		private var shBack:Shape;

        private var spBall:Sprite;

		private var doRotate:Boolean;

        private var prevX:Number;

        private var prevY:Number;

        private var curTheta:Number;

        private var curPhi:Number;

		private var rad:Number;
		
		private var nMesh:Number;
		
		private var pieceWidth:Number;
	
        private var pieceHeight:Number;

		private var fLen:Number;
		

		/*
		The constructor takes one parameter: a BitmapData object, 'b', corresponding
		to the picture to be pasted over a sphere. Typically, it will be
		a BitmapData object corresponding to an image imported to the Library.
		When an image in the Library is linked to AS3, Flash creates a BitmapData
		object corresponding to the image. 
		*/
		
		
		public function BitmapSphere(b:BitmapData,Width:Number=0,Height:Number=0) {
			
		  //bdPic holds all the pixels information about the image
		  //that will be pasted over a sphere.
			
		  bdPic=b;
		  
		  //The width of the main image is set to the width of the BitmapData
		  //object passed to the constructor. Its height is set to the half
		  // of the width. If the image passed to the constructor is taller,
		  //the bottom will be cropped. If you change picHeight to bdPic.height,
		  //the image will be distorted rather than cropped.
			
		 /* if(Width==0)
		  {*/
		  		picWidth=bdPic.width;
			  //picHeight=picWidth/2;
			  picHeight=bdPic.height;
		  /*}
		  else
		  {
			  picWidth = Width ;
			  picHeight = Height ;
		  }*/
		  
		  
		  //The width of the picture has to be equal to the circumference
		  //of the sphere. Thus, the radius, rad, is set accordingly.
		  //Choosing a different radius will distort the image.
		  
		  rad=Math.floor(picWidth/(Math.PI*2));
		  
		  //The size of the square background behing the sphere and its color.
			
		  backSize=3*rad+50;
		  
		  backColor=0x000000;
		 
		  //The constant responsible for perspective distortion. 
			
		  fLen=2000
		  
		  //The main container.
			
		  spBoard=new Sprite();

          this.addChild(spBoard);
		  
		  shBack=new Shape();

          spBoard.addChild(shBack);
		  
		  //spBall is the Sprite in which the sphere will be drawn.

          spBall=new Sprite();

          spBoard.addChild(spBall);
		  
		  //Sepehr : Who asked you to change ball position???? ha!??
		  //spBall.x=backSize/2;
		  
		  //spBall.y=backSize/2;
		  
		  doRotate=false;
		  
		  //curTheta and curPhi are the horizontal and the vertical angles of
		  //displacement of the observer.

          curTheta=180;

          curPhi=60;
		  
		  /*
		  The sphere will be made up of 30*30=900 3D quadrangles. Our image will be divided
		  into 30*30=900 rectangular images (pieces) that will be mapped onto 2D projections
		  of those quadrangles using the BitmapTransformer.
		  */
		  
		  nMesh=10//30;
		  
		  //The width and the height of each small piece of our image.
		  
		  pieceWidth=picWidth/nMesh;
	
          pieceHeight=picHeight/nMesh;
		  
		  //We create an instance of BitmapTransformer.

          btTransform=new BitmapTransformer(pieceWidth,pieceHeight,1,1);
		  
		  //tilesArray holds 3D coordinates of the vertices in the mesh.
		  
          tilesArray=[];
		  
		  //piecesArray holds pieces of our image.

          piecesArray=[];
		  
		  //We are callling functions that initialize our app.

		  drawBack();
		  
		  setTilesArray();

          setPicsArray();

          renderView(curTheta,curPhi);
		  
		  setUpListeners();

		}
		
		
		private function drawBack():void {
	
			return ;
			
	        shBack.graphics.clear();
	
	        shBack.graphics.lineStyle(1,backColor);
	
	        shBack.graphics.beginFill(backColor);
	
	        shBack.graphics.drawRect(0,0,backSize,backSize);
	
	        shBack.graphics.endFill();
	
          }
		
		
	private function setTilesArray():void {
	
	      var i:int;
	
	      var j:int;
	
	      var istep:Number;
	
          var jstep:Number;
	
          istep=2*Math.PI/nMesh;
	
          jstep=Math.PI/nMesh;

	  for(i=0;i<=nMesh;i++){
		
		  tilesArray[i]=[];
		
		 for(j=0;j<=nMesh;j++){
			 
			 //We are setting 3D coordinates of our mesh vertices on the sphere 
			 //using parametric equation of the sphere of radius 'rad'.
			
			tilesArray[i][j]=[rad*Math.cos(istep*i)*Math.sin(jstep*j),rad*Math.sin(istep*i)*Math.sin(jstep*j),rad*Math.cos(jstep*j)];
				
		 }
		
	  }
	
   }


   private function setPicsArray():void {
	
	  var i:int;
	
	  var j:int;
	
	  for(i=0;i<nMesh;i++){
		
		piecesArray[i]=[];
		
		for(j=0;j<nMesh;j++){
			
			//We are cutting our bitmap (more precisely, BitmapData) into small rectangles. 
			
			piecesArray[i][j]=new BitmapData(pieceWidth,pieceHeight);
			
			piecesArray[i][j].copyPixels(bdPic,new Rectangle(i*pieceWidth,j*pieceHeight,pieceWidth,pieceHeight),new Point(0,0));
			
			
		  }
		
	  }
	
   }
   
   /*
   'renderView' function gives the view of the sphere corresponding to the horizontal angular
   displacement of the observer 't' and the vertical angular displacement 'p'. The function
   uses helper functions to calculate 3D coordinates of each vertex in the mesh for the new view
   angles, projects the vertices onto the 2D screen and depths-sorts the quadrangles. After that,
   the function uses our instance of BitmapTranformer to map each small piece of our image
   onto the corresponding projected quadrangle.
   */


  private function renderView(t:Number,p:Number):void {
	
	
	var i:int;
	
	var j:int;
	
	var n:int;
	
	var distArray:Array=[];
	
	var dispArray:Array=[];
	
	var tilesNewArray:Array=[];
	
	var midPoint:Array=[];

	var dist:Number;
	
	var depLen:Number;
	
	var curv0:Array=[];
	
	var curv1:Array=[];
	
	var curv2:Array=[];
	
	var curv3:Array=[];
	
	t=t*PI_180;
	
	p=p*PI_180;
	
	spBall.graphics.clear();
	
	for(i=0;i<=nMesh;i++){
		
		tilesNewArray[i]=[]; 
		
		for(j=0;j<=nMesh;j++){
			
			tilesNewArray[i][j]=pointNewView(tilesArray[i][j],t,p);
			
		}
			
	}
	
	for(i=0;i<nMesh;i++){
		
		for(j=0;j<nMesh;j++){
		
		midPoint[0]=(tilesNewArray[i][j][0]+tilesNewArray[i+1][j][0]+tilesNewArray[i][j+1][0]+tilesNewArray[i+1][j+1][0])/4;
		
		midPoint[1]=(tilesNewArray[i][j][1]+tilesNewArray[i+1][j][1]+tilesNewArray[i][j+1][1]+tilesNewArray[i+1][j+1][1])/4;
		
		midPoint[2]=(tilesNewArray[i][j][2]+tilesNewArray[i+1][j][2]+tilesNewArray[i][j+1][2]+tilesNewArray[i+1][j+1][2])/4;
		
		dist=Math.sqrt(Math.pow(fLen-midPoint[0],2)+Math.pow(midPoint[1],2)+Math.pow(midPoint[2],2));
		
		distArray.push([dist,i,j]);
		
		}
		
	}
	
	
	distArray.sort(byDist);

	for(i=0;i<=nMesh;i++){
		
		dispArray[i]=[];
		
		for(j=0;j<=nMesh;j++){
		
		dispArray[i][j]=[fLen/(fLen-tilesNewArray[i][j][0])*tilesNewArray[i][j][1],-fLen/(fLen-tilesNewArray[i][j][0])*tilesNewArray[i][j][2]];
		
		}
	}
	
	depLen=distArray.length;
	
	for(n=0;n<depLen;n++){
		//Sepehr line tor increace performance and reality.
		if(distArray[n][0]<2000)
		{
			break;
		}
		i=distArray[n][1]; 
		
		j=distArray[n][2];
		
		curv0=dispArray[i][j];
		
		curv1=dispArray[i+1][j];
		
		curv2=dispArray[i+1][j+1];
		
		curv3=dispArray[i][j+1];
		
		btTransform.mapBitmapData(piecesArray[i][j],new Point(curv0[0],curv0[1]),new Point(curv1[0],curv1[1]),new Point(curv2[0],curv2[1]),new Point(curv3[0],curv3[1]),spBall);
			
	 }
	
	
  }


  //Listeners which allow the user to rotate the sphere with the mouse.

  private function setUpListeners():void {
		
		  spBoard.addEventListener(MouseEvent.ROLL_OUT,boardOut);
		
		  //Sepehr Update : Event.ENTER_FRAME < MouseEvent.MOUSE_MOVE
          spBoard.addEventListener(Event.ENTER_FRAME,boardMove);
		
          spBoard.addEventListener(MouseEvent.MOUSE_DOWN,boardDown);
		
          spBoard.addEventListener(MouseEvent.MOUSE_UP,boardUp);
	
	}
	
	     
	
     private function boardOut(e:MouseEvent):void {
			
			doRotate=false;
			
	}
	
     private function boardDown(e:MouseEvent):void {			
			
			prevX=spBoard.mouseX;
			
			prevY=spBoard.mouseY;
				
			doRotate=true&&(!isLock);
			
	}
	
     private function boardUp(e:MouseEvent):void {
			
			doRotate=false;
			
	}
	
	 //Sepehr Update : Event.ENTER_FRAME < MouseEvent.MOUSE_MOVE
     private function boardMove(e:Event):void {
		 
	        var locX:Number=prevX;
			
			var locY:Number=prevY;
	
			if(doRotate){
			
			prevX=spBoard.mouseX;
			
			prevY=spBoard.mouseY;
			
			//Sepehr updates , - < +
			//I change the view , so it is reverce again + < -
			curTheta+=(prevX-locX)/2;
			
			//Sepehr updates , - < +
			//I change the view , so it is reverce again + < -
			curPhi+=(prevY-locY)/2;
			
			//Sepehr Updates
			if(curPhi>180)
			{
				curPhi = 180 ;
			}
			if(curPhi<0)
			{
				curPhi = 0 ;
			}
			
			renderView(curTheta,curPhi);
			
			//e.updateAfterEvent();
			
			}
	}



   
   private function byDist(v:Array,w:Array):Number {
	
	 if (v[0]>w[0]){
		
		return -1;
		
	  } else if (v[0]<w[0]){
		
		return 1;
	
	   } else {
		
		return 0;
	  }
	  
  }


   private function pointNewView(v:Array,theta:Number,phi:Number):Array {
	
	  var newCoords:Array=[];
	
	  newCoords[0]=v[0]*Math.cos(theta)*Math.sin(phi)+v[1]*Math.sin(theta)*Math.sin(phi)+v[2]*Math.cos(phi);
	
	  newCoords[1]=-v[0]*Math.sin(theta)+v[1]*Math.cos(theta);
	
	  newCoords[2]=-v[0]*Math.cos(theta)*Math.cos(phi)-v[1]*Math.sin(theta)*Math.cos(phi)+v[2]*Math.sin(phi);
	
	  return newCoords;
	
   }

     //A public method that changes the color of the background.
	 
	  public function changeBackColor(c:Number): void {
		  
		  backColor=c;
		  
		  drawBack();
		  
	  }
	  
	  //A public method that changes the size of the background.
	  
	  public function changeBackSize(w:Number,h:Number=NaN): void {
		  
		  //Sepehr upgrades
		  if(isNaN(h))
		  {
			  h = w ;
		  }
		  backSize=w;
		  
		  drawBack();
		  //Sepehr , who asked you to change sphere position???
		  spBall.x=w/2;
		  
		  spBall.y=h/2;
		  
	  }
	  
	  //The public method that should be called before an instance of BitmapSphere is removed.
	  
	  public function destroy():void {
		  
		  spBoard.removeEventListener(MouseEvent.ROLL_OUT,boardOut);
		
		  //Sepehr Update : Event.ENTER_FRAME < MouseEvent.MOUSE_MOVE
          spBoard.removeEventListener(Event.ENTER_FRAME,boardMove);
		
          spBoard.removeEventListener(MouseEvent.MOUSE_DOWN,boardDown);
		
          spBoard.removeEventListener(MouseEvent.MOUSE_UP,boardUp);
		  
		  spBall.graphics.clear();
		  
		  shBack.graphics.clear();
	  
	  }
	  
	 	
		
	}
	
	
}