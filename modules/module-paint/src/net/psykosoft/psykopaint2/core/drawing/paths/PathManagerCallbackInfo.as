package net.psykosoft.psykopaint2.core.drawing.paths
{
	final public class PathManagerCallbackInfo
	{
		public var callbackObject:Object;
		public var onPathPoints:Function;
		public var onPathStart:Function;
		public var onPathEnd:Function;
		public var onPickColor:Function;
		
		public function PathManagerCallbackInfo(callbackObject:Object, onPathPoints:Function = null, onPathStart:Function = null, onPathEnd:Function = null, onPickColor:Function = null)
		{
			this.callbackObject = callbackObject;
			this.onPathPoints = onPathPoints;
			this.onPathStart = onPathStart;
			this.onPathEnd = onPathEnd;
			this.onPickColor = onPickColor;
		}
	}
}