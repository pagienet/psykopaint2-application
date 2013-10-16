package net.psykosoft.psykopaint2.home.views.home.atelier
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.materials.methods.LightMapMethod;
	import away3d.textures.ATFTexture;
	import away3d.textures.BitmapTexture;
	import away3d.materials.SinglePassMaterialBase;

	import flash.events.Event;

	import flash.utils.ByteArray;
	import flash.display.BitmapData;
	import flash.geom.Matrix3D;

	import net.psykosoft.psykopaint2.base.utils.io.QueuedFileLoader;
	import net.psykosoft.psykopaint2.base.utils.io.events.AssetLoadedEvent;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.home.views.home.atelier.data.ElementsData;
	import net.psykosoft.psykopaint2.home.views.home.atelier.data.FloorData;
	import net.psykosoft.psykopaint2.home.views.home.atelier.data.IconuserData;
	import net.psykosoft.psykopaint2.home.views.home.atelier.data.LightsData;
	import net.psykosoft.psykopaint2.home.views.home.atelier.data.LogoData;
	import net.psykosoft.psykopaint2.home.views.home.atelier.data.TitlesData;
	import net.psykosoft.psykopaint2.home.views.home.atelier.data.WallsData;
	import net.psykosoft.psykopaint2.home.views.home.atelier.data.Walls_editmaterial1Data;

	public class Atelier extends ObjectContainer3D
	{
		private var _fileLoader:QueuedFileLoader;
		private var _assetsCount:uint;
		private var _assetsLoaded:uint;

		private var _iconTexture:BitmapTexture;
//		private var _floorTexture:BitmapTexture;
		private var _wallDiffuseTexture:BitmapTexture;

		private var _wallTexture:ATFTexture;
		private var _elementsTexture:ATFTexture;

		private var _meshes:Vector.<Mesh>;

		function Atelier ():void
		{
			super();

			_meshes = new Vector.<Mesh>();
			_fileLoader = new QueuedFileLoader();
		}

		//todo: replace the icon user with app user icon source
		//todo2: imporve disposal of meshes, materials, etc...
		override public function dispose():void
		{
			_iconTexture.dispose();
//			_floorTexture.dispose();
			_wallTexture.dispose();
			_iconTexture = null;
//			_floorTexture = null;
			_wallTexture = null;

			for(var i:uint = 0;i<_meshes.length;++i){
				this.removeChild(_meshes[i]);
				_meshes[i].material = null;
				_meshes[i].geometry.dispose();
				_meshes[i] = null;
			}

			if(_fileLoader) _fileLoader = null;

			super.dispose();
		}

		// replaces user icon
		public function set iconImage(bitmapData:BitmapData):void
		{
			changeImage(_iconTexture, bitmapData);
		}

		// replaces user floorimage
//		public function set floorImage(bitmapData:BitmapData):void
//		{
//			changeImage(_floorTexture, bitmapData);
//		}

		// replaces user wallimage
		public function set wallImage(bitmapData:BitmapData):void
		{
			changeImage(_wallDiffuseTexture, bitmapData);
		}

		public function init():void
		{
			var atfURL : String = CoreSettings.RUNNING_ON_iPAD ? "/home-packaged-ios/away3d/atelier/atfs/" : "/home-packaged-desktop/away3d/atelier/atfs/";
			var imgURL : String = "/home-packaged/away3d/atelier/";
			var titlesData:TitlesData = new TitlesData();
			var titles_rd:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,0.035400401800870895,300,27.497100830078125,1]);
			var titles:Mesh = new Mesh(titlesData.geometryData, null);
			applyTransform(titles_rd, titles, "titles");
			loadATFMaterial(titles, atfURL + "titles.atf", 0);
 
			var logoData:LogoData = new LogoData();
			var logo_rd:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,-266.8269958496094,-1.1448999643325806,-353.1099853515625,1]);
			var logo:Mesh = new Mesh(logoData.geometryData, null);
			applyTransform(logo_rd, logo, "logo");
			//we should ruse the atf from app
			loadATFMaterial(logo, atfURL + "logo.atf", 1);

			var iconuserData:IconuserData = new IconuserData();
			var iconuser_rd:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,983.531982421875,67.75910186767578,-9.93535041809082,1]);
			var iconuser:Mesh = new Mesh(iconuserData.geometryData, null);
			applyTransform(iconuser_rd, iconuser, "iconuser");
			loadBitmapMaterial(iconuser, imgURL + "jpgs/iconuser.jpg", 2);

			var floorData:FloorData = new FloorData();
			var floor_rd:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,2.070430040359497,-176.58900451660156,1.2002899646759033,1]);
			var floor:Mesh = new Mesh(floorData.geometryData, null);
			applyTransform(floor_rd, floor, "floor");
			loadBitmapMaterial(floor, imgURL + "jpgs/floor.jpg", 3);
			loadATFMaterial(floor, atfURL + "floor_LM.atf", 4);

			var lightsData:LightsData = new LightsData();
			var lights_rd:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,213.26800537109375,44.445098876953125,-116.06900024414063,1]);
			var lights:Mesh = new Mesh(lightsData.geometryData, null);
			applyTransform(lights_rd, lights, "lights");
			loadBitmapMaterial(lights, imgURL + "pngs/lights.png", 5);

			var elementsData:ElementsData = new ElementsData();
			var elements_rd:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,212.177001953125,11.164899826049805,10.134900093078613,1]);
			var elements:Mesh = new Mesh(elementsData.geometryData, null);
			applyTransform(elements_rd, elements, "elements");
			loadATFMaterial(elements, atfURL + "elements.atf", 6);

			var wallsData:WallsData = new WallsData();
			var walls_rd:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,2.4526400566101074,153.84300231933594,0.0783080980181694,1]);
			var walls:Mesh = new Mesh(wallsData.geometryData, null);
			applyTransform(walls_rd, walls, "walls");
			loadATFMaterial(walls, atfURL + "walls.atf", 7);
		}

		private function loadATFMaterial(mesh:Mesh, url:String, id:uint):void
		{
			_assetsCount++;
			_fileLoader.loadBinary(url, null, onError, {mesh:mesh, id:id}, finalizeObject);
		}

		private function loadBitmapMaterial(mesh:Mesh, url:String, id:uint):void
		{
			_assetsCount++;
			_fileLoader.loadImage(url, finalizeObject, onError, {mesh:mesh, id:id});
		}

		private function clearLoader():void
		{
			_assetsLoaded++;
			if(_assetsLoaded ==_assetsCount) {
				_fileLoader = null;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}

		private function onError(e:AssetLoadedEvent):void
		{
			trace ("ERROR LOADING! " + e.message);
//			_assetsLoaded++;
			clearLoader();
		}

		private function finalizeObject(e:AssetLoadedEvent):void
		{
			var mesh:Mesh = e.customData.mesh;
			var id:uint = e.customData.id;
			
			switch(id){
				//logo, titles, elements
				case 0:
				case 1:
					mesh.material = buildATFMaterial(ByteArray(e.data));
					if(id == 0) _elementsTexture = ATFTexture(TextureMaterial(mesh.material).texture);
					break;
				
				//default icon user
				case 2:
					mesh.material = buildBitmapMaterial(BitmapData(e.data));
					_iconTexture = BitmapTexture(TextureMaterial(mesh.material).texture);
					break;

				//floor, elements
				case 3:
					mesh.material = buildBitmapMaterial(BitmapData(e.data));
					mesh.material.repeat = true;
					break;

				//floor lightmap, add the texture and leave
				case 4:
					addLightMapMethod(SinglePassMaterialBase(mesh.material), ByteArray(e.data), true);
					clearLoader();
					return;

				//spots	
				case 5:
					mesh.material = buildBitmapMaterial(BitmapData(e.data));
					TextureMaterial(mesh.material).alphaBlending = true;
					break;
				//elements
				case 6:
					mesh.material = new TextureMaterial(_elementsTexture);
					break;

				//non editable walls
				case 7:
					mesh.material = buildATFMaterial(ByteArray(e.data));
					mesh.material.repeat = true;
					_wallTexture = ATFTexture(TextureMaterial(mesh.material).texture);

					//we have all the textures we need for the editable part of the walls model
					buildWalls();
			}

			_meshes.push(mesh);
			this.addChild(mesh);

			clearLoader();
		}

		private function buildWalls():void
		{
			var walls_editmaterialData:Walls_editmaterial1Data = new Walls_editmaterial1Data();
			var walls_editmaterial_rd:Vector.<Number> = Vector.<Number>([-1,-1.5099580252808664e-7,8.742277657347586e-8,0,-1.5099581673894136e-7,1,-1.5099580252808664e-7,0,-8.742275525719378e-8,-1.5099581673894136e-7,-1,0,2.049999952316284,177.3800048828125,1.2799999713897705,1]);
			var m:Mesh = new Mesh(walls_editmaterialData.geometryData, buildBitmapMaterial( new BitmapData(64, 64, false, 0xFFFFFF) ) );
			applyTransform(walls_editmaterial_rd, m, "wallsEdit");
			//the texture we use for walls toggles
			_wallDiffuseTexture = BitmapTexture(TextureMaterial(m.material).texture);
			var lightMap:LightMapMethod = new LightMapMethod(_wallTexture, LightMapMethod.MULTIPLY, true);
			SinglePassMaterialBase(m.material).addMethod(lightMap);

			_meshes.push(m);
			this.addChild(m);
		}

		private function applyTransform(rawData:Vector.<Number>, mesh:Mesh, id:String):void
		{
			var t:Matrix3D = new Matrix3D(rawData);
			mesh.transform = t;
			mesh.name = id;
		}

		private function buildATFMaterial(ba:ByteArray):TextureMaterial
		{
			var AFTTexture:ATFTexture = new ATFTexture(ba);
			return new TextureMaterial(AFTTexture);
		}

		private function buildBitmapMaterial(bitmapData:BitmapData):TextureMaterial
		{
			var bitmapTexture:BitmapTexture = new BitmapTexture(bitmapData);
			return new TextureMaterial(bitmapTexture);
		}

		private function addLightMapMethod(material:SinglePassMaterialBase, ba:ByteArray, useSecondaryUV:Boolean):void
		{
			var AFTTexture:ATFTexture = new ATFTexture(ba);
			var lightMap:LightMapMethod = new LightMapMethod(AFTTexture, LightMapMethod.MULTIPLY, useSecondaryUV);
			material.addMethod(lightMap);
		}
  
		private function changeImage(texture:BitmapTexture, bitmapData:BitmapData):void
		{
			var bmd:BitmapData = texture.bitmapData;
			bmd.dispose();
			texture.invalidateContent();
			texture.bitmapData = bitmapData;
		}

	}
}