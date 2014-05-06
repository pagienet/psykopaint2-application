package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;

	/* makes copies of the current point and distributes them within a given offset range */

	final public class SpawnDecorator extends AbstractPointDecorator
	{
		
		public static const PARAMETER_IR_MULTIPLES:String = "Multiples";
		public static const PARAMETER_N_MINIMUM_OFFSET:String = "Minimum Offset";
		public static const PARAMETER_N_MAXIMUM_OFFSET:String = "Maximum Offset";
		public static const PARAMETER_SL_OFFSET_MODE:String = "Offset Mode";
		public static const PARAMETER_AR_OFFSET_ANGLE:String = "Offset Angle";
		public static const PARAMETER_AR_BRUSH_ANGLE_VARIATION:String = "Brush Angle Variation";
		public static const PARAMETER_N_BRISTLE_VARIATION:String = "Bristle Variation";
		public static const PARAMETER_B_AUTOROTATE:String = "Auto Rotate";
		public static const PARAMETER_N_MAXIMUM_SPEED:String = "Maximum Speed";
		public static const PARAMETER_N_MAXIMUM_SIZE:String = "Maximum Size";
		public static const PARAMETER_SL_MULTIPLE_MODE:String = "Multiples Mode";
		
		static public const INDEX_MODE_FIXED:int = 0;
		static public const INDEX_MODE_RANDOM:int = 1;
		static public const INDEX_MODE_SPEED:int = 2;
		static public const INDEX_MODE_SPEED_INV:int = 6;
		static public const INDEX_MODE_PRESSURE_SPEED:int = 3;
		static public const INDEX_MODE_SIZE:int = 4;
		static public const INDEX_MODE_SIZE_INV:int = 5;
		
		
		
		public var param_multiples:PsykoParameter;
		public var param_minOffset:PsykoParameter;
		public var param_maxOffset:PsykoParameter;
		public var param_offsetMode:PsykoParameter;
		public var param_offsetAngleRange:PsykoParameter;
		/* USE lowerRangeValue AND upperRangeValue IN DEGREES */
		public var param_brushAngleRange:PsykoParameter;
		public var param_bristleVariation:PsykoParameter;
		public var param_maxSpeed:PsykoParameter;
		/* LIMITING THE OVERALL SIZE OF THE SPREAD OF THE SPAWN  */
		public var param_maxSize:PsykoParameter;
		public var param_autorotate:PsykoParameter;
		public var param_multiplesMode:PsykoParameter;
		
		private var swapVector:Vector.<SamplePoint>;
		
		public function SpawnDecorator()
		{
			super( );
			
			param_multiples       = new PsykoParameter( PsykoParameter.IntRangeParameter,PARAMETER_IR_MULTIPLES,1,4,1,16);
			param_minOffset       = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_MINIMUM_OFFSET,0,0,100);
			param_maxOffset       = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_MAXIMUM_OFFSET,16,0,100);
			param_offsetMode      = new PsykoParameter( PsykoParameter.StringListParameter, PARAMETER_SL_OFFSET_MODE,2,["Fixed","Random","Speed","Speed Inverse","Pressure/Speed","Size","Size Inverse"]);
			param_multiplesMode   = new PsykoParameter( PsykoParameter.StringListParameter, PARAMETER_SL_MULTIPLE_MODE,5,["Fixed","Random","Speed","Speed Inverse","Pressure/Speed","Size","Size Inverse"]);
			
			param_offsetAngleRange  = new PsykoParameter( PsykoParameter.AngleRangeParameter, PARAMETER_AR_OFFSET_ANGLE,0,0,-180,180);
			param_brushAngleRange  = new PsykoParameter( PsykoParameter.AngleRangeParameter, PARAMETER_AR_BRUSH_ANGLE_VARIATION,0,0,-180,180);
			param_bristleVariation  = new PsykoParameter( PsykoParameter.NumberParameter, PARAMETER_N_BRISTLE_VARIATION,1,0,1);
			param_autorotate      = new PsykoParameter( PsykoParameter.BooleanParameter, PARAMETER_B_AUTOROTATE,1);
			param_maxSpeed   		= new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_MAXIMUM_SPEED,20,1,100);
			param_maxSize   		= new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_MAXIMUM_SIZE,1,0,1);
			
			_parameters.push(  param_multiples,param_multiplesMode, param_minOffset, param_maxOffset, param_offsetMode, param_offsetAngleRange, param_brushAngleRange, param_bristleVariation,param_maxSpeed,param_autorotate,param_maxSize);
			swapVector = new Vector.<SamplePoint>()
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var result:Vector.<SamplePoint> = swapVector;
			
			var count:int = points.length;
			var ms:Number = param_maxSpeed.numberValue;
			var ar:Boolean = param_autorotate.booleanValue;
			var mapIndex:int = param_multiplesMode.index;
			var msz:Number = param_maxSize.numberValue;
			var c:int = 0;
			
			var oar_lrng:Number = param_offsetAngleRange.lowerRangeValue;
			var oar_rng:Number = param_offsetAngleRange.rangeValue;
			var bn:Number = param_bristleVariation.numberValue;
			var bar_rng:Number = param_brushAngleRange.rangeValue;
			var bar_lrng:Number = param_brushAngleRange.lowerRangeValue;
			
			for ( var j:int = 0; j < count; j++ )
			{
				var point:SamplePoint =  points[j];
				var spawnCount:int =  param_multiples.lowerRangeValue + param_multiples.rangeValue * [1/* fixed */,Math.random()/* random */, point.speed / 25 /* speed */, Math.max(0,msz - (point.speed / 25)) / msz  /* speed inverted*/, point.pressure > 0 ? point.pressure / 1200 : point.speed / 25, point.size, Math.max(0,msz - point.size) / msz][mapIndex]; 
				
				//trace(spawnCount, point.size);
				var offsetRange:Number = param_maxOffset.numberValue - param_minOffset.numberValue;
				var distance:Number = _scalingFactor * 2 * offsetRange / spawnCount;
				switch ( param_offsetMode.index )
				{
					case INDEX_MODE_RANDOM:
						distance *= Math.random();
					break;
					case INDEX_MODE_SPEED:
						distance *=  points[j].speed / ms;
						break;
					case INDEX_MODE_SPEED_INV:
						distance /=  points[j].speed / ms;
						break;
					case INDEX_MODE_PRESSURE_SPEED:
						if ( points[j].pressure > 0 )
						{
							distance *= points[j].pressure / 2000;
						} else {
							distance *=  points[j].speed / ms;
						}
						break;
				}
				
				distance += param_minOffset.numberValue;
				
				for ( var i:int = 0; i < spawnCount; i++ )
				{
					var p:SamplePoint = points[j].getClone();
					var offsetAngle:Number = ((ar ? p.angle + Math.PI * 0.5 : 0 ) + Math.random() * oar_rng + oar_lrng);
					var radius:Number = (i-spawnCount/2) * distance + (Math.random()-Math.random()) * distance*0.5*bn;
					p.angle +=  (Math.random() * bar_rng + bar_lrng);
					p.x +=  Math.cos(offsetAngle) * radius; 
					p.y +=  Math.sin(offsetAngle) * radius; 
					result[c++] = p;
				}
				PathManager.recycleSamplePoint(points[j]);
			}
			//points.length = 0;
			
			result.length = c;
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