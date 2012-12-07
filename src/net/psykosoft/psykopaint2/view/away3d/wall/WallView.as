package net.psykosoft.psykopaint2.view.away3d.wall
{

	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.CubeGeometry;

	import net.psykosoft.psykopaint2.view.away3d.base.Away3dViewBase;

	import org.osflash.signals.Signal;

	public class WallView extends Away3dViewBase
	{
		private var _object:Mesh;

		public var objectClickedSignal:Signal;

		public function WallView() {

			super();

			objectClickedSignal = new Signal();

			// Init lights.
			var light:PointLight = new PointLight();
			light.position = _camera.position;
			addChild3d( light );
			var lightPicker:StaticLightPicker = new StaticLightPicker( [ light ] );

			// Init object material.
			var colorMaterial:ColorMaterial = new ColorMaterial( 0xFF0000 );
			colorMaterial.lightPicker = lightPicker;

			// Init object.
			_object = new Mesh( new CubeGeometry( 500, 500, 500 ), colorMaterial );
			addChild3d( _object );

			// Listen for object clicks.
			_object.mouseEnabled = true;
			_object.addEventListener( MouseEvent3D.MOUSE_DOWN, onObjectMouseDown );
		}

		private function onObjectMouseDown( event:MouseEvent3D ):void {
			objectClickedSignal.dispatch();
		}

		override protected function onUpdate():void {

//			Cc.info( this, "active" );

			_object.rotationX += 0.6;
			_object.rotationY += 0.7;
			_object.rotationZ += 0.8;

		}
	}
}
