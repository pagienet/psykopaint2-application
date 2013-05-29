package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	
	import com.quasimondo.geom.ColorMatrix;
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManagerCallbackInfo;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	
	
	public class ConditionalDecorator extends AbstractPointDecorator
	{
		private var testProperty:PsykoParameter;
		private var threshold:PsykoParameter;
		
		private var rng:LCG;
		
		public function ConditionalDecorator()
		{
			super();
			testProperty  = new PsykoParameter( PsykoParameter.StringListParameter,"Test Property",0,["Speed","Luminance","Random"] );
			threshold  = new PsykoParameter( PsykoParameter.NumberParameter,"Threshold",0,-1000, 1000);
			
			_parameters.push(testProperty, threshold);
			rng = new LCG(Math.random() * 0xffffffff);
			
		}
		
		override public function compare(points:Vector.<SamplePoint>, manager:PathManager):Vector.<Vector.<SamplePoint>>
		{
			var result:Vector.<Vector.<SamplePoint>> = new Vector.<Vector.<SamplePoint>>(2,true);
			result[0] = new Vector.<SamplePoint>();
			result[1] = new Vector.<SamplePoint>();
			
			var cb:PathManagerCallbackInfo =  manager.callbacks;
			var conditionIndex:int = testProperty.index
			var th:Number = threshold.numberValue;
			
			for ( var i:int = 0; i < points.length; i++ )
			{
				switch (conditionIndex)
				{
					case 0:
						//Speed
						result[(points[i].speed < th ? 0 : 1)].push(points[i]);
						break;
					case 1:
						//Luminance
						break;
					case 2:
						//Random
						result[rng.getChance(th) ? 0 : 1].push(points[i]);
						break;
					
				}
				
				
			}
			return result;
		}
		
		override public function getParameterSet( path:Array ):XML
		{
			var data:XML = <ConditionalDecorator />;
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				data.appendChild( _parameters[i].toXML(path) );
			}
			return data;
		}
		
	}
}