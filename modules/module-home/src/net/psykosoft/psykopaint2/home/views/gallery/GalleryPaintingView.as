package net.psykosoft.psykopaint2.home.views.gallery
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;

	import net.psykosoft.psykopaint2.home.views.book.HomeGeometryCache;
	import net.psykosoft.psykopaint2.home.views.book.HomeMaterialsCache;

	public class GalleryPaintingView extends ObjectContainer3D
	{
		private var _mesh:Mesh;
		private var _material:MaterialBase;
		private var _frameMesh:Mesh;
		private var _paintingGeometry:Geometry;

		
		public function GalleryPaintingView(paintingGeometry:Geometry,material:MaterialBase)
		{
			super();
			this._paintingGeometry = paintingGeometry;
			_material = material;
			
			_mesh = new Mesh(paintingGeometry, material);
			this.addChild(_mesh);
			_mesh.z=0;
			
			
			//WHEN LOADING TEXTURE FINISHED WE LOAD THE LOADING TEXTURE
			//BookMaterialsProxy.onCompleteSignal.addOnce(loadTexture);
			loadTexture();
		}

		private var _ribbon:Mesh;
		public function showRibbon(value:Boolean, mesh:Mesh = null):void {
//			trace("GalleryPaintingView - showPaintingBadge: " + value);
			if(value) {
				_ribbon = mesh.clone() as Mesh;
				addChild(_ribbon);
			}
			else if(_ribbon) {
				removeChild(_ribbon);
				_ribbon = null;
			}

		}

		private function loadTexture():void{
			
			var isframe:Boolean = (Math.random()>0.9);
			isframe=false;
			
			var frameMaterial:TextureMaterial = HomeMaterialsCache.getTextureMaterialById((isframe)? HomeMaterialsCache.FRAME_WHITE : HomeMaterialsCache.FRAME_EMPTY);
			var frameGeometry:Geometry = HomeGeometryCache.getGeometryById(HomeGeometryCache.FRAME_GEOMETRY);
			_frameMesh = new Mesh(frameGeometry, frameMaterial);
			_frameMesh.scaleX = 236;
			_frameMesh.scaleY = 232;
			_frameMesh.y=3;
			TextureMaterial(_frameMesh.material).alphaBlending=true;
			this.addChild(_frameMesh);
			
			//IF THERE'S NO FRAME WE PUT IT BEHIND THE PAINTING
			_frameMesh.z=(isframe)?-1:4;
		}
		
		
		public function get mesh():Mesh
		{
			return _mesh;
		}

		public function set mesh(value:Mesh):void
		{
			_mesh = value;
		}

		public function get material():MaterialBase
		{
			return _material;
		}

		public function set material(value:MaterialBase):void{
			_material= value;
			_mesh.material=value;
		}
		
		override public function dispose():void{
			
			if(_mesh.parent){
				removeChild(_mesh);
			}
//			if(_loadingMesh.parent){
//				removeChild(_loadingMesh);
//			}
			if(_ribbon) {
				removeChild(_ribbon);
			}
			_ribbon = null;
			_mesh.dispose();
		}
	}
}