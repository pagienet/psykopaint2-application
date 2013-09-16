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
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;

	final public class SplatterDecorator extends AbstractPointDecorator
	{
		
		public static const PARAMETER_SL_MODE:String = "Mode";
		public static const PARAMETER_SL_OFFSET_MAPPING:String = "Offset Mapping";
		public static const PARAMETER_N_SPLAT_FACTOR:String = "Splat Factor";
		public static const PARAMETER_N_MINIMUM_OFFSET:String = "Minimum Offset";
		public static const PARAMETER_A_OFFSET_ANGLE_RANGE:String = "Offset Angle Range";
		public static const PARAMETER_N_SIZE_FACTOR:String = "Size Factor";
		public static const PARAMETER_A_ANGLE_ADJUSTMENT:String = "Angle Adjustment";
		
		public static const INDEX_MODE_SPEED:int = 0;
		public static const INDEX_MODE_SIZE:int = 1;
		static public const INDEX_MODE_PRESSURE_SPEED:int = 2;
		public static const INDEX_MODE_FIXED:int = 3;
		
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
		
		private var minOffset:PsykoParameter;
		private var splatFactor:PsykoParameter;
		private var sizeFactor:PsykoParameter;
		private var offsetAngleRange:PsykoParameter;
		private var mappingMode:PsykoParameter;
		private var mappingFunction:PsykoParameter;
		private var angleAdjustment:PsykoParameter;
		
		private var rng:LCG;
		
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
		/*
			offsets the point based on its angle and speed
			
			splatFactor: maximum offset based on speed
			offsetAngleRange: random angle range around perpendicular angle
			brush angle range: random brush rotation range
			size factor: inverse speed multiplier based on offset distance (1 = the further the offset the smaller the size)
		*/

		public function SplatterDecorator()
		{
			super();
			mappingMode  	  = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_MODE,0,["Speed","Size", "Pressure/Speed", "Fixed"]);
			mappingFunction   = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_OFFSET_MAPPING,1,["Linear",
				"CircQuad",
				"Circular",
				"Sine",
				"Quadratic",
				"Cubic",
				"Quartic",
				"Quintic",
				"Strong",
				"Expo"]);
			
			splatFactor  	  = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_SPLAT_FACTOR,2,0,500);
			minOffset   	  = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_MINIMUM_OFFSET,2,0,64);
			offsetAngleRange  = new PsykoParameter( PsykoParameter.AngleParameter,PARAMETER_A_OFFSET_ANGLE_RANGE,15,0,180);
			sizeFactor 	      = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_SIZE_FACTOR,0.3,0,2);
			angleAdjustment   = new PsykoParameter( PsykoParameter.AngleParameter,PARAMETER_A_ANGLE_ADJUSTMENT,0,-180,180);
			_parameters.push(mappingMode,mappingFunction, splatFactor,minOffset,offsetAngleRange,sizeFactor,angleAdjustment );
			
			rng = new LCG( Math.random() * 0xffffff );
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var pi2:Number   = Math.PI*  0.5;
			var pi3:Number   = Math.PI * 1.5;
			var mapIndex:int = mappingMode.index;
			var mf:Function  = mappingFunctions[mappingFunction.index];
			var oar:Number   = offsetAngleRange.numberValue;
			var aaj:Number   = angleAdjustment.numberValue;
			var sf:Number    = sizeFactor.numberValue;
			var bar:Number   = manager.brushAngleRange;
			var spf:Number   = splatFactor.numberValue;
			var mo:Number    = minOffset.numberValue;
			
			for ( var i:int = 0; i < points.length; i++ )
			{
				var point:SamplePoint = points[i];
				var angle:Number = point.angle + aaj + rng.getNumber(-oar,oar) + (rng.getChance() ? pi2 : pi3);
				var offset:Number =  rng.getMappedNumber(0, 1, mf );
				
				var distance:Number =  mo + spf * offset * [point.speed / 25, point.size, point.pressure > 0 ? point.pressure / 1200 : point.speed / 25, 1][mapIndex]; 
				point.x  +=  Math.cos(angle) * distance;
				point.y  +=  Math.sin(angle) * distance;
				point.size *=  1 - Math.min(1,sf * offset) ; 
				point.angle += rng.getNumber(-bar,bar);
			}
			return points;
		}
		
		override  public function getParameterSetAsXML( path:Array ):XML
		{
			var result:XML = <SplatterDecorator/>;
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				result.appendChild( _parameters[i].toXML(path) );
			}
			return result;
		}
	}
}