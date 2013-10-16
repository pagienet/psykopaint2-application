package net.psykosoft.psykopaint2.home.views.home.objects
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	
	import away3d.containers.View3D;
	import away3d.core.pick.PickingColliderType;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.hacks.RecoverableATFTexture;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.LightPickerBase;
	import away3d.primitives.PlaneGeometry;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.home.assets.HomeEmbeddedAssets;
	
	import org.osflash.signals.Signal;

	public class Easel extends GalleryPainting
	{
		private var _painting:EaselPainting;
		private var _easel:Mesh;
		private var _view:View3D;
		private var _lightPicker:LightPickerBase;
		private var _disposeVoWhenDone:Boolean;
		private var _voToBeSetAfterAnimation:PaintingInfoVO;

		public var easelTappedSignal:Signal;

		public function Easel( view:View3D, lightPicker:LightPickerBase ) {
			super();
			easelTappedSignal = new Signal();
			_view = view;
			_lightPicker = lightPicker;
			initPainting();
		}

		override public function dispose():void {

			removeChild( _painting );
			_painting.dispose();
			_painting = null;

			removeChild( _easel );
			_easel.geometry.dispose();
			var easelTexture:RecoverableATFTexture = TextureMaterial( _easel.material ).texture as RecoverableATFTexture;
			_easel.material.dispose();
			easelTexture.dispose();
			_easel.dispose();

			TweenLite.killTweensOf( _painting );
			_voToBeSetAfterAnimation = null;

			super.dispose();
		}

		private function initPainting():void {
			_painting = new EaselPainting( _lightPicker );
			_painting.scale( 0.75 );
			_painting.visible = false;
			_painting.y -= 78;
			addChild( _painting );

			_painting.mouseEnabled = true;
			_painting.pickingCollider = PickingColliderType.BOUNDS_ONLY;
			_painting.showBounds = true;
			_painting.addEventListener( MouseEvent3D.MOUSE_UP, onEaselMouseUp );

			if( CoreSettings.RUNNING_ON_RETINA_DISPLAY ) {
				_painting.scaleX *= 0.5;
				_painting.scaleY = _painting.scaleX;
			}
		}

		private function onEaselMouseUp( event:MouseEvent3D ):void {
			easelTappedSignal.dispatch();
		}

		public function set easelVisible( visible:Boolean ):void {
			if( !_easel ) {

				//var bytes:ByteArray = new HomeEmbeddedAssets.instance.EaselImage() as ByteArray;
				//var texture:ATFTexture = new ATFTexture( bytes );
				var texture:RecoverableATFTexture = new RecoverableATFTexture( HomeEmbeddedAssets.instance.EaselImage );
				texture.getTextureForStage3D( _view.stage3DProxy );
				//temporarily disabled to counter ios7 buge
				//bytes.clear();
				var easelMaterial:TextureMaterial = new TextureMaterial( texture );
				easelMaterial.alphaBlending = true;
				easelMaterial.mipmap = false;

				_easel = new Mesh( new PlaneGeometry( 1024, 1024, 1, 1, false ), easelMaterial );
				_easel.z = 10;
				_easel.y = -250;
				_easel.scale( 1.05 );
				addChild( _easel );
			}
			_easel.visible = visible;
		}

		public function setContent( vo:PaintingInfoVO, animate:Boolean = false, disposeWhenDone:Boolean = false ):void {
			TweenLite.killTweensOf( _painting );
			_painting.x = 0;

			_disposeVoWhenDone = disposeWhenDone;

			if( !animate ) {
				_painting.setContent( vo, _view.stage3DProxy );
				if( disposeWhenDone ) vo.dispose();
			}
			else if( vo != null ) {
				_voToBeSetAfterAnimation = vo;
				if( _painting.visible ) {
					tweenOutThenSetContent();
				}
				else {
					onTweenOutComplete();
				}
			}
		}

		private function tweenOutThenSetContent():void {
			TweenLite.to( _painting, 0.5, { x: 3000, ease: Strong.easeIn, onComplete: onTweenOutComplete } );
		}

		private function onTweenOutComplete():void {
			_painting.setContent( _voToBeSetAfterAnimation, _view.stage3DProxy );
			if( _disposeVoWhenDone ) _voToBeSetAfterAnimation.dispose();
			_voToBeSetAfterAnimation = null;
			_painting.x = -3000;
			TweenLite.to( _painting, 0.5, { delay: 0.25, x: 0, ease: Strong.easeOut } );
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		override public function get painting():Mesh {
			return _painting;
		}
	}
}
