package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	import com.greensock.easing.Quad;
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;

	public class SpawnDecorator extends AbstractPointDecorator
	{
		private var multiples:PsykoParameter;
		private var maxOffset:PsykoParameter;
		private var offsetParent:PsykoParameter;
		private var offsetMode:PsykoParameter;
		private var offsetAngleRange:PsykoParameter;
		private var brushAngleRange:PsykoParameter;
		private var bristleVariation:PsykoParameter;
		private var maxSpeed:PsykoParameter;
		
		private var rng:LCG;
		
		public function SpawnDecorator( minMultiples:int = 1, maxMultiples:int = 4, maxOffset:Number = 16, offsetParent:Boolean = false )
		{
			super( );
			
			this.multiples       = new PsykoParameter( PsykoParameter.IntRangeParameter,"Multiples",minMultiples,maxMultiples,1,16);
			this.maxOffset       = new PsykoParameter( PsykoParameter.NumberParameter,"Maximum Offset",maxOffset,0,100);
			this.offsetParent       = new PsykoParameter( PsykoParameter.BooleanParameter,"Offset Parent",offsetParent);
			this.offsetMode      = new PsykoParameter( PsykoParameter.StringListParameter, "Offset Mode",2,["Fixed","Random","Speed","Pressure"]);
			this.offsetAngleRange  = new PsykoParameter( PsykoParameter.AngleRangeParameter, "Offset Angle",0,0,-180,180);
			this.brushAngleRange  = new PsykoParameter( PsykoParameter.AngleRangeParameter, "Brush Angle Variation",0,0,-180,180);
			this.bristleVariation  = new PsykoParameter( PsykoParameter.NumberParameter, "Bristle Variation",0,0,1);
			maxSpeed   		= new PsykoParameter( PsykoParameter.NumberParameter,"Maximum Speed",20,1,100);
			
			_parameters.push(this.multiples,this.maxOffset,this.offsetParent, offsetMode, offsetAngleRange, brushAngleRange, bristleVariation,maxSpeed);
			rng = new LCG(Math.random() * 0xffffffff);
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var count:int = points.length;
			var ms:Number = maxSpeed.numberValue;
			for ( var j:int = 0; j < count; j++ )
			{
				var spawnCount:int = rng.getNumber(multiples.lowerRangeValue, multiples.upperRangeValue);
				
				var distance:Number = 2 * maxOffset.numberValue / spawnCount;
				switch ( offsetMode.index )
				{
					case 1:
						distance *= rng.getNumber();
					break;
					case 2:
						distance *=  points[j].speed / ms;
						break;
					case 3:
						if ( points[j].pressure > 0 )
						{
							distance *= points[j].pressure / 2000;
						} else {
							distance *=  points[j].speed / ms;
						}
						break;
				}
				
				for ( var i:int = 0; i < spawnCount; i++ )
				{
					var p:SamplePoint = points[j].getClone();
					var offsetAngle:Number = (p.angle + Math.PI * 0.5 +  rng.getNumber( offsetAngleRange.lowerRangeValue, offsetAngleRange.upperRangeValue ));;// * (rng.getChance() ? 1 : -1);
					var radius:Number = (i-spawnCount/2) * distance + rng.getNumber(-distance,distance)*0.5*bristleVariation.numberValue;
					p.angle += rng.getNumber( brushAngleRange.lowerRangeValue, brushAngleRange.upperRangeValue );
					p.x +=  Math.cos(offsetAngle) * radius; 
					p.y +=  Math.sin(offsetAngle) * radius; 
					points.push(p );
				}
				if ( offsetParent.booleanValue )
				{
					p = points[j];
				 	offsetAngle = (p.angle + Math.PI * 0.5 +  rng.getNumber( offsetAngleRange.lowerRangeValue, offsetAngleRange.upperRangeValue ));
					radius = rng.getNumber(-distance,distance)*0.5*bristleVariation.numberValue;
					p.angle += rng.getNumber( brushAngleRange.lowerRangeValue, brushAngleRange.upperRangeValue );
					p.x +=  Math.cos(offsetAngle) * radius; 
					p.y +=  Math.sin(offsetAngle) * radius; 
				}
			}
			return points;
		}
		
		override public function getParameterSet(path:Array):XML
		{
			var result:XML = <SpawnDecorator/>;
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				result.appendChild( _parameters[i].toXML(path) );
			}
			return result;
		}
	}
}