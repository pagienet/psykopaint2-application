package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	import com.greensock.easing.Circ;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Quart;
	import com.greensock.easing.Quint;
	import com.greensock.easing.Sine;
	import com.greensock.easing.Strong;
	import com.greensock.easing.CircQuad;
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;

	final public class SizeDecorator extends AbstractPointDecorator
	{
		static public const PARAMETER_SL_MODE:String = "Mode";
		static public const PARAMETER_N_FACTOR:String = "Factor";
		static public const PARAMETER_N_RANGE:String = "Range";
		
		static public const PARAMETER_SL_MAPPING:String = "Mapping";
		static public const PARAMETER_B_INVERT_MAPPING:String = "Invert Mapping";
		static public const PARAMETER_N_MAXIMUM_SPEED:String  = "Maximum Speed";
		
		static public const INDEX_MODE_FIXED:int = 0;
		static public const INDEX_MODE_SPEED:int = 1;
		static public const INDEX_MODE_PRESSURE_SPEED:int = 2;
		static public const INDEX_MODE_MULTIPLY:int = 3;
		static public const INDEX_MODE_ADD:int = 4;
		
		static public const INDEX_MAPPING_LINEAR:int = 0;
		static public const INDEX_MAPPING_CIRCQUAD:int = 1;
		static public const INDEX_MAPPING_CIRCULAR:int = 2;
		static public const INDEX_MAPPING_SINE:int = 3;
		static public const INDEX_MAPPING_QUADRATIC:int =4;
		static public const INDEX_MAPPING_CUBIC:int = 5;
		static public const INDEX_MAPPING_QUARTIC:int = 6;
		static public const INDEX_MAPPING_QUINTIC:int = 7;
		static public const INDEX_MAPPING_STRONG:int = 8;
		static public const INDEX_MAPPING_EXPONENTIAL:int = 9;
		
		private const _applyArray:Array = [0,0,1,1];
		
		private var mappingMode:PsykoParameter;
		private var mappingFactor:PsykoParameter;
		private var mappingRange:PsykoParameter;
		private var mappingFunction:PsykoParameter;
		private var invertMapping:PsykoParameter;
		private var maxSpeed:PsykoParameter;
		
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
		
		public function SizeDecorator()
		{
			super();
			mappingMode  	 = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_MODE,INDEX_MODE_FIXED,["Fixed","Speed","Pressure/Speed","Multiply","Add"]);
			mappingFactor   = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_FACTOR,0.5,0,1);
			mappingRange   = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_RANGE,0.5,0,1);
			
			mappingFunction   = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_MAPPING,INDEX_MAPPING_LINEAR,["Linear",
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
			
			_parameters.push(mappingMode,mappingFactor,mappingRange,mappingFunction,invertMapping,maxSpeed );
			
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var applyArray:Array = _applyArray;
			var mode:int = mappingMode.index;
			var minFactor:Number = mappingFactor.numberValue - mappingRange.numberValue;
			if ( minFactor < 0 ) minFactor = 0;
			if ( minFactor > 1 ) minFactor = 1;
			var maxFactor:Number = mappingFactor.numberValue + mappingRange.numberValue;
			if ( maxFactor < 0 ) maxFactor = 0;
			if ( maxFactor > 1 ) maxFactor = 1;
			
			var mapping:Function = mappingFunctions[mappingFunction.index];
			var ms:Number = maxSpeed.numberValue;
			var inv:Boolean = invertMapping.booleanValue;
			for ( var i:int = 0; i < points.length; i++ )
			{
				var point:SamplePoint = points[i];
				if ( mode == 0)
				{
					point.size =  minFactor + Math.random() * (maxFactor - minFactor );
				} else if ( mode == 1 )
				{
					applyArray[0] = Math.min(point.speed,ms) / ms;
					point.size = mapping.apply( null, applyArray);
					if ( inv ) point.size = 1 - point.size;
					point.size = minFactor + point.size * (maxFactor - minFactor );
				}  else if ( mode == 2 )
				{
					if ( point.pressure > 0 )
					{
						applyArray[0] = point.pressure / 2000;
						point.size = mapping.apply( null, applyArray);
					} else {
						applyArray[0] = Math.min(point.speed,ms) / ms;
						point.size = mapping.apply( null, applyArray);
					}
					if ( inv ) point.size = 1 - point.size;
					point.size = minFactor + point.size * (maxFactor - minFactor );
				}  else if ( mode == 3 )
				{
					point.size *=  minFactor + Math.random() * (maxFactor - minFactor );
				} else if ( mode == 4 )
				{
					point.size *=  minFactor + Math.random() * (maxFactor - minFactor );
				} 
			}
			return points;
		}
		
		override  public function getParameterSetAsXML( path:Array ):XML
		{
			var result:XML = <SizeDecorator/>;
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				result.appendChild( _parameters[i].toXML(path) );
			}
			return result;
		}
	}
}