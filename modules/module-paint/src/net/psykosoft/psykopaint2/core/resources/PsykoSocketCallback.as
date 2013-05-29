package net.psykosoft.psykopaint2.core.resources
{
	final public class PsykoSocketCallback
	{
		public var callbackObject:Object;
		public var callbackMethod:Function;
		public var fullTargetPath:String;
		public var targetPath:Array;
		
		public function PsykoSocketCallback(targetPath:String, callbackObject:Object, callbackMethod:Function )
		{
			this.fullTargetPath = targetPath;
			this.callbackObject = callbackObject;
			this.callbackMethod = callbackMethod;
			this.targetPath = targetPath.split(".");
		}
		
		public function isReceipient( incomingPath:Array ):Boolean
		{
			
			for ( var i:int = 0; i < Math.min( targetPath.length, incomingPath.length ); i++ )
			{
				if ( targetPath[i] == "*" ) return true;
				if ( targetPath[i] != incomingPath[i] ) return false;
			}
			return targetPath.length != incomingPath.length;
		}
	}
}