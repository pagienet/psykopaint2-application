package net.psykosoft.psykopaint2.home.views.home.atelier
{
	import away3d.hacks.BitmapRectTexture;

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.hacks.TrackedATFTexture;
	import away3d.hacks.TrackedBitmapTexture;
	import away3d.materials.MaterialBase;
	import away3d.materials.SinglePassMaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.methods.LightMapMethod;
	import away3d.textures.ATFData;
	import away3d.textures.ATFTexture;
	import away3d.textures.BitmapTexture;
	import away3d.textures.Texture2DBase;
	
	import net.psykosoft.psykopaint2.base.utils.io.QueuedFileLoader;
	import net.psykosoft.psykopaint2.base.utils.io.events.AssetLoadedEvent;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.home.views.home.atelier.data.DomeData;
	import net.psykosoft.psykopaint2.home.views.home.atelier.data.Elements2Data;
	import net.psykosoft.psykopaint2.home.views.home.atelier.data.ElementsData;
	import net.psykosoft.psykopaint2.home.views.home.atelier.data.FloorData;
	import net.psykosoft.psykopaint2.home.views.home.atelier.data.IconuserData;
	import net.psykosoft.psykopaint2.home.views.home.atelier.data.Items_no_editData;
	import net.psykosoft.psykopaint2.home.views.home.atelier.data.LightsData;
	import net.psykosoft.psykopaint2.home.views.home.atelier.data.LogoData;
	import net.psykosoft.psykopaint2.home.views.home.atelier.data.TitlesData;
	import net.psykosoft.psykopaint2.home.views.home.atelier.data.Walls_editmaterial1Data;

	public class Atelier extends ObjectContainer3D
	{
		private var _fileLoader:QueuedFileLoader;
		private var _assetsCount:uint;
		private var _assetsLoaded:uint;

		private var _userIconMaterial:TextureMaterial;
		private var _defaultUserIconTexture:BitmapTexture;
		private var _userIconTexture:BitmapRectTexture;
		private var _wallTexture:ATFTexture;
		private var _elementsTextureMaterial:TextureMaterial;

		private var _meshes:Vector.<Mesh>;
		private var _pendingWallTexture : ByteArray;
		private var _wallMesh : Mesh;

		private var _textures : Vector.<Texture2DBase>;
		private var _materials : Vector.<MaterialBase>;
		private var _stage3DProxy : Stage3DProxy;


		function Atelier (stage3DProxy : Stage3DProxy):void
		{
			super();

			_stage3DProxy = stage3DProxy;
			_textures = new Vector.<Texture2DBase>();
			_materials = new Vector.<MaterialBase>();
			_meshes = new Vector.<Mesh>();
			_fileLoader = new QueuedFileLoader();
			
		}

		//todo: replace the icon user with app user icon source
		//todo2: imporve disposal of meshes, materials, etc...
		override public function dispose():void
		{
			var i:uint;
			if (_userIconTexture) {
				_userIconTexture.dispose();
				_userIconTexture = null;
			}
			_defaultUserIconTexture = null;
			_wallTexture = null;

			for (i = 0;i<_meshes.length;++i) {
				this.removeChild(_meshes[i]);
				_meshes[i].material = null;
				_meshes[i].geometry.dispose();
				_meshes[i] = null;
			}

			for (i = 0; i < _textures.length; ++i)
				_textures[i].dispose();

			for (i = 0; i < _materials.length; ++i)
				_materials[i].dispose();

			_textures = null;
			_materials = null;

			if(_fileLoader) _fileLoader = null;

			super.dispose();
		}

		// replaces user icon
		public function setIconImage(bitmapData:BitmapData):void
		{
			if (!_userIconMaterial) return;

			if (bitmapData) {
				if (!_userIconTexture)
					_userIconTexture = new BitmapRectTexture(bitmapData);
				else
					_userIconTexture.bitmapData = bitmapData;

				_userIconTexture.getTextureForStage3D(_stage3DProxy);

				_userIconMaterial.texture = _userIconTexture;
			}
			else {
				if (_userIconTexture) {
					_userIconTexture.dispose();
					_userIconTexture = null;
				}

				_userIconMaterial.texture = _defaultUserIconTexture;
			}
		}

		// replaces user wallimage
		public function setWallImage(data:ByteArray):void
		{
			if (_wallTexture)
				_wallTexture.atfData = new ATFData(data);
			else {
				if (_wallMesh) {
					_wallMesh.material = buildATFMaterial(_pendingWallTexture);
					_wallTexture = ATFTexture(TextureMaterial(_wallMesh.material).texture);
				}
				else
					_pendingWallTexture = data;
			}
		}

		public function init():void
		{
			var currentPlatform:String =CoreSettings.RUNNING_ON_iPAD ? "ios":"desktop";
			
			///var atfURL : String =  "/home-packaged-"+currentPlatform+"/away3d/atelier/atfs/"
			var atfURL : String =  "/home-packaged/away3d/atelier/atfs/"+((CoreSettings.RUNNING_ON_RETINA_DISPLAY==true)?"retina/":"regular/");
			//var atfURL : String =  "/home-packaged/away3d/atelier/atfs/retina/";
			var imgURL : String = "/home-packaged/away3d/atelier/";

			var titlesData:TitlesData = new TitlesData();
			var titles_rd:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,4.273069858551025,249.8874969482422,-4.537360191345215,1]);
			var titles:Mesh = new Mesh(titlesData.geometryData, null);
			applyTransform(titles_rd, titles, "titles");
			loadATFMaterial(titles, atfURL + "elements.atf", 0);
 			
			var elementsData:ElementsData = new ElementsData();
			var elements_rd:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,376.53948974609375,10.186001777648926,-17.01059913635254,1]);
			var elements:Mesh = new Mesh(elementsData.geometryData, null);
			applyTransform(elements_rd, elements, "elements");
			loadATFMaterial(elements, atfURL + "elements.atf", 1);

			

			var iconuserData:IconuserData = new IconuserData();
			var iconuser_rd:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,983.533203125,67.34795379638672,-1.5569911003112793,1]);
			var iconuser:Mesh = new Mesh(iconuserData.geometryData, null);
			applyTransform(iconuser_rd, iconuser, "iconuser");
			loadBitmapMaterial(iconuser, imgURL + "jpgs/iconuser.jpg", 2);

			var floorData:FloorData = new FloorData();
			var floor_rd:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,-1.4995100498199463,-164.59500122070313,1.2002899646759033,1]);
			var floor:Mesh = new Mesh(floorData.geometryData, null);
			applyTransform(floor_rd, floor, "floor");
			loadBitmapMaterial(floor, imgURL + "jpgs/woodfloor.jpg", 3);
			loadATFMaterial(floor, atfURL + "floor_LM.atf", 4);

			var lightsData:LightsData = new LightsData();
			var lights_rd:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,63.72710037231445,21.96869659423828,-78.13249969482422,1]);
			var lights:Mesh = new Mesh(lightsData.geometryData, null);
			applyTransform(lights_rd, lights, "lights");
			loadBitmapMaterial(lights, imgURL + "pngs/lights.png", 5);
			//loadATFMaterial(lights, atfURL + "lights.atf", 5);

			var logoData:LogoData = new LogoData();
			var logo_rd:Vector.<Number> = Vector.<Number>([1.02,0,0,0,0,1.02,0,0,0,0,1,0,-266.8269958496094,-1.1448999643325806,-344.1099853515625,1]);
			var logo:Mesh = new Mesh(logoData.geometryData, null);
			applyTransform(logo_rd, logo, "logo");
			loadATFMaterial(logo, atfURL + "logo.atf", 6);
			
			var elements2Data:Elements2Data = new Elements2Data();
			var elements2_rd:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,-353.1919860839844,20.652700424194336,-18.818300247192383,1]);
			var elements2:Mesh = new Mesh(elements2Data.geometryData, null);
			applyTransform(elements2_rd, elements2, "elements2");
			loadATFMaterial(elements2, atfURL + "elements2.atf", 7);

			var domeData:DomeData = new DomeData();
			var dome_rd:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,286.0880126953125,332.2690124511719,-52.463199615478516,1]);
			var dome:Mesh = new Mesh(domeData.geometryData, null);
			applyTransform(dome_rd, dome, "dome");
			//loadBitmapMaterial(dome, imgURL + "jpgs/dome.jpg", 8);
			loadATFMaterial(dome, atfURL + "sky.atf", 8);


			var items_no_editData:Items_no_editData = new Items_no_editData();
			var items_no_edit_rd:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,-2.3050498962402344,153.61300659179688,-5.307400226593018,1]);
			var items_no_edit:Mesh = new Mesh(items_no_editData.geometryData, null);
			applyTransform(items_no_edit_rd, items_no_edit, "items_no_edit");
			//loadBitmapMaterial(items_no_edit, imgURL + "jpgs/stucco.jpg", 9);
			loadATFMaterial(items_no_edit, atfURL + "items_no_edit.atf", 9);

			var wallsData:Walls_editmaterial1Data = new Walls_editmaterial1Data();
			var walls_rd:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,-1.5399999618530273,159.82000732421875,-1.4199999570846558,1]);
			
			var walls:Mesh = new Mesh(wallsData.geometryData, null);
			applyTransform(walls_rd, walls, "walls");
//			loadBitmapMaterial(walls, imgURL + "jpgs/stucco.jpg", 11);
			loadATFMaterial(walls, atfURL + "walls_LM.atf", 10);
		}

		private function loadATFMaterial(mesh:Mesh, url:String, id:uint):void
		{
			_assetsCount++;
			_fileLoader.loadBinary(url, finalizeObject, onError, {mesh:mesh, id:id});
			
			//_fileLoader.loadBinary(url, finalizeObject, onError, {mesh:mesh, id:id});
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
					//mesh.material = buildATFMaterial(ByteArray(e.data));
					if(id == 0) _elementsTextureMaterial = buildATFMaterial(ByteArray(e.data));
					//mesh.material = _elementsTexture
					//REUSE MATERIAL FOR ID = 1
					mesh.material = _elementsTextureMaterial;
					
					
					//HACK TO REMOVE:
					//dispatchEvent(new Event(Event.COMPLETE));
					
					break;
				
				
				//default icon user
				case 2:
					mesh.material = buildBitmapMaterial(BitmapData(e.data));
					_userIconMaterial = TextureMaterial(mesh.material);
					_userIconMaterial.mipmap = false;
					_defaultUserIconTexture = BitmapTexture(_userIconMaterial.texture);
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

				//lights	
				case 5:
					mesh.material = buildBitmapMaterial(BitmapData(e.data));
					//mesh.material = buildATFMaterial(ByteArray(e.data));
					TextureMaterial(mesh.material).alphaBlending = true;
					break;
				//elements
				case 6:
					mesh.material = buildATFMaterial(ByteArray(e.data));
					break;

				//elements2
				case 7:
					mesh.material = buildATFMaterial(ByteArray(e.data));
					break;

				//dome  --> getter for it to update rotation on enterframe
				case 8:
					//mesh.material = buildBitmapMaterial(BitmapData(e.data));
					mesh.material = buildATFMaterial(ByteArray(e.data));
					break;

				//items no edit (plints, some ceilings)
				case 9:
					mesh.material = buildATFMaterial(ByteArray(e.data));
					break;

				//walls + diffuse
//				case 10:
//					mesh.material = buildBitmapMaterial(BitmapData(e.data));
//					_wallDiffuseTexture = ATFTexture(TextureMaterial(mesh.material).texture);
//					mesh.material.repeat = true;
//					break;

				//walls + lightmap
				case 10:
					buildWalls(mesh, ByteArray(e.data));
					clearLoader();
					return;
				
			}
			
			
			if (_meshes.indexOf(mesh) == -1) {
				_meshes.push(mesh);
				addChild(mesh);
			}

			clearLoader();
		}

		private function buildWalls(mesh : Mesh, byteArray : ByteArray):void
		{
			_wallMesh = mesh;
			
			//the texture we use for walls toggles
			if (_pendingWallTexture) {
				_wallMesh.material = buildATFMaterial(_pendingWallTexture);
				_wallMesh.material.repeat = true;
				_wallTexture = ATFTexture(TextureMaterial(_wallMesh.material).texture);
				_pendingWallTexture = null;
			}

			SinglePassMaterialBase(mesh.material).mipmap=false;
			addLightMapMethod(SinglePassMaterialBase(mesh.material), byteArray, true);

			_meshes.push(_wallMesh);
			addChild(_wallMesh);
		}

		private function applyTransform(rawData:Vector.<Number>, mesh:Mesh, id:String):void
		{
			var t:Matrix3D = new Matrix3D(rawData);
			mesh.transform = t;
			mesh.name = id;
		}

		private function buildATFMaterial(ba:ByteArray):TextureMaterial
		{
			var texture : ATFTexture = new TrackedATFTexture(ba);
			var material : TextureMaterial = new TextureMaterial(texture);
			_textures.push(texture);
			_materials.push(material);
			return material;
		}

		private function buildBitmapMaterial(bitmapData:BitmapData):TextureMaterial
		{
			var texture : BitmapTexture = new TrackedBitmapTexture(bitmapData);
			var material : TextureMaterial = new TextureMaterial(texture);
			texture.getTextureForStage3D(_stage3DProxy);
			//bitmaps cannot be disposed since they might get reuploaded upon context loss
			//bitmapData.dispose();
			_textures.push(texture);
			_materials.push(material);
			return material;
		}

		private function addLightMapMethod(material:SinglePassMaterialBase, ba:ByteArray, useSecondaryUV:Boolean):void
		{
			var texture:ATFTexture = new TrackedATFTexture(ba);
			var lightMap:LightMapMethod = new LightMapMethod(texture, LightMapMethod.MULTIPLY, useSecondaryUV);
			material.addMethod(lightMap);
			_textures.push(texture);
		}
	}
}