package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{

	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.drawing.paths.helpers.BalancingKDTree;
	import net.psykosoft.psykopaint2.core.drawing.paths.helpers.KDTreeNode;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	final public class CircularRotationDecorator extends AbstractPointDecorator
	{
		
		static public const PARAMETER_SL_MODE:String = "Mode";
		static public const PARAMETER_A_ANGLE_ADJUSTMENT:String = "Angle Adjustment";
		static public const PARAMETER_I_RANDOM_POINT_COUNT:String = "Random Point Count";
		
		static public const INDEX_MODE_PRESET:int = 0;
		static public const INDEX_MODE_RANDOM:int = 1;
		
		private var kdTree:BalancingKDTree;
		private var centers:XML = <centers/>;
		private var _canvasModel:CanvasModel;
		private var tempPoint:SamplePoint;
		
		public var param_angleAdjustment:PsykoParameter;
		public var param_mode:PsykoParameter;
		public var param_randomPoints:PsykoParameter;
		
		public function CircularRotationDecorator( )
		{
			super();
			param_mode  = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_MODE,0,["Preset","Random"]);
			
			param_angleAdjustment  = new PsykoParameter( PsykoParameter.AngleParameter,PARAMETER_A_ANGLE_ADJUSTMENT,0,-90, 90);
			param_randomPoints  	 = new PsykoParameter( PsykoParameter.IntParameter,PARAMETER_I_RANDOM_POINT_COUNT,0,0,200);
			
			_parameters.push(param_mode,param_angleAdjustment,param_randomPoints);
			tempPoint = new SamplePoint();
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			if (kdTree) 
			{
				
				for ( var i:int = 0; i < points.length; i++ )
				{
					tempPoint.x = points[i].x / manager.canvasModel.width;
					tempPoint.y = points[i].y / manager.canvasModel.height;
					
					var nearestNode:KDTreeNode = kdTree.findNearestFor( tempPoint );
					points[i].angle = Math.atan2(nearestNode.point.y -tempPoint.y ,nearestNode.point.x - tempPoint.x) + nearestNode.point.angle + param_angleAdjustment.numberValue;
				}
			}
			return points;
		}
		
		override public function getParameterSetAsXML( path:Array ):XML
		{
			var data:XML = <CircularRotationDecorator />;
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				data.appendChild( _parameters[i].toXML(path) );
			}
			data.appendChild(centers);
			return data;
		}
		
		override public function updateParametersFromXML(message:XML):void
		{
			//TODO: maybe add some center point generator?
			
			super.updateParametersFromXML(message);
			kdTree = new BalancingKDTree();
			if ( param_mode.index == 0 && message.centers.length() > 0 &&  message.centers[0].point.length() > 0)
			{
				centers = message.centers[0];
				var pdata:XMLList =  message.centers[0].point;
				for ( var i:int = 0; i < pdata.length(); i++ )
				{
					kdTree.insertPoint( new SamplePoint(Number(pdata[i].@x), Number( pdata[i].@y)));
				}
			} 
			if (  param_mode.index == 1 && param_randomPoints.intValue > 0 )
			{
				for ( i = param_randomPoints.intValue; --i > -1; )
				{
					kdTree.insertPoint( new SamplePoint( Math.random(), Math.random()));
				}
				
			}
			
		}
		
	}
}