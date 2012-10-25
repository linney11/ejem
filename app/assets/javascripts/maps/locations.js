/**
 * Created with JetBrains RubyMine.
 * User: Linney
 * Date: 19/10/12
 * Time: 08:43 PM
 * To change this template use File | Settings | File Templates.
 */

var map

function initMap(locations) {

    map = new OpenLayers.Map("map");

    var mapnik = new OpenLayers.Layer.OSM();
    var bing = new OpenLayers.Layer.Bing({
        key: "AoIoT37Xzuc5maJ13V1rOADMrY1_-MRL688Z3twaWPEhKK9cYANzpL3giYMkAuZ8", //Get API key at https://www.bingmapsportal.com
        type: "Aerial"
    });

    map.addLayers([mapnik, bing]);
    map.addControl(new OpenLayers.Control.LayerSwitcher());

    //var locationsLayer = new OpenLayers.Layer.Vector("Locations");
   // map.addLayer(locationsLayer);

    fromProjection = new OpenLayers.Projection("EPSG:4326") ;
    toProjection = new OpenLayers.Projection("EPSG:900913");

    try{
        var locationsLayer = new OpenLayers.Layer.Vector("Locations",{
            styleMap: new OpenLayers.StyleMap({'default':{
                externalGraphic: '/assets/maps/img/marker-blue.png',
                graphicWidth: 20, graphicHeight: 24, graphicYOffset: -24,
                pointRadius: 6,
                labelYOffset: -15,
                labelOutlineColor: "white",
                labelOutlineWidth: 3
                //label: "${label}"
            }}),
            eventListeners:{
                'featureselected':function(evt){
                    var feature = evt.feature;
                    var popup = new OpenLayers.Popup.FramedCloud("popup",
                        OpenLayers.LonLat.fromString(feature.geometry.toShortString()),
                        null,
                        "<strong><u>"+feature.attributes.message+"</u></strong><br>"+feature.attributes.location,
                        null,
                        true, //aparece la opción de cerrar
                        null
                    );
                    popup.autoSize = true;
                    popup.maxSize = new OpenLayers.Size(400,800);
                    popup.fixedRelativePosition = true;
                    feature.popup = popup;
                    map.addPopup(popup);
                },
                'featureunselected':function(evt){
                    var feature = evt.feature;
                    map.removePopup(feature.popup);
                    feature.popup.destroy();
                    feature.popup = null;
                }
            }
        });


        var locationsJSON = eval('(' + locations + ')');

        for (var location in locationsJSON) {
        var locationPosition = new OpenLayers.LonLat(locationsJSON[location].longitude,locationsJSON[location].latitude).transform(fromProjection, toProjection);


        var locationMarker = new OpenLayers.Feature.Vector(
            new OpenLayers.Geometry.Point(locationPosition.lon, locationPosition.lat), {
                label: locationsJSON[location].name,
                message: locationsJSON[location].name
                //location: locationsJSON[location].description

            }
        );


        //locationsLayer.addFeatures(locationMarker);



        //Step 3 - create the selectFeature control
        var selector = new OpenLayers.Control.SelectFeature(locationsLayer,{
            hover:true,
            autoActivate:true
        });

        locationsLayer.addFeatures(locationMarker);

        map.addControl(selector);
        map.addLayer(locationsLayer);

    }
        map.setCenter(locationPosition, 11);

    }
    catch(x)
    { alert(x)}


}



