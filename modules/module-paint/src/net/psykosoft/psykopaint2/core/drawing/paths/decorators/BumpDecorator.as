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
		public static const PARAMETER_NR_BUMPINESS : String = "Bumpiness";
		public static const PARAMETER_N_BUMP_INFLUENCE : String = "Bump Influence";
		static public const PARAMETER_SL_MODE:String = "Mode";
		static public const PARAMETER_NR_FACTOR:String = "Factor";
		static public const PARAMETER_SL_MAPPING:String = "Mapping";
		static public const PARAMETER_B_INVERT_MAPPING:String = "Invert Mapping";
		static public const PARAMETER_N_MAXIMUM_SPEED:String  = "Maximum Speed";
		
		static public const MODE_INDEX_FIXED:int = 0;
		static public const MODE_INDEX_SPEED:int = 1;
		static public const MODE_INDEX_PRESSURE:int = 2;
		static public const MODE_INDEX_PRESSURE_SPEED:int = 3;
		static public const MODE_INDEX_MULTIPLY:int = 4;
		static public const MODE_INDEX_ADD:int = 5;
		
		
		private var shininess:PsykoParameter;
		private var glossiness:PsykoParameter;
		private var bumpiness:PsykoParameter;
		private var bumpInfluence:PsykoParameter;
		private var mappingMode:PsykoParameter;
		private var mappingFactor:PsykoParameter;
		private var mappingFunction:PsykoParameter;
		private var invertMapping:PsykoParameter;
		private var maxSpeed:PsykoParameter;
		
		private const _applyArray:Array = [0,0,1,1];
		
		
		
		
		static private const mappingFunctions:Vector.<Function> = Vector.<Function>([
			Linear.easeNone,
			CircQuad.easeIn,
			Circ.easeIn,
			Sine.easeIn,
			Quad.easeIn, 
			Cubic.easeIn, 
			Quart.easeIn, 
			Quint.easeIn,
			Strong.easeIn,
			Expo.easeIn
		]);
		
		
		public function BumpDecorator()
		{
			super();
			
			mappingMode  	 = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_MODE,0,["Fixed","Speed","Pressure","Automatic","Multiply","Add"]);
			mappingFactor   = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_NR_FACTOR,0,1,0,1);
			mappingFunction   = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_MAPPING,0,["Linear",
				"CircQuad",
				"Circular",
				"Sine",
				"Quadratic",
				"Cubic",
				"Quartic",
				"Quintic",
				"Strong",
				"Expo"]);
			invertMapping   = new PsykoParameter( PsykoParameter.BooleanParameter,PARAMETER_B_INVERT_MAPPING,0);
			maxSpeed   		= new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_MAXIMUM_SPEED,20,1,100);
			
			shininess     = new PsykoParameter( PsykoParameter.NumberParameter,      PARAMETER_N_SHININESS, 0.4, 0, 5);
			glossiness    = new PsykoParameter( PsykoParameter.NumberParameter,      PARAMETER_N_GLOSSINESS, 0.4, 0.01, 5);
			bumpiness     = new PsykoParameter( PsykoParameter.NumberRangeParameter, PARAMETER_NR_BUMPINESS, 0, 2, -10, 10 );
			bumpInfluence = new PsykoParameter( PsykoParameter.NumberParameter,      PARAMETER_N_BUMP_INFLUENCE, 0.6, -1, 1 );
			
			_parameters.push(shininess, glossiness, bumpiness, bumpInfluence, mappingMode,mappingFactor,mappingFunction,invertMapping,maxSpeed);
			
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var applyArray:Array = _applyArray;
			
			var mode:int = mappingMode.index;
			var minFactor:Number = mappingFactor.lowerRangeValue;
			var maxFactor:Number = mappingFactor.upperRangeValue;
			
			var mapping:Function = mappingFunctions[mappingFunction.index];
			var ms:Number = maxSpeed.numberValue;
			var inv:Boolean = invertMapping.booleanValue;
			;
			for ( var i:int = 0; i < points.length; i++ )
			{
				var point:SamplePoint = points[i];
				var bumpFactors:Vector.<Number> = point.bumpFactors;
				var bmp:Number = bumpFactors[1];
				if ( mode == 0)
				{
					bmp = mappingFactor.randomValue;
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
					bmp *= mappingFactor.randomValue;
				} else if ( mode == 5 )
				{
					bmp *= mappingFactor.randomValue;
				} 
				
				bumpFactors[0] = bumpFactors[4] = bumpFactors[8]  = bumpFactors[12] = glossiness.numberValue;
				bumpFactors[1] = bumpFactors[5] = bumpFactors[9]  = bumpFactors[13] = bumpiness.lowerRangeValue + (bumpiness.rangeValue * bmp );
				bumpFactors[2] = bumpFactors[6] = bumpFactors[10] = bumpFactors[14] = shininess.numberValue;
				bumpFactors[3] = bumpFactors[7] = bumpFactors[11] = bumpFactors[15] = bumpInfluence.numberValue;
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