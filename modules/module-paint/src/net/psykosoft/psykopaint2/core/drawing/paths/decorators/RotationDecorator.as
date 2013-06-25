package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	
	
	final public class RotationDecorator extends AbstractPointDecorator
	{
		private var angleAdjustment:PsykoParameter;
		private var rng:LCG;
		
		public function RotationDecorator( minAdjustmentAngle:Number = -1.5707963267948966192313216916398, maxAdjustmentAngle:Number = 1.5707963267948966192313216916398 )
		{
			super();
			this.angleAdjustment  = new PsykoParameter( PsykoParameter.NumberRangeParameter,"Angle Adjustment",minAdjustmentAngle,maxAdjustmentAngle,- Math.PI, Math.PI);
			_parameters.push(this.angleAdjustment);
			rng = new LCG(Math.random() * 0xffffffff);
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean ):Vector.<SamplePoint>
		{
			for ( var i:int = 0; i < points.length; i++ )
			{
				points[i].angle += rng.getNumber( angleAdjustment.lowerRangeValue, angleAdjustment.upperRangeValue );
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