package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;

	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;

	/*
	* Contains a painting within a frame.
	* */
	public class FramedPainting extends ObjectContainer3D
	{
		private var _painting:ObjectContainer3D;
		private var _frame:Frame;
		private var _easel:Mesh;
		private var _view:View3D;

		public function FramedPainting( view:View3D ) {
			super();
			_view = view;
		}

		public function set easelVisible( visible:Boolean ):void {
			if( !_easel ) {
				var easelMaterial:TextureMaterial = TextureUtil.getAtfMaterial( HomeView.HOME_BUNDLE_ID, "easelImage", _view );
				easelMaterial.alphaBlending = true;
				easelMaterial.mipmap = false;
				_easel = new Mesh( new PlaneGeometry( 1024, 1024 ), easelMaterial );
				_easel.y = -210;
				if( _frame ) _easel.z = _frame.depth / 2 + 1;
				else _easel.z = 50;
				_easel.scale( 1.575 );
				_easel.rotationX = -90;
				addChild( _easel );
			}
			_easel.visible = visible;
		}

		override public function dispose():void {
			if( _painting ) {
				_painting.dispose();
				_painting = null;
			}
			if( _frame ) {
				_frame.dispose();
				_frame = null;
			}
			super.dispose();
		}

		public function setPainting( value:ObjectContainer3D ):void {
			if( _painting ) {
				removeChild( _painting );
				_painting.dispose();
			}
			if ( value ) {
				_painting = value;
				addChild(_painting);
			}
		}

		public function setFrame( frame:Frame ):void {
			if( _frame ) {
				removeChild( _frame );
			}
			_frame = frame;
			if( _easel ) _easel.z = _frame.depth / 2 + 1;
			addChild( _frame );
		}

		public function get width():Number {
			if( _easel ) return 1024;
			if( _frame ) return _frame.width;
			return 0;
		}

		public function get height():Number {
			if( _easel ) return 1024;
			if( _frame ) return _frame.height;
			return 0;
		}

		public function get depth():Number {
			if( _frame ) return _frame.depth;
			return 0;
		}

		public function get painting():ObjectContainer3D {
			return _painting;
		}
	}
}
