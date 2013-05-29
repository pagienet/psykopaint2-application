package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
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
		
		private var rng:LCG;
		
		static private const mappingFunctions:Vector.<Function> = Vector.<Function>([null,Quad.easeIn,Quad.easeInOut,Quad.easeOut]);
		
		public function SizeDecorator()
		{
			super();
			this.mappingMode  	 = new PsykoParameter( PsykoParameter.StringListParameter,"Mode",0,["Fixed","Speed"]);
			this.mappingFactor   = new PsykoParameter( PsykoParameter.NumberRangeParameter,"Factor",1,1,0,100);
			this.mappingFunction   = new PsykoParameter( PsykoParameter.NumberParameter,"Mapping",0,["Linear","Quad In","Quad InOut","Quad Out"]);
			_parameters.push(this.mappingMode,this.mappingFactor,this.mappingFunction );
			
			rng = new LCG( Math.random() * 0xffffff );
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var mode:int = mappingMode.index;
			var minFactor:Number = mappingFactor.lowerRangeValue;
			var maxFactor:Number = mappingFactor.upperRangeValue;
			
			var mapping:Function = mappingFunctions[mappingFunction.index];
			
			for ( var i:int = 0; i < points.length; i++ )
			{
				var point:SamplePoint = points[i];
				switch ( mode )
				{
					case 0:
						point.size = rng.getNumber(minFactor,maxFactor );
						break;
					case 1:
						point.size = ( mapping ? mapping.apply( null, [point.speed,0,1,1]) : point.speed ) * rng.getNumber(minFactor,maxFactor );
						break;
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