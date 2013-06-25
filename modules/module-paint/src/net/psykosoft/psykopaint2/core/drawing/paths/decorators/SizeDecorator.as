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
		static public const PARAMETER_NR_FACTOR:String = "Factor";
		static public const PARAMETER_SL_MAPPING:String = "Mapping";
		static public const PARAMETER_B_INVERT_MAPPING:String = "Invert Mapping";
		static public const PARAMETER_N_MAXIMUM_SPEED:String  = "Maximum Speed";
		
		
		private var mappingMode:PsykoParameter;
		private var mappingFactor:PsykoParameter;
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
			
			_parameters.push(mappingMode,mappingFactor,mappingFunction,invertMapping,maxSpeed );
			
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var mode:int = mappingMode.index;
			var minFactor:Number = mappingFactor.lowerRangeValue;
			var maxFactor:Number = mappingFactor.upperRangeValue;
			
			var mapping:Function = mappingFunctions[mappingFunction.index];
			var ms:Number = maxSpeed.numberValue;
			var inv:Boolean = invertMapping.booleanValue;
			for ( var i:int = 0; i < points.length; i++ )
			{
				var point:SamplePoint = points[i];
				if ( mode == 0)
				{
					point.size = mappingFactor.randomValue;
				} else if ( mode == 1 )
				{
					point.size = mapping.apply( null, [Math.min(point.speed,ms) / ms,0,1,1]);
					if ( inv ) point.size = 1 - point.size;
					point.size = minFactor + point.size * (maxFactor - minFactor );
				}  else if ( mode == 2 )
				{
					if ( point.pressure > 0 )
					{
						point.size = mapping.apply( null, [point.pressure / 2000,0,1,1]);
						if ( inv ) point.size = 1 - point.size;
						point.size = minFactor + point.size * (maxFactor - minFactor );
					} else {
						point.size = minFactor;
					}
				} else if ( mode == 3 )
				{
					if ( point.pressure > 0 )
					{
						point.size = mapping.apply( null, [point.pressure / 2000,0,1,1]);
					} else {
						point.size = mapping.apply( null, [Math.min(point.speed,ms) / ms,0,1,1]);
					}
					if ( inv ) point.size = 1 - point.size;
					point.size = minFactor + point.size * (maxFactor - minFactor );
				}  else if ( mode == 4 )
				{
					point.size *= mappingFactor.randomValue;
				} else if ( mode == 5 )
				{
					point.size *= mappingFactor.randomValue;
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