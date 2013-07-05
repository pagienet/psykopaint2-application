package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	import com.greensock.easing.Circ;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Quart;
	import com.greensock.easing.Quint;
	
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
		
		
		private var minOffset:PsykoParameter;
		private var splatFactor:PsykoParameter;
		private var sizeFactor:PsykoParameter;
		private var offsetAngleRange:PsykoParameter;
		private var mappingMode:PsykoParameter;
		private var mappingFunction:PsykoParameter;
		private var angleAdjustment:PsykoParameter;
		
		private var rng:LCG;
		static private const mappingFunctions:Vector.<Function> = Vector.<Function>([Linear.easeNone,Quad.easeIn,Quad.easeInOut,Quad.easeOut, Quart.easeIn,Quart.easeInOut,Quart.easeOut, Quint.easeIn,Quint.easeInOut,Quint.easeOut,Expo.easeIn, Expo.easeInOut, Expo.easeOut, Circ.easeIn,Circ.easeInOut, Circ.easeOut ]);
		
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
			mappingMode  	  = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_MODE,0,["Speed","Size", "Pressure", "Fixed"]);
			mappingFunction   = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_OFFSET_MAPPING,1,["Linear","Quadratic In","Quadratic InOut","Quadratic Out","Quartic In","Quartic InOut","Quartic Out","Quintic In","Quintic InOut","Quintic Out","Expo In","Expo InOut","Expo Out","Circular In","Circular InOut","Circular Out"]);
			
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
			var pi2:Number = Math.PI*  0.5;
			var pi3:Number = Math.PI * 1.5;
			var mapIndex:int = mappingMode.index;
			var mf:Function = mappingFunctions[mappingFunction.index];
			var oar:Number = offsetAngleRange.numberValue;
			var aaj:Number = angleAdjustment.numberValue;
			
			for ( var i:int = 0; i < points.length; i++ )
			{
				var point:SamplePoint = points[i];
				var angle:Number = point.angle + aaj + rng.getNumber(-oar,oar) + (rng.getChance() ? pi2 : pi3);
				var offset:Number =  rng.getMappedNumber(0, 1, mf );
				
				var distance:Number =  minOffset.numberValue + splatFactor.numberValue * offset * [point.speed, point.size, point.pressure / 2000, 1][mapIndex]; 
				point.x  +=  Math.cos(angle) * distance;
				point.y  +=  Math.sin(angle) * distance;
				point.size *=  1 - Math.min(1,sizeFactor.numberValue *  offset) ; 
				point.angle += rng.getNumber(-manager.brushAngleRange,manager.brushAngleRange);
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