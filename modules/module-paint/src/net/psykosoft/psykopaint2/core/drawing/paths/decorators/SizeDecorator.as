package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	import com.greensock.easing.Circ;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;

	public class SizeDecorator extends AbstractPointDecorator
	{
		private var mappingMode:PsykoParameter;
		private var mappingFactor:PsykoParameter;
		private var mappingFunction:PsykoParameter;
		private var invertMapping:PsykoParameter;
		
		private var rng:LCG;
		
		static private const mappingFunctions:Vector.<Function> = Vector.<Function>([null,Quad.easeIn,Quad.easeInOut,Quad.easeOut, Expo.easeIn, Expo.easeInOut, Expo.easeOut, Circ.easeIn,Circ.easeInOut, Circ.easeOut ]);
		
		public function SizeDecorator()
		{
			super();
			mappingMode  	 = new PsykoParameter( PsykoParameter.StringListParameter,"Mode",0,["Fixed","Speed"]);
			mappingFactor   = new PsykoParameter( PsykoParameter.NumberRangeParameter,"Factor",1,1,0,100);
			mappingFunction   = new PsykoParameter( PsykoParameter.StringListParameter,"Mapping",0,["Linear","Quad In","Quad InOut","Quad Out","Expo In","Expo InOut","Expo Out","Circular In","Circular InOut","Circular Out"]);
			invertMapping   = new PsykoParameter( PsykoParameter.BooleanParameter,"Invert Mapping",0);
			
			_parameters.push(mappingMode,mappingFactor,mappingFunction,invertMapping );
			
			rng = new LCG( Math.random() * 0xffffff );
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var mode:int = mappingMode.index;
			var minFactor:Number = mappingFactor.lowerRangeValue;
			var maxFactor:Number = mappingFactor.upperRangeValue;
			
			var mapping:Function = mappingFunctions[mappingFunction.index];
			var m1:Number = invertMapping.booleanValue ? 1 : 0;
			var m2:Number = 1 - m1;
			for ( var i:int = 0; i < points.length; i++ )
			{
				var point:SamplePoint = points[i];
				if ( mode == 0 )
				{
					point.size = rng.getNumber(minFactor,maxFactor );
				} else if ( mode == 1 )
				{
					point.size = ( mapping ? mapping.apply( null, [point.speed,m1,m2,1]) : point.speed ) * rng.getNumber(minFactor,maxFactor );
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