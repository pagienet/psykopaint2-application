package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;

	final public class GridDecorator  extends AbstractPointDecorator
	{
		public static const PARAMETER_N_CELL_WIDTH:String = "Cell Width";
		public static const PARAMETER_N_CELL_HEIGHT:String = "Cell Height";
		public static const PARAMETER_N_COLUMN_OFFSET:String = "Column Offset";
		public static const PARAMETER_N_ROW_OFFSET:String = "Row Offset";
		public static const PARAMETER_A_ANGLE_STEP:String = "Angle Step";
		public static const PARAMETER_A_ANGLE_OFFSET:String = "Angle Offset";
		
		
		private var stepX:PsykoParameter;
		private var stepY:PsykoParameter;
		private var offsetCol:PsykoParameter;
		private var offsetRow:PsykoParameter;
		private var angleStep:PsykoParameter;
		private var angleOffset:PsykoParameter;
		
		public function GridDecorator( stepX:Number = 64, stepY:Number = 64, angleStep:Number = -1, angleOffset:Number = 0,  offsetCol:Number = 0, offsetRow:Number = 0)
		{
			super();
			this.stepX       = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_CELL_WIDTH,stepX,0,512);
			this.stepY       = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_CELL_HEIGHT,stepX,0,512);
			this.offsetCol   = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_COLUMN_OFFSET,offsetCol,-512,512);
			this.offsetRow   = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_ROW_OFFSET,offsetRow,-512,512);
			this.angleStep   = new PsykoParameter( PsykoParameter.AngleParameter,PARAMETER_A_ANGLE_STEP,angleStep,-1,360);
			this.angleOffset = new PsykoParameter( PsykoParameter.AngleParameter,PARAMETER_A_ANGLE_OFFSET,angleOffset,-360,360);
			_parameters.push(this.stepX,this.stepY,this.angleStep,this.angleOffset,this.offsetCol, this.offsetRow);
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var sx:Number = stepX.numberValue;
			var sy:Number = stepY.numberValue;
			var col:Number = 1;
			var row:Number = 1;
			for ( var i:int = 0; i < points.length; i++ )
			{
				var p:SamplePoint = points[i];
				if ( sx > 0 ) 
				{
					points[i].x = p.x - (p.x % sx) + 0.5 * sx;
					col = int(p.x / sx);
				}
				if ( sy > 0 ) 
				{
					points[i].y = p.y - (p.y % sy) + 0.5 * sy;
					row = int(p.y / sy);
				}
				
				if ( sx > 0 ) 
					p.x += (row * offsetRow.numberValue) % sx;
				if ( sy > 0 ) 
					p.y += (col * offsetCol.numberValue) % sy;
				
				if ( angleStep.degrees > -1 ) p.angle = (angleStep.numberValue > 0 ? (p.angle - p.angle % angleStep.numberValue) : 0 ) + angleOffset.numberValue;
				if ( i > 0 )
				{
					if ( p.x == points[int(i-1)].x && p.y == points[int(i-1)].y )
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