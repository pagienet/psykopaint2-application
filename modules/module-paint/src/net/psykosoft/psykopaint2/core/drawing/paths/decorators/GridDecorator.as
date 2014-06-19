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
		
		/**
		 * The Grid Decorator allows to snap the points to a given grid
		 * and/or snap the rotations to limited angles
		 */
		//"Cell Width" - NumberValue
		public var param_stepX:PsykoParameter;
		
		//"Cell Height" - NumberValue
		public var param_stepY:PsykoParameter;
		
		//"Column Offset" - NumberValue
		//allows to shift the columns about a value for each subsequent row
		public var param_offsetCol:PsykoParameter;
		
		//"Row Offset" - NumberValue
		//allows to shift the rows about a value for each subsequent column
		public var param_offsetRow:PsykoParameter;
		
		//"Angle Step" - AngleValue
		//limits the rotation of the SamplePoints to given steps
		public var param_angleStep:PsykoParameter;
		
		//"Angle Offset" - AngleValue
		//allows to add a rotation that is applied after the limiting
		public var param_angleOffset:PsykoParameter;
		
		
		public function GridDecorator( stepX:Number = 64, stepY:Number = 64, angleStep:Number = -1, angleOffset:Number = 0,  offsetCol:Number = 0, offsetRow:Number = 0)
		{
			super();
			this.param_stepX       = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_CELL_WIDTH,stepX,0,1024);
			this.param_stepY       = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_CELL_HEIGHT,stepX,0,1024);
			this.param_offsetCol   = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_COLUMN_OFFSET,offsetCol,-512,512);
			this.param_offsetRow   = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_ROW_OFFSET,offsetRow,-512,512);
			this.param_angleStep   = new PsykoParameter( PsykoParameter.AngleParameter,PARAMETER_A_ANGLE_STEP,angleStep,-1,360);
			this.param_angleOffset = new PsykoParameter( PsykoParameter.AngleParameter,PARAMETER_A_ANGLE_OFFSET,angleOffset,-360,360);
			_parameters.push(this.param_stepX,this.param_stepY,this.param_angleStep,this.param_angleOffset,this.param_offsetCol, this.param_offsetRow);
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var sx:Number = param_stepX.numberValue;
			var sy:Number = param_stepY.numberValue;
			var col:Number = 1;
			var row:Number = 1;
			for ( var i:int = 0; i < points.length; i++ )
			{
				var p:SamplePoint = points[i];
				if ( sx > 0 ) 
				{
					p.x = p.x - (p.x % sx)+ 0.5 * sx;
					col = int(p.x / sx);
				}
				if ( sy > 0 ) 
				{
					p.y = p.y - (p.y % sy)+ 0.5 * sy;
					row = int(p.y / sy);
				}
				
				if ( sx > 0 ) 
					p.x += (row * param_offsetRow.numberValue) % sx;
				if ( sy > 0 ) 
					p.y += (col * param_offsetCol.numberValue) % sy;
				
				if ( param_angleStep.degrees > 0 ) 
				{
					var mod:Number = p.angle  % param_angleStep.numberValue;
					if (mod < param_angleStep.numberValue * 0.5)
					{
						if (mod < -param_angleStep.numberValue*0.5)
							p.angle +=  -param_angleStep.numberValue - mod;
						else
							p.angle -= mod;
					} else
						p.angle += param_angleStep.numberValue - mod;
					
					p.angle += param_angleOffset.numberValue;
				}
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