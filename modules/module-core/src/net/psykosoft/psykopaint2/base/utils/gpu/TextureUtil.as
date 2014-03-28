package net.psykosoft.psykopaint2.base.utils.gpu
{

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import away3d.containers.View3D;
	import away3d.core.base.CompactSubGeometry;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.hacks.TrackedATFTexture;
	import away3d.hacks.TrackedBitmapTexture;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.ATFTexture;
	import away3d.textures.BitmapTexture;
	import away3d.tools.utils.TextureUtils;
	import away3d.utils.Cast;
	
	import br.com.stimuli.loading.BulkLoader;
	
	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;


	public class TextureUtil
	{
		private static const MAX_SIZE:uint = 2048;

		public static function getNextPowerOfTwo( number:int ):int {
			if( number > 0 && (number & (number - 1)) == 0 ) // see: http://goo.gl/D9kPj
				return number;
			else {
				var result:int = 1;
				while( result < number ) result <<= 1;
				return result;
			}
		}

	 	public static function autoResizePowerOf2(bmData:BitmapData,smoothing:Boolean = true):BitmapData
		{
			if (TextureUtils.isBitmapDataValid(bmData))
				return bmData;
			
			var max:Number = Math.max(bmData.width, bmData.height);
			max = TextureUtils.getBestPowerOf2(max);
			var mat:Matrix = new Matrix();
			mat.scale(max/bmData.width, max/bmData.height);
			var bmd:BitmapData = new BitmapData(max, max,bmData.transparent,0x00000000);
			bmd.draw(bmData, mat, null, null, null, smoothing);
			return bmd;
		} 
		
		
		public static function displayObjectToTextureMaterial(displayObject:DisplayObject):TextureMaterial
		{
			//AUTOREISEPOWEROF2ONLY HAPPEN IF NECESSARY SO we'RE GOOD TO NOT MAKE A CONDITION
			var bmd:BitmapData = autoResizePowerOf2(displayObjectToBitmapData(displayObject));
			var texture:BitmapTexture = new BitmapTexture(bmd);
			var textureMaterial:TextureMaterial = new TextureMaterial(Cast.bitmapTexture(texture));
			
			return textureMaterial;
		}
		
		
		public static function displayObjectToBitmapData(displayObject:DisplayObject):BitmapData{
			var pageBitmapData:BitmapData = new BitmapData(displayObject.getBounds(displayObject).width, displayObject.getBounds(displayObject).height, true,0x00000000);
			pageBitmapData.draw(displayObject, null, null, "normal", null, true);
			return pageBitmapData;
		}
		
		
	}
}
