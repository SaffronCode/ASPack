// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package com.mteamapp
{
	/**asancron jobs manager :<br>
	 * each new jobs will calling wait with its id and each finishing will call isFinished with
	 * task id. this class checks if any task with this id is in porcess , it will send false in isFinished function*/
	public class Syncer
	{
		/**tasks id list*/
		private static var tasksID:Array;
		
		/**tasks jobs*/
		private static var tasksJobs:Array ;
		
		/**wait for this tasked id to finish*/
		public static function wait(ID:uint,waitNumber:uint=1):void
		{
			setUp();
			var I:int = tasksID.indexOf(ID);
			if(I != -1)
			{
				tasksJobs[I]+=waitNumber;
				//trace("++tasksJobs[I] : "+tasksJobs[I]);
			}
			else
			{
				tasksID.push(ID);
				tasksJobs.push(waitNumber);
			}
		}
		
		/**reset syncs*/
		public static function reset(ID:uint):void
		{
			setUp();
			var I:int = tasksID.indexOf(ID);
			if(I != -1)
			{
				tasksJobs[I] = 0;
			}
			else
			{
				tasksID.push(ID);
				tasksJobs.push(0);
			}
		}
		
		/**this will tells that this task is finished, but if any task is steel waiting , it will returns false*/
		public static function isFinished(ID:uint):Boolean
		{
			setUp();
			var I:int = tasksID.indexOf(ID);
			if(I != -1)
			{
				tasksJobs[I]--;
				//trace("tasksJobs[I] : "+tasksJobs[I]);
				if(tasksJobs[I]<=0)
				{
					//no more tasks lefted
					tasksID.splice(I,1);
					tasksJobs.splice(I,1);
					return true ;
				}
				else
				{
					//more tasks are waiting to finish
					return false;
				}
			}
			else
			{
				return false;
			}
		}
		
		/**this will set up arrays if needed*/
		private static function setUp()
		{
			if(tasksID == null)
			{
				tasksID = new Array();
				tasksJobs = new Array();
			}
		}
	}
}