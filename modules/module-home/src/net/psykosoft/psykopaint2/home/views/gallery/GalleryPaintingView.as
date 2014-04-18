package net.psykosoft.psykopaint2.home.views.gallery
{
	import flash.display.BitmapData;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.hacks.PaintingMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	
	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.home.views.book.BookGeometryProxy;
	import net.psykosoft.psykopaint2.home.views.book.BookMaterialsProxy;
	
	public class GalleryPaintingView extends ObjectContainer3D
	{
		private var _mesh:Mesh;
		private var _material:MaterialBase;
		
		private var _loadingMesh:Mesh;
		private var _loadingTexture:BitmapTexture;
		
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
		
		
		private function loadTexture():void{
			
			trace("SWAP LOADING TEXTURE");
			var isframe:Boolean = (Math.random()>0.9);
			
			var frameTexture:BitmapTexture = new BitmapTexture(TextureUtil.autoResizePowerOf2(BookMaterialsProxy.getBitmapDataById((isframe)?BookMaterialsProxy.FRAME_WHITE:BookMaterialsProxy.FRAME_EMPTY)));
			var frameGeometry:PlaneGeometry = 	new PlaneGeometry(236, 232, 1, 1, false);
			_frameMesh = new Mesh(frameGeometry, new TextureMaterial(frameTexture));
			_frameMesh.y=3;
			TextureMaterial(_frameMesh.material).alphaBlending=true;
			this.addChild(_frameMesh);
			
			//IF THERE'S NOT FRAME WE PUT IT BEHIND THE PAINTING
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
			_mesh.dispose();
			//MATERIAL IS DISPOSED IN THE PARENT GAlleryView
			//_material.dispose();
			//_loadingTexture.dispose();
			//_loadingMesh.dispose();
		}
	}
}