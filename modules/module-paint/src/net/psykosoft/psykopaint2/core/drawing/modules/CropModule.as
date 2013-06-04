package net.psykosoft.psykopaint2.core.drawing.modules
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	
	import net.psykosoft.psykopaint2.core.drawing.data.ModuleType;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.utils.TextureUtils;

	public class CropModule implements IModule
	{
		[Inject]
		public var notifyCropModuleActivatedSignal : NotifyCropModuleActivatedSignal;

		[Inject]
		public var notifyCropCompleteSignal : NotifyCropCompleteSignal;

		[Inject]
		public var stage : Stage;

		[Inject]
		public var stage3D : Stage3D;

		private var _active : Boolean;
		private var _bitmapData:BitmapData;
		private var _canvasWidth:int;
		private var _canvasHeight:int;
		//private var _baseTextureSize:int;
	
		public function CropModule()
		{
			super();
		}

		public function type():String {
			return ModuleType.CROP;
		}

		public function activate(bitmapData : BitmapData) : void
		{
			_active = true;
			_bitmapData = bitmapData;
			_canvasWidth = stage.stageWidth;
			_canvasHeight = stage.stageHeight;
			notifyCropModuleActivatedSignal.dispatch(bitmapData);
		}

		public function deactivate() : void
		{
			_active = false;
		}
		
		
/*
		public function crop( m:Matrix ) : void
		{
			var croppedTextureMap:BitmapData;
			if ( _canvasWidth > _canvasHeight )
			{
				croppedTextureMap = new BitmapData( _baseTextureSize, _baseTextureSize * _canvasHeight / _canvasWidth, false,0);
			} else {
				croppedTextureMap = new BitmapData( _baseTextureSize * _canvasWidth / _canvasHeight , _baseTextureSize,false,0);
			}
			var holder:Sprite = new Sprite();
			var bm:Bitmap = new Bitmap(_bitmapData,"auto",true);
			bm.x = -_bitmapData.width * 0.5;
			bm.y = -_bitmapData.height * 0.5;
			holder.addChild(bm);
			croppedTextureMap.drawWithQuality(holder,m,null,"normal",null,true,StageQuality.BEST);
			
			notifyCropCompleteSignal.dispatch(croppedTextureMap);
			_bitmapData.dispose();
		}
		*/

		public function render() : void
		{
		}
	}
}