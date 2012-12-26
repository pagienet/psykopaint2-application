var doc = fl.getDocumentDOM();

var layers;
var numLayers;
var currentLayer;
var i;
var pngName;
var saveName;
var originalDocWidth;
var originalDocHeight;

execute();

function execute() {

	fl.trace( "Running JFSL script..." );

	// Get a save location.
	var saveDir = fl.browseForFolderURL( "Choose a folder in which to save your exported PNGs: " );
	if (saveDir) {

		// Remember document size ( will be changing ).
		originalDocWidth = doc.width;
		originalDocHeight = doc.height;

		// Duplicate the currently selected library item.
		var selectedSymbol = doc.library.getSelectedItems()[ 0 ];
		fl.trace( "Selected library item: " + selectedSymbol.name );
		var dump = selectedSymbol.name.split( "/" );
		var assetName = dump[ 1 ];
		fl.trace( "Asset name: " + assetName );
		doc.library.duplicateItem();
		var duplicateItemName = selectedSymbol.name + " copy";
		doc.library.selectItem( duplicateItemName );
		fl.trace( "Duplicated library item: " + duplicateItemName.name );

		// Get layers.
		layers = doc.getTimeline().layers
		numLayers = layers.length;

		// Hide all layers.
		for ( i = 0; i < numLayers; i++ ) {
			currentLayer = layers[ i ];
			currentLayer.visible = false;
		};

		// Layer to PNG.
		for ( i = 0; i < numLayers; i++ ) {

			currentLayer = layers[ i ];

			if( currentLayer.layerType == "normal" ) {
				currentLayer.visible = true;

				var item = currentLayer.frames[ 0 ].elements[ 0 ];
				item.x = item.width / 2;
				item.y = item.height / 2;
				fl.trace( "item size: " + item.width + ", " + item.height );

				doc.width = Math.round( item.width );
				doc.height = Math.round( item.height );
				fl.trace( "Set doc size: " + doc.width + ", " + doc.height );

				saveName = saveDir + "/" + assetName + "_" + currentLayer.name + ".png";
				fl.trace( "Exporting png: " + saveName );
				exportPng();

				currentLayer.visible = false;
			}

		};

		// Delete duplicate and restore library selection.
		doc.library.deleteItem();
		doc.library.selectItem( selectedSymbol );

		// Restore document size.
		doc.width = originalDocWidth;
		doc.height = originalDocHeight;

	}
}

function exportPng() {
	doc.exportPNG( saveName, true, true );
}