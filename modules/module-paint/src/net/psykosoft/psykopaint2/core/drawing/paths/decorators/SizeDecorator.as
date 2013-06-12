package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	import com.greensock.easing.Circ;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Quart;
	import com.greensock.easing.Quint;
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.base.remote.PsykoSocket;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;

	public class SizeDecorator extends AbstractPointDecorator
	{
		private var mappingMode:PsykoParameter;
		private var mappingFactor:PsykoParameter;
		private var mappingFunction:PsykoParameter;
		private var invertMapping:PsykoParameter;
		private var maxSpeed:PsykoParameter;
		
		private var rng:LCG;
		
		static private const mappingFunctions:Vector.<Function> = Vector.<Function>([Linear.easeNone,Quad.easeIn,Quad.easeInOut,Quad.easeOut, Quart.easeIn,Quart.easeInOut,Quart.easeOut, Quint.easeIn,Quint.easeInOut,Quint.easeOut,Expo.easeIn, Expo.easeInOut, Expo.easeOut, Circ.easeIn,Circ.easeInOut, Circ.easeOut ]);
		
		public function SizeDecorator()
		{
			super();
			mappingMode  	 = new PsykoParameter( PsykoParameter.StringListParameter,"Mode",0,["Fixed","Speed","Pressure"]);
			mappingFactor   = new PsykoParameter( PsykoParameter.NumberRangeParameter,"Factor",0,1,0,10);
			mappingFunction   = new PsykoParameter( PsykoParameter.StringListParameter,"Mapping",0,["Linear","Quadratic In","Quadratic InOut","Quadratic Out","Quartic In","Quartic InOut","Quartic Out","Quintic In","Quintic InOut","Quintic Out","Expo In","Expo InOut","Expo Out","Circular In","Circular InOut","Circular Out"]);
			invertMapping   = new PsykoParameter( PsykoParameter.BooleanParameter,"Invert Mapping",0);
			maxSpeed   		= new PsykoParameter( PsykoParameter.NumberParameter,"Maximum Speed",20,1,100);
			
			_parameters.push(mappingMode,mappingFactor,mappingFunction,invertMapping,maxSpeed );
			
			rng = new LCG( Math.random() * 0xffffff );
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
					point.size = rng.getNumber(minFactor,maxFactor );
				} else if ( mode == 1 )
				{
					point.size = mapping.apply( null, [Math.min(point.speed,maxSpeed.numberValue),0,ms,ms]);
					if ( inv ) point.size = ms - point.size;
					point.size = minFactor + point.size * (maxFactor - minFactor );
				}  else if ( mode == 2 )
				{
					if ( point.pressure != -1 )
					{
						
						point.size = mapping.apply( null, [point.pressure / 2000,0,1,1]);
						if ( inv ) point.size = 1 - point.size;
						point.size = minFactor + point.size * (maxFactor - minFactor );
					} else {
						point.size = rng.getNumber(minFactor,maxFactor );
					}
				}
			}
			return points;
		}
		
		override  public function getParameterSet( path:Array ):XML
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