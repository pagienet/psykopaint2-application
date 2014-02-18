package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	
	final public class OrderDecorator extends AbstractPointDecorator
	{
		static public const PARAMETER_I_BUFFER_SIZE:String = "Buffer Size";
		
		private var rng:LCG;
		private var buffer:Vector.<SamplePoint>;
		
		public var param_bufferSize:PsykoParameter;
		
		public function OrderDecorator( )
		{
			super( );
			buffer = new Vector.<SamplePoint>();
			param_bufferSize   	 = new PsykoParameter( PsykoParameter.IntParameter,"Buffer Size",8,0,50);
			
			_parameters.push( param_bufferSize);
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			if ( points.length > 0 )
			{
				for ( var i:int = 0; i < points.length; i++ )
				{
					buffer.splice(int((buffer.length >> 1) + Math.random() * (buffer.length >> 1)), 0, points[i] );
				}
				points.length = 0;
				while ( buffer.length > param_bufferSize.intValue )
				{
					points.push( buffer.splice( int(Math.random() * (buffer.length >> 1)), 1 )[0])
				}
			} else if ( buffer.length > 0 )
			{
				var count:int = 1 + Math.random() * (buffer.length-1);
				while ( count-- > 0 )
					points.push( buffer.splice(int(Math.random() * (buffer.length >> 1)), 1 )[0])
			}
			return points;
		}
		
		override public function getParameterSetAsXML(path:Array ):XML
		{
			var result:XML = <OrderDecorator/>;
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				result.appendChild( _parameters[i].toXML(path) );
			}
			return result;
		}
		
		override public function hasActivePoints():Boolean
		{
			return buffer.length > 0;
		}
		
		
	}
}