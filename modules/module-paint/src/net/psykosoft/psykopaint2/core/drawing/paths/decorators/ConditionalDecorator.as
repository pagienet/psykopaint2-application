package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManagerCallbackInfo;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.managers.pen.WacomPenManager;
	
	
	final public class ConditionalDecorator extends AbstractPointDecorator
	{
		public static const PARAMETER_SL_TEST_PROPERTY : String = "Test Property";
		public static const PARAMETER_N_SPEED_THRESHOLD : String = "Speed Threshold";
		public static const PARAMETER_N_LUMINANCE_THRESHOLD : String = "Luminance Threshold";
		public static const PARAMETER_N_RANDOM_THRESHOLD : String = "Random Threshold";
		public static const PARAMETER_N_PRESSURE_THRESHOLD : String = "Pressure Threshold";
		
		public static const PROPERTY_INDEX_SPEED : int = 0;
		public static const PROPERTY_INDEX_LUMINANCE : int = 1;
		public static const PROPERTY_INDEX_RANDOM : int = 2;
		public static const PROPERTY_INDEX_PEN_AVAILABLE : int = 3;
		public static const PROPERTY_INDEX_PEN_PRESSURE : int = 4;
		public static const PROPERTY_INDEX_PEN_BUTTON_1 : int = 5;
		public static const PROPERTY_INDEX_PEN_BUTTON_2 : int = 6;
		
		
		private var testProperty:PsykoParameter;
		private var speedThreshold:PsykoParameter;111
		private var luminanceThreshold:PsykoParameter;
		private var randomThreshold:PsykoParameter;
		private var pressureThreshold:PsykoParameter;
		
		private var rng:LCG;
		
		public function ConditionalDecorator()
		{
			super();
			testProperty  = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_TEST_PROPERTY,0,["Speed","Luminance","Random","Pen Available","Pressure","Pen Button 1","Pen Button 2"] );
			speedThreshold  = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_SPEED_THRESHOLD,0,0, 10);
			luminanceThreshold  = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_LUMINANCE_THRESHOLD,0,0, 255);
			randomThreshold  = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_RANDOM_THRESHOLD,0,0, 1);
			pressureThreshold  = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_PRESSURE_THRESHOLD,0,0, 2000);
			
			_parameters.push(testProperty, speedThreshold, luminanceThreshold, randomThreshold, pressureThreshold);
			rng = new LCG(Math.random() * 0xffffffff);
			
		}
		
		override public function compare(points:Vector.<SamplePoint>, manager:PathManager):Vector.<Vector.<SamplePoint>>
		{
			var result:Vector.<Vector.<SamplePoint>> = new Vector.<Vector.<SamplePoint>>(2,true);
			result[0] = new Vector.<SamplePoint>();
			result[1] = new Vector.<SamplePoint>();
			
			var cb:PathManagerCallbackInfo =  manager.callbacks;
			var conditionIndex:int = testProperty.index
			
			for ( var i:int = 0; i < points.length; i++ )
			{
				switch (conditionIndex)
				{
					case 0:
						//Speed
						result[(points[i].speed < speedThreshold.numberValue ? 0 : 1)].push(points[i]);
						break;
					case 1:
						//Luminance
						break;
					case 2:
						//Random
						result[rng.getChance(randomThreshold.numberValue) ? 0 : 1].push(points[i]);
						break;
					case 3:
						//Pen available
						result[(WacomPenManager.hasPen ? 0 : 1)].push(points[i]);
						break;
					case 4:
						//Speed
						result[(points[i].pressure < pressureThreshold.numberValue ? 0 : 1)].push(points[i]);
						break;
					case 5:
						//Pen Button 1
						result[((points[i].penButtonState & 1) == 1 ? 0 : 1)].push(points[i]);
						break;
					case 6:
						//Pen Button 2
						result[((points[i].penButtonState & 2) == 2  ? 0 : 1)].push(points[i]);
						break;
				}
				
				
			}
			return result;
		}
		
		override public function getParameterSetAsXML( path:Array ):XML
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