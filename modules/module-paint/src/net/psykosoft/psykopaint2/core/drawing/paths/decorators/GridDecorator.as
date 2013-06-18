package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;

	public class GridDecorator  extends AbstractPointDecorator
	{
		private var stepX:PsykoParameter;
		private var stepY:PsykoParameter;
		private var offsetCol:PsykoParameter;
		private var offsetRow:PsykoParameter;
		private var angleStep:PsykoParameter;
		private var angleOffset:PsykoParameter;
		
		public function GridDecorator( stepX:Number = 64, stepY:Number = 64, angleStep:Number = -1, angleOffset:Number = 0,  offsetCol:Number = 0, offsetRow:Number = 0)
		{
			super();
			this.stepX       = new PsykoParameter( PsykoParameter.NumberParameter,"Cell Width",stepX,1,512);
			this.stepY       = new PsykoParameter( PsykoParameter.NumberParameter,"Cell Height",stepX,1,512);
			this.offsetCol   = new PsykoParameter( PsykoParameter.NumberParameter,"Column Offset",offsetCol,-512,512);
			this.offsetRow   = new PsykoParameter( PsykoParameter.NumberParameter,"Row Offset",offsetRow,-512,512);
			this.angleStep   = new PsykoParameter( PsykoParameter.AngleParameter,"Angle Step",angleStep,-1,360);
			this.angleOffset = new PsykoParameter( PsykoParameter.AngleParameter,"Angle Offset",angleOffset,-360,360);
			_parameters.push(this.stepX,this.stepY,this.angleStep,this.angleOffset,this.offsetCol, this.offsetRow);
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			for ( var i:int = 0; i < points.length; i++ )
			{
				points[i].x = points[i].x - (points[i].x % stepX.numberValue) + 0.5 * stepX.numberValue;
				points[i].y = points[i].y - (points[i].y % stepY.numberValue) + 0.5 * stepY.numberValue;
				var col:Number = int(points[i].x / stepX.numberValue);
				var row:Number = int(points[i].y / stepY.numberValue);
				points[i].x += (row * offsetRow.numberValue) % stepX.numberValue;
				points[i].y += (col * offsetCol.numberValue) % stepY.numberValue;
				
				if ( angleStep.degrees > -1 ) points[i].angle = (angleStep.numberValue > 0 ? (points[i].angle - points[i].angle % angleStep.numberValue) : 0 ) + angleOffset.numberValue;
				if ( i > 0 )
				{
					if ( points[i].x == points[i-1].x && points[i].y == points[i-1].y )
					{
						points.splice(i,1);
						i--;
					}
				}
			}
			return points;
		}
		
		override public function getParameterSetAsXML( path:Array ):XML
		{
			var result:XML = <GridDecorator />;
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				result.appendChild( _parameters[i].toXML(path) );
			}
			return result;
		}
	}
}