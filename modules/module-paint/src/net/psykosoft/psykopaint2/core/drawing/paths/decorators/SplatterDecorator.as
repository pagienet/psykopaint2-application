package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	import com.greensock.easing.Quad;
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	public class SplatterDecorator extends AbstractPointDecorator
	{
		private var minOffset:PsykoParameter;
		private var splatFactor:PsykoParameter;
		private var sizeFactor:PsykoParameter;
		private var offsetAngleRange:PsykoParameter;
		
		private var rng:LCG;
		
		/*
			offsets the point based on its angle and speed
			
			splatFactor: maximum offset based on speed
			offsetAngleRange: random angle range around perpendicular angle
			brush angle range: random brush rotation range
			size factor: inverse speed multiplier based on offset distance (1 = the further the offset the smaller the size)
		*/

		public function SplatterDecorator( splatFactor:Number = 2, minOffset:Number = 2, offsetAngleRange:Number = 1.57079632679, sizeFactor:Number = 0.3 )
		{
			super();
			this.splatFactor  	  = new PsykoParameter( PsykoParameter.NumberParameter,"Splat Factor",splatFactor,0,10);
			this.minOffset   	  = new PsykoParameter( PsykoParameter.NumberParameter,"Minimum Offset",minOffset,0,64);
			this.offsetAngleRange = new PsykoParameter( PsykoParameter.AngleParameter,"Offset Angle Range",offsetAngleRange,0,180);
			this.sizeFactor 	  = new PsykoParameter( PsykoParameter.NumberParameter,"Size Factor",sizeFactor,0,2);
			_parameters.push(this.splatFactor,this.minOffset,this.offsetAngleRange,this.sizeFactor );
			
			rng = new LCG( Math.random() * 0xffffff );
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var pi2:Number = Math.PI*  0.5;
			var pi3:Number = Math.PI * 1.5;
			for ( var i:int = 0; i < points.length; i++ )
			{
				var point:SamplePoint = points[i];
				var angle:Number = point.angle  + rng.getNumber(-offsetAngleRange.numberValue,offsetAngleRange.numberValue) + (rng.getChance() ? pi2 : pi3);
				var offset:Number =  rng.getMappedNumber(0, 1, Quad.easeIn );
				var distance:Number =  minOffset.numberValue + splatFactor.numberValue * offset * point.speed; 
				point.x  +=  Math.cos(angle) * distance;
				point.y  +=  Math.sin(angle) * distance;
				point.size *= ( 1 - sizeFactor.numberValue *  offset ); 
				point.angle += rng.getNumber(-manager.brushAngleRange,manager.brushAngleRange);
			}
			return points;
		}
		
		override  public function getParameterSet( path:Array ):XML
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