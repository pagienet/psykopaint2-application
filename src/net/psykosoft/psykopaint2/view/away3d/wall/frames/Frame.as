package net.psykosoft.psykopaint2.view.away3d.wall.frames
{

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;

	import com.junkbyte.console.Cc;

	public class Frame extends ObjectContainer3D
	{
		// TODO: must be able to adapt to different painting sizes in some sort of 3D 9-slice thingy
		public function Frame( frameModel:Mesh, lightPicker:StaticLightPicker, paintingWidth:Number, paintingHeight:Number ) {

			super();

			// Material.
			// TODO: centralize all frame materials ( might be texture materials, can be chosen by the user, etc )
			var frameMaterial:ColorMaterial = new ColorMaterial( 0xFFFFFF * Math.random() );
			frameMaterial.gloss = 100;
			frameMaterial.specular = 0.35;
			frameMaterial.ambient = 0.1;
			frameMaterial.lightPicker = lightPicker;

			// Identify original frame dimensions.
			var frameWidth:Number = frameModel.maxX - frameModel.minX;
			var frameHeight:Number = frameModel.maxY - frameModel.minY;
			var frameDepth:Number = frameModel.maxZ - frameModel.minZ;

			// Mesh.
			frameModel.material = frameMaterial;
			frameModel.scaleX = paintingWidth / frameWidth;
			frameModel.scaleY = paintingHeight / frameHeight;
			frameModel.scaleZ = frameModel.scaleY;
			addChild( frameModel );

		}
	}
}
