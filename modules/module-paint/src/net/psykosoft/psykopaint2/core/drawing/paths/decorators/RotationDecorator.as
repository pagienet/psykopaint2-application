package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	
	
	final public class RotationDecorator extends AbstractPointDecorator
	{
		private var rng:LCG;
		
		//"Angle Adjustment" - NumberRangeValue
		//adds a random rotation within the given range to the current rotation value of a SamplePoint
		public var param_angleAdjustment:PsykoParameter;
		
		public function RotationDecorator( minAdjustmentAngle:Number = -1.5707963267948966192313216916398, maxAdjustmentAngle:Number = 1.5707963267948966192313216916398 )
		{
			super();
			this.param_angleAdjustment  = new PsykoParameter( PsykoParameter.NumberRangeParameter,"Angle Adjustment",minAdjustmentAngle,maxAdjustmentAngle,- Math.PI, Math.PI);
			_parameters.push(this.param_angleAdjustment);
			rng = new LCG(Math.random() * 0xffffffff);
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean ):Vector.<SamplePoint>
		{
			for ( var i:int = 0; i < points.length; i++ )
			{
				points[i].angle += rng.getNumber( param_angleAdjustment.lowerRangeValue, param_angleAdjustment.upperRangeValue );
			}
			return points;
		}
		
		override public function getParameterSetAsXML( path:Array ):XML
		{
			var data:XML = <RotationDecorator />;
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				data.appendChild( _parameters[i].toXML(path) );
			}
			return data;
		}
		
	}
}