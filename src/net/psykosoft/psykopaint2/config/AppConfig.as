package net.psykosoft.psykopaint2.config
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.controller.ChangeStateCommand;
	import net.psykosoft.psykopaint2.model.StateModel;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.util.Debugger;
	import net.psykosoft.psykopaint2.view.away3d.base.Away3dRootSprite;
	import net.psykosoft.psykopaint2.view.away3d.wall.Wall3dView;
	import net.psykosoft.psykopaint2.view.away3d.wall.Wall3dViewMediator;
	import net.psykosoft.psykopaint2.view.starling.navigation.Navigation2dView;
	import net.psykosoft.psykopaint2.view.starling.navigation.Navigation2dViewMediator;
	import net.psykosoft.psykopaint2.view.starling.splash.Splash2dView;
	import net.psykosoft.psykopaint2.view.starling.splash.Splash2dViewMediator;

	import org.swiftsuspenders.Injector;

	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.framework.api.IConfig;
	import robotlegs.bender.framework.api.IContext;

	import starling.core.Starling;

	public class AppConfig implements IConfig
	{
		[Inject]
		public var context:IContext;

		[Inject]
		public var commandMap:ISignalCommandMap;

		[Inject]
		public var mediatorMap:IMediatorMap;

		[Inject]
		public var injector:Injector;

		[Inject]
		public var contextView:ContextView;

		private var _debugger:Debugger;

		public function AppConfig() {
			super();
		}

		public function configure():void {

			// Debug utility.
			if( Settings.DEBUG_MODE ) {
				_debugger = new Debugger( contextView.view );
				Cc.info( this, "configuring app - " + Settings.NAME + " " + Settings.VERSION );
			}

			// Map commands and their corresponding signal requests.
			commandMap.map( RequestStateChangeSignal ).toCommand( ChangeStateCommand );

			// Map independent notification signals.
			injector.map( NotifyStateChangedSignal ).asSingleton();

			// Map 2d views.
			mediatorMap.map( Splash2dView ).toMediator( Splash2dViewMediator );
			mediatorMap.map( Navigation2dView ).toMediator( Navigation2dViewMediator );

			// Map 3d views.
			mediatorMap.map( Wall3dView ).toMediator( Wall3dViewMediator );

			// Map models.
			injector.map( StateModel ).asSingleton();

			// Map services.
//			injector.map( IPhotoGalleryService ).toSingleton( FlickrImageService );

			// Start.
			context.lifecycle.afterInitializing( init );

		}

		private function init():void {

			// Initialize 3d display tree.
			// Note: the 2d display tree ( StarlingRootSprite.as ) is initialized in the main class,
			// with the creation of the Starling object.
			contextView.view.addChild( new Away3dRootSprite() );

			Cc.info( this, "*** app ready ***" );
			Cc.info( this, "Starling.contentScaleFactor: " + Starling.contentScaleFactor );

		}
	}
}
