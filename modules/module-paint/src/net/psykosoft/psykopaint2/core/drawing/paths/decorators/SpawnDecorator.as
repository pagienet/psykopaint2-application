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
		
		private var rng:LCG;
		
		public function SpawnDecorator( minMultiples:int = 1, maxMultiples:int = 4, maxOffset:Number = 16, offsetParent:Boolean = false )
		{
			super( );
			
			this.multiples       = new PsykoParameter( PsykoParameter.IntRangeParameter,"Multiples",minMultiples,maxMultiples,1,16);
			this.maxOffset       = new PsykoParameter( PsykoParameter.NumberParameter,"Maximum Offset",maxOffset,0,100);
			this.offsetParent    = new PsykoParameter( PsykoParameter.BooleanParameter,"Offset Parent Point",offsetParent);
			
			_parameters.push(this.multiples,this.maxOffset,this.offsetParent);
			rng = new LCG(Math.random() * 0xffffffff);
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var count:int = points.length;
			for ( var j:int = 0; j < count; j++ )
			{
				var spawnCount:int = rng.getNumber(multiples.lowerRangeValue, multiples.upperRangeValue);
				for ( var i:int = 0; i < spawnCount; i++ )
				{
					var p:SamplePoint = points[j].getClone();
					p.x += rng.getMappedNumber(0,maxOffset.numberValue,Quad.easeIn);
					p.y += rng.getMappedNumber(0,maxOffset.numberValue,Quad.easeIn);
					points.push(p );
				}
				if ( offsetParent.booleanValue )
				{
					points[j].x += rng.getMappedNumber(0,maxOffset.numberValue,Quad.easeIn);
					points[j].y += rng.getMappedNumber(0,maxOffset.numberValue,Quad.easeIn);
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