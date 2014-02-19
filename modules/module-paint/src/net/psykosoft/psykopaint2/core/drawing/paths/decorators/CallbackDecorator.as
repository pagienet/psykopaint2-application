package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	
	final public class CallbackDecorator extends AbstractPointDecorator
	{
		private var callbackObject:Object;
		private var callbackFunction:Function;
		private var callbackArray:Array;
		
		public function CallbackDecorator( callbackObject:Object, callbackFunction:Function )
		{
			super( );
			this.callbackObject = callbackObject;
			this.callbackFunction = callbackFunction;
			callbackArray = [];
		}
		
		
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			callbackArray[0] = points;
			callbackArray[1] = manager;
			callbackArray[2] = fingerIsDown;
			
			return callbackFunction.apply(callbackObject,callbackArray);
		}
		
		override public function getParameterSetAsXML(path:Array ):XML
		{
			var result:XML = <CallbackDecorator/>;
			return result;
		}
	}
}