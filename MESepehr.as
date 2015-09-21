var COPYRIGHT:String;
COPYRIGHT='Mohammad Ebrahim Sepehr';
//

_root.fadeAndGo=true
var سيو:SharedObject = SharedObject.getLocal("همراهنوروز",'/') ;
if(سيو.data.هانچيچي!=true && _root.fadeAndGo==undefined){
	_root._visible = false;
	var khafa:Sound = new Sound(_root);
	khafa.setVolume(0);
}

//set places
function EQP(targ1,targ2){
	targ1._x = targ2._x ;
	targ1._y = targ2._y ;
}
//slowly
function EQPs1(ASPactarg1,ASPactarg2,ASPacSP){
	////trace(ASPactarg1)
	ASPactarg1.createEmptyMovieClip('EQPCash',ASPactarg1.getNextHighestDepth());
	ASPactarg1.EQPCash.onEnterFrame = function(){
		ASPactarg1._x+=Number((Number(ASPactarg2._x)-Number(ASPactarg1._x))/ASPacSP);
		////trace((ASPactarg2))
		ASPactarg1._y+=Number((Number(ASPactarg2._y)-Number(ASPactarg1._y))/ASPacSP);
		////trace('jaja')
		if(Math.abs(ASPactarg2._x-ASPactarg1._x)<1&&Math.abs(ASPactarg2._y-ASPactarg1._y)<1){
			removeMovieClip(ASPactarg1.EQPCash)
		}
	}
}

///////
function randCM(randCv,randCMv){
	if(randCMv==undefined){
		randCMv=0;
	}
	return (Math.floor(Math.random()*micV+randCMv)*Math.pow(-1,Math.ceil(Math.random()*2)))
}
function randC(randCMv){
	return (Math.floor(Math.random()*randCMv)*Math.pow(-1,Math.ceil(Math.random()*2)))
}
///
function rand(randV){
	return(Math.floor(Math.random()*randV))
}

///////////////////set Place
function setPlace(targ,X0,Y0,X,Y,R){		//targ ra be X0+x , Y0+y  montaghel mikonad , ba tavajoh be zavieye chatkhesh
	var Rn = R/180*Math.PI ;
	targ._x = X0 - Math.sin(Rn)*Y + Math.cos(Rn)*X;
	targ._y = Y0 + Math.sin(Rn)*X + Math.cos(Rn)*Y;
}
//// pause everyTingh
function pauseAll(target){
	trace(target)
	target.EnterFrameCach = target.onEnterFrame;
	target.MouseDownCach = target.onMouseDown;
	delete target.onMouseDown;
	delete target.onEnterFrame;
	for(i in target){
		if(target[i]._x==undefined){
			continue
		}
		pauseAll(target[i])
	}
}
function playAll(target){
	if(target.ShowldPlayIt){
		target.play();
		delete target.ShowldPlayIt;
	}
	target.onEnterFrame = target.EnterFrameCach;
	target.onMouseDown = target.MouseDownCach;
	for(i in target){
		if(target[i]._x==undefined){
			continue
		}
		playAll(target[i])
	}
}


/////////////