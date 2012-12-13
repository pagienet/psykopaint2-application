package net.psykosoft.psykopaint2.view.away3d.wall.frames
{

	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	import away3d.materials.ColorMaterial;

	import net.psykosoft.psykopaint2.util.ScenegraphUtil;

	public class Frame extends ObjectContainer3D
	{
		private var _model:ObjectContainer3D;
		private var _material:ColorMaterial;
		private var _paintingWidth:Number;

		public function Frame( frameModel:ObjectContainer3D ) {

			super();

			_model = frameModel;
			addChild( _model );

		}

		public function set material( value:ColorMaterial ):void {
			_material = value;
			ScenegraphUtil.applyMaterialToAllChildMeshes( _model, _material );
		}

		public function fitToPaintingWidth( paintingWidth:Number ):void {

			_paintingWidth = paintingWidth;

			// Identify original frame dimensions.
			var frameWidth:Number = _model.maxX - _model.minX;
			var frameHeight:Number = _model.maxY - _model.minY;
			var smallestDimension:Number = Math.min( frameWidth, frameHeight );

			// Scale frame without modifying aspect ratio.
			_model.scaleX = 1.1 * ( _paintingWidth ) / smallestDimension; // TODO: scaling value will depend on frame model ( size of picture area ).
			_model.scaleY = _model.scaleX;
			_model.scaleZ = _model.scaleX;

		}

		public function get width():Number {
			return ( _model.maxX - _model.minX ) * _model.scaleX;
		}

		override public function clone():Object3D {
			var clone:Frame = new Frame( _model.clone() as ObjectContainer3D );
			clone.material = _material;
			clone.fitToPaintingWidth( _paintingWidth );
			return clone;
		}
	}
}
