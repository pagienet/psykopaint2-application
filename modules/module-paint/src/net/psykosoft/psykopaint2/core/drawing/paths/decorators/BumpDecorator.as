package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	
	import com.greensock.easing.Circ;
	import com.greensock.easing.CircQuad;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Quart;
	import com.greensock.easing.Quint;
	import com.greensock.easing.Sine;
	import com.greensock.easing.Strong;
	import com.quasimondo.geom.ColorMatrix;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManagerCallbackInfo;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	
	
	final public class BumpDecorator extends AbstractPointDecorator
	{
		
		public static const PARAMETER_N_SHININESS : String = "Shininess";
		public static const PARAMETER_N_GLOSSINESS : String = "Glossiness";
		public static const PARAMETER_N_BUMPINESS : String = "Bumpiness";
		public static const PARAMETER_N_BUMPINESS_RANGE : String = "Bumpiness Range";
		public static const PARAMETER_N_BUMP_INFLUENCE : String = "Bump Influence";
		static public const PARAMETER_SL_MODE:String = "Mode";
		static public const PARAMETER_NR_FACTOR:String = "Factor";
		static public const PARAMETER_SL_MAPPING:String = "Mapping";
		static public const PARAMETER_B_INVERT_MAPPING:String = "Invert Mapping";
		static public const PARAMETER_N_MAXIMUM_SPEED:String  = "Maximum Speed";
		static public const PARAMETER_N_NO_BUMP_PROB:String  = "No Bump Probability";
		
		static public const INDEX_MODE_FIXED:int = 0;
		static public const INDEX_MODE_SPEED:int = 1;
		static public const INDEX_MODE_PRESSURE:int = 2;
		static public const INDEX_MODE_PRESSURE_SPEED:int = 3;
		static public const INDEX_MODE_MULTIPLY:int = 4;
		static public const INDEX_MODE_ADD:int = 5;
		static public const INDEX_MODE_RANDOM:int = 6;
		static public const INDEX_MODE_RANDOM2:int = 7;
		
		private const _applyArray:Array = [0,0,1,1];
		
		public var param_shininess:PsykoParameter;
		public var param_glossiness:PsykoParameter;
		public var param_bumpiness:PsykoParameter;
		public var param_bumpinessRange:PsykoParameter;
		public var param_bumpInfluence:PsykoParameter;
		public var param_mappingMode:PsykoParameter;
		public var param_mappingFactor:PsykoParameter;
		public var param_mappingFunction:PsykoParameter;
		public var param_invertMapping:PsykoParameter;
		public var param_noBumpProbability:PsykoParameter;
		public var param_maxSpeed:PsykoParameter;
		
		public function BumpDecorator()
		{
			super();
			
			param_mappingMode  	 = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_MODE,0,["Fixed","Speed","Pressure","Automatic","Multiply","Add","Random","Random 2"]);
			param_mappingFactor   = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_NR_FACTOR,0,1,0,1);
			param_mappingFunction   = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_MAPPING,0,mappingFunctionLabels);
			param_invertMapping   = new PsykoParameter( PsykoParameter.BooleanParameter,PARAMETER_B_INVERT_MAPPING,0);
			param_maxSpeed   		= new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_MAXIMUM_SPEED,20,1,100);
			
			param_shininess     = new PsykoParameter( PsykoParameter.NumberParameter,      PARAMETER_N_SHININESS, 0.4, 0, 5);
			param_glossiness    = new PsykoParameter( PsykoParameter.NumberParameter,      PARAMETER_N_GLOSSINESS, 0.4, 0.01, 5);
			param_bumpiness     = new PsykoParameter( PsykoParameter.NumberParameter, PARAMETER_N_BUMPINESS, 1, -10, 10 );
			param_bumpinessRange  = new PsykoParameter( PsykoParameter.NumberParameter, PARAMETER_N_BUMPINESS_RANGE, 0.2, 0, 10 );
			param_bumpInfluence = new PsykoParameter( PsykoParameter.NumberParameter,      PARAMETER_N_BUMP_INFLUENCE, 0.6, -5, 5 );
			param_noBumpProbability     = new PsykoParameter( PsykoParameter.NumberParameter, PARAMETER_N_NO_BUMP_PROB, 0.5, 0, 1 );
			_parameters.push(param_shininess, param_glossiness, param_bumpiness, param_bumpinessRange,param_bumpInfluence, param_mappingMode,param_mappingFactor,param_mappingFunction,param_invertMapping,param_maxSpeed,param_noBumpProbability);
			
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var applyArray:Array = _applyArray;
			
			var mode:int = param_mappingMode.index;
			var minFactor:Number = param_mappingFactor.lowerRangeValue;
			var maxFactor:Number = param_mappingFactor.upperRangeValue;
			
			var mapping:Function = mappingFunctions[param_mappingFunction.index];
			var ms:Number = param_maxSpeed.numberValue;
			var inv:Boolean = param_invertMapping.booleanValue;
			var nbp:Number = param_noBumpProbability.numberValue;
			for ( var i:int = 0; i < points.length; i++ )
			{
				var point:SamplePoint = points[i];
				var bumpFactors:Vector.<Number> = point.bumpFactors;
				var bmp:Number = bumpFactors[1];
				if ( mode == 0)
				{
					bmp = param_mappingFactor.randomValue;
				} else if ( mode == 1 )
				{
					applyArray[0] = Math.min(point.speed,ms) / ms;
					bmp = mapping.apply( null, applyArray);
					if ( inv ) bmp = 1 -bmp;
					bmp = minFactor + bmp * (maxFactor - minFactor );
				}  else if ( mode == 2 )
				{
					if ( point.pressure > 0 )
					{
						applyArray[0] = point.pressure / 2000;
						bmp = mapping.apply( null, applyArray);
						if ( inv ) bmp = 1 - bmp;
						bmp = minFactor + bmp * (maxFactor - minFactor );
					} else {
						bmp = minFactor;
					}
				} else if ( mode == 3 )
				{
					if ( point.pressure > 0 )
					{
						applyArray[0] = point.pressure / 2000;
						bmp = mapping.apply( null, applyArray);
					} else {
						applyArray[0] = Math.min(point.speed,ms) / ms;
						bmp = mapping.apply( null, applyArray);
					}
					if ( inv ) bmp = 1 - bmp;
					bmp = minFactor + bmp * (maxFactor - minFactor );
				}  else if ( mode == 4 )
				{
					bmp *= param_mappingFactor.randomValue;
				} else if ( mode == 5 )
				{
					bmp += param_mappingFactor.randomValue;
				}  else if ( mode == 6 )
				{
					bmp = param_mappingFactor.randomValue;
				} else if ( mode == 7 )
				{
					bmp = Math.random() < nbp ? 0 : param_mappingFactor.randomValue;
				} 
				//MATHIEU I ADDED THE "1-" TO MAKE A HIGHER NUMBER THE GLOSSIER... SINCE DAVID IS NOT CONVINVED IT's INVERTED
				bumpFactors[0] = bumpFactors[4] = bumpFactors[8]  = bumpFactors[12] = 1-param_glossiness.numberValue;
				bumpFactors[1] = bumpFactors[5] = bumpFactors[9]  = bumpFactors[13] = param_bumpiness.numberValue - param_bumpinessRange.numberValue + (  param_bumpinessRange.numberValue * 2 * bmp );
				bumpFactors[2] = bumpFactors[6] = bumpFactors[10] = bumpFactors[14] = param_shininess.numberValue;
				bumpFactors[3] = bumpFactors[7] = bumpFactors[11] = bumpFactors[15] = param_bumpInfluence.numberValue;
			}
			
			
			return points;
		}
		
		override public function getParameterSetAsXML( path:Array ):XML
		{
			var data:XML = <BumpDecorator />;
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				data.appendChild( _parameters[i].toXML(path) );
			}
			return data;
		}
		
	}
}