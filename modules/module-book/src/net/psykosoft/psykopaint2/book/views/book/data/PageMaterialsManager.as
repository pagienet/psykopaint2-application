package net.psykosoft.psykopaint2.book.views.book.data
{
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;
	import away3d.materials.SinglePassMaterialBase;
	import away3d.textures.BitmapCubeTexture;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.tools.utils.TextureUtils;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.book.views.book.data.BlankBook;

 	public class PageMaterialsManager
 	{
 		private var _materials:Dictionary;
 		private var _defaultPageMaterial:TextureMaterial;
 		private var _enviroMethod:EnvMapMethod;
 		private var _enviroMethodRings:EnvMapMethod;
 		private var _pageBitmapCubeTexture:BitmapCubeTexture;
 		private var _craftMaterial:TextureMaterial;
 		private var _blankBook:BlankBook;
 
     		public function PageMaterialsManager()
 		{
 			_materials = new Dictionary();
 		}

 		public function set blankBook(blankBook:BlankBook):void
 		{
 			_blankBook = blankBook;
 		}
 		

 		public function generateEnviroMapMethod(bitmapDatas:Vector.<BitmapData>):void
 		{
 			_pageBitmapCubeTexture = new BitmapCubeTexture(	bitmapDatas[0],
										bitmapDatas[1],
										bitmapDatas[2],
										bitmapDatas[3],
										bitmapDatas[4],
										bitmapDatas[5]);

			_enviroMethod = new EnvMapMethod(_pageBitmapCubeTexture, 0.25);

			if(_craftMaterial) applyEnviroMethod(_craftMaterial);

 		}
 
 		//craft
 		public function generateCraftMaterial(bitmapData:BitmapData):void
 		{
 			_craftMaterial = generateMaterialFromBitmapData(bitmapData);

 			if(_enviroMethod) applyEnviroMethod(_craftMaterial);
 		}
 		
 		public function get craftMaterial():TextureMaterial
 		{
 			return _craftMaterial;
 		}

 		//pages
 		//returns the material per page side
 		public function getPageMaterial(index:uint):TextureMaterial
 		{
 			var textureMaterial:TextureMaterial;

 			if(_materials["mat"+index]){
 				textureMaterial = _materials["mat"+index];
 			} else {
 				throw new Error("The requested page ("+index+") has not been builded yet!!");
 			}
 			
 			return textureMaterial;
 		}

 		public function registerPageMaterial(index:uint, bitmapData:BitmapData):TextureMaterial
 		{
 			var textureMaterial:TextureMaterial = generateMaterialFromBitmapData(bitmapData);

 			if(_enviroMethod) applyEnviroMethod(textureMaterial);

 			textureMaterial.normalMap = generatePageNormalMap();

 			_materials["mat"+index] = textureMaterial;

 			return textureMaterial;
 		}

 		public function dispose():void
 		{
 			var material:TextureMaterial;
 			for(var key:String in _materials){
 				material = _materials[key];
 				material.texture.dispose();
 				_materials[key] = null;
 			}
 			_pageBitmapCubeTexture.dispose();
 			_craftMaterial.dispose();
 			_craftMaterial = null;
 			_materials = null;
 			_enviroMethod = null;
 			_enviroMethodRings = null;
 		}

 		private function generateMaterialFromBitmapData(bitmapData:BitmapData):TextureMaterial
 		{
 			bitmapData = validateMap(bitmapData);
 
 			//old
			var bitmapTexture:BitmapTexture = new BitmapTexture(bitmapData);
			var textureMaterial:TextureMaterial = new TextureMaterial(bitmapTexture);

			//to do once David has the equivallent for BitmapTexture
			//var bitmapTexture:TrackedTexture = new TrackedTexture(bitmapData);
			//var textureMaterial:TextureMaterial = new TextureMaterial(bitmapTexture);

			return textureMaterial;
		}

		private function generatePageNormalMap():BitmapTexture
		{
			var bitmapTexture:BitmapTexture = new BitmapTexture(_blankBook.getBasePageNormalmap(true));

			return bitmapTexture;
		}

		private function applyEnviroMethod(material:MaterialBase):void
 		{
 			SinglePassMaterialBase(material).addMethod(_enviroMethod);
 		}
 
		private function validateMap(origBmd:BitmapData):BitmapData
		{
			var nw:uint = origBmd.width;
			var nh:uint = origBmd.height;
			if(!TextureUtils.isPowerOfTwo(nw)) nw = TextureUtils.getBestPowerOf2(nw);
			
			if(!TextureUtils.isPowerOfTwo(nh)) nh = TextureUtils.getBestPowerOf2(nh);
			
			if(nw == origBmd.width && nh == origBmd.height)
				return origBmd;
			 
			var bmd:BitmapData = new BitmapData(nw, nh, origBmd.transparent, origBmd.transparent? 0x00FFFFFF : 0x000000);
			var w:Number = nw/origBmd.width;
			var h:Number = nh/origBmd.height;
			var t:Matrix = new Matrix();
			t.scale(w, h);
			bmd.draw(origBmd, t, null, "normal", null, true);
			
			origBmd.dispose();
			
			return bmd;
		}

 	}
 }