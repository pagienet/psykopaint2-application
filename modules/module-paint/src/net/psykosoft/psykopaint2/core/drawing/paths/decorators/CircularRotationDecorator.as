package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{

	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.drawing.paths.helpers.BalancingKDTree;
	import net.psykosoft.psykopaint2.core.drawing.paths.helpers.KDTreeNode;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	public class CircularRotationDecorator extends AbstractPointDecorator
	{
		private var kdTree:BalancingKDTree;
		private var centers:XML = <centers/>;
		private var angleAdjustment:PsykoParameter;
		private var _canvasModel:CanvasModel;
		private var tempPoint:SamplePoint;
		
		public function CircularRotationDecorator( angleAdjustment:Number = 0 )
		{
			super();
			this.angleAdjustment  = new PsykoParameter( PsykoParameter.AngleParameter,"Angle Adjustment",angleAdjustment,-90, 90);
			_parameters.push(this.angleAdjustment);
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
					points[i].angle = Math.atan2(nearestNode.point.y -tempPoint.y ,nearestNode.point.x - tempPoint.x) + nearestNode.point.angle + angleAdjustment.numberValue;
				}
			}
			return points;
		}
		
		override public function getParameterSet( path:Array ):XML
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
			if ( message.centers.length() > 0 &&  message.centers[0].point.length() > 0)
			{
				centers = message.centers[0];
				kdTree = new BalancingKDTree();
				var pdata:XMLList =  message.centers[0].point;
				for ( var i:int = 0; i < pdata.length(); i++ )
				{
					kdTree.insertPoint( new SamplePoint(Number(pdata[i].@x), Number( pdata[i].@y)));
				}
			}
			
		}
		
	}
}