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
		
		
		
		
		private const _applyArray:Array = [0,0,1,1];
		
		public var param_mappingMode:PsykoParameter;
		public var param_mappingFactor:PsykoParameter;
		public var param_mappingRange:PsykoParameter;
		public var param_mappingFunction:PsykoParameter;
		public var param_invertMapping:PsykoParameter;
		public var param_maxSpeed:PsykoParameter;
		
		public function SizeDecorator()
		{
			super();
			param_mappingMode  	 = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_MODE,INDEX_MODE_FIXED,["Fixed","Speed","Pressure/Speed","Multiply","Add"]);
			param_mappingFactor   = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_FACTOR,0.5,0,1);
			param_mappingRange   = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_RANGE,0.5,0,1);
			
			param_mappingFunction   = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_MAPPING,INDEX_MAPPING_LINEAR,mappingFunctionLabels);
			param_invertMapping   = new PsykoParameter( PsykoParameter.BooleanParameter,PARAMETER_B_INVERT_MAPPING,0);
			param_maxSpeed   		= new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_MAXIMUM_SPEED,20,1,200);
			
			_parameters.push(param_mappingMode,param_mappingFactor,param_mappingRange,param_mappingFunction,param_invertMapping,param_maxSpeed );
			
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var applyArray:Array = _applyArray;
			var mode:int = param_mappingMode.index;
			var minFactor:Number = param_mappingFactor.numberValue - param_mappingRange.numberValue;
			if ( minFactor < 0 ) minFactor = 0;
			if ( minFactor > 1 ) minFactor = 1;
			var maxFactor:Number = param_mappingFactor.numberValue + param_mappingRange.numberValue;
			if ( maxFactor < 0 ) maxFactor = 0;
			if ( maxFactor > 1 ) maxFactor = 1;
			
			var mapping:Function = mappingFunctions[param_mappingFunction.index];
			var ms:Number = param_maxSpeed.numberValue;
			var inv:Boolean = param_invertMapping.booleanValue;
			for ( var i:int = 0; i < points.length; i++ )
			{
				var point:SamplePoint = points[i];
				if ( mode == INDEX_MODE_FIXED)
				{
					point.size =  minFactor + Math.random() * (maxFactor - minFactor );
				} else if ( mode == INDEX_MODE_SPEED )
				{
					applyArray[0] = Math.min(point.speed,ms) / ms;
					point.size = mapping.apply( null, applyArray);
					if ( inv ) point.size = 1 - point.size;
					point.size = minFactor + point.size * (maxFactor - minFactor );
				}  else if ( mode == INDEX_MODE_PRESSURE_SPEED )
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
				}  else if ( mode == INDEX_MODE_MULTIPLY )
				{
					point.size *=  minFactor + Math.random() * (maxFactor - minFactor );
				} else if ( mode == INDEX_MODE_ADD )
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