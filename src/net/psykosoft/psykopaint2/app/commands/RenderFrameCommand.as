package net.psykosoft.psykopaint2.app.commands
{

	import net.psykosoft.psykopaint2.app.utils.DisplayContextManager;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;

	public class RenderFrameCommand
	{
		[Inject]
		public var canvasRenderer:CanvasRenderer;

		public function execute():void {

//			trace( this, "execute ------------------------" );
//			trace( this, "-> canvasRenderer: " + canvasRenderer );

			// TODO: Figure out why clearing is necessary
			DisplayContextManager.stage3dProxy.clear();
			canvasRenderer.render();
			DisplayContextManager.stage3dProxy.context3D.setRenderToBackBuffer();
			DisplayContextManager.stage3dProxy.context3D.clear( 1, 1, 1, 1 );
			DisplayContextManager.away3d.render();
			DisplayContextManager.starling.nextFrame();
			DisplayContextManager.stage3dProxy.present();

		}
	}
}
