package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;

	final public class SpawnDecorator extends AbstractPointDecorator
	{
		
		public static const PARAMETER_IR_MULTIPLES:String = "Multiples";
		public static const PARAMETER_N_MAXIMUM_OFFSET:String = "Maximum Offset";
		public static const PARAMETER_SL_OFFSET_MODE:String = "Offset Mode";
		public static const PARAMETER_AR_OFFSET_ANGLE:String = "Offset Angle";
		public static const PARAMETER_AR_BRUSH_ANGLE_VARIATION:String = "Brush Angle Variation";
		public static const PARAMETER_NR_BRISTLE_VARIATION:String = "Bristle Variation";
		public static const PARAMETER_B_AUTOROTATE:String = "Auto Rotate";
		public static const PARAMETER_N_MAXIMUM_SPEED:String = "Maximum Speed";
		public static const PARAMETER_N_MAXIMUM_SIZE:String = "Maximum Size";
		public static const PARAMETER_SL_MULTIPLE_MODE:String = "Multiples Mode";
		
		static public const INDEX_MODE_FIXED:int = 0;
		static public const INDEX_MODE_RANDOM:int = 1;
		static public const INDEX_MODE_SPEED:int = 2;
		static public const INDEX_MODE_PRESSURE_SPEED:int = 3;
		static public const INDEX_MODE_SIZE:int = 4;
		static public const INDEX_MODE_SIZE_INV:int = 5;
		
		
		
		private var multiples:PsykoParameter;
		private var maxOffset:PsykoParameter;
		private var offsetMode:PsykoParameter;
		private var offsetAngleRange:PsykoParameter;
		private var brushAngleRange:PsykoParameter;
		private var bristleVariation:PsykoParameter;
		private var maxSpeed:PsykoParameter;
		private var maxSize:PsykoParameter;
		
		private var autorotate:PsykoParameter;
		private var multiplesMode:PsykoParameter;
		
		private var rng:LCG;
		private var swapVector:Vector.<SamplePoint>;
		
		public function SpawnDecorator()
		{
			super( );
			
			multiples       = new PsykoParameter( PsykoParameter.IntRangeParameter,PARAMETER_IR_MULTIPLES,1,4,1,16);
			maxOffset       = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_MAXIMUM_OFFSET,16,0,100);
			offsetMode      = new PsykoParameter( PsykoParameter.StringListParameter, PARAMETER_SL_OFFSET_MODE,2,["Fixed","Random","Speed","Pressure/Speed","Size","Size Inverse"]);
			multiplesMode   = new PsykoParameter( PsykoParameter.StringListParameter, PARAMETER_SL_MULTIPLE_MODE,5,["Fixed","Random","Speed","Pressure/Speed","Size","Size Inverse"]);
			
			offsetAngleRange  = new PsykoParameter( PsykoParameter.AngleRangeParameter, PARAMETER_AR_OFFSET_ANGLE,0,0,-180,180);
			brushAngleRange  = new PsykoParameter( PsykoParameter.AngleRangeParameter, PARAMETER_AR_BRUSH_ANGLE_VARIATION,0,0,-180,180);
			bristleVariation  = new PsykoParameter( PsykoParameter.NumberParameter, PARAMETER_NR_BRISTLE_VARIATION,1,0,1);
			autorotate      = new PsykoParameter( PsykoParameter.BooleanParameter, PARAMETER_B_AUTOROTATE,1);
			maxSpeed   		= new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_MAXIMUM_SPEED,20,1,100);
			maxSize   		= new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_MAXIMUM_SIZE,1,0,1);
			
			_parameters.push(  multiples,multiplesMode, maxOffset, offsetMode, offsetAngleRange, brushAngleRange, bristleVariation,maxSpeed,autorotate,maxSize);
			rng = new LCG(Math.random() * 0xffffffff);
			swapVector = new Vector.<SamplePoint>()
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var result:Vector.<SamplePoint> = swapVector;
			
			var count:int = points.length;
			var ms:Number = maxSpeed.numberValue;
			var ar:Boolean = autorotate.booleanValue;
			var mapIndex:int = multiplesMode.index;
			var msz:Number = maxSize.numberValue;
			for ( var j:int = 0; j < count; j++ )
			{
				var point:SamplePoint =  points[j];
				var spawnCount:int =  multiples.lowerRangeValue + multiples.rangeValue * [1,Math.random(), point.speed / 25, point.pressure > 0 ? point.pressure / 1200 : point.speed / 25, point.size, Math.max(0,msz - point.size) / msz][mapIndex]; 
				
				//trace(spawnCount, point.size);
				
				var distance:Number = 2 * maxOffset.numberValue / spawnCount;
				switch ( offsetMode.index )
				{
					case 1:
						distance *= rng.getNumber();
					break;
					case 2:
						distance *=  points[j].speed / ms;
						break;
					case 3:
						if ( points[j].pressure > 0 )
						{
							distance *= points[j].pressure / 2000;
						} else {
							distance *=  points[j].speed / ms;
						}
						break;
				}
				
				for ( var i:int = 0; i < spawnCount; i++ )
				{
					var p:SamplePoint = points[j].getClone();
					var offsetAngle:Number = ((ar ? p.angle + Math.PI * 0.5 : 0 ) +  rng.getNumber( offsetAngleRange.lowerRangeValue, offsetAngleRange.upperRangeValue ));
					var radius:Number = (i-spawnCount/2) * distance + rng.getNumber(-distance,distance)*0.5*bristleVariation.numberValue;
					p.angle += rng.getNumber( brushAngleRange.lowerRangeValue, brushAngleRange.upperRangeValue );
					p.x +=  Math.cos(offsetAngle) * radius; 
					p.y +=  Math.sin(offsetAngle) * radius; 
					result.push(p );
				}
				PathManager.recycleSamplePoint(points[j]);
			}
			points.length = 0;
			swapVector = points;
			return result;
		}
		
		override public function getParameterSetAsXML(path:Array):XML
		{
			var result:XML = <SpawnDecorator/>;
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				result.appendChild( _parameters[i].toXML(path) );
			}
			return result;
		}
	}
}