package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	
	final public class LimiterDecorator extends AbstractPointDecorator
	{
		static public const PARAMETER_I_MAX_POINTS:String = "Maximum Points";
		private var maxPointCount:PsykoParameter;
		
		public function LimiterDecorator( )
		{
			super( );
			maxPointCount    = new PsykoParameter( PsykoParameter.IntParameter,PARAMETER_I_MAX_POINTS,50,1,100);
			
			_parameters.push( maxPointCount);
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var mp:int = maxPointCount.intValue;
			while ( points.length > mp )
			{
				PathManager.recycleSamplePoint( points.splice( int(Math.random() * points.length),1)[0]);
			}
			return points;
		}
		
		override public function getParameterSetAsXML(path:Array ):XML
		{
			var result:XML = <LimiterDecorator/>;
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				result.appendChild( _parameters[i].toXML(path) );
			}
			return result;
		}
	}
}